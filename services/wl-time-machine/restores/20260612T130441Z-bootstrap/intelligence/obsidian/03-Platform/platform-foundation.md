---
title: Platform Foundation
type: platform
status: draft
version: 1.0.0
parent: "[[wonderland-reference-architecture]]"
tags:
  - platform
  - foundation
---

# Platform Foundation

> [!abstract]
> Defines the initial platform foundation for Wonderland-v4 before specific infrastructure implementation.

## Purpose

The platform foundation establishes where Wonderland systems live, how repositories are organized, how commands are invoked, and how implementation state is tracked.

## Platform Principles

- Local-first where practical
- Version-controlled by default
- Recoverable from documented state
- Portable across macOS and Linux
- Compatible with containerized services
- Operable without Architect

## Primary Operator Environments

- macOS Apple Silicon
- Linux
- Container runtime environments
- Obsidian knowledge core
- Git repositories

## Foundation Components

- [[workspace-layout]]
- [[repository-strategy]]
- [[wl-command-interface]]
- [[implementation-registry]]
- [[git-strategy]]

## Runtime Constraint

> [!danger]
> Architect may generate platform assets.
>
> Architect must not be required to operate them.
