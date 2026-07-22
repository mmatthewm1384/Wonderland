from .errors import JsonSchemaError, JsonSemanticError


def validate_required_fields(data, fields):
    missing = [
        field for field in fields
        if field not in data
    ]

    if missing:
        raise JsonSchemaError(
            f"Missing required fields: {missing}"
        )


def validate_certification(data):
    validate_required_fields(
        data,
        [
            "certified",
            "engine"
        ]
    )

    if data["certified"] is True:
        return True

    raise JsonSemanticError(
        "Certification artifact is not trusted"
    )
