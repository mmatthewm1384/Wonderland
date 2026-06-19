#!/usr/bin/env python3
import argparse
import json
import os
import time
import urllib.request
import urllib.error
from pathlib import Path

WL_HOME = Path(os.environ.get("WL_HOME", str(Path.home() / "Wonderland")))
CONFIG = WL_HOME / "config" / "ai-providers.env"
AI_ROOT = WL_HOME / "vault" / "08-Operations" / "ai"

for d in ["requests", "responses", "reviews", "decisions", "audits", "implementations"]:
    (AI_ROOT / d).mkdir(parents=True, exist_ok=True)

def now():
    return time.strftime("%Y%m%dT%H%M%SZ", time.gmtime())

def load_env():
    if CONFIG.exists():
        for line in CONFIG.read_text().splitlines():
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                k, v = line.split("=", 1)
                os.environ.setdefault(k.strip(), v.strip().strip('"').strip("'"))

    vaults = {
        "OPENAI_API_KEY": WL_HOME / "secrets" / ".openai_token_vault",
        "XAI_API_KEY": WL_HOME / "secrets" / ".xai_token_vault"
    }

    for k, p in vaults.items():
        if not os.environ.get(k) and p.exists():
            val = p.read_text().strip()
            if val:
                os.environ[k] = val

def redact(x):
    x = str(x)
    for k in ["OPENAI_API_KEY", "XAI_API_KEY"]:
        v = os.environ.get(k, "")
        if v:
            x = x.replace(v, "[REDACTED]")
    return x

def read_intent(path):
    data = json.loads(Path(path).read_text())
    for k in ["id", "mode", "title", "objective"]:
        if k not in data:
            raise SystemExit(f"FAIL intent missing {k}")
    return data

def make_prompt(i):
    return (
        "You are a Wonderland provider.\n\n"
        f"Mode: {i.get('mode')}\n"
        f"Title: {i.get('title')}\n"
        f"Objective: {i.get('objective')}\n\n"
        "Return:\n"
        "1. Architecture\n"
        "2. Implementation\n"
        "3. Verification\n"
        "4. Recovery\n"
        "5. Rollback\n"
        "6. Risks\n"
        "7. Decision recommendation\n\n"
        "Intent:\n"
        + json.dumps(i, indent=2)
    )

def http_json(url, headers, payload):
    req = urllib.request.Request(
        url,
        data=json.dumps(payload).encode(),
        headers=headers,
        method="POST"
    )

    try:
        with urllib.request.urlopen(req, timeout=120) as r:
            return json.loads(r.read().decode())
    except urllib.error.HTTPError as e:
        raise RuntimeError(f"HTTP {e.code}: {redact(e.read().decode(errors='replace'))}")
    except Exception as e:
        raise RuntimeError(str(e))

def ask_chatgpt(i):
    key = os.environ.get("OPENAI_API_KEY", "")
    if not key:
        raise RuntimeError("OPENAI_API_KEY missing")

    data = http_json(
        "https://api.openai.com/v1/responses",
        {
            "Authorization": f"Bearer {key}",
            "Content-Type": "application/json"
        },
        {
            "model": os.environ.get("OPENAI_MODEL", "gpt-5.5"),
            "input": make_prompt(i)
        }
    )

    if data.get("output_text"):
        return data["output_text"]

    chunks = []
    for item in data.get("output", []):
        for c in item.get("content", []):
            if "text" in c:
                chunks.append(c["text"])

    return "\n".join(chunks).strip() or json.dumps(data, indent=2)

def ask_grok(i):
    key = os.environ.get("XAI_API_KEY", "")
    if not key:
        raise RuntimeError("XAI_API_KEY missing")

    base = os.environ.get("XAI_BASE_URL", "https://api.x.ai/v1").rstrip("/")

    data = http_json(
        f"{base}/chat/completions",
        {
            "Authorization": f"Bearer {key}",
            "Content-Type": "application/json"
        },
        {
            "model": os.environ.get("XAI_MODEL", "grok-4"),
            "messages": [
                {
                    "role": "system",
                    "content": "You are a Wonderland provider. Be auditable and recoverable."
                },
                {
                    "role": "user",
                    "content": make_prompt(i)
                }
            ]
        }
    )

    return data["choices"][0]["message"]["content"]

def local_response(i, reason):
    return (
        f"# Local Provider Response — {i['id']}\n\n"
        "## Status\n\n"
        "Local fallback active.\n\n"
        "## Reason\n\n"
        "```txt\n"
        f"{redact(reason)}\n"
        "```\n\n"
        "## Architecture\n\n"
        "Remote providers are optional. Wonderland remains the implementation authority.\n\n"
        "## Implementation\n\n"
        "Manual implementation required before mutation.\n\n"
        "## Verification\n\n"
        "```bash\n"
        "bin/wl-ai verify\n"
        "ls -lah vault/08-Operations/ai/responses\n"
        "ls -lah vault/08-Operations/ai/audits\n"
        "```\n\n"
        "## Recovery\n\n"
        "Use `.wl/snapshots/`.\n\n"
        "## Rollback\n\n"
        "```bash\n"
        "git status\n"
        "git restore <file>\n"
        "git reset --hard <known-good-commit>\n"
        "```\n\n"
        "## Decision\n\n"
        "Pending operator approval.\n"
    )

