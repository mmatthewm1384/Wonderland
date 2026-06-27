from __future__ import annotations


class DeployEngine:
    def deploy(self, desired_state: dict) -> dict:
        return {
            "status": "noop",
            "detail": "Controller v2 deploy engine installed; compose migration remains compatibility-backed.",
            "desired_state_present": bool(desired_state),
        }
