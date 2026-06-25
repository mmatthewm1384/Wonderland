# Matrix Command Surface

## Core

```bash
wl matrix status
wl matrix summary
wl matrix doctor-all
wl matrix certify
Run Cycle
wl matrix run-cycle
wl matrix run-list
wl matrix run-show
Event Bus
wl matrix events-list
wl matrix archive-events
Atom Slam
wl matrix atom-slam-visual
wl matrix atom-slam 93 impulse
wl matrix atom-slam-import <event.json>
wl matrix atom-slam-list
wl matrix atom-slam-report
wl matrix atom-slam-doctor
Fluderation
wl matrix fluderation
wl matrix fluderation-verify
wl matrix fluderation-doctor
wl matrix fluderation-import <recording.json>
wl matrix fluderation-list
wl matrix fluderation-report
wl matrix fluderation-summary
wl matrix fluderation-consume-events
Existing Tauri Apps
wl matrix agitate
wl matrix spin-city
wl matrix core

wl matrix agitate-event 72
wl matrix spin-city-event 81
wl matrix core-event 50

wl matrix tauri-doctor
wl matrix tauri-events-test
Certified Flow
Atom Slam / Agitate / Spin City / Core
        ↓
Matrix Event Bus
        ↓
Fluderation
        ↓
Recording + Report
        ↓
Certification
        ↓
Archive


## Governance Principle

This component may be destroyed and rebuilt without loss of authority.

Authority resides in:

- documented intent
- service definitions
- recovery procedures
- version-controlled governance records

Runtime state is disposable.
Authority is not.
