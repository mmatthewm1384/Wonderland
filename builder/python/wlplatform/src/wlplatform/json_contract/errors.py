class JsonArtifactError(Exception):
    """Base JSON artifact validation error."""
    pass


class JsonSyntaxError(JsonArtifactError):
    pass


class JsonSchemaError(JsonArtifactError):
    pass


class JsonSemanticError(JsonArtifactError):
    pass
