from wlknowledge.model import Entity, KnowledgeModel


def test_model_counts_and_fingerprint() -> None:
    model = KnowledgeModel(commands=[Entity(name="wl", path="bin/wl", kind="command")])
    model.finalize()

    data = model.to_dict()

    assert data["system"] == "Wonderland Knowledge Engine"
    assert data["counts"]["commands"] == 1
    assert data["fingerprint"]
