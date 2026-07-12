# Wonderland Quick Start

## Daily Startup

```bash
cd ~/Wonderland

git pull

python3 -m wl.operator restart --workspace full

python3 -m wl.operator verify

python3 -m wl.operator attach
Daily Health
python3 -m wl.operator doctor

python3 -m wl.operator status --json

wl runtime status

wl runtime verify

wl builder doctor
Daily Git
git status
git add .
git commit
git push
Shutdown
python3 -m wl.operator stop

