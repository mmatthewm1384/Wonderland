COMMANDS = {

    "start": "start",

    "stop": "stop",

    "restart": "restart",

    "sleep": "sleep",

    "wake": "wake",

    "status": "verify_health"

}


def resolve(command):

    return COMMANDS.get(command)
