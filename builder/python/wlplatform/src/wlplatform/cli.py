from __future__ import annotations

from pathlib import Path

from .certification_command import certification_gate

import argparse
import json
import sys

from . import __version__
from .certification import (
    CertificationError,
    certify,
)

from wlplatform.paths import repository_root
from .context import PlatformContext, PlatformContextError
from .controller import PlatformController
from .result import PlatformReport
from .engine import PlatformCertificationEngine
from .certification_state import CertificationState


def _render_report(
    report: PlatformReport,
    *,
    verbose: bool,
) -> None:
    print("Wonderland Platform Engine")
    print(f"version: {report.engine_version}")
    print()

    width = max(
        len(check.name)
        for check in report.checks
    )

    for check in report.checks:
        print(
            f"{check.name:<{width}}: "
            f"{check.status.value}"
        )

        if verbose:
            print(f"  summary: {check.summary}")
            print(f"  duration_ms: {check.duration_ms}")

            if check.command:
                print(
                    "  command: "
                    + " ".join(check.command)
                )

            if check.details:
                for key, value in sorted(
                    check.details.items()
                ):
                    print(f"  {key}: {value}")

            if check.stdout:
                print("  stdout:")

                for line in check.stdout.splitlines():
                    print(f"    {line}")

            if check.stderr:
                print("  stderr:")

                for line in check.stderr.splitlines():
                    print(f"    {line}")

    try:
        state = CertificationState(
            Path("/Users/wonderland/Wonderland")
        ).collect()

        print()

        print("Certification")

        platform = state.get(
            "platform",
            {}
        )

        trust = state.get(
            "trust",
            {}
        )

        graph = state.get(
            "graph",
            {}
        )

        print(
            f"  platform : {platform.get('state', 'UNKNOWN')}"
        )

        print(
            f"  certified: {platform.get('certified', False)}"
        )

        print(
            f"  trust    : {trust.get('trust', 'UNKNOWN')}"
        )

        print(
            f"  graph    : {graph.get('certified', False)}"
        )

    except Exception as exc:
        print()
        print(
            f"Certification: ERROR ({exc})"
        )


    print()
    print(f"duration_ms: {report.duration_ms}")
    print()
    print(f"RESULT {report.result.value}")





# RUNTIME_ECOLOGY_COMPLETE_CLI

def attach_runtime_ecology(runtime_sub):

    ecology = runtime_sub.add_parser(
        "ecology",
        help="Runtime Ecology lifecycle"
    )

    ecology_sub = ecology.add_subparsers(
        dest="ecology_action"
    )

    for action in (
        "start",
        "stop",
        "status",
        "verify",
        "health",
        "doctor",
        "recover",
        "certify",
    ):
        ecology_sub.add_parser(action)

    return ecology


def build_runtime_parser(subparsers):

    runtime = subparsers.add_parser(
        "runtime",
        help="Runtime Engine lifecycle",
    )

    runtime_sub = runtime.add_subparsers(
        dest="runtime_action"
    )

    for action in (
        "start",
        "stop",
        "status",
        "verify",
        "health",
        "doctor",
        "recover",
        "certify",
        "ecology",
    ):
        runtime_sub.add_parser(action)

    return runtime


def build_lifecycle_commands(subparsers):

    for action in (
        "start",
        "stop",
        "restart",
        "sleep",
        "wake",
        "status",
    ):
        subparsers.add_parser(action)




ENGINE_COMMANDS = {
    "architecture",
    "builder",
    "governance",
    "mirror",
    "academy",
    "registry",
}


def route_engine_command(argv):

    if not argv:
        return argv

    if argv[0] not in ENGINE_COMMANDS:
        return argv

    engine = argv[0]
    remaining = argv[1:]

    return [
        "engine",
        engine,
        *remaining,
    ]




ENGINE_COMMANDS = {
    "architecture",
    "builder",
    "governance",
    "mirror",
    "academy",
    "registry",
    "security",
}


