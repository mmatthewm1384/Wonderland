# Wonderland Mirror Operations

## Overview

The mirror subsystem provides a first-class `wl mirror` command for managing the Wonderland external recovery mirror.

## Commands

```bash
wl mirror status
wl mirror verify
wl mirror diff
wl mirror update
Certification
bin/wl-mirror-certify
Rollback

If the wl dispatcher patch breaks command routing:

bin/wl-mirror-rollback

This restores the most recent bin/wl backup from:

builder/backups/wl-before-mirror-dispatch-*
Recommended Completion Check
wl mirror status
wl mirror verify
wl mirror diff
bin/wl-mirror-certify

