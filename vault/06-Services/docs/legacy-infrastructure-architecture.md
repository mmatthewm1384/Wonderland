# Infrastructure Architecture

## Objective

Provide persistent, recoverable, auditable infrastructure for Wonderland-v4.

## Core Components

- Docker
- nerdctl
- Harbor
- Portainer
- Git
- tmux
- Python
- Swift

## Naming Standards

Commands:
- wl-*

Services:
- wl-<service>

Containers:
- wl-<service>

Networks:
- wonderland-*

Volumes:
- wl-<service>-data

## Design Requirements

- Local-first
- Version controlled
- Backup aware
- Disaster recoverable
- Automated deployment
- Observable operation

## Verification

Infrastructure changes must be reproducible from documentation.

## Recovery

All critical services require documented restoration procedures.

## Rollback

Every deployment must have a rollback path.
