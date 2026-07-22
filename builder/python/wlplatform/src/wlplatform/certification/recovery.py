"""
Certification Recovery Engine

Diagnoses certification failures and
creates recovery actions.
"""

from dataclasses import dataclass
from datetime import datetime, timezone



@dataclass
class RecoveryAction:

    failure: str

    component: str

    action: str

    status: str = "PENDING"



class CertificationRecovery:


    def diagnose(
        self,
        result
    ):

        if not result:

            return RecoveryAction(
                failure="UNKNOWN",
                component="unknown",
                action="INSPECT_STATE"
            )


        if result.get(
            "status"
        ) == "FAILED":


            checks = result.get(
                "checks",
                []
            )


            for check in checks:

                if not check["passed"]:

                    return RecoveryAction(

                        failure=
                            check["id"],

                        component=
                            check["id"],

                        action=
                            self.remediation(
                                check["id"]
                            )
                    )


        return RecoveryAction(
            failure="NONE",
            component="system",
            action="NO_ACTION",
            status="COMPLETE"
        )



    def remediation(
        self,
        failure
    ):

        actions = {

            "evidence-present":
                "REGENERATE_EVIDENCE",

            "digest-valid":
                "REBUILD_DIGEST",

            "lineage-present":
                "REBUILD_LINEAGE"
        }


        return actions.get(
            failure,
            "INSPECT_STATE"
        )



    def recover(
        self,
        action
    ):

        return {

            "failure":
                action.failure,

            "action":
                action.action,

            "status":
                "READY",

            "timestamp":
                datetime.now(
                    timezone.utc
                ).isoformat()
        }
