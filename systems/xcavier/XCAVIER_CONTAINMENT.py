import sys
from importlib.util import module_from_spec, spec_from_file_location
from pathlib import Path

_CONTAINMENT_DIR = Path(__file__).resolve().parent / "XCAVIER-CONTAINMENT-v1"
_VALIDATOR_PATH = _CONTAINMENT_DIR / "validator.py"

if not _VALIDATOR_PATH.is_file():
    raise ImportError(f"XCAVIER containment validator not found: {_VALIDATOR_PATH}")

# validator.py imports transition_policy, so make its directory importable.
_containment_path = str(_CONTAINMENT_DIR)
if _containment_path not in sys.path:
    sys.path.insert(0, _containment_path)

_spec = spec_from_file_location("xcavier_containment", _VALIDATOR_PATH)

if _spec is None or _spec.loader is None:
    raise ImportError(f"Unable to load XCAVIER validator: {_VALIDATOR_PATH}")

_module = module_from_spec(_spec)

# Register before execution; required for dataclass module resolution.
sys.modules[_spec.name] = _module
_spec.loader.exec_module(_module)

# Canonical public exports.
validate_action = _module.validate_action
validate_transition = _module.validate_transition

ValidationResult = _module.ValidationResult
TransitionResult = _module.TransitionResult
AUTHORIZATION_REQUIRED_TRANSITIONS = _module.AUTHORIZATION_REQUIRED_TRANSITIONS
