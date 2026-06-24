# Wonderland Language Authority (WLA)

## Purpose

Defines the approved language set for Wonderland and THE∅MATRIX.

This authority exists to reduce long-term maintenance burden, recovery complexity, audit scope, implementation drift, and knowledge fragmentation.

## Scope

Applies to all Wonderland and THE∅MATRIX services, commands, applications, automations, registries, documentation, visual systems, and future implementations.

## Authority Hierarchy

Code: WLA  
Parent: WAT  
Layer: Platform Governance  
Status: Certified  
Version: 1.0  

## Context Model

Languages are operational dependencies.

Every language added to Wonderland increases:

- Installation surface
- Recovery complexity
- Debugging complexity
- Toolchain drift
- Documentation burden
- Security review scope

New languages require documented architectural justification.

## Approved Language Set

| Layer | Language | Use |
|---|---|---|
| CLI / install / repair | Bash | `wl-*` commands, bootstrap, shell automation |
| Structured automation | Python | audits, registries, reports, JSON processing |
| Native macOS apps | Swift / SwiftUI | menu bar apps, native interfaces, visual tools |
| Cross-platform visual apps | TypeScript | Tauri UI, web dashboards, simulations |
| Runtime services | Python or Go | APIs, workers, daemons |
| Machine-readable data | JSON | registries, metadata, intents, status |
| Documentation / canon | Markdown | Obsidian, governance, handoffs, runbooks |
| Styling / themes | CSS | palettes, dashboards, visual systems |
| Containers | Dockerfile / Compose | container build and service orchestration |

## Default Decision Matrix

```text
Need a command?
    Bash

Need automation?
    Python

Need a macOS app?
    Swift / SwiftUI

Need a visual cross-platform app?
    TypeScript + Tauri

Need a long-running service?
    Python or Go

Need persistence?
    JSON

Need documentation?
    Markdown

Need styling?
    CSS

Wonderland Rule
Bash starts it.
Python understands it.
JSON records it.
Markdown explains it.
Swift presents it.
TypeScript visualizes it.
Docker contains it.
THE∅MATRIX Rule
Python models behavior.
JSON preserves canon.
TypeScript renders systems.
Swift makes native presence.
Markdown preserves mythology.
Disallowed by Default

These languages are not forbidden, but they require explicit justification:

Ruby
Perl
PHP
Java
C#
Lua
Rust
Kotlin
Elixir
Excessive YAML logic
Inputs and Applicability

This authority applies when creating:

New wl-* commands
New automation scripts
New services
New visual apps
New native apps
New registries
New documentation
New runtime components
Required Artifacts

This authority controls:

language policy
language registry
toolchain standards
runtime language choices
implementation review records
Verification
wl-language verify
wl-authorities context
Recovery

Restore this authority from the latest governance backup.

cp -R ~/Wonderland/backups/language-authority-*/authorities/platform/wla.md \
  ~/Wonderland/vault/09-Governance/authorities/platform/wla.md

wl-language verify
Rollback

Rollback is required when the approved language set is changed without justification or a toolchain becomes unrecoverable.

cp -R ~/Wonderland/backups/language-authority-*/authorities \
  ~/Wonderland/vault/09-Governance/

wl-authorities context
Certification
PASS approved-language-set
PASS decision-matrix
PASS drift-control
PASS recovery
PASS rollback
PASS authority-context

RESULT PASS
Machine-Readable Status
authority:
  code: WLA
  parent: WAT
  layer: Platform Governance
  version: "1.0"
  status: certified
  result: PASS

RESULT PASS

## Verification

Verification command:

```bash
wl-language verify
wl-authorities context
Expected result:

PASS WLA-document
PASS language-registry
PASS registry-json
RESULT PASS
Recovery

Recovery restores the Wonderland Language Authority and its registry from the latest governance backup.

Procedure:

cp -R ~/Wonderland/backups/language-authority-*/authorities/platform/wla.md \
  ~/Wonderland/vault/09-Governance/authorities/platform/wla.md

cp -R ~/Wonderland/backups/language-authority-*/authorities/registry/language-registry.json \
  ~/Wonderland/vault/09-Governance/authorities/registry/language-registry.json

wl-language verify
wl-authorities context
Rollback

Rollback is required when the approved language set changes without justification, when a new language enters the system without registry approval, or when the language registry becomes invalid.

Procedure:

cp -R ~/Wonderland/backups/wla-section-repair-*/wla.md.bak \
  ~/Wonderland/vault/09-Governance/authorities/platform/wla.md

wl-language verify
wl-authorities context
Certification

Certification requirements:

PASS approved-language-set
PASS decision-matrix
PASS drift-control
PASS language-registry
PASS verification
PASS recovery
PASS rollback
PASS authority-context

RESULT PASS


## Recovery

Recovery restores the Wonderland Language Authority and its language registry from the latest governance backup.

Procedure:

```bash
cp ~/Wonderland/backups/language-authority-*/authorities/platform/wla.md \
  ~/Wonderland/vault/09-Governance/authorities/platform/wla.md

cp ~/Wonderland/backups/language-authority-*/authorities/registry/language-registry.json \
  ~/Wonderland/vault/09-Governance/authorities/registry/language-registry.json

wl-language verify
wl-authorities context

Recovery is successful only when both language verification and authority context verification return RESULT PASS.

Rollback

Rollback is required when:

An unauthorized language enters Wonderland
The approved language set changes without justification
The language registry becomes invalid
A toolchain becomes unrecoverable

Procedure:

cp ~/Wonderland/backups/wla-section-repair-*/wla.md.bak \
  ~/Wonderland/vault/09-Governance/authorities/platform/wla.md

wl-language verify
wl-authorities context

Rollback must restore the previous certified language policy.

Certification

Certification requirements:

PASS approved-language-set
PASS decision-matrix
PASS language-registry
PASS drift-control
PASS verification
PASS recovery
PASS rollback
PASS authority-context

RESULT PASS

WLA is certified only when the language policy, registry, recovery procedure, rollback procedure, and authority context audit all pass.


## Rollback

Rollback is required when language governance drifts from the approved registry.

Rollback Procedure:

```bash
cp ~/Wonderland/backups/wla-section-repair-*/wla.md.bak \
  ~/Wonderland/vault/09-Governance/authorities/platform/wla.md

wl-language verify
wl-authorities context

Rollback restores the previous certified WLA document and language registry.

Certification

Certification requirements:

PASS approved-language-set
PASS decision-matrix
PASS language-registry
PASS drift-control
PASS verification
PASS recovery
PASS rollback
PASS authority-context

RESULT PASS

WLA certification requires verified language policy, registry integrity, recovery, rollback, and authority context.


## Certification

WLA is certified when the approved language set, language registry, recovery procedure, rollback procedure, and authority context audit all pass.

```text
PASS approved-language-set
PASS language-registry
PASS recovery
PASS rollback
PASS authority-context

RESULT PASS

