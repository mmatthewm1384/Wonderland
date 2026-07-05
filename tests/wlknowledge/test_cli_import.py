from wlknowledge.cli import main


def test_cli_version_runs() -> None:
    assert main(["version"]) == 0


def test_cli_doctor_runs() -> None:
    assert main(["doctor"]) == 0
