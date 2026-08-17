extends Node2D

const GameState = preload("res://core/GameState.gd")
var game := GameState.new()
var message := "Mission 001: GET TO THE RIVER"
var message_timer := 0.0
const SPEED := 230.0

func _ready() -> void:
    queue_redraw()

func _process(delta: float) -> void:
    var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    if direction.length_squared() > 0.0:
        game.move(direction.normalized() * SPEED * delta)
        _evaluate_world()
        queue_redraw()
    if message_timer > 0.0:
        message_timer -= delta
        if message_timer <= 0.0:
            message = ""
            queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("interact"):
        _interact()
    elif event.is_action_pressed("verify"):
        _respond("verify")
    elif event.is_action_pressed("distance"):
        _respond("distance")
    elif event.is_action_pressed("rest"):
        _respond("rest")
    elif event.is_action_pressed("leave"):
        _respond("leave")
    elif event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_F5:
            _set_message("STATE SAVED" if game.save_game() else "SAVE FAILED")
        elif event.keycode == KEY_F9:
            _set_message("STATE RESTORED" if game.load_game() else "NO VALID SAVE")
            queue_redraw()

func _respond(response: String) -> void:
    if not game.state.flags.static_encountered:
        _set_message("Nothing is demanding a response yet.")
        return
    _set_message(game.choose_response(response))
    queue_redraw()

func _interact() -> void:
    var p := Vector2(game.state.position.x, game.state.position.y)
    if p.distance_to(Vector2(320, 390)) < 90.0:
        game.meet_taylor()
        _set_message("Taylor is with you. Anchor established.")
    elif game.state.flags.static_encountered:
        game.record_evidence("observation", "Static pressure detected; interpretation intentionally left open.")
        _set_message("EVIDENCE RECORDED: OBSERVED, not assumed.")
    else:
        _set_message("You observe the environment before deciding what it means.")
    queue_redraw()

func _evaluate_world() -> void:
    var p := Vector2(game.state.position.x, game.state.position.y)
    if p.x > 470.0 and p.x < 900.0:
        var was_static := game.state.flags.static_encountered
        game.trigger_static()
        if not was_static:
            _set_message("STATIC DETECTED — 1 VERIFY  2 DISTANCE  3 REST  4 LEAVE")
    if p.x >= 1050.0:
        var was_sanctuary := game.state.flags.river_sanctuary_reached
        game.reach_sanctuary()
        if not was_sanctuary:
            _set_message("RIVER SANCTUARY REACHED — MISSION COMPLETE" if game.state.flags.mission_complete else "RIVER SANCTUARY REACHED — find Taylor")
    queue_redraw()

func _set_message(value: String) -> void:
    message = value
    message_timer = 6.0

func _draw() -> void:
    draw_rect(Rect2(0, 0, 1280, 720), Color("071017"))
    draw_rect(Rect2(0, 100, 1280, 520), Color("0d1b22"))
    draw_rect(Rect2(0, 285, 1280, 210), Color("111d23"))
    draw_line(Vector2(0, 390), Vector2(1280, 390), Color("263941"), 3.0)

    draw_rect(Rect2(0, 100, 260, 185), Color("0b211d"))
    for x in range(25, 250, 45):
        draw_line(Vector2(x, 250), Vector2(x + 18, 130), Color("173b32"), 12.0)

    draw_rect(Rect2(380, 315, 520, 150), Color("152a31"))
    draw_line(Vector2(400, 350), Vector2(880, 350), Color("405a61"), 5.0)
    draw_line(Vector2(400, 430), Vector2(880, 430), Color("405a61"), 5.0)

    draw_rect(Rect2(1050, 100, 230, 520), Color("0b2635"))
    for y in range(130, 600, 42):
        draw_line(Vector2(1070, y), Vector2(1260, y + 12), Color("16455a"), 2.0)

    draw_string(ThemeDB.fallback_font, Vector2(30, 145), "FOREST EDGE", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("8fb9a9"))
    draw_string(ThemeDB.fallback_font, Vector2(405, 305), "MAX CORRIDOR", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("9bb7c0"))
    draw_string(ThemeDB.fallback_font, Vector2(1090, 145), "WILLAMETTE", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("83bcd5"))
    draw_string(ThemeDB.fallback_font, Vector2(1090, 175), "RIVER SANCTUARY", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("83bcd5"))

    var taylor_color := Color("d6a8ff") if game.state.flags.met_taylor else Color("8b719f")
    draw_circle(Vector2(320, 390), 22.0, taylor_color)
    draw_string(ThemeDB.fallback_font, Vector2(293, 430), "TAYLOR", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, taylor_color)

    var player := Vector2(game.state.position.x, game.state.position.y)
    draw_circle(player, 18.0, Color("5ee7f2"))
    draw_circle(player, 28.0, Color(0.37, 0.91, 0.95, 0.12))

    if game.state.flags.static_encountered:
        draw_circle(Vector2(680, 390), 145.0, Color(0.85, 0.25, 0.62, 0.08))
        draw_arc(Vector2(680, 390), 145.0, 0, TAU, 64, Color(0.85, 0.25, 0.62, 0.35), 2.0)
        draw_string(ThemeDB.fallback_font, Vector2(620, 390), "STATIC", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("e98fcb"))

    _draw_hud()

func _draw_hud() -> void:
    draw_rect(Rect2(0, 0, 1280, 100), Color("05090d"))
    draw_string(ThemeDB.fallback_font, Vector2(30, 35), "VEIL // PDX", HORIZONTAL_ALIGNMENT_LEFT, -1, 27, Color("5ee7f2"))
    draw_string(ThemeDB.fallback_font, Vector2(30, 67), message if message != "" else "Protect your agency. Preserve your connection. Find your way through.", HORIZONTAL_ALIGNMENT_LEFT, 700, 17, Color("c3d1d5"))

    var stats: Dictionary = game.state.stats
    var labels := ["CLARITY", "COMPOSURE", "ENERGY", "SIGNAL", "TRUST"]
    var keys := ["clarity", "composure", "energy", "signal", "trust"]
    for i in labels.size():
        var x := 760.0 + i * 100.0
        draw_string(ThemeDB.fallback_font, Vector2(x, 35), labels[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("78939b"))
        draw_string(ThemeDB.fallback_font, Vector2(x, 60), str(stats[keys[i]]), HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("e1edf0"))

    draw_rect(Rect2(20, 645, 1240, 55), Color(0.02, 0.04, 0.05, 0.92))
    draw_string(ThemeDB.fallback_font, Vector2(35, 678), "WASD / ARROWS MOVE   E INTERACT   1 VERIFY   2 DISTANCE   3 REST   4 LEAVE   F5 SAVE   F9 LOAD", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("9cb2b8"))

    if game.state.flags.mission_complete:
        draw_rect(Rect2(390, 250, 500, 120), Color(0.02, 0.07, 0.08, 0.94))
        draw_string(ThemeDB.fallback_font, Vector2(435, 300), "SANCTUARY", HORIZONTAL_ALIGNMENT_LEFT, -1, 34, Color("5ee7f2"))
        draw_string(ThemeDB.fallback_font, Vector2(435, 335), "You kept moving without surrendering agency.", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("c3d1d5"))
