# SOVEREIGN-001 v0.1 schema tests

Dependency: Python package jsonschema.

Run from the SOVEREIGN-001 v0.1 directory:

    python3 -m pip install jsonschema
    python3 -m unittest discover -s tests -p 'test_*.py' -v

Invariants tested:

- A sovereign object cannot acquire an implicit owner field.
- A transfer record cannot acquire an implicit owner field.
- An unestablished registrar is representable without inventing an authority.
- An established registrar requires an authority source.
- An unestablished transfer is a valid registry state.
- A found transfer entry can be represented separately from the transfer proposition.
- Search results are enumerated and cannot silently become arbitrary claims.
- Negative record counts are rejected.
