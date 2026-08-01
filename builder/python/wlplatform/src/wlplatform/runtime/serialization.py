from pathlib import Path


def normalize(value):
    if isinstance(value, dict):
        return {
            str(key): normalize(item)
            for key, item in value.items()
        }

    if isinstance(value, (list, tuple)):
        return [
            normalize(item)
            for item in value
        ]

    if isinstance(value, Path):
        return str(value)

    return value
