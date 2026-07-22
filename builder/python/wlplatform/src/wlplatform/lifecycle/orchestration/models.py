from dataclasses import dataclass, asdict
from datetime import datetime, timezone
import uuid


@dataclass
class WorkflowContext:

    workflow_id: str

    status: str

    stages: list


    def export(self):

        return {

            **asdict(self),

            "timestamp":
                datetime.now(
                    timezone.utc
                ).isoformat()

        }


def create_context():

    return WorkflowContext(

        workflow_id=str(
            uuid.uuid4()
        ),

        status="INITIALIZED",

        stages=[]

    )
