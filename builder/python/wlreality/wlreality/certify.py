def certify(model):

    checks = {
        "name": bool(model.name),
        "nodes": bool(model.nodes),
        "relations": bool(model.relations)
    }

    return {
        "status":
            "PASS"
            if all(checks.values())
            else "FAIL",
        "checks": checks
    }
