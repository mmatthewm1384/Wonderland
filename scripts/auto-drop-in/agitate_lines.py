{
  "name": "agitate-flat-frequency-waves",
  "version": "0.1.0",
  "objective": "Create script that agitates flat/stale frequency wave lines into dynamic wavy lines matching example green style via perturbation.",
  "scope": "Static image line agitation only. In: dark-bg line drawings. Out: agitated overlay image. Excludes audio, video, vectors, GUIs.",
  "assumptions": [
    "Python container with numpy/pillow/opencv via nerdctl.",
    "Near-horizontal lines; agitation = sine + jitter on y coords.",
    "Input path given; intensity param controls strength.",
    "Output PNG with agitated lines."
  ],
  "required_files": [
    {
      "path": "scripts/auto-drop-in/wl-agitate-waves.sh",
      "purpose": "Bash wrapper, idempotent, parses args and calls python.",
      "template": "bash"
    },
    {
      "path": "scripts/auto-drop-in/agitate_lines.py",
      "purpose": "Load image, apply sine+jitter agitation to lines, save output.",
      "template": "python"
    },
    {
      "path": "intents/agitate-flat-frequency-waves.intent.json",
      "purpose": "Versioned intent definition.",
      "template": "json"
    }
  ],
  "commands": [
    {
      "name": "wl-agitate-waves",
      "description": "Agitates flat wave lines in image to produce wavy output.",
      "usage": "wl-agitate-waves --input PATH --output PATH [--intensity 0.5]",
      "script_path": "scripts/auto-drop-in/wl-agitate-waves.sh",
      "env_vars": ["INPUT_PATH", "OUTPUT_PATH", "AGITATION_INTENSITY", "WONDERLAND_ROOT"]
    }
  ],
  "verification_steps": [
    "wl-agitate-waves --input /home/workdir/attachments/IMG_0017.jpg --output /tmp/agitated.png --intensity 0.7 --dry-run (exit 0)",
    "Confirm /tmp/agitated.png exists with visible waviness increase"
  ],
  "recovery_steps": [
    "rm partial outputs; re-run command",
    "Check container logs for dep errors"
  ],
  "rollback_steps": [
    "rm -f /tmp/agitated.png",
    "git checkout -- scripts/auto-drop-in/agitate_lines.py"
  ],
  "metadata": {
    "created_by": "intent-builder",
    "created_at": "2026-06-17T21:05:00-07:00",
    "author": "Grok",
    "tags": ["image-processing", "generative-art", "creative-tool"],
    "security": "Least privilege. Env vars only. No secrets.",
    "auditable": true,
    "versioned": true,
    "modular": true,
    "recovery": "Idempotent re-runs + git checkout recommended."
  }
}
