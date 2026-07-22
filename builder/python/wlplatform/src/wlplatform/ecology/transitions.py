TRANSITIONS = {

    "ACTIVE": [
        "FLOW",
        "RESTING",
        "SANCTUARY"
    ],

    "FLOW": [
        "ACTIVE",
        "RESTING"
    ],

    "RESTING": [
        "ACTIVE",
        "DREAM",
        "SANCTUARY"
    ],

    "DREAM": [
        "ACTIVE",
        "RESTING"
    ],

    "SANCTUARY": [
        "RESTING",
        "ACTIVE"
    ]
}
