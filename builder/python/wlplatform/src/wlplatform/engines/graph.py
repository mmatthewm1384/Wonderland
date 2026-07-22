from __future__ import annotations

from .catalog import ENGINE_CATALOG


def dependencies(name):

    return ENGINE_CATALOG[name]["depends_on"]


def capabilities(name):

    return ENGINE_CATALOG[name]["capabilities"]


def graph():

    return {
        name: {
            "depends_on": data["depends_on"],
            "capabilities": data["capabilities"],
        }
        for name, data in ENGINE_CATALOG.items()
    }
