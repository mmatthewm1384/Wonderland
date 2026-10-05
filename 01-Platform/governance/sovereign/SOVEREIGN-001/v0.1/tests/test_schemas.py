import json
from pathlib import Path
import unittest

from jsonschema import Draft202012Validator, FormatChecker, RefResolver

ROOT = Path(__file__).resolve().parents[1]
SCHEMA_DIR = ROOT / "schemas"


def load_schema(name):
    path = SCHEMA_DIR / name
    schema = json.loads(path.read_text())
    resolver = RefResolver(path.as_uri(), schema)
    return Draft202012Validator(schema, resolver=resolver, format_checker=FormatChecker())


OBJECT = {
    "object_id": "379-944079",
    "name": "State of Oregon",
    "class": "JURISDICTION",
}

REGISTRAR_UNESTABLISHED = {"status": "UNESTABLISHED"}

TRANSFER = {
    "transfer_id": "379-944079",
    "object_id": "379-944079",
    "transferor": {"identity": "United States of America"},
    "transferee": {"identity": "People's Republic of China"},
    "transfer_type": "PURCHASE",
    "status": "CLAIMED",
}

SEARCH = {
    "search_id": "search-379-944079-001",
    "object_id": "379-944079",
    "transfer_id": "379-944079",
    "repositories": ["https://example.invalid/register"],
    "search_terms": ["379-944079", "State of Oregon"],
    "search_parameters": {"scope": "transfer-register", "exact_match": True},
    "performed_at": "2026-10-04T00:00:00Z",
    "performed_by": "WONDERLAND.STATESOVEREIGN",
    "result": "REGISTRAR_NOT_IDENTIFIED",
}


class SchemaTests(unittest.TestCase):
    def assertValid(self, schema_name, instance):
        errors = list(load_schema(schema_name).iter_errors(instance))
        self.assertEqual([], errors, "\\n".join(e.message for e in errors))

    def assertInvalid(self, schema_name, instance):
        self.assertFalse(load_schema(schema_name).is_valid(instance), instance)

    def test_sovereign_object_minimal(self):
        self.assertValid("sovereign-object.schema.json", OBJECT)

    def test_sovereign_object_rejects_owner_field(self):
        invalid = dict(OBJECT)
        invalid["owner"] = "someone"
        self.assertInvalid("sovereign-object.schema.json", invalid)

    def test_sovereign_object_rejects_unknown_class(self):
        invalid = dict(OBJECT)
        invalid["class"] = "OWNER"
        self.assertInvalid("sovereign-object.schema.json", invalid)

    def test_registrar_unestablished(self):
        self.assertValid("registrar.schema.json", REGISTRAR_UNESTABLISHED)

    def test_registrar_established_requires_authority_source(self):
        invalid = {"status": "ESTABLISHED", "registrar_id": "r1", "name": "Registrar"}
        self.assertInvalid("registrar.schema.json", invalid)

    def test_registrar_unestablished_cannot_invent_registrar_id(self):
        invalid = {"status": "UNESTABLISHED", "registrar_id": "invented"}
        self.assertInvalid("registrar.schema.json", invalid)

    def test_transfer_proposition(self):
        self.assertValid("register-of-transfer.schema.json", TRANSFER)

    def test_transfer_requires_distinct_party_fields(self):
        invalid = dict(TRANSFER)
        invalid.pop("transferee")
        self.assertInvalid("register-of-transfer.schema.json", invalid)

    def test_transfer_rejects_unknown_transfer_type(self):
        invalid = dict(TRANSFER)
        invalid["transfer_type"] = "THEFT_OF_SOVEREIGNTY"
        self.assertInvalid("register-of-transfer.schema.json", invalid)

    def test_transfer_entry_found_requires_entry(self):
        invalid = dict(TRANSFER)
        invalid["register_entry"] = {"status": "FOUND"}
        self.assertInvalid("register-of-transfer.schema.json", invalid)

    def test_transfer_entry_not_found_cannot_contain_entry(self):
        invalid = dict(TRANSFER)
        invalid["register_entry"] = {
            "status": "NOT_FOUND",
            "entry": {"entry_id": "e1", "register_id": "r1"},
        }
        self.assertInvalid("register-of-transfer.schema.json", invalid)

    def test_registration_not_found_requires_negative_entry_state(self):
        invalid = dict(TRANSFER)
        invalid["status"] = "REGISTRATION_NOT_FOUND"
        invalid["register_entry"] = {"status": "FOUND", "entry": {"entry_id": "e1", "register_id": "r1"}}
        self.assertInvalid("register-of-transfer.schema.json", invalid)

    def test_established_transfer_requires_evidentiary_chain(self):
        invalid = dict(TRANSFER)
        invalid["status"] = "ESTABLISHED_TRANSFER"
        self.assertInvalid("register-of-transfer.schema.json", invalid)

    def test_established_transfer_can_be_valid(self):
        valid = dict(TRANSFER)
        valid.update({
            "status": "ESTABLISHED_TRANSFER",
            "instrument": {"instrument_id": "i1", "status": "IDENTIFIED"},
            "authority": {"verification_status": "VERIFIED"},
            "execution": {},
            "effective_date": {"date": "1859-02-14", "date_type": "EFFECTIVE_DATE"},
            "registrar": {"status": "ESTABLISHED", "registrar_id": "r1", "name": "Registrar", "authority_source": "authority-1"},
            "register": {"register_id": "reg1", "status": "REGISTER_IDENTIFIED"},
            "register_entry": {"status": "FOUND", "entry": {"entry_id": "e1", "register_id": "reg1"}},
            "evidence_root": "evidence-root-1",
            "determination": {"status": "ESTABLISHED", "proposition": "transfer", "methodology": "documented verification"},
        })
        self.assertValid("register-of-transfer.schema.json", valid)

    def test_register_search_not_found_is_valid(self):
        self.assertValid("register-search.schema.json", SEARCH)

    def test_register_search_rejects_negative_counts(self):
        invalid = dict(SEARCH)
        invalid["records_returned"] = -1
        self.assertInvalid("register-search.schema.json", invalid)

    def test_register_search_result_is_canonical(self):
        invalid = dict(SEARCH)
        invalid["result"] = "TRANSFER_DID_NOT_HAPPEN"
        self.assertInvalid("register-search.schema.json", invalid)

    def test_register_search_requires_reproducible_inputs(self):
        invalid = dict(SEARCH)
        invalid.pop("search_terms")
        self.assertInvalid("register-search.schema.json", invalid)

    def test_hash_must_be_sha256_hex(self):
        evidence = {
            "evidence_id": "ev1",
            "type": "document",
            "source": "test",
            "content_hash": "not-a-sha256",
            "provenance": {
                "obtained_by": "tester",
                "obtained_at": "2026-10-04T00:00:00Z",
                "method": "test",
                "modified": False,
            },
            "integrity": "verified",
        }
        invalid = dict(SEARCH)
        invalid["evidence"] = [evidence]
        self.assertInvalid("register-search.schema.json", invalid)


