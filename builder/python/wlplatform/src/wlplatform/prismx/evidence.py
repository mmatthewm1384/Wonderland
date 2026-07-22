"""
PRISMX Evidence Records
"""


from datetime import datetime


def create_evidence(
    component,
    status
):

    return {
        "component": component,
        "status": status,
        "timestamp":
            datetime.utcnow().isoformat()
    }
