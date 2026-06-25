# WONDERLAND SEED VAULT MANIFEST

<!-- ID: VAULT-DOCUMENT-CATALOG-V4 -->

## 1. Vault

* System: Wonderland
* Path: `$WL_AUTHORITY_ROOT/intelligence/obsidian/00-Core/`
* Owner: Matthew Mahaney
* Status: Ready

This vault holds the main files for Wonderland.

The files explain the system, the rules, the tools, and the restore steps.

The vault must be easy to read, easy to test, and safe to restore.

---

## 2. Files

| Name       | File            | Use                  |
| ---------- | --------------- | -------------------- |
| Manifest   | `MANIFEST.md`   | Lists the core files |
| Authority  | `AUTHORITY.md`  | Sets owner rules     |
| Knowledge  | `KNOWLEDGE.md`  | Shows vault paths    |
| Runtime    | `RUNTIME.md`    | Sets tool rules      |
| Security   | `SECURITY.md`   | Sets file safety     |
| Operations | `OPERATIONS.md` | Shows `wl` use       |
| Recovery   | `RECOVERY.md`   | Shows restore steps  |

Each file must exist.

Each file must pass review.

---

## 3. Rules

Each file must use:

* Markdown
* Clear sections
* A file ID
* Local tools
* No plain secrets

Each file starts with:

```html
<!-- ID: VAULT-XXXX-V4 -->
```

Runtime rules:

* Use `nerdctl`
* Use `containerd`
* Use Apple Silicon
* Use local Python
* Avoid global installs

---

## 4. Checks

Target density:

```text
0.69 - 0.75
```

File access:

```text
0600 or 0700
```

Each design must include:

* Verify
* Recover
* Rollback

---

## 5. Commands

Verify:

```bash
wl doctor
```

Repair:

```bash
wl core repair
```

Rollback:

```bash
git checkout HEAD -- 00-Core/
```
