from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import sys
from pathlib import Path


SESSION = "wonderland"
WINDOWS = ["dashboard", "runtime", "builder", "chaos", "security", "logs", "git", "scratch"]


def repo_root() -> Path:
    return Path.cwd()


def state_dir(root: Path) -> Path:
    return root / "state" / "operator"


def run(cmd: list[str], check: bool = True) -> subprocess.CompletedProcess[str]:
    return subprocess.run(cmd, text=True, check=check)


def tmux_required() -> None:
    if shutil.which("tmux") is None:
        raise SystemExit("FAIL tmux not found")


def session_exists() -> bool:
    return run(["tmux", "has-session", "-t", SESSION], check=False).returncode == 0


def write_theme(root: Path) -> Path:
    d = state_dir(root)
    d.mkdir(parents=True, exist_ok=True)
    conf = d / "operator.tmux.conf"
    conf.write_text(
        """
set -g status on
set -g status-position bottom
set -g status-interval 5
set -g mouse on
set -g history-limit 50000

# Wonderland Operator keymap
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# Operator reload
bind R source-file "#{pane_current_path}/state/operator/operator.tmux.conf" \\; display-message "Wonderland Operator reloaded"

# Pane management
bind | split-window -h
bind - split-window -v
bind z resize-pane -Z

# Pane navigation
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Pane resize
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5

# Wonderland windows
bind d select-window -t dashboard
bind r select-window -t runtime
bind b select-window -t builder
bind c select-window -t chaos
bind s select-window -t security
bind L select-window -t logs
bind g select-window -t git
bind x select-window -t scratch

set -g status-style "bg=#10141F,fg=#D7E1F0"
set -g status-left-length 50
set -g status-right-length 100
set -g status-left "#[fg=#10141F,bg=#2FE66B,bold] Wonderland #[fg=#2FE66B,bg=#10141F] "
set -g status-right "#[fg=#20D6E8]#H #[fg=#9B5CFF]| #[fg=#2FE66B]%H:%M #[fg=#667085]%d-%b-%y "
setw -g window-status-format "#[fg=#667085] #I:#W "
setw -g window-status-current-format "#[fg=#10141F,bg=#9B5CFF,bold] #I:#W "
set -g pane-border-style "fg=#667085"
set -g pane-active-border-style "fg=#20D6E8"
set -g message-style "bg=#9B5CFF,fg=#D7E1F0,bold"
set -g mode-style "bg=#20D6E8,fg=#10141F,bold"
""".strip()
        + "\n"
    )
    return conf


def send(window: str, command: str) -> None:
    run(["tmux", "send-keys", "-t", f"{SESSION}:{window}", command, "C-m"])


def dashboard(root: Path) -> None:
    git_branch = subprocess.getoutput("git branch --show-current 2>/dev/null || true")
    git_changes = subprocess.getoutput("git status --short 2>/dev/null | wc -l | tr -d ' '")

    print("\033[2J\033[H", end="")
    print("\033[38;2;47;230;107m┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓\033[0m")
    print("\033[38;2;47;230;107m┃                  Wonderland Operator                         ┃\033[0m")
    print("\033[38;2;47;230;107m┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛\033[0m")
    print()
    print("\033[38;2;32;214;232mlocal-first operator environment\033[0m")
    print()
    print(f"\033[38;2;155;92;255mRoot      \033[0m {root}")
    print(f"\033[38;2;155;92;255mBranch    \033[0m {git_branch or 'unknown'}")
    print(f"\033[38;2;155;92;255mGit       \033[0m {git_changes} changed files")
    print()
    print("\033[38;2;47;230;107mWindows\033[0m")
    for i, name in enumerate(WINDOWS):
        print(f"  {i} {name}")
    print()
    print("\033[38;2;255;159;67mCommands\033[0m")
    print("  wl operator status")
    print("  wl operator reload")
    print("  wl operator verify")
    print("  wl runtime status")
    print("  wl runtime verify")
    print("  wl doctor")
    print()
    print("\033[38;2;32;214;232mNavigation\033[0m")
    print("  Ctrl-a 0..7     switch window")
    print("  Ctrl-a d        dashboard")
    print("  Ctrl-a r        runtime")
    print("  Ctrl-a b        builder")
    print("  Ctrl-a c        chaos")
    print("  Ctrl-a s        security")
    print("  Ctrl-a L        logs")
    print("  Ctrl-a g        git")
    print("  Ctrl-a x        scratch")
    print("  Ctrl-a then d   detach if using tmux default detach binding")


