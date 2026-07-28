#!/usr/bin/env python3

import os
import sys
from pathlib import Path


###############################################################################
# Bootstrap runtime path
###############################################################################

WL_ROOT = os.environ.get("WL_ROOT")

if not WL_ROOT:
    raise RuntimeError(
        "WL_ROOT is required"
    )


SOURCE_ROOT = (
    Path(WL_ROOT) /
    "builder/python/wlplatform/src"
)


if not SOURCE_ROOT.exists():
    raise RuntimeError(
        f"Invalid wlplatform source root: {SOURCE_ROOT}"
    )


sys.path.insert(
    0,
    str(SOURCE_ROOT)
)


###############################################################################
# Imports after bootstrap
###############################################################################

from wlplatform.runtime.context import get_context
from wlplatform.registry.registry_command import execute as registry_execute
from wlplatform.lifecycle_command import execute as lifecycle_execute


###############################################################################
# Dispatcher
###############################################################################


LIFECYCLE_COMMANDS = {
    "start",
    "stop",
    "restart",
    "sleep",
    "wake",
    "status",
}


def dispatch(args):

    context = get_context()


    if len(args) < 1:
        raise SystemExit(
            "usage: wl <service> <command> [args]"
        )


    service = args[0]


    # PLATFORM LIFECYCLE COMMANDS
    if service in (
        "start",
        "stop",
        "restart",
        "sleep",
        "wake",
        "status",
    ):

        from wlplatform.services.platform_service import PlatformService

        platform = PlatformService(
            context.root
        )

        handler = getattr(
            platform,
            service
        )

        return handler()


    if service == "registry":

        if len(args) < 2:
            raise SystemExit(
                "usage: wl registry <command> [package]"
            )


        package = (
            args[2]
            if len(args) > 2
            else None
        )


        return registry_execute(
            context.root,
            args[1],
            package,
        )


    raise SystemExit(
        f"unsupported service: {service}"
    )


def main():

    result = dispatch(
        sys.argv[1:]
    )

    print(result)


if __name__ == "__main__":
    main()
