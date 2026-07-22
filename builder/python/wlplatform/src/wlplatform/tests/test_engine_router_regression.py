from pathlib import Path

from wlplatform.engine_router import EngineRouter


ROOT = Path(".")


def test_router_verify_contract():

    router = EngineRouter(ROOT)

    result = router.execute(
        "mirror",
        "verify",
        json=True,
    )

    assert result["engine"] == "mirror"
    assert result["action"] == "verify"
    assert result["status"] == "PASS"


def test_router_result_is_json_safe():

    router = EngineRouter(ROOT)

    result = router.execute(
        "architecture",
        "verify",
        json=True,
    )

    assert isinstance(result, dict)
    assert "status" in result
