import json

from wlplatform.ecology.controller import EcologyController


_controller = EcologyController()


def handle(args):

    if not args or args[0] != "ecology":
        return False

    action = args[1] if len(args) > 1 else "status"

    if action == "status":
        result = _controller.status()

    else:
        states = {
            "rest": "RESTING",
            "dream": "DREAM",
            "sanctuary": "SANCTUARY",
        }

        if action not in states:
            raise RuntimeError(
                f"Unknown ecology command: {action}"
            )

        result = _controller.transition(
            states[action]
        )

    print(json.dumps(result, indent=2))

    return True


# WONDERLAND_PATH_GUARD

from pathlib import Path


def validate_runtime_ecology_router():

    path = Path(__file__)

    if not path.exists():
        raise RuntimeError(
            "Runtime ecology router missing"
        )

    return {
        "component": "runtime-ecology-router",
        "validated": True,
        "path": str(path)
    }