def route_engine_argv(argv: list[str]) -> list[str]:

    if not argv:
        return argv

    command = argv[0]

    # Certification commands must preserve nested arguments.
    # Example:
    # wl platform certify graph status
    # wl platform certify trust

    if argv and argv[0] == "prismx":

        from .prismx.cli.commands import (
            status,
            list_streams,
            play_stream,
            certify,
            recover,
        )

        action = getattr(
            args,
            "prismx_action",
            None
        )

        if action == "status":

            print(
                status()
            )

            return 0

        if action == "streams":

            print(
                list_streams()
            )

            return 0

        if action == "play":

            print(
                play_stream(
                    args.stream
                )
            )

            return 0

        if action == "certify":

            print(
                certify()
            )

            return 0

        if action == "recover":

            print(
                recover()
            )
            return 0

        parser.print_help()
        return 2

    if command == "certify":
        return argv

    if command in ENGINE_COMMANDS:
        return [
            "engine",
            command,
            *argv[1:]
        ]

    return argv


def build_doctor_parser(subparsers):
    doctor = subparsers.add_parser(
        "doctor",
        help="Platform diagnostics",
    )

    doctor_sub = doctor.add_subparsers(
        dest="doctor_action",
        required=True,
    )

    doctor_sub.add_parser(
        "python-runtime",
        help="Validate Wonderland Python runtime",
    )

    doctor_sub.add_parser(
        "list",
        help="List available doctor capabilities",
    )

    doctor_sub.add_parser(
        "status",
        help="Show doctor engine status",
    )

    doctor_sub.add_parser(
        "evidence",
        help="Validate doctor evidence",
    )

    return doctor

def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="wl platform",
        description="Wonderland Platform Engine",
    )
        
    parser.add_argument(
        "--version",
        action="version",
        version=__version__,
    )

    subparsers = parser.add_subparsers(
        dest="command",
    )

    build_doctor_parser(
        subparsers
    )

    engine_parser = subparsers.add_parser(
        "engine",
        help="Engine command router",
    )

    engine_sub = engine_parser.add_subparsers(
        dest="engine_name",
    )

    for engine_name in (
        "architecture",
        "builder",
        "governance",
        "mirror",
        "academy",
        "registry",
        "runtime",
    ):
        ep = engine_sub.add_parser(engine_name)

        ep.add_argument(
            "action",
            nargs="?",
            default="verify",
        )

        ep.add_argument(
            "--json",
            action="store_true",
        )


    build_lifecycle_commands(
        subparsers
    )

    build_runtime_parser(
        subparsers
    )

    for name in (
        "verify",
        "status",
    ):
        command = subparsers.add_parser(name)
        command.add_argument(
            "--json",
            action="store_true",
        )
        command.add_argument(
            "--verbose",
            action="store_true",
        )
        command.add_argument(
            "--include-optional",
            action="store_true",
            help="include Mirror and Academy checks",
        )

    certify_parser = subparsers.add_parser(

        "certify"
    )

    certify_sub = certify_parser.add_subparsers(
        dest="certify_action"
    )

    certify_sub.add_parser(
        "status"
    )

    certify_explain = certify_sub.add_parser(
        "explain"
    )

    certify_explain.add_argument(
        "engine"
    )

    certify_migrate = certify_sub.add_parser(
        "migrate"
    )

    certify_migrate.add_argument(
        "--apply",
        action="store_true",
        help="perform migration instead of dry-run",
    )

    certify_sub.add_parser(
        "lineage"
    )

    certify_sub.add_parser(
        "trust"
    )

    certify_sub.add_parser(
        "gate"
    )


    certify_graph = certify_sub.add_parser(
        "graph",
        help="Certification graph operations",
    )

    certify_graph.add_argument(
        "graph_action",
        choices=[
            "rebuild",
            "status",
        ],
    )

    certify_parser.add_argument(
        "--json",
        action="store_true",
    )
    certify_parser.add_argument(
        "--include-optional",
        action="store_true",
    )

    commands_json = subparsers.add_parser(
        "commands-json",
        help="Public command registry projection",
    )

    commands_json.add_argument(
        "--json",
        action="store_true",
    )


    subparsers.add_parser("help")

    return parser


def normalize_argv(
    argv: list[str],
) -> list[str]:
    if not argv:
        return ["verify"]

    if argv[0] in {
        "--json",
        "--verbose",
        "--include-optional",
    }:
        return ["verify", *argv]

    if argv[0] in {"-h", "--help"}:
        return ["help"]

    return argv