def start(args: argparse.Namespace) -> None:
    tmux_required()
    root = repo_root()
    conf = write_theme(root)

    if session_exists():
        run(["tmux", "source-file", str(conf)])
        print(f"PASS operator already running: {SESSION}")
        return

    run(["tmux", "-f", str(conf), "new-session", "-d", "-s", SESSION, "-c", str(root), "-n", "dashboard"])
    run(["tmux", "source-file", str(conf)])

    send("dashboard", f"cd {shlex_quote(str(root))}; python3 -m wl.operator.dashboard")

    for name in WINDOWS[1:]:
        run(["tmux", "new-window", "-t", SESSION, "-c", str(root), "-n", name])

    send("runtime", "clear; echo Runtime; echo; echo 'Try: wl runtime status'")
    send("builder", "clear; echo Builder; echo; echo 'Try: wl builder status || wl builder doctor'")
    send("chaos", "clear; echo Chaos; echo; echo 'Try: wl chaos status || wl-chaos-session status'")
    send("security", "clear; echo Security; echo; echo 'Future: wl security dashboard'")
    send("logs", "clear; echo Logs; find state logs vault/chaos -maxdepth 3 -type f 2>/dev/null | sort | tail -80")
    send("git", "clear; git status --short")
    send("scratch", "clear; echo Scratch")

    run(["tmux", "select-window", "-t", f"{SESSION}:dashboard"])

    manifest = {
        "version": 1,
        "session": SESSION,
        "root": str(root),
        "intent": "Wonderland local-first operator environment",
        "backend": "tmux",
        "windows": WINDOWS,
        "theme": str(conf),
    }
    (state_dir(root) / "operator.json").write_text(json.dumps(manifest, indent=2) + "\n")

    print(f"PASS started operator: {SESSION}")


def shlex_quote(value: str) -> str:
    import shlex
    return shlex.quote(value)


def stop(args: argparse.Namespace) -> None:
    tmux_required()
    if not session_exists():
        print(f"PASS operator not running: {SESSION}")
        return
    run(["tmux", "kill-session", "-t", SESSION])
    print(f"PASS stopped operator: {SESSION}")


def attach(args: argparse.Namespace) -> None:
    tmux_required()
    if not session_exists():
        start(args)
    run(["tmux", "attach-session", "-t", SESSION])


def status(args: argparse.Namespace) -> None:
    tmux_required()
    if not session_exists():
        raise SystemExit(f"FAIL operator not running: {SESSION}")
    print(f"PASS operator running: {SESSION}")
    run(["tmux", "list-windows", "-t", SESSION])


def reload(args: argparse.Namespace) -> None:
    tmux_required()
    root = repo_root()
    conf = write_theme(root)
    if not session_exists():
        raise SystemExit(f"FAIL operator not running: {SESSION}")
    run(["tmux", "source-file", str(conf)])
    send("dashboard", f"cd {shlex_quote(str(root))}; python3 -m wl.operator.dashboard")
    print(f"PASS reloaded operator: {SESSION}")


def verify(args: argparse.Namespace) -> None:
    tmux_required()
    root = repo_root()
    conf = state_dir(root) / "operator.tmux.conf"
    manifest = state_dir(root) / "operator.json"

    print("PASS tmux found")
    print("PASS module importable")
    if session_exists():
        print(f"PASS session exists: {SESSION}")
    else:
        raise SystemExit(f"FAIL session missing: {SESSION}")

    if conf.exists():
        print(f"PASS theme exists: {conf}")
    else:
        raise SystemExit(f"FAIL theme missing: {conf}")

    if manifest.exists():
        print(f"PASS manifest exists: {manifest}")
    else:
        raise SystemExit(f"FAIL manifest missing: {manifest}")


def main() -> int:
    parser = argparse.ArgumentParser(prog="wl operator")
    sub = parser.add_subparsers(dest="command", required=True)

    commands = {
        "start": start,
        "stop": stop,
        "restart": None,
        "attach": attach,
        "status": status,
        "reload": reload,
        "dashboard": None,
        "verify": verify,
    }

    for name in commands:
        sub.add_parser(name)

    args = parser.parse_args()

    if args.command == "restart":
        stop(args)
        start(args)
        return 0

    if args.command == "dashboard":
        dashboard(repo_root())
        return 0

    commands[args.command](args)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
