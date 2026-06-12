#!/usr/bin/env python3

import json
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path.cwd()

REPORT_DIR = ROOT / "vault/09-Governance/wil/reports"
AUDIT_DIR = ROOT / "vault/09-Governance/wil/audit"
EVENT_DIR = ROOT / "vault/09-Governance/wil/events"

REPORT_DIR.mkdir(parents=True, exist_ok=True)
AUDIT_DIR.mkdir(parents=True, exist_ok=True)
EVENT_DIR.mkdir(parents=True, exist_ok=True)


def now_utc():
    return datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")


def load_wil(path):
    p = Path(path)

    if not p.exists():
        print(json.dumps({
            "result": "FAIL",
            "reason": "file not found",
            "path": path
        }, indent=2))
        sys.exit(1)

    if p.suffix != ".json":
        print(json.dumps({
            "result": "FAIL",
            "reason": "WIL v0.2 supports JSON only",
            "path": path
        }, indent=2))
        sys.exit(1)

    return json.loads(p.read_text())


def parse_cli_overrides(argv):
    overrides = {}

    for arg in argv:
        if "=" in arg and not arg.startswith("--"):
            key, value = arg.split("=", 1)
            if key:
                overrides[key] = value

    return overrides


def interpolate_value(value, variables):
    if isinstance(value, str):
        out = value
        for key, replacement in variables.items():
            out = out.replace("${" + key + "}", str(replacement))
        return out

    if isinstance(value, list):
        return [interpolate_value(item, variables) for item in value]

    if isinstance(value, dict):
        return {
            key: interpolate_value(val, variables)
            for key, val in value.items()
        }

    return value


def apply_overrides(doc, overrides):
    variables = doc.get("variables", {})

    if not isinstance(variables, dict):
        variables = {}

    variables.update(overrides)
    doc["variables"] = variables

    return doc


def apply_variables(doc):
    variables = doc.get("variables", {})

    if not isinstance(variables, dict):
        variables = {}

    return interpolate_value(doc, variables)


def compile_doc(doc):
    return {
        "wil_version": doc.get("version"),
        "kind": doc.get("kind"),
        "id": doc.get("id"),
        "intent": doc.get("intent"),
        "variables": doc.get("variables", {}),
        "target": doc.get("target", {}),
        "desired_state": doc.get("desired_state", {}),
        "requires": doc.get("requires", []),
        "verify": doc.get("verify", []),
        "prove": doc.get("prove", []),
        "do": doc.get("do", []),
        "outputs": doc.get("outputs", []),
        "observe": doc.get("observe", []),
        "recovery": doc.get("recovery", []),
        "recover": doc.get("recover", []),
        "rollback": doc.get("rollback", []),
        "consequences": doc.get("consequences", {}),
        "risks": doc.get("risks", [])
    }


def validate_requires(doc):
    results = []

    for item in doc.get("requires", []):
        if isinstance(item, str):
            rid = item
        elif isinstance(item, dict):
            rid = item.get("artifact") or item.get("id") or item.get("name")
        else:
            rid = None

        if not rid:
            results.append({
                "requirement": None,
                "status": "FAIL",
                "reason": "invalid requirement"
            })
            continue

        checks = [
            ROOT / "bin" / rid,
            ROOT / "services" / rid,
            ROOT / "vault/09-Governance/wil/artifacts" / f"{rid}.artifact.json"
        ]

        results.append({
            "requirement": rid,
            "status": "PASS" if any(path.exists() for path in checks) else "FAIL"
        })

    return results


def run_actions(actions):
    results = []

    for action in actions:
        name = action.get("name", "unnamed")
        command = action.get("run")

        if not command:
            results.append({
                "name": name,
                "status": "FAIL",
                "reason": "missing run command"
            })
            break

        proc = subprocess.run(command, shell=True, cwd=ROOT)

        results.append({
            "name": name,
            "command": command,
            "status": "PASS" if proc.returncode == 0 else "FAIL"
        })

        if proc.returncode != 0:
            break

    return results


