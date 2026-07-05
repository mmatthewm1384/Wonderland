from __future__ import annotations

import shutil
import subprocess
from pathlib import Path

from wl.operator.theme import PALETTE


class TmuxBackend:
    def __init__(self, root: Path, session: str = "wonderland") -> None:
        self.root = root
        self.session = session
        self.state_dir = root / "state" / "operator"
        self.conf = self.state_dir / "operator.tmux.conf"

    def run(self, args: list[str], check: bool = True) -> subprocess.CompletedProcess[str]:
        return subprocess.run(args, text=True, check=check)

    def require(self) -> None:
        if shutil.which("tmux") is None:
            raise SystemExit("FAIL tmux not found")

    def exists(self) -> bool:
        return self.run(["tmux", "has-session", "-t", self.session], check=False).returncode == 0

    def write_config(self) -> Path:
        p = PALETTE
        self.state_dir.mkdir(parents=True, exist_ok=True)
        self.conf.write_text(f"""
set -g status on
set -g status-position bottom
set -g status-interval 5
set -g mouse on
set -g history-limit 50000
set -g base-index 0
setw -g pane-base-index 0

unbind C-b
set -g prefix C-a
bind C-a send-prefix

bind R source-file "{self.conf}" \\; display-message "Wonderland Operator reloaded"

bind | split-window -h
bind - split-window -v
bind z resize-pane -Z

bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5

bind d select-window -t dashboard
bind r select-window -t runtime
bind b select-window -t builder
bind c select-window -t chaos
bind s select-window -t security
bind L select-window -t logs
bind g select-window -t git
bind x select-window -t scratch

set -g status-style "bg={p['bg']},fg={p['fg']}"
set -g status-left-length 50
set -g status-right-length 100
set -g status-left "#[fg={p['bg']},bg={p['green']},bold] Wonderland #[fg={p['green']},bg={p['bg']}] "
set -g status-right "#[fg={p['cyan']}]#H #[fg={p['purple']}]| #[fg={p['green']}]%H:%M #[fg={p['muted']}]%d-%b-%y "
setw -g window-status-format "#[fg={p['muted']}] #I:#W "
setw -g window-status-current-format "#[fg={p['bg']},bg={p['purple']},bold] #I:#W "
set -g pane-border-style "fg={p['muted']}"
set -g pane-active-border-style "fg={p['cyan']}"
set -g message-style "bg={p['purple']},fg={p['fg']},bold"
set -g mode-style "bg={p['cyan']},fg={p['bg']},bold"
""".strip() + "\n")
        return self.conf

    def source(self) -> None:
        self.run(["tmux", "source-file", str(self.conf)])

    def send(self, window: str, command: str) -> None:
        self.run(["tmux", "send-keys", "-t", f"{self.session}:{window}", command, "C-m"])

    def new_session(self, first_window: str) -> None:
        self.run(["tmux", "-f", str(self.conf), "new-session", "-d", "-s", self.session, "-c", str(self.root), "-n", first_window])

    def new_window(self, name: str) -> None:
        self.run(["tmux", "new-window", "-t", self.session, "-c", str(self.root), "-n", name])

    def select(self, name: str) -> None:
        self.run(["tmux", "select-window", "-t", f"{self.session}:{name}"])

    def attach(self) -> None:
        self.run(["tmux", "attach-session", "-t", self.session])

    def stop(self) -> None:
        self.run(["tmux", "kill-session", "-t", self.session])

    def list_windows(self) -> None:
        self.run(["tmux", "list-windows", "-t", self.session])
