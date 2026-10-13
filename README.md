# Wonderland

**Engineered with Purpose. Crafted with Soul.**

Wonderland is a composable engineering platform for persistent memory, isolated computation, governed interaction, and verifiable system state.

Its architecture separates what must endure from what may be disposable. Components are designed to be understandable, recoverable, auditable, and independently testable.

> **Crystals remember. Sparks compute. Mesh connects and governs.**

## Core Architecture

- **Crystal** — Durable, addressable memory for knowledge, state, artifacts, relationships, provenance, and history. Crystal state is independent of the lifetime of any Spark that uses it.
- **Spark** — An isolated computation environment with an explicit lifecycle. Sparks may be ephemeral or persistent; their working state does not become durable merely because execution succeeded.
- **Crystal Mesh** — The fabric for identity, trust, topology, relationships, and authorized interaction among Crystals, Sparks, and Nodes.
- **Node** — A host or execution presence on which platform capabilities run.
- **Veil** — The isolation and security boundary that governs access to execution resources and data.
- **Evidence** — Verifiable records used to establish integrity, provenance, and observed outcomes rather than merely requested actions.

## Architectural Principles

- **Recoverability over convenience**
- **Auditability over speed**
- **Simplicity over cleverness**
- Durable memory must not depend on compute lifetime.
- State publication must be controlled, verifiable, and recoverable.
- Security boundaries and authorization must be explicit.
- A passing result must be supported by evidence.
- Prefer composable interfaces, reproducible tests, and reversible changes over one-off fixes.

## Runtime Direction

Wonderland's Spark runtime follows a **containerd-first** direction with a runtime-neutral contract. Alternative backends may be used for development and comparison, but must not silently redefine the canonical interface.

The intended lifecycle separates execution, durable publication, and teardown:

1. Validate the Spark specification and authorization.
2. Provision an isolated execution environment.
3. Execute the requested workload.
4. Validate and stage outputs.
5. Publish durable state through the Crystal commit protocol.
6. Verify the commit and record evidence.
7. Tear down volatile execution resources and certify cleanup separately.

A successful execution is not, by itself, proof of a durable commit, successful cleanup, or complete isolation.

## Engineering Workflow

Wonderland favors evidence-driven development:

1. Establish the current state and source of truth.
2. Define boundaries, invariants, and failure behavior.
3. Make the smallest controlled change.
4. Run targeted and regression tests.
5. Independently verify the result.
6. Capture evidence and document recovery or rollback.

## Repository

This repository contains Wonderland platform components, runtime implementations, governance specifications, tools, tests, and supporting documentation. Individual subsystems may have different maturity levels; implementation status should be established from source and verification evidence rather than inferred from a directory name or design document.

## Project Status

Wonderland is under active development. Architectural concepts and implementation capabilities are not automatically equivalent: a capability should be treated as implemented only when its source, integration path, and verification evidence support that conclusion.
