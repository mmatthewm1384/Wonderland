#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
WL_V4="${WL_V4:-$WL_HOME/Wonderland-v4}"

INTENTS_DIR="$WL_V4/intents"
DOCS_DIR="$WL_V4/docs/theomatrix"
BIN_DIR="$WL_HOME/bin"

INTENT_FILE="$INTENTS_DIR/spin-the-city-eye-time-space.intent.json"
DOC_FILE="$DOCS_DIR/spin-the-city-eye-time-space.md"
CMD_FILE="$BIN_DIR/wl-spin-the-city-intent"

BACKUP_DIR="$WL_HOME/.backup-spin-the-city-intent-$(date +%Y%m%d-%H%M%S)"

echo "== spin-the-city intent installer =="
echo "WL_HOME=$WL_HOME"
echo "WL_V4=$WL_V4"
echo "BACKUP=$BACKUP_DIR"
echo

mkdir -p "$INTENTS_DIR" "$DOCS_DIR" "$BIN_DIR" "$BACKUP_DIR"

backup_if_exists() {
  local path="$1"
  if [[ -e "$path" ]]; then
    mkdir -p "$BACKUP_DIR$(dirname "$path")"
    cp -a "$path" "$BACKUP_DIR$path"
    echo "backup: $path"
  fi
}

backup_if_exists "$INTENT_FILE"
backup_if_exists "$DOC_FILE"
backup_if_exists "$CMD_FILE"

cat > "$INTENT_FILE" <<'JSON'
{
  "intent_id": "theomatrix.spin-the-city.eye-time-space.v1",
  "title": "Spin-The-City Eye-Time-Space Intent",
  "project": "THEOMATRIX",
  "app": "spin-the-city",
  "status": "draft",
  "mode": "DESIGN",
  "created_by": "Architect",
  "operator": "Matthew",
  "concept": {
    "primary_statement": "Spin-The-City creates an environment through counter-spinning temporal rings. The observer's eye movement traces a path through space. That path defines a state of time through space. The environment manifests in time from that state.",
    "flow": [
      "Observer",
      "Eye movement",
      "Path through space",
      "State of time through space",
      "Environment manifestations in time"
    ],
    "replacement_for": [
      "Observer",
      "Eye movement",
      "Path selection",
      "State selection",
      "Environment manifestation"
    ]
  },
  "geometry": {
    "model": "cone-time-space",
    "tip": {
      "meaning": "compressed present moment",
      "unit": "1 minute"
    },
    "rings": {
      "meaning": "temporal coordinate fields",
      "behavior": "adjacent rings counter-rotate to create transient corridors, gates, and path opportunities"
    },
    "outer_ring": {
      "meaning": "expanded temporal state-space",
      "candidate_radius": 168,
      "radius_meaning": "hours in a week"
    },
    "vertical_sections": {
      "count": 60,
      "meaning": "minute layers of temporal unfolding"
    }
  },
  "interaction_model": {
    "input": "eye movement",
    "tracked_subjects": [
      "Matthew",
      "Taylor Swift"
    ],
    "selection_principle": "The eye does not directly choose a menu item. The eye traces a route through a rotating temporal coordinate system.",
    "state_derivation": {
      "path_position": "where the gaze travels",
      "path_duration": "how long the gaze remains in a region",
      "path_velocity": "how quickly the gaze moves",
      "path_curvature": "how much the route bends through the field",
      "ring_alignment": "which counter-rotating gates are crossed"
    }
  },
  "environment_state": {
    "outputs": [
      "spin intensity",
      "ring deformation",
      "particle density",
      "color atmosphere",
      "field pressure",
      "visual calm",
      "visual agitation",
      "temporal depth"
    ],
    "rule": "The environment is the manifested state of time-space resulting from the observer's route through the spun field."
  },
  "design_constraints": {
    "not_a_game_controller": true,
    "not_linear_selection": true,
    "not_uniform_orbits": true,
    "must_use_counter_rotation": true,
    "must_use_eye-led_pathing": true,
    "must_feel_like_environment_state_change": true
  },
  "implementation_targets": {
    "app_path": "~/Workshop/apps/tauri/wl-spin-city",
    "future_name": "spin-the-city",
    "runtime": "Tauri",
    "visual_system": "THEOMATRIX",
    "input_backends": [
      "mouse-position proxy",
      "camera gaze approximation",
      "future eye-tracking integration"
    ]
  },
  "verification": {
    "checks": [
      "intent JSON parses",
      "documentation exists",
      "launcher command exists",
      "flow contains 'Path through space'",
      "flow contains 'State of time through space'",
      "flow contains 'Environment manifestations in time'"
    ]
  },
  "rollback": {
    "strategy": "Restore files from generated backup directory or delete created intent/doc/launcher files."
  }
}
JSON

cat > "$DOC_FILE" <<'MD'
# Spin-The-City Eye-Time-Space Intent

## Intent

Spin-The-City creates an environment through counter-spinning temporal rings.

