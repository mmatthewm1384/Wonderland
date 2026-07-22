from wlplatform.certification.install.validator import (
    InstallationResult
)


def test_installation_result():

    result = InstallationResult()

    result.add(
        "package",
        True
    )

    result.add(
        "tests",
        True
    )

    assert result.finalize().certified
