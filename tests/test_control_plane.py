from pathlib import Path

import pytest

from wonderland.validation import validate_host_environment


def tmp_workspace(tmp_path: Path) -> Path:
    """Fixture to provide an isolated workspace root for testing."""
    root = tmp_path / "wonderland"
    root.mkdir()
    (root / "images").mkdir()
    return root


def test_host_validation_passes(monkeypatch, tmp_path):
    workspace = tmp_workspace(tmp_path)
    monkeypatch.setenv("WONDERLAND_ROOT", str(workspace))

    # Assert validation passes on valid environment structure
    assert validate_host_environment(workspace) is True


def test_blocking_targets_contract():
    """Ensure restricted architectural contracts cannot be invoked."""
    restricted_ops = ["launch-ssh", "control-daemon-start", "benchmark"]
    for op in restricted_ops:
        with pytest.raises(PermissionError):
            # Simulated check for disabled daemons
            from wonderland.control import assert_daemonless_compliance

            assert_daemonless_compliance(op)
