"""
Organizer Engine Certification Adapter
"""

from pathlib import Path


class OrganizerCertificationAdapter:
    name = "organizer"

    required_capabilities = [
        "organizer.scan",
        "organizer.index",
        "organizer.classify",
        "organizer.relate",
        "organizer.verify",
    ]

    def certify(self, engine):

        failures = []

        if engine.name != self.name:
            failures.append("engine_name")

        for capability in self.required_capabilities:
            if capability not in engine.capabilities:
                failures.append(capability)

        return {
            "engine": self.name,
            "certified": len(failures) == 0,
            "failures": failures,
        }
