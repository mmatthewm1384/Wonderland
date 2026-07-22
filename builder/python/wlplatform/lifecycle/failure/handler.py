from pathlib import Path
import json


class LifecycleFailureHandler:


    def __init__(self, evidence_path):

        self.path = Path(
            evidence_path
        )

        self.path.parent.mkdir(
            parents=True,
            exist_ok=True
        )


    def handle(self, failure):

        evidence = failure.evidence()

        records = []

        if self.path.exists():

            records = json.loads(
                self.path.read_text()
            )


        records.append(
            evidence
        )


        self.path.write_text(
            json.dumps(
                records,
                indent=2
            )
        )

        return evidence