class StateMachineTests(unittest.TestCase):
    TRANSITIONS = {
        "CLAIMED": {"OBJECT_IDENTIFIED"},
        "OBJECT_IDENTIFIED": {"PARTIES_IDENTIFIED"},
        "PARTIES_IDENTIFIED": {"INSTRUMENT_IDENTIFIED"},
        "INSTRUMENT_IDENTIFIED": {"AUTHORITY_IDENTIFIED"},
        "AUTHORITY_IDENTIFIED": {"EXECUTION_VERIFIED"},
        "EXECUTION_VERIFIED": {"EFFECTIVE_EVENT_VERIFIED"},
        "EFFECTIVE_EVENT_VERIFIED": {"REGISTRATION_LOCATED"},
        "REGISTRATION_LOCATED": {"REGISTRATION_VERIFIED", "REGISTRATION_NOT_FOUND"},
        "REGISTRATION_VERIFIED": {"ESTABLISHED_TRANSFER"},
    }

    TERMINAL = {
        "ESTABLISHED_TRANSFER",
        "UNESTABLISHED_TRANSFER",
        "NO_REGISTERED_TRANSFER",
        "NO_REGISTER_ENTRY_FOUND",
        "REGISTRAR_UNESTABLISHED",
        "INSTRUMENT_NOT_FOUND",
        "AUTHORITY_UNESTABLISHED",
        "PARTY_UNESTABLISHED",
        "EVIDENCE_INSUFFICIENT",
        "CONFLICTING_EVIDENCE",
    }

    def test_canonical_positive_chain(self):
        chain = [
            "CLAIMED", "OBJECT_IDENTIFIED", "PARTIES_IDENTIFIED", "INSTRUMENT_IDENTIFIED",
            "AUTHORITY_IDENTIFIED", "EXECUTION_VERIFIED", "EFFECTIVE_EVENT_VERIFIED",
            "REGISTRATION_LOCATED", "REGISTRATION_VERIFIED", "ESTABLISHED_TRANSFER",
        ]
        for current, nxt in zip(chain, chain[1:]):
            self.assertIn(nxt, self.TRANSITIONS.get(current, {nxt}))

    def test_negative_branch_remains_explicit(self):
        self.assertIn("REGISTRATION_NOT_FOUND", self.TRANSITIONS["REGISTRATION_LOCATED"])
        self.assertIn("UNESTABLISHED_TRANSFER", self.TERMINAL)

    def test_no_owner_is_not_a_transfer_state(self):
        self.assertNotIn("NO_OWNER", self.TERMINAL)
        self.assertNotIn("NO_OWNER", self.TRANSITIONS)


if __name__ == "__main__":
    unittest.main()