# WONDERLAND_COMMUNICATION_CLI


def main(argv: list[str] | None = None) -> int:
    argv = list(
        sys.argv[1:] if argv is None else argv
    )

    argv = route_engine_argv(argv)
    
    argv = normalize_argv(argv)
    parser = build_parser()
    args = parser.parse_args(argv)
    
    from wlplatform.runtime.context import get_context

    root = get_context().root
    

    if args.command == "help":
        parser.print_help()
        return 0

    try:
        context = PlatformContext(
            root=root
        )

        controller = PlatformController(
            context=context
        )


        if args.command == "engine":

            engine = args.engine_name
            action = args.action

            if not engine:
                parser.print_help()
                return 2


            from .engine_router import EngineRouter


            router = EngineRouter(
                root=root
            )


            result = router.execute(
                engine,
                action,
                json=args.json,
            )


            if args.json:
                print(
                    json.dumps(
                        result,
                        indent=2,
                    )
                )
            else:
                print(result)


            return 0
    except PlatformContextError as exc:
        print(f"FAIL {exc}", file=sys.stderr)
        return 1

    
    if args.command == "commands-json":

        payload = {
            "schema_version": 1,
            "commands": [
                "architecture",
                "builder",
                "governance",
                "mirror",
                "academy",
                "registry",
                "runtime",
                "security",
                "start",
                "stop",
                "restart",
                "sleep",
                "wake",
                "verify",
                "status",
                "doctor",
                "certify",
            ],
        }

        print(
            json.dumps(
                payload,
                indent=2,
            )
        )

        return 0


    if args.command == "verify":

        report = controller.verify(
            include_optional=getattr(args, 'include_optional', False),
        )

        payload = report.to_dict()

        if getattr(args, 'json', False):
            print(
                json.dumps(
                    payload,
                    indent=2,
                    sort_keys=True,
                )
            )
        else:
            _render_report(
                report,
                verbose=getattr(args, 'verbose', False),
            )

        return (
            0
            if payload["result"] == "PASS"
            else 1
        )


    if (
        args.command == "certification"
        and
        args.certification_command == "gate"
    ):

        result = certification_gate(
            ROOT
        )

        if args.json:
            print(
                json.dumps(
                    result,
                    indent=2,
                )
            )
        else:
            print(result)

        return 0

    
    if args.command == "doctor":

        if args.doctor_action:

            from wlplatform.doctor.router import run_doctor
            from wlplatform.doctor.cli import handle_doctor_command

            if args.doctor_action in (
                "list",
                "status",
            ):
                return handle_doctor_command(
                    args.doctor_action
                )

            result = run_doctor(
                args.doctor_action,
                repository_root(),
            )

            print("PYTHON RUNTIME DOCTOR")
            print("=====================")
            print()

            print(
                f"Capability : {result['name']}"
            )
            print(
                f"Status     : {result['status']}"
            )
            print()

            for name, passed in result["checks"].items():
                state = "PASS" if passed else "FAIL"
                print(
                    f"{name:<15} {state}"
                )

            if "evidence" in result:
                print()
                print(
                    f"Evidence   : {result['evidence']['status']}"
                )

            return (
                0
                if result["status"] == "PASS"
                else 1
            )

    if args.command == "certify":

        if getattr(
            args,
            "certify_action",
            None
        ) == "status":

            state = CertificationState(
                root
            ).collect()

            print(
                json.dumps(
                    state,
                    indent=2,
                )
            )

            return


        if getattr(
            args,
            "certify_action",
            None
        ) == "explain":

            state = CertificationState(
                root
            ).collect()

            engine = (
                state
                .get("engines", {})
                .get(args.engine)
            )

            print(engine)

            return


        if getattr(
            args,
            "certify_action",
            None
        ) == "migrate":

            from .certification_migration import (
                CertificationMigration,
            )

            report = CertificationMigration(
                root
            ).migrate(
                dry_run=not args.apply
            )

            print(
                json.dumps(
                    report,
                    indent=2,
                    sort_keys=True,
                )
            )

            return


        if getattr(
            args,
            "certify_action",
            None
        ) == "migrate":

            from .certification_migrate import (
                migrate_certifications,
            )

            report = migrate_certifications(
                root
            )

            print(
                json.dumps(
                    report,
                    indent=2,
                    sort_keys=True,
                )
            )

            return


        if getattr(
            args,
            "certify_action",
            None
        ) == "persist-lineage":

            from .certification_lineage_persist import (
                persist_lineage,
            )

            report = persist_lineage(
                root
            )

            print(
                json.dumps(
                    report,
                    indent=2,
                    sort_keys=True,
                )
            )

            return


        if getattr(
            args,
            "certify_action",
            None
        ) == "lineage":

            from .certification_lineage import (
                CertificationLineage,
            )

            report = CertificationLineage(
                root
            ).build()

            print(
                json.dumps(
                    report,
                    indent=2,
                    sort_keys=True,
                )
            )

            return


        if getattr(
            args,
            "certify_action",
            None
        ) == "gate":

            from .certification_command import (
                certification_gate,
            )

            report = certification_gate(
                root
            )

            print(
                json.dumps(
                    report,
                    indent=2,
                    sort_keys=True,
                )
            )

            return



        if getattr(
            args,
            "certify_action",
            None
        ) == "gate":

            from .certification_command import (
                certification_gate,
            )

            report = certification_gate(
                root
            )

            print(
                json.dumps(
                    report,
                    indent=2,
                    sort_keys=True,
                )
            )

            return



        if getattr(
            args,
            "certify_action",
            None
        ) == "trust":

            from .certification_trust import (
                CertificationTrustEvaluator,
            )

            report = CertificationTrustEvaluator(
                root
            ).evaluate()

            print(
                json.dumps(
                    report,
                    indent=2,
                    sort_keys=True,
                )
            )

            return

        if getattr(
            args,
            "certify_action",
            None
        ) == "graph":

            from .certification_graph import (
                CertificationGraph,
            )

            graph = CertificationGraph(
                root
            )

            if args.graph_action == "rebuild":
                report = graph.rebuild()
            else:
                report = graph.status()

            print(
                json.dumps(
                    report,
                    indent=2,
                    sort_keys=True,
                )
            )

            return

        try:
            output = certify(
                controller,
                include_optional=getattr(args, 'include_optional', False),
            )
        except CertificationError as exc:
            payload = {
                "schema_version": 1,
                "result": "FAIL",
                "error": str(exc),
            }

            if getattr(args, 'json', False):
                print(
                    json.dumps(
                        payload,
                        indent=2,
                        sort_keys=True,
                    )
                )
            else:
                print("Wonderland Platform Certification")
                print()
                print(f"FAIL {exc}")
                print()
                print("RESULT FAIL")

            return 1

        payload = {
            "schema_version": 1,
            "result": "PASS",
            "certification": str(output),
        }

        if getattr(args, 'json', False):
            print(
                json.dumps(
                    payload,
                    indent=2,
                    sort_keys=True,
                )
            )
        else:
            print("Wonderland Platform Certification")
            print()
            print(f"evidence: {output}")
            print()
            print("RESULT PASS")

        return 0

    report = controller.verify(
        include_optional=getattr(args, 'include_optional', False),
    )

    if getattr(args, 'json', False):
        print(
            json.dumps(
                report.to_dict(),
                indent=2,
                sort_keys=True,
            )
        )
    else:
        _render_report(
            report,
            verbose=getattr(args, 'verbose', False),
        )

    return report.exit_code


if __name__ == "__main__":
    raise SystemExit(main())


def certification_status(root):
    import json



# Registry v1.4 capability support

from .engines.capabilities import (
    list_capabilities,
)



# WONDERLAND_SECURITY_COMMUNICATION_ROUTER

def build_security_parser(subparsers):

    security = subparsers.add_parser(
        "security",
        help="Security Engine"
    )

    security_sub = security.add_subparsers(
        dest="security_action"
    )

    communication = security_sub.add_parser(
        "communication",
        help="Communication security"
    )

    communication_sub = communication.add_subparsers(
        dest="communication_action"
    )

    communication_sub.add_parser(
        "providers",
        help="List communication providers"
    )

    communication_sub.add_parser(
        "status",
        help="Communication status"
    )

    return security