def run_checks(checks, command_key="command"):
    results = []

    for check in checks:
        name = check.get("name", "unnamed")
        command = check.get(command_key)

        if not command:
            results.append({
                "name": name,
                "status": "FAIL",
                "reason": f"missing {command_key}"
            })
            continue

        proc = subprocess.run(
            command,
            shell=True,
            cwd=ROOT,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        )

        results.append({
            "name": name,
            "command": command,
            "status": "PASS" if proc.returncode == 0 else "FAIL"
        })

    return results


def inspect_outputs(doc):
    results = []

    for item in doc.get("outputs", []):
        kind = item.get("kind")
        raw_path = item.get("path")

        if not raw_path:
            results.append({
                "kind": kind,
                "path": None,
                "status": "FAIL",
                "reason": "missing path"
            })
            continue

        path = ROOT / raw_path

        if kind == "directory":
            ok = path.is_dir()
        elif kind == "file":
            ok = path.is_file()
        else:
            ok = path.exists()

        results.append({
            "kind": kind,
            "path": raw_path,
            "status": "PASS" if ok else "FAIL"
        })

    return results


def write_event(doc, mode, result):
    stamp = now_utc()
    safe_id = doc.get("id", "unknown").replace("/", "-")
    event_id = f"{stamp}-{safe_id}-{mode}"

    event = {
        "kind": "event",
        "id": event_id,
        "version": 0,
        "program": safe_id,
        "mode": mode,
        "result": result,
        "occurred": stamp
    }

    out = EVENT_DIR / f"{event_id}.event.json"
    out.write_text(json.dumps(event, indent=2))
    return str(out)


def write_audit(doc, mode, payload):
    stamp = now_utc()
    safe_id = doc.get("id", "unknown").replace("/", "-")
    out = AUDIT_DIR / f"{stamp}-{safe_id}-{mode}.audit.json"

    record = {
        "kind": "audit",
        "id": f"{stamp}-{safe_id}-{mode}",
        "version": 0,
        "program": safe_id,
        "mode": mode,
        "generated": stamp,
        "payload": payload
    }

    out.write_text(json.dumps(record, indent=2))
    return str(out)


def plan_program(doc):
    print(f"Program: {doc.get('id')}")
    print(f"Intent: {doc.get('intent', '')}")
    print()

    if doc.get("requires"):
        print("Requires:")
        for item in doc.get("requires", []):
            print(f"- {item}")
        print()

    if doc.get("do"):
        print("Actions:")
        for i, action in enumerate(doc.get("do", []), 1):
            print(f"{i}. {action.get('name', 'unnamed')}: {action.get('run')}")
        print()

    if doc.get("prove"):
        print("Proof:")
        for i, check in enumerate(doc.get("prove", []), 1):
            print(f"{i}. {check.get('name', 'unnamed')}: {check.get('command')}")
        print()

    if doc.get("outputs"):
        print("Outputs:")
        for i, item in enumerate(doc.get("outputs", []), 1):
            print(f"{i}. {item.get('kind')}: {item.get('path')}")
        print()

    if doc.get("recover"):
        print("Recovery:")
        for i, action in enumerate(doc.get("recover", []), 1):
            print(f"{i}. {action.get('name', 'unnamed')}: {action.get('run')}")
        print()

    if doc.get("rollback"):
        print("Rollback:")
        for i, action in enumerate(doc.get("rollback", []), 1):
            print(f"{i}. {action.get('name', 'unnamed')}: {action.get('run')}")
        print()


def emit_payload(doc, mode, payload, write_history=True):
    if write_history:
        payload["event"] = write_event(doc, mode, payload.get("result", "UNKNOWN"))
        payload["audit"] = write_audit(doc, mode, payload)

    print(json.dumps(payload, indent=2))


