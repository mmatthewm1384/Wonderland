import inspect

from wlplatform.certification import certify


def test_certify_supports_cli_contract():
    signature = inspect.signature(certify)

    params = signature.parameters

    assert "controller" in params
    assert "include_optional" in params


def test_certify_accepts_optional_argument():
    class Controller:
        root = "."

    result = certify(
        Controller(),
        include_optional=False,
    )

    assert isinstance(result, dict)
    assert "certified" in result
