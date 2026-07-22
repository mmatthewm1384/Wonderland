from __future__ import annotations


ENGINE_CATALOG = {

    "architecture": {
        "class": "ArchitectureEngine",
        "module": ".",
        "capabilities": [
            "architecture.verify",
            "graph.analysis",
        ],
        "depends_on": [],
    },

    "builder": {
        "class": "BuilderEngine",
        "module": ".",
        "capabilities": [
            "image.build",
            "artifact.create",
        ],
        "depends_on": [
            "architecture",
        ],
    },

    "governance": {
        "class": "GovernanceEngine",
        "module": ".",
        "capabilities": [
            "policy.validation",
            "compliance.verify",
        ],
        "depends_on": [
            "architecture",
        ],
    },

    "mirror": {
        "class": "MirrorEngine",
        "module": ".",
        "capabilities": [
            "snapshot",
            "restore",
        ],
        "depends_on": [
            "registry",
        ],
    },

    "academy": {
        "class": "AcademyEngine",
        "module": ".",
        "capabilities": [
            "learning",
            "documentation",
        ],
        "depends_on": [
            "registry",
        ],
    },

    "registry": {
        "class": "RegistryEngine",
        "module": ".registry",
        "capabilities": [
            "engine.discovery",
            "capability.discovery",
            "dependency.graph",
        ],
        "depends_on": [
            "architecture",
        ],
    },


    "repository": {
        "class": "RepositoryEngine",
        "module": ".",
        "capabilities": [
            "repository.verify",
            "repository.health",
        ],
        "depends_on": [
            "registry",
        ],
    },

    "runtime": {
        "class": "RuntimeEngine",
        "module": ".",
        "capabilities": [
            "runtime.verify",
            "runtime.lifecycle",
        ],
        "depends_on": [
            "registry",
        ],
    },

    "organizer": {
           "name": "organizer",
           "version": "1.0.0",
           "type": "engine",
           "module": ".organizer",
           "class": "OrganizerEngine",
           "capabilities": [
               "organizer.scan",
               "organizer.index",
               "organizer.classify",
               "organizer.relate",
               "organizer.verify"
           ]
       },   
}