def main():
    if len(sys.argv) < 3:
        print("usage: wil <compile|verify|report|plan|requires|inspect|run|recover|rollback> <file> [--yes] [key=value]")
        sys.exit(1)

    command = sys.argv[1]
    path = sys.argv[2]

    raw_doc = load_wil(path)
    raw_doc = apply_overrides(raw_doc, parse_cli_overrides(sys.argv[3:]))
    doc = apply_variables(raw_doc)
    compiled = compile_doc(doc)

    if command == "compile":
        print(json.dumps(compiled, indent=2))
        return

    if command == "verify":
        checks = doc.get("verify", [])
        results = run_checks(checks)
        passed = all(r["status"] == "PASS" for r in results)

        print(json.dumps({
            "id": doc.get("id"),
            "kind": doc.get("kind"),
            "mode": "verify",
            "result": "PASS" if passed else "FAIL",
            "checks": results
        }, indent=2))

        sys.exit(0 if passed else 1)

    if command == "report":
        checks = doc.get("verify", [])
        results = run_checks(checks)
        out = REPORT_DIR / f"{doc.get('id')}.report.json"

        report = {
            "id": doc.get("id"),
            "kind": doc.get("kind"),
            "compiled": compiled,
            "verification": results
        }

        out.write_text(json.dumps(report, indent=2))
        print(out)
        return

    if command == "plan":
        if doc.get("kind") != "program":
            print("plan only supports kind: program")
            sys.exit(1)
        plan_program(doc)
        return

    if command == "requires":
        results = validate_requires(doc)
        passed = all(r["status"] == "PASS" for r in results)

        print(json.dumps({
            "id": doc.get("id"),
            "kind": doc.get("kind"),
            "mode": "requires",
            "result": "PASS" if passed else "FAIL",
            "requires": results
        }, indent=2))

        sys.exit(0 if passed else 1)

    if command == "inspect":
        if doc.get("kind") != "program":
            print("inspect only supports kind: program")
            sys.exit(1)

        results = inspect_outputs(doc)
        passed = all(r["status"] == "PASS" for r in results)

        print(json.dumps({
            "id": doc.get("id"),
            "kind": doc.get("kind"),
            "mode": "inspect",
            "result": "PASS" if passed else "FAIL",
            "outputs": results
        }, indent=2))

        sys.exit(0 if passed else 1)

    if command == "run":
        if doc.get("kind") != "program":
            print("run only supports kind: program")
            sys.exit(1)

        if "--yes" not in sys.argv:
            print("Refusing to execute without --yes")
            print(f"Preview with: wil plan {path}")
            sys.exit(1)

        require_results = validate_requires(doc)

        if not all(r["status"] == "PASS" for r in require_results):
            payload = {
                "id": doc.get("id"),
                "kind": doc.get("kind"),
                "mode": "run",
                "result": "FAIL",
                "reason": "requirements failed",
                "requires": require_results,
                "actions": [],
                "proof": []
            }

            emit_payload(doc, "run", payload)
            sys.exit(1)

        action_results = run_actions(doc.get("do", []))
        proof_results = run_checks(doc.get("prove", []))
        output_results = inspect_outputs(doc)

        passed = (
            all(r["status"] == "PASS" for r in require_results)
            and all(r["status"] == "PASS" for r in action_results)
            and all(r["status"] == "PASS" for r in proof_results)
            and all(r["status"] == "PASS" for r in output_results)
        )

        payload = {
            "id": doc.get("id"),
            "kind": doc.get("kind"),
            "mode": "run",
            "result": "PASS" if passed else "FAIL",
            "requires": require_results,
            "actions": action_results,
            "proof": proof_results,
            "outputs": output_results
        }

        emit_payload(doc, "run", payload)
        sys.exit(0 if passed else 1)

    if command in ("recover", "rollback"):
        if doc.get("kind") != "program":
            print(f"{command} only supports kind: program")
            sys.exit(1)

        if "--yes" not in sys.argv:
            print(f"Refusing to execute {command} without --yes")
            print(f"Preview with: wil plan {path}")
            sys.exit(1)

        section = "recover" if command == "recover" else "rollback"
        action_results = run_actions(doc.get(section, []))
        output_results = inspect_outputs(doc)

        passed = all(r["status"] == "PASS" for r in action_results)

        payload = {
            "id": doc.get("id"),
            "kind": doc.get("kind"),
            "mode": command,
            "result": "PASS" if passed else "FAIL",
            "actions": action_results,
            "outputs": output_results
        }

        emit_payload(doc, command, payload)
        sys.exit(0 if passed else 1)

    print(f"unknown command: {command}")
    sys.exit(1)


if __name__ == "__main__":
    main()
