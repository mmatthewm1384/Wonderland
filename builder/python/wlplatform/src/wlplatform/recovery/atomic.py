import os
import tempfile
from pathlib import Path


def atomic_replace(source, target):

    target = Path(target)
    source = Path(source)

    temp = tempfile.NamedTemporaryFile(
        dir=target.parent,
        delete=False
    )

    temp.close()

    temp_path = Path(temp.name)

    os.replace(
        source,
        temp_path
    )

    os.replace(
        temp_path,
        target
    )

    return target
