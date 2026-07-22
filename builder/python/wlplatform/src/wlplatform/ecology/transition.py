ALLOWED_TRANSITIONS = {
    "ACTIVE": [
        "FLOW",
        "RESTING",
        "SANCTUARY",
    ],
    "FLOW": [
        "ACTIVE",
        "RESTING",
    ],
    "RESTING": [
        "ACTIVE",
        "DREAM",
        "SANCTUARY",
    ],
    "DREAM": [
        "ACTIVE",
        "SANCTUARY",
    ],
    "SANCTUARY": [
        "ACTIVE",
    ],
}
