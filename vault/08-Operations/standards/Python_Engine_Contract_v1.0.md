# Wonderland Python Engine Contract v1.0

Status: Ratified

## Purpose

Defines the minimum requirements for all Wonderland Python engines.

Every engine must be:

- importable
- testable
- discoverable
- certifiable
- reproducible
- maintainable

---

# Package Contract

All engines must exist inside:


builder/python/wlplatform/<engine>


Required structure:


<engine>/

├── init.py
├── implementation modules
├── tests/
└── documentation references


---

# Import Contract

Engines must be imported through the Wonderland package namespace.

Required:


from wlplatform.<engine> import ...


Forbidden:


sys.path.append(...)
temporary import hacks
direct file execution


---

# Test Discovery Contract

All engines must support:


pytest


from the Wonderland root.

Required:


pytest.ini


must expose:


builder/python


as the Python package root.

---

# Artifact Safety Contract

JSON artifacts are data.

Required flow:


JSON artifact
|
v
json.load()
|
v
validation
|
v
engine consumption


Forbidden:


python3 artifact.json


---

# Engine Lifecycle Contract

Every engine must support:


create
validate
execute
verify
certify
recover


---

# Certification Contract

Engine certification requires:

- package discovery PASS
- import verification PASS
- test suite PASS
- artifact validation PASS
- evidence generation PASS

---

# Recovery Contract

State-changing operations require:

- transaction ID
- staging area
- checkpoint
- validation
- atomic replacement
- verification
- rollback capability

---

# Governance Rule

No Wonderland engine may bypass shared platform contracts.

Shared infrastructure owns:

- package discovery
- validation
- certification
- evidence generation
- recovery safety