def write_output(provider, i, text, status="complete", reason=""):
    out = AI_ROOT / "responses" / f"{i['id']}.{provider}.md"
    audit = AI_ROOT / "audits" / f"{i['id']}.{provider}.audit.json"

    out.write_text(redact(text).rstrip() + "\n")

    audit.write_text(json.dumps({
        "id": f"{i['id']}.{provider}.{now()}",
        "intent": i["id"],
        "provider": provider,
        "status": status,
        "reason": redact(reason),
        "output": str(out),
        "created_utc": now()
    }, indent=2) + "\n")

    label = "PASS" if status == "complete" else "PASS fallback"
    print(label, provider + ":", out)

def new_intent(title):
    safe = "".join(c for c in title.lower().replace(" ", "-") if c.isalnum() or c in "-_")
    iid = f"wl-idea-{time.strftime('%Y%m%d')}-{safe}"
    p = WL_HOME / "intents" / f"{safe}.intent.json"

    p.write_text(json.dumps({
        "id": iid,
        "mode": "DESIGN",
        "title": title,
        "objective": title,
        "providers": ["chatgpt", "grok", "local"],
        "requirements": [
            "persistent",
            "recoverable",
            "auditable",
            "secure",
            "automated",
            "versioned",
            "modular"
        ],
        "outputs": {
            "design": True,
            "implementation_plan": True,
            "verification": True,
            "rollback": True
        },
        "status": "draft"
    }, indent=2) + "\n")

    print(p)

def compare(intent_id):
    files = sorted((AI_ROOT / "responses").glob(f"{intent_id}.*.md"))

    if not files:
        raise SystemExit("FAIL no responses found")

    review = AI_ROOT / "reviews" / f"{intent_id}.review.md"

    body = [f"# Wonderland AI Review — {intent_id}", ""]

    for f in files:
        body += [f"## {f.name}", "", f.read_text(), ""]

    body += [
        "## Decision checklist",
        "",
        "- [ ] Architecture accepted",
        "- [ ] Security reviewed",
        "- [ ] Secrets excluded",
        "- [ ] Verification defined",
        "- [ ] Recovery defined",
        "- [ ] Rollback defined",
        "- [ ] Implementation approved",
        ""
    ]

    review.write_text("\n".join(body))
    print("PASS review:", review)

def verify():
    required = [
        CONFIG,
        WL_HOME / "services/wl-ai-router/wl_ai_router.py",
        WL_HOME / "bin/wl-ai",
        WL_HOME / "bin/wl-idea",
        WL_HOME / "bin/wl-ai-verify",
        WL_HOME / "vault/09-Governance/registry/ai-provider-registry.json",
        AI_ROOT / "responses",
        AI_ROOT / "reviews",
        AI_ROOT / "audits"
    ]

    fail = False

    for p in required:
        if p.exists():
            print("PASS", p)
        else:
            print("FAIL", p)
            fail = True

    print("RESULT FAIL" if fail else "RESULT PASS")

    if fail:
        raise SystemExit(1)

def main():
    load_env()

    ap = argparse.ArgumentParser(prog="wl-ai")
    sub = ap.add_subparsers(dest="cmd", required=True)

    n = sub.add_parser("new")
    n.add_argument("title")

    a = sub.add_parser("ask")
    a.add_argument("--provider", choices=["chatgpt", "grok", "local"], required=True)
    a.add_argument("--intent", required=True)
    a.add_argument("--fallback", action="store_true")

    c = sub.add_parser("compare")
    c.add_argument("--intent-id", required=True)

    sub.add_parser("verify")

    args = ap.parse_args()

    if args.cmd == "new":
        new_intent(args.title)

    elif args.cmd == "ask":
        i = read_intent(args.intent)

        if args.provider == "local":
            write_output(
                "local",
                i,
                local_response(i, "local provider selected"),
                "fallback",
                "local provider selected"
            )
            return

        try:
            text = ask_chatgpt(i) if args.provider == "chatgpt" else ask_grok(i)
            write_output(args.provider, i, text)
        except Exception as e:
            if not args.fallback:
                raise SystemExit(f"FAIL {args.provider}: {redact(e)}")

            write_output(
                f"{args.provider}-fallback",
                i,
                local_response(i, str(e)),
                "fallback",
                str(e)
            )

    elif args.cmd == "compare":
        compare(args.intent_id)

    elif args.cmd == "verify":
        verify()

if __name__ == "__main__":
    main()
