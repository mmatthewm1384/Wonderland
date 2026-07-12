# Platform Convergence 2.0

## Purpose

Platform Convergence 2.0 makes the Registry Engine the authoritative source of truth for Wonderland.

The goal is to stop duplicated classification logic and make every platform subsystem consume the same architectural model.

## Core Idea

```text
Registry Engine
  ├── Domains
  ├── Capabilities
  ├── Components
  ├── Implementations
  ├── Artifacts
  └── Ownership
Everything else asks the Registry Engine.

Why This Exists

Wonderland had too many overlapping scripts and scanners. Multiple systems tried to classify the same files, commands, registries, and runtime areas differently.

Convergence 2.0 fixes that by enforcing:

one source of truth
one capability owner
one architecture model
one path classifier
one purge policy
one teachable explanation
Current Domains

- `doctrine` — Wonderland Doctrine
- `cli` — CLI Engine
- `academy` — Wonderland Academy
- `architecture` — Architecture Engine
- `builder` — Builder Engine
- `applications` — Application Layer
- `infrastructure` — Infrastructure Engine
- `runtime` — Runtime Engine
- `knowledge` — Knowledge Engine
- `operations` — Operations Engine
- `security` — Security Engine
- `configuration` — Configuration Engine
- `design` — Design System
- `legacy` — Legacy Archive
- `os` — Wonderland OS
- `development` — Development Tooling
- `registry` — Registry Engine
- `local-state` — Operations Engine
- `source` — Source Workspace
- `ci` — Development Tooling
- `experiments` — Legacy Archive
- `legacy-scripts` — Legacy Archive
- `legacy-root-artifacts` — Legacy Archive
- `verification` — Verification Engine
- `local-development` — Development Tooling


Current Capabilities

- `platform.direction` — Define the permanent mission, principles, and implementation direction.
- `academy.understanding` — Teach every capability so the operator and future learners can understand and explain it.
- `security.defensive-lab` — Provide safe isolated environments for authorized defensive testing and learning.
- `os.reference.bookworm` — Provide reproducible Linux runtime, certification baseline, Academy labs, and future OS packaging base.
- `platform.convergence` — Inventory, consolidate, archive, and purge excess after certified replacements exist.
- `cli.dispatch` — Provide the single Wonderland operator interface.
- `platform.capability-registry` — Maintain authoritative capability ownership.
- `platform.architecture` — Model Wonderland domains, capabilities, components, implementations, and ownership.
- `runtime.lifecycle` — Start, stop, verify, and supervise runtime services.
- `operations.state` — Persist operational state, evidence, inventory, ownership, and certification records.
- `security.defensive` — Teach and enforce defensive security, privacy, hardening, and authorized testing principles.
- `builder.pipeline` — Build, package, and verify Wonderland runtime artifacts.
- `applications.consumer` — Provide user-facing applications that consume platform engines.
- `infrastructure.runtime` — Provide rootless infrastructure foundations for Wonderland.
- `configuration.policy` — Own configuration schemas, profiles, and policy settings.
- `design.assets` — Own visual assets and shared design language.
- `knowledge.documentation` — Generate and maintain Wonderland documentation and project knowledge.
- `legacy.review` — Preserve and classify legacy material before archive or purge.
- `artifact.backup` — Classify backup artifacts as archive candidates with purge blocked.
- `artifact.temporary` — Classify temporary artifacts as removal candidates only after certification.
- `artifact.build` — Classify generated build outputs.
- `artifact.quarantine` — Classify quarantined items for manual review.
- `verification.tests` — Own test suites and verification checks for Wonderland capabilities.


Current Components

- `cli.dispatch` — Provide the single Wonderland operator interface.
- `capability.registry` — Maintain the authoritative capability registry.
- `architecture.graph` — Model domains, capabilities, components, implementations, and ownership.
- `academy.curriculum` — Teach Wonderland concepts and platform internals.
- `academy.security-lab` — Provide safe defensive security labs.
- `os.bookworm.reference` — Provide the reproducible Linux reference runtime.
- `runtime.lifecycle` — Start, stop, verify, and supervise runtime services.
- `operations.state` — Persist operational state and evidence.
- `security.defensive` — Teach and enforce defensive security principles.


Current Implementations

- `cli.shell-wrapper` — 
- `capability.python-engine` — 
- `architecture.python-engine` — 
- `academy.markdown-curriculum` — 
- `academy.security-lab` — 
- `os.bookworm.reference-runtime` — 
- `operations.state-vault` — 


Artifact Policies

- `artifact.backup` — Artifact Policy
- `artifact.temporary` — Artifact Policy
- `artifact.build` — Artifact Policy
- `artifact.quarantine` — Artifact Policy


Operational Flow
Repository
  ↓
Registry Engine
  ↓
Inventory
  ↓
Ownership
  ↓
Consolidation
  ↓
Certification
  ↓
Academy
Explain It Test

The operator should be able to explain:

Why the Registry Engine exists.
Why inventory should not classify paths independently.
Why ownership derives from domains/components/implementations.
Why purge remains blocked by default.
How Platform Convergence 2.0 reduces waste.
How Academy teaches the architecture.
Purge Rule

Nothing is purged until the architecture proves it is unnecessary and the replacement is:

implemented
verified
certified
understood
explainable
teachable
Summary

Platform Convergence 2.0 turns Wonderland from a collection of tools into a coherent registry-driven educational operating platform.
