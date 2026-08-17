extends RefCounted

const GameState = preload("res://core/GameState.gd")

static func run() -> void:
    var game := GameState.new()
    assert(game.state.version == 1)
    assert(game.state.mission == "001_get_to_the_river")
    assert(game.state.stats.clarity == 100)
    game.meet_taylor()
    assert(game.state.flags.met_taylor)
    assert(game.state.stats.trust == 80)
    game.trigger_static()
    assert(game.state.flags.static_encountered)
    assert(game.state.stats.clarity == 88)
    var before: int = game.state.stats.clarity
    game.choose_response("verify")
    assert(game.state.stats.clarity > before)
    game.record_evidence("observation", "test")
    assert(game.state.evidence.size() == 1)
    game.reach_sanctuary()
    assert(game.state.flags.river_sanctuary_reached)
    assert(game.state.flags.mission_complete)
