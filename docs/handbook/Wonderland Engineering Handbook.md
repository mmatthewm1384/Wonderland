# Wonderland Engineering Handbook

Version: 1.0

## Purpose

This handbook defines how Wonderland is engineered.

It is the architectural reference for the project.

---

# Core Principles

• Local First
• Security by Default
• Simplicity
• Reliability
• Recoverability
• Observability
• Documentation

---

# Platform

Applications
        ↓
Platform Services
        ↓
Operator
        ↓
Runtime
        ↓
Linux

---

# Tier 1

Runtime

Operator

Builder

Storage

Security

Registry

Vault

Scheduler

Documentation

---

# Engineering Rules

Always:

• Verify first

• Document changes

• Prefer manifests

• Prefer shared services

• Keep APIs stable

• Think long-term

---

# Before Commit

python3 -m wl.operator verify

python3 -m wl.operator doctor

wl verify

git status

---

# Final Principle

Every change should make Wonderland:

Simpler

Safer

More Reliable

More Recoverable

Better Documented

More Maintainable

