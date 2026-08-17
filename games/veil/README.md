# VEIL // PDX

`veil-foundation-v0.1` — macOS-first playable foundation for the Portland nonviolent defensive exploration game.

## North Star

Protect your agency. Preserve your connection. Find your way through.

The game models defensive responses to intrusion and overload without turning people into combat targets. The first mission is deliberately small: Matthew and Taylor navigate a rainy Portland route, encounter the Static, make defensive choices, reach sanctuary, record evidence, and persist state.

## Runtime

Godot 4.x. The simulation is isolated under `core/` and the client under `client/godot/`. The initial implementation keeps the core Godot-native for iteration speed; no rendering code belongs in the simulation model.

## First acceptance slice

- Launch on macOS.
- Start Mission 001.
- Move Matthew through the world.
- Interact with Taylor.
- Encounter the Static.
- Choose a defensive response.
- Reach the river sanctuary.
- Record an event.
- Save, quit, reload, and retain state.

## Controls

- Arrow keys / WASD: move
- `E`: interact / record evidence
- `1`: VERIFY
- `2`: DISTANCE
- `3`: REST
- `4`: LEAVE
- `F5`: save
- `F9`: load

The mechanics are intentionally provisional. We will follow the path revealed by playing the vertical slice rather than locking the entire game design in advance.