The observer's eye movement traces a path through space.

That path defines a state of time through space.

The environment manifests in time from that state.

## Canonical Flow

```text
Observer
    ↓
Eye movement
    ↓
Path through space
    ↓
State of time through space
    ↓
Environment manifestations in time

Replaced Flow

This replaces the earlier interaction model:

Observer
    ↓
Eye movement
    ↓
Path selection
    ↓
State selection
    ↓
Environment manifestation

The older model implied a decision tree.

The new model defines a continuous time-space trajectory.

Core Principle

The rings are not the environment.

The rings are the spun temporal coordinate system that creates the environment.

The eye is not a controller.

The eye is a path generator.

The city is not a fixed place.

The city is the manifestation of time-space produced by the observer's path through the counter-spinning field.

Cone-Time Geometry

The conceptual geometry is a cone.

Tip: compressed present moment.
Vertical axis: unfolding minute layers.
Rings: temporal coordinate fields.
Outer radius: expanded state-space horizon.
Ring counter-rotation: temporal distortion.
Eye path: trajectory through the spun environment.

Candidate symbolic geometry:

tip = 1 minute
vertical sections = 60 minute layers
outer radius = 168 hours
outer radius meaning = hours in a week

This does not need to be physically literal. It is a control geometry for visual behavior.

Counter-Spinning Rings

Adjacent rings rotate in opposite directions.

This creates temporary alignments.

Those alignments are interpreted as:

gates
corridors
bridges
pressure seams
temporal crossings
state transition paths

The observer's gaze crosses or follows these alignments.

That route determines the state of the environment.

Eye Path Inputs

The state engine should derive meaning from:

Input	Meaning
Gaze position	Where the observer is looking
Gaze duration	How long attention stays there
Gaze velocity	How quickly attention moves
Gaze curvature	Whether the eye follows arcs, spirals, or cuts
Ring alignment crossing	Which temporal gates are crossed
Radial depth	How far from the center the gaze travels
Environmental Outputs

The route through the spun field should affect:

spin intensity
counter-rotation tension
ring deformation
particle density
color atmosphere
spatial pressure
visual calm
visual agitation
temporal depth
city manifestation style
Design Rule

Do not make Spin-The-City feel like ordinary spinning circles.

Make it feel like the observer's eyes are moving through a temporal space, and the environment is being manifested by that path.

Implementation Direction

Start with mouse-position as a proxy for gaze.

Then map pointer or gaze movement into:

path through space
    → temporal state vector
    → environment manifestation

Possible state vector:

{
  "radial_depth": 0.0,
  "angular_velocity": 0.0,
  "gaze_dwell": 0.0,
  "path_curvature": 0.0,
  "ring_crossings": 0,
  "alignment_pressure": 0.0,
  "spin_intensity": 0.0,
  "temporal_depth": 0.0
}
Verification

The concept is valid when:

The app no longer feels like passive orbital animation.
Eye or pointer motion visibly changes the environment.
Counter-spinning rings create meaningful visual routes.
The route changes the state of time through space.
The environment manifests differently depending on the path.
Recovery

If implementation becomes visually noisy, reduce the system to three layers:

center core
counter-spinning rings
eye-path state vector

Disable particles, secondary effects, and deformation until the core eye-path behavior is legible.

Rollback

Rollback by restoring prior Spin City visual behavior and removing this intent from the active design registry.

Created files:

Wonderland-v4/intents/spin-the-city-eye-time-space.intent.json
Wonderland-v4/docs/theomatrix/spin-the-city-eye-time-space.md
bin/wl-spin-the-city-intent

MD

cat > "$CMD_FILE" <<'SH'
#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
WL_V4="${WL_V4:-$WL_HOME/Wonderland-v4}"

INTENT_FILE="$WL_V4/intents/spin-the-city-eye-time-space.intent.json"
DOC_FILE="$WL_V4/docs/theomatrix/spin-the-city-eye-time-space.md"

case "${1:-show}" in
show)
cat "$INTENT_FILE"
;;
doc)
cat "$DOC_FILE"
;;
path)
printf '%s\n%s\n' "$INTENT_FILE" "$DOC_FILE"
;;
verify)
python3 -m json.tool "$INTENT_FILE" >/dev/null
grep -q "Path through space" "$INTENT_FILE"
grep -q "State of time through space" "$INTENT_FILE"
grep -q "Environment manifestations in time" "$INTENT_FILE"
test -f "$DOC_FILE"
echo "PASS spin-the-city-intent"
;;
*)
echo "usage: wl-spin-the-city-intent {show|doc|path|verify}" >&2
exit 2
;;
esac
SH

chmod +x "$CMD_FILE"

echo
echo "== verify =="
python3 -m json.tool "$INTENT_FILE" >/dev/null
"$CMD_FILE" verify

echo
echo "created:"
echo "$INTENT_FILE"
echo "$DOC_FILE"
echo "$CMD_FILE"
echo
echo "backup:"
echo "$BACKUP_DIR"
