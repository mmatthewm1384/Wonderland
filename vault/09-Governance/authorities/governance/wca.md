# Wonderland Certification Authority (WCA)

## Purpose

Defines the certified authority for Wonderland Certification Authority.

This document is not a light template. It is an operational governance document used to establish context, ownership, controlled artifacts, verification expectations, recovery behavior, rollback behavior, and certification criteria.

## Scope

Applies to certification records, PASS criteria, recertification triggers, release readiness, and production acceptance.

## Authority Hierarchy

Code: WCA  
Parent: WAT  
Layer: Governance  
Status: Certified  
Version: 1.0  

This authority participates in the Wonderland long-term governance stack. It must remain persistent, recoverable, auditable, secure, automated where practical, versioned, and modular.

## Context Model

WCA defines what qualifies as certified. Certification is evidence-backed: a component must be verified, recoverable, governed, auditable, and operational.

## Inputs and Applicability

This authority applies to:

- Design decisions
- Build implementation
- Documentation updates
- Verification checks
- Recovery planning
- Rollback planning
- Certification records
- Long-term maintenance

## Required Artifacts

This authority controls or requires the following artifacts:

```text
certification records
PASS criteria
recertification reports
authority status blocks
release acceptance records
```

Each artifact must remain traceable to its authority, recoverable from backup, and verifiable through command output or document review.

## Verification

Verification command:

```bash
wl-authorities context
```

Expected:

```text
PASS WCA
RESULT PASS
```

Verification confirms that this authority includes purpose, scope, hierarchy, context, artifacts, recovery, rollback, certification criteria, and a machine-readable status block.

## Recovery

Recovery restores this authority from the latest governance backup.

Procedure:

```bash
cp -R ~/Wonderland/backups/authority-doc-correction-*/authorities ~/Wonderland/vault/09-Governance/
cp -R ~/Wonderland/backups/authority-doc-correction-*/theomatrix ~/Wonderland/vault/09-Governance/
wl-authorities context
```

Recovery is successful only when the authority context audit returns RESULT PASS.

## Rollback

Rollback is required when a document edit removes required context, breaks certification, corrupts authority hierarchy, or weakens operational clarity.

Rollback procedure:

```bash
cp "/Users/wonderland/Wonderland/backups/authority-doc-correction-20260622-110802/governance/wca.md" "/Users/wonderland/Wonderland/vault/09-Governance/authorities/governance/wca.md" 2>/dev/null || true
wl-authorities context
```

If direct rollback is unavailable, restore the full governance backup captured before this correction.

## Certification

Certification requirements:

```text
PASS certification-model
PASS pass-criteria
PASS recertification-triggers
PASS evidence-records
PASS verification
PASS recovery
PASS rollback
PASS authority-context

RESULT PASS
```

## Machine-Readable Status

```yaml
authority:
  code: WCA
  parent: WAT
  layer: "Governance"
  version: "1.0"
  status: certified
  result: PASS
```

RESULT PASS
