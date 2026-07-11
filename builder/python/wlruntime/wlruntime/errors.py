class RuntimeEngineError(Exception):
    """Base controlled runtime-engine error."""


class RegistryValidationError(RuntimeEngineError):
    """Registry schema or dependency validation failed."""


class LifecycleExecutionError(RuntimeEngineError):
    """Lifecycle operation failed."""


class StateError(RuntimeEngineError):
    """Persistent state operation failed."""
