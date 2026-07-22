"""
Certification Policy Engine

Evaluates certification state against
versioned policy definitions.
"""

import json
from pathlib import Path


class CertificationPolicy:


    def __init__(self, policy):

        self.policy = policy



    @classmethod
    def load(cls, path):

        data = json.loads(
            Path(path).read_text()
        )

        return cls(data)



    def requirements(self):

        return self.policy.get(
            "requirements",
            []
        )



    def evaluate(self, evidence):

        results = []

        for requirement in self.requirements():

            requirement_type = (
                requirement["type"]
            )

            passed = (
                requirement_type
                in evidence
            )

            results.append(
                {
                    "id":
                        requirement["id"],

                    "passed":
                        passed
                }
            )


        certified = all(
            item["passed"]
            for item in results
        )


        return {

            "status":
                "CERTIFIED"
                if certified
                else "FAILED",

            "checks":
                results
        }
