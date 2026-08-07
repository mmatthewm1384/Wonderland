class GenesisValidator:


    COMMANDS = {
        "crystal": [
            "status"
        ],
        "spark": [
            "status"
        ],
        "verify": []
    }


    def validate(self, command, action=None):

        if command not in self.COMMANDS:
            raise ValueError(
                f"Unknown command: {command}"
            )

        if action and action not in self.COMMANDS[command]:
            raise ValueError(
                f"Unknown action: {action}"
            )

        return True
