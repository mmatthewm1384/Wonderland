#!/usr/bin/env python3
"""Validation tests for SOVEREIGN-001 v0.1.

Requires: python -m pip install jsonschema
Run:      python -m unittest discover -s tests -p 'test_*.py'
"""

import json
import unittest
from datetime import datetime
from pathlib import Path

from jsonschema import Draft202012Validator, FormatChecker, RefResolver


ROOT = Path(__file__).resolve().parents[1]
SCHEMA_DIR = ROOT / "schemas"


def load(name):
    with (SCHEMA_DIR / name).open(encoding="utf-8") as fh:
        return json.load(fh)


def validator(name):
    schema = load(name)
    resolver = RefResolver(
        base_uri=(SCHEMA_DIR.as_uri() + "/"),
        referrer=schema,
    )
    return Draft202012Validator(schema, resolver=resolver, format_checker=FormatChecker())


OBJECT = {
    "object_id": "379-944079",
    "name": "State of Oregon",
    "class": "JURISDICTION",
    "jurisdiction": "Oregon",
}

REGISTRAR_UNESTABLISHED = {
    "registrar_id": None,
    "name": None,
    "status": "UNESTABLISHED",
}

TRANSFER = {
    "transfer_id": "379-944079",
    "object_id": "379-944079",
    "transferor": {
        "identity": "United States of America",
        "legal_capacity": None,
        "authority": None,
        "status": "IDENTIFIED",
    },
    "transferee": {
        "identity": "People's Republic of China",
        "legal_capacity": None,
        "authority": None,
        "status": "IDENTIFIED",
    },
    "transfer_type": "PURCHASE",
    "registrar": REGISTRAR_UNESTABLISHED,
    "register_entry_status": "ENTRY_NOT_FOUND",
    "instrument_status": "NOT_FOUND",
    "authority_status": "UNESTABLISHED",
    "determination": "UNESTABLISHED",
}

SEARCH = {
    "search_id": "search-379-944079-001",
    "object_id": "379-944079",
    "transfer_id": "379-944079",
    "search_parameters": {
        "scope": "register identification and transfer-entry discovery"
    },
    "performed_at": "2026-10-04T20:00:00Z",
    "performed_by": "WONDERLAND.STATESOVEREIGN",
    "records_returned": 0,
    "records_examined": 0,
    "result": "REGISTRAR_NOT_IDENTIFIED",
    "limitations": [
        "No registrar was established by the schema test."
    ],
}


class Sovereign001SchemaTests(unittest.TestCase):
    def assertValid(self, schema_name, instance):
        errors = sorted(validator(schema_name).iter_errors(instance), key=str)
        self.assertEqual([], errors, "\n".join(str(e) for e in errors))

    def assertInvalid(self, schema_name, instance):
        self.assertTrue(
            any(validator(schema_name).iter_errors(instance)),
            "Expected schema validation failure",
        )

    def test_sovereign_object_minimal(self):
        self.assertValid("sovereign-object.schema.json", OBJECT)

    def test_sovereign_object_rejects_implicit_owner(self):
        invalid = dict(OBJECT)
        invalid["owner"] = "Matthew Mahaney"
        self.assertInvalid("sovereign-object.schema.json", invalid)

    def test_registrar_unestablished(self):
        self.assertValid("registrar.schema.json", REGISTRAR_UNESTABLISHED)

    def test_registrar_established_requires_authority(self):
        invalid = {
            "registrar_id": "reg-001",
            "name": "Example Registrar",
            "jurisdiction": "Example",
            "status": "ESTABLISHED",
        }
        self.assertInvalid("registrar.schema.json", invalid)

    def test_transfer_unestablished_is_valid(self):
        self.assertValid("register-of-transfer.schema.json", TRANSFER)

    def test_transfer_rejects_owner_field(self):
        invalid = dict(TRANSFER)
        invalid["owner"] = "Matthew Mahaney"
        self.assertInvalid("register-of-transfer.schema.json", invalid)

    def test_transfer_rejects_unrecognized_transfer_type(self):
        invalid = dict(TRANSFER)
        invalid["transfer_type"] = "OWNERSHIP_CLAIM"
        self.assertInvalid("register-of-transfer.schema.json", invalid)

    def test_transfer_can_record_found_entry(self):
        valid = dict(TRANSFER)
        valid["register_entry_status"] = "ENTRY_FOUND"
        valid["register"] = {
            "register_id": "register-001",
            "name": "Example Register",
            "registrar_id": "registrar-001",
            "jurisdiction": "Example",
            "register_type": "TRANSFER",
            "repository": "example://register",
            "access_method": "public",
        }
        valid["register_entry"] = {
            "entry_id": "entry-001",
            "entry_number": "123",
            "registration_date": "2026-01-01",
            "recorded_parties": ["A", "B"],
            "recorded_object": "379-944079",
            "recorded_instrument": "instrument-001",
            "source": "example://entry",
            "content_hash": "sha256:example",
            "authenticity_status": "VERIFIED",
        }
        self.assertValid("register-of-transfer.schema.json", valid)

    def test_register_search_no_registrar(self):
        self.assertValid("register-search.schema.json", SEARCH)

    def test_register_search_rejects_negative_counts(self):
        invalid = dict(SEARCH)
        invalid["records_returned"] = -1
        self.assertInvalid("register-search.schema.json", invalid)

    def test_register_search_rejects_unknown_result(self):
        invalid = dict(SEARCH)
        invalid["result"] = "NO_OWNER"
        self.assertInvalid("register-search.schema.json", invalid)

    def test_search_timestamp_is_parseable(self):
        datetime.fromisoformat(SEARCH["performed_at"].replace("Z", "+00:00"))


if __name__ == "__main__":
    unittest.main()
