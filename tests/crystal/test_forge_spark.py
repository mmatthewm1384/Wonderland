from pathlib import Path
import sys

import pytest

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))

from scripts.crystal.forge_spark import generate, validate_idea


PROFILE = {
    "identity": {"namespace": "spark"},
    "security": {
        "trust_boundary": "veil.spark",
        "network_default": "deny",
        "encryption_default": "required",
        "least_privilege": "required",
    },
    "experience": {"owner": "spark", "dashboard_integration": "manifest", "ui_namespace": "spark.ui"},
    "lifecycle": {"initial_state": "DRAFT", "terminal_states": ["ARCHIVED", "OBLIVION"]},
    "verification": {"required": ["schema", "identity"]},
}


def test_factory_generates_standard_contract_set():
    idea = {
        "id": "example",
        "name": "Example Spark",
        "class": "intelligence",
        "purpose": "Test the factory.",
    }
    files = generate(idea, PROFILE, "test-v1")
    assert set(files) == {
        "spark.yaml", "identity.yaml", "capabilities.yaml", "policy.yaml",
        "runtime.yaml", "experience.yaml", "lifecycle.yaml", "evidence.yaml",
        "README.md", "tests/contract_test.py", "ui/manifest.yaml",
    }


def test_factory_requires_minimal_idea():
    with pytest.raises(ValueError, match="missing required fields"):
        validate_idea({"id": "example"})


def test_factory_rejects_unsafe_identifier():
    idea = {"id": "../escape", "name": "x", "class": "x", "purpose": "x"}
    with pytest.raises(ValueError, match="id must contain"):
        validate_idea(idea)
