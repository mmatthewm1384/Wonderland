import subprocess


class LimaAdapter:

    def __init__(
        self,
        instance="wonderland-rootless"
    ):
        self.instance = instance


    def _run(self, command, timeout=300):

        try:
            result = subprocess.run(
                command,
                capture_output=True,
                text=True,
                timeout=timeout,
                check=False,
            )

            return {
                "command": command,
                "exit_code": result.returncode,
                "stdout": result.stdout.strip(),
                "stderr": result.stderr.strip(),
            }

        except subprocess.TimeoutExpired:
            return {
                "command": command,
                "exit_code": -1,
                "stdout": "",
                "stderr": "COMMAND TIMEOUT",
            }


    def state(self):

        result = self._run(
            [
                "limactl",
                "list",
                self.instance,
                "--format",
                "{{.Status}}"
            ]
        )

        return result["stdout"]


    def start(self):

        current = self.state()

        if current == "Running":
            return {
                "adapter": "lima",
                "instance": self.instance,
                "action": "already-running",
                "status": "ready",
            }


        return self._run(
            [
                "limactl",
                "start",
                self.instance
            ]
        )


    def stop(self):

        current = self.state()

        if current != "Running":
            return {
                "adapter": "lima",
                "instance": self.instance,
                "action": "already-stopped",
                "status": "ready",
            }


        return self._run(
            [
                "limactl",
                "stop",
                self.instance
            ]
        )


    def status(self):

        return {
            "adapter": "lima",
            "instance": self.instance,
            "state": self.state(),
            "lima": self._run(
                [
                    "limactl",
                    "list",
                    self.instance
                ]
            )
        }


    def nerdctl_status(self):

        return self._run(
            [
                "limactl",
                "shell",
                self.instance,
                "nerdctl",
                "ps"
            ]
        )
