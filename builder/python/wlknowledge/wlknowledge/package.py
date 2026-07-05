from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
import zipfile


@dataclass(frozen=True)
class PackageResult:
    path: Path
    file_count: int


def package_knowledge(root: Path) -> PackageResult:
    knowledge_dir = root / "knowledge"
    packages_dir = knowledge_dir / "packages"
    packages_dir.mkdir(parents=True, exist_ok=True)

    stamp = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S")
    package_path = packages_dir / f"Wonderland-Knowledge-Engine-{stamp}.zip"

    file_count = 0

    with zipfile.ZipFile(package_path, "w", compression=zipfile.ZIP_DEFLATED) as archive:
        for path in sorted(knowledge_dir.rglob("*")):
            if not path.is_file():
                continue

            if "packages" in path.parts:
                continue

            archive.write(path, path.relative_to(root).as_posix())
            file_count += 1

    return PackageResult(path=package_path, file_count=file_count)
