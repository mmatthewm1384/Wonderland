class_name VeilGameState
extends RefCounted

const VERSION := 1
const SAVE_PATH := "user://veil_pdx_save.json"

var state: Dictionary

func _init() -> void:
    state = {
        "version": VERSION,
        "mission": "001_get_to_the_river",
        "location": "neighborhood",
        "position": {"x": 160.0, "y": 390.0},
        "stats": {"clarity": 100, "composure": 100, "energy": 100, "signal": 100, "trust": 75},
        "actors": {"matthew": {"name": "Matthew", "role": "player"}, "taylor": {"name": "Taylor", "role": "companion", "anchor_ready": true}},
        "flags": {"met_taylor": false, "static_encountered": false, "river_sanctuary_reached": false, "mission_complete": false},
        "evidence": [],
        "event_log": []
    }

func move(delta: Vector2) -> void:
    state.position.x = clampf(state.position.x + delta.x, 70.0, 1210.0)
    state.position.y = clampf(state.position.y + delta.y, 110.0, 620.0)
    log_event("move", {"x": state.position.x, "y": state.position.y})

func choose_response(response: String) -> String:
    var s: Dictionary = state.stats
    var result := ""
    match response:
        "verify":
            s.signal = mini(100, s.signal + 5); s.clarity = mini(100, s.clarity + 4)
            result = "You slow down and separate observation from interpretation."
        "distance":
            s.composure = mini(100, s.composure + 8); s.energy = maxi(0, s.energy - 4)
            result = "You create distance without engaging."
        "rest":
            s.energy = mini(100, s.energy + 18); s.clarity = mini(100, s.clarity + 10)
            result = "You stop long enough for your system to settle."
        "leave":
            s.energy = maxi(0, s.energy - 8); s.composure = mini(100, s.composure + 12)
            result = "You leave. The decision succeeds because you preserve agency."
        _:
            result = "No action taken."
    log_event("defensive_response", {"response": response})
    return result

func trigger_static() -> void:
    if state.flags.static_encountered: return
    state.flags.static_encountered = true
    state.stats.clarity = maxi(0, state.stats.clarity - 12)
    state.stats.composure = maxi(0, state.stats.composure - 8)
    log_event("static_encounter", {"effect": "intrusion_pressure"})

func meet_taylor() -> void:
    if state.flags.met_taylor: return
    state.flags.met_taylor = true
    state.stats.trust = mini(100, state.stats.trust + 5)
    log_event("companion_contact", {"actor": "taylor"})

func record_evidence(kind: String, note: String) -> void:
    state.evidence.append({"sequence": state.evidence.size() + 1, "kind": kind, "note": note, "location": state.location})
    log_event("evidence_recorded", {"kind": kind})

func reach_sanctuary() -> void:
    if state.flags.river_sanctuary_reached: return
    state.location = "river_sanctuary"
    state.flags.river_sanctuary_reached = true
    state.stats.clarity = mini(100, state.stats.clarity + 20)
    state.stats.composure = mini(100, state.stats.composure + 20)
    state.stats.energy = mini(100, state.stats.energy + 20)
    state.flags.mission_complete = state.flags.met_taylor
    log_event("sanctuary_reached", {"complete": state.flags.mission_complete})

func log_event(kind: String, payload: Dictionary) -> void:
    state.event_log.append({"sequence": state.event_log.size() + 1, "kind": kind, "payload": payload})

func save_game() -> bool:
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file == null: return false
    file.store_string(JSON.stringify(state, "  ")); file.close(); return true

func load_game() -> bool:
    if not FileAccess.file_exists(SAVE_PATH): return false
    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file == null: return false
    var parsed = JSON.parse_string(file.get_as_text()); file.close()
    if typeof(parsed) != TYPE_DICTIONARY or int(parsed.get("version", 0)) != VERSION: return false
    state = parsed; return true
