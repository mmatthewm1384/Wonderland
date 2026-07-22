import json

from wlplatform.ecology.controller import EcologyController


controller = EcologyController()


def run(command):

    commands = {
        "ecology": status,
        "rest": lambda: transition("RESTING"),
        "dream": lambda: transition("DREAM"),
        "sanctuary": lambda: transition("SANCTUARY"),
    }

    if command not in commands:
        raise RuntimeError(
            f"Unknown ecology command: {command}"
        )

    return commands[command]()


def transition(target):

    result = controller.transition(target)

    print(json.dumps(
        result,
        indent=2
    ))


def status():

    print(json.dumps(
        controller.status(),
        indent=2
    ))
