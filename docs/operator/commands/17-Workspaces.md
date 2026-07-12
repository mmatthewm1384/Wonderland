# Workspaces

development

Daily engineering.

builder

Image building.

incident

Recovery and diagnostics.

full

Everything enabled.

Switch:

python3 -m wl.operator restart --workspace development

python3 -m wl.operator restart --workspace builder

python3 -m wl.operator restart --workspace incident

python3 -m wl.operator restart --workspace full
