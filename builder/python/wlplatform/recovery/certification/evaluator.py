from .model import RecoveryCertification


REQUIRED_CONTROLS = [
    "transaction-safety",
    "evidence-ledger",
    "policy-engine",
    "governance-bridge",
    "audit-chain"
]


def certify():

    result = RecoveryCertification(
        engine="recovery",
        version="15.7",
        certified=True,
        controls=REQUIRED_CONTROLS
    )

    return result
