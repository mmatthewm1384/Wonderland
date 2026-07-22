from pathlib import Path
import json
from datetime import datetime, timezone


class CapabilityLifecycleError(Exception):
    pass



class CapabilityLifecycleController:


    STATES = {
        "REGISTERED",
        "ENABLED",
        "DISABLED",
        "UPGRADING",
        "RETIRED"
    }


    def __init__(self, state_file):

        self.state_file = Path(state_file)

        self.state_file.parent.mkdir(
            parents=True,
            exist_ok=True
        )

        if not self.state_file.exists():
            self.state_file.write_text(
                json.dumps(
                    {
                        "capabilities": {}
                    },
                    indent=2
                )
            )


    def load(self):

        return json.loads(
            self.state_file.read_text()
        )


    def save(self, data):

        self.state_file.write_text(
            json.dumps(
                data,
                indent=2
            )
        )


    def register(
        self,
        name,
        version
    ):

        data = self.load()

        data["capabilities"][name] = {
            "version": version,
            "state": "REGISTERED",
            "updated":
                datetime.now(timezone.utc)
                .isoformat()
        }

        self.save(data)

        return data["capabilities"][name]


    def transition(
        self,
        name,
        target
    ):

        if target not in self.STATES:
            raise CapabilityLifecycleError(
                f"Unknown state {target}"
            )


        data = self.load()


        if name not in data["capabilities"]:
            raise CapabilityLifecycleError(
                f"Unknown capability {name}"
            )


        data["capabilities"][name]["state"] = target

        data["capabilities"][name]["updated"] = (
            datetime.now(timezone.utc)
            .isoformat()
        )


        self.save(data)

        return data["capabilities"][name]
