from pathlib import Path

from wlplatform.context import PlatformContext
from wlplatform.paths import repository_root


def test_repository_root_uses_wl_root(monkeypatch, tmp_path):
    root = Path("/mnt/wonderland").resolve()

    monkeypatch.setenv("WL_ROOT", str(root))
    monkeypatch.chdir(tmp_path)

    assert PlatformContext.discover().root == root
    assert repository_root() == root
