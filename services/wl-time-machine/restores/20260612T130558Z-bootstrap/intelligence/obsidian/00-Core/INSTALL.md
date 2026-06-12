# Wonderland System Installation Runbook

## Host Environment Requirements
* **Hardware Profile:** Apple Silicon (ARM64 Native)
* **Base OS Context:** macOS (14+ Preferred)
* **Isolation Prerequisite:** Homebrew package manager or localized independent binary paths linked for custom rootless configurations.

## Bootstrap Sequence
1. Clone the core engineering vault directory structure directly into the target base home folder at `~/Wonderland`.
2. Configure the rootless virtualization engine variables within your user environment to guarantee total host user boundary separation.
3. Move into the Tier 3 implementation workspace (`~/Wonderland/Wonderland-v4`) and invoke the core tool sequence script (`bin/wl repair`) to automatically construct the runtime virtual environment.
