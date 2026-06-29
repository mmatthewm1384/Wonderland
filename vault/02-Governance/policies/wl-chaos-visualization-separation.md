# WL Chaos Visualization Separation Policy

Status: Authority  
Version: 1.0

## Rule

Wonderland Chaos must not automatically launch visualization applications or Console.app.

## Visualization apps

These applications are optional Wonderland tools, not Chaos side effects:

- Agitate Waves
- Spin City
- Matrix Atom Destroyer

## Allowed behavior

Chaos may write state, audit records, scheduler records, and controller execution records.

Wonderland Control Center may expose visualization apps intentionally through a Tools or Visualizations section.

## Forbidden behavior

Chaos actions, scheduler runs, leases, check-ins, and model execution must not automatically open:

- Agitate Waves
- Spin City
- Matrix Atom Destroyer
- Console.app

## Rationale

Chaos is an operational subsystem. Visualizations are optional user-facing tools.
