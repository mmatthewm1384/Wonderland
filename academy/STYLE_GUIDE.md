# Code Examples

Code is one of the primary teaching tools used throughout Wonderland Academy.

Every code example should be written as though it will be copied into a production system.

## Every code example should

- Execute successfully whenever practical.
- Demonstrate production-quality engineering practices.
- Be complete enough to understand without unnecessary context.
- Favor clarity over cleverness.
- Include comments only when they improve understanding.
- Include verification steps when appropriate.
- Explain tradeoffs when multiple approaches exist.
- Avoid placeholder code unless explicitly marked as illustrative.

---

## Language Identifiers

Always specify the language for fenced code blocks.

### Correct

```bash
wl academy today
```

```python
print("Hello, Wonderland")
```

```swift
print("Hello, Wonderland")
```

```json
{
  "academy": "wonderland"
}
```

```yaml
version: 1.0
academy: enabled
```

```sql
SELECT * FROM lessons;
```

```text
Wonderland Academy
PASS lesson completed
```

### Incorrect

Do not use unlabeled fenced code blocks.

```
echo "Missing language identifier"
```

---

## Preferred Code Block Languages

Use these language identifiers consistently throughout Wonderland Academy.

| Language | Usage |
|-----------|-------|
| `bash` | Shell commands |
| `text` | Terminal output, logs, directory trees |
| `python` | Python |
| `swift` | Swift / SwiftUI |
| `json` | JSON |
| `yaml` | YAML |
| `toml` | TOML |
| `sql` | SQL |
| `diff` | Patches |
| `mermaid` | Diagrams (when supported) |

---

## Code Quality

Every example should demonstrate:

- readable naming
- sensible defaults
- validation
- error handling
- maintainability
- security-conscious practices
- production-quality formatting

Avoid intentionally poor code unless teaching why it is incorrect.

---

## Verification

Whenever practical, code examples should include a verification section.

Example:

```bash
wl academy doctor

# Expected
RESULT PASS
```

The expected outcome should be documented so learners know whether the exercise succeeded.

---

# Shell Commands

Shell commands should be safe, reproducible, and easy to follow.

Unless otherwise specified, commands assume the current working directory is:

```text
~/Wonderland
```

---

## Command Formatting

Use one command per line whenever practical.

Good:

```bash
cd ~/Wonderland

wl academy today

wl academy lab
```

When commands must be executed together, group them logically:

```bash
cd ~/Wonderland

git pull

wl academy quality
```

---

## Destructive Commands

Commands that modify or delete data must include:

- an explanation,
- verification steps,
- rollback guidance (when applicable),
- expected outcome.

Example:

```bash
rm old-file.txt
```

Explanation:

Removes an obsolete file.

Verification:

```bash
ls old-file.txt
```

Expected:

```text
ls: old-file.txt: No such file or directory
```

Rollback:

Restore the file from Git.

```bash
git restore old-file.txt
```

---

## Long Commands

Commands longer than one line should use shell continuation.

Example:

```bash
rsync \
  -avh \
  --delete \
  ~/Wonderland/ \
  /Volumes/T7_Wonderland/Wonderland/
```

Avoid excessively long single-line commands that reduce readability.

---

## Safety

Never present destructive commands without context.

Whenever a command may:

- delete files,
- overwrite data,
- modify Git history,
- stop services,
- change permissions,
- alter infrastructure,

include a warning explaining the consequences.

---

## Expected Output

Important commands should include representative output.

Example:

```bash
wl doctor academy
```

Expected:

```text
PASS Constitution
PASS Canon
PASS Codex
PASS Module 1
RESULT PASS
```

Representative output helps learners verify success without requiring exact character-for-character matches.

---

## Platform Assumptions

Unless explicitly noted otherwise:

- macOS examples assume Apple Silicon.
- Linux examples assume Debian Bookworm or Ubuntu LTS.
- Containers use `nerdctl`.
- Virtual machines use Lima.
- Shell examples use `zsh` unless portability requires POSIX `sh`.

When platform-specific behavior differs, document the difference rather than assuming identical behavior.

---

## Principle

Commands should not merely demonstrate *what* to type.

They should teach:

- what the command does,
- why it is used,
- how to verify it,
- how to recover if something goes wrong.
