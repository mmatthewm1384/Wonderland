# Wonderland OS Runtime Design Library

Runtime startup, boot, splash, and terminal visual assets for Wonderland OS.

## Structure

```text
design/runtime/
├── wonderland-os-runtime-dual-spinner-v1.png
├── wonderland-os-terminal-startup-v1.png
├── concepts/
├── exports/
├── source/
├── animation/
├── icons/
├── logos/
├── palettes/
├── typography/
└── references/
Asset Naming

Use lowercase kebab-case with version suffixes.

wonderland-os-runtime-dual-spinner-v1.png
wonderland-os-terminal-startup-v1.png
wonderland-os-runtime-boot-animation-v1.mp4
wonderland-os-runtime-logo-v1.svg
Purpose

These assets define the Wonderland OS runtime startup identity:

terminal-first
local-first
secure
hypnotic but restrained
operational, not decorative
suitable for CLI, boot splash, website, and documentation
Current Assets
Asset	Purpose
wonderland-os-runtime-dual-spinner-v1.png	Full runtime splash concept
wonderland-os-terminal-startup-v1.png	Terminal startup concept
Directory Roles
Directory	Purpose
concepts/	Experimental mockups and alternate directions
exports/	Final exported assets for use in apps/docs
source/	Editable source files
animation/	Boot/startup animation frames and videos
icons/	Runtime iconography
logos/	Runtime logos and marks
palettes/	Color palettes
typography/	Font and type usage notes
references/	Inspiration/reference material
EOF	

cat > design/runtime/palettes/runtime-neon.md <<'EOF'

Runtime Neon Palette

Primary visual direction for Wonderland OS startup visuals.

Token	Hex	Usage
runtime-bg	#05070A	Terminal background
runtime-cyan	#41F3FF	Primary glow/accent
runtime-blue	#4C7DFF	Secondary accent
runtime-purple	#A855F7	Spinner depth/glow
runtime-green	#38F58A	PASS / ready state
runtime-muted	#7A8799	Secondary text
runtime-white	#F4F7FB	Primary text
