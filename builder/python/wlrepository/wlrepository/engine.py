from __future__ import annotations

import hashlib
import json
import os
import subprocess
import tempfile
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Sequence


GENERATED_HEADER = """\
###############################################################################
# Wonderland Repository Ignore Policy 2.0
#
# GENERATED FILE. DO NOT EDIT DIRECTLY.
#
# Source:
#   policy/repository/policy.json
#
# Regenerate:
#   wl repo generate
#
###############################################################################
"""


@dataclass(frozen=True)
class Finding:
    level: str
    code: str
    message: str
    path: str | None = None

    def as_dict(self) -> dict[str, Any]:
        result: dict[str, Any] = {
            "level": self.level,
            "code": self.code,
            "message": self.message,
        }
        if self.path is not None:
            result["path"] = self.path
        return result


@dataclass
class VerificationResult:
    findings: list[Finding] = field(default_factory=list)

    @property
    def errors(self) -> int:
        return sum(item.level == "ERROR" for item in self.findings)

    @property
    def warnings(self) -> int:
        return sum(item.level == "WARN" for item in self.findings)

    @property
    def passed(self) -> bool:
        return self.errors == 0

    def add(
        self,
        level: str,
        code: str,
        message: str,
        path: str | None = None,
    ) -> None:
        self.findings.append(Finding(level, code, message, path))

    def as_dict(self) -> dict[str, Any]:
        return {
            "result": "PASS" if self.passed else "FAIL",
            "errors": self.errors,
            "warnings": self.warnings,
            "findings": [item.as_dict() for item in self.findings],
        }


class RepositoryEngine:
    def __init__(self, root: Path) -> None:
        self.root = root.resolve()
        self.policy_path = self.root / "policy/repository/policy.json"
        self.gitignore_path = self.root / ".gitignore"

    def _run_git(
        self,
        args: Sequence[str],
        *,
        input_text: str | None = None,
        check: bool = True,
    ) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            ["git", *args],
            cwd=self.root,
            input=input_text,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=check,
        )

    def load_document(self) -> dict[str, Any]:
        try:
            document = json.loads(self.policy_path.read_text(encoding="utf-8"))
        except FileNotFoundError as exc:
            raise RuntimeError(
                f"repository policy missing: {self.policy_path}"
            ) from exc
        except json.JSONDecodeError as exc:
            raise RuntimeError(
                f"invalid repository policy JSON: {exc}"
            ) from exc

        if document.get("schema_version") != 1:
            raise RuntimeError(
                "unsupported repository policy schema_version"
            )

        policy = document.get("policy")
        if not isinstance(policy, dict):
            raise RuntimeError("repository policy object missing")

        sections = policy.get("sections")
        if not isinstance(sections, list) or not sections:
            raise RuntimeError("repository policy sections missing")

        return document

    def render_gitignore(self) -> str:
        document = self.load_document()
        policy = document["policy"]

        output: list[str] = [GENERATED_HEADER.rstrip(), ""]

        principles = policy.get("principles", [])
        if principles:
            output.extend(
                [
                    "###############################################################################",
                    "# Policy principles",
                    "###############################################################################",
                    "",
                ]
            )
            for principle in principles:
                output.append(f"# - {principle}")
            output.append("")

        for section in policy["sections"]:
            name = section.get("name")
            patterns = section.get("patterns")

            if not isinstance(name, str) or not name.strip():
                raise RuntimeError("policy section has no valid name")
            if not isinstance(patterns, list):
                raise RuntimeError(
                    f"policy section has invalid patterns: {name}"
                )

            output.extend(
                [
                    "###############################################################################",
                    f"# {name}",
                    "###############################################################################",
                    "",
                ]
            )

            seen: set[str] = set()
            for raw_pattern in patterns:
                if not isinstance(raw_pattern, str):
                    raise RuntimeError(
                        f"non-string ignore pattern in section: {name}"
                    )

                pattern = raw_pattern.strip()
                if not pattern or pattern in seen:
                    continue

                if "\n" in pattern or "\r" in pattern:
                    raise RuntimeError(
                        f"invalid multiline ignore pattern: {pattern!r}"
                    )

                output.append(pattern)
                seen.add(pattern)

            output.append("")

        output.extend(
            [
                "###############################################################################",
                "# Protected source trees",
                "###############################################################################",
                "",
                "# These trees remain eligible for source control.",
            ]
        )

        for prefix in policy.get("protected_source_prefixes", []):
            output.append(f"#   /{prefix}")

        output.append("")
        return "\n".join(output)

    def generated_digest(self) -> str:
        return hashlib.sha256(
            self.render_gitignore().encode("utf-8")
        ).hexdigest()

    def current_digest(self) -> str | None:
        if not self.gitignore_path.exists():
            return None
        return hashlib.sha256(
            self.gitignore_path.read_bytes()
        ).hexdigest()

    def policy_digest(self) -> str:
        return hashlib.sha256(
            self.policy_path.read_bytes()
        ).hexdigest()

    def health(self) -> dict[str, Any]:
        verification = self.verify()

        score = 100
        score -= verification.errors * 25
        score -= verification.warnings * 5
        score = max(score, 0)

        return {
            "score": score,
            "result": "PASS" if verification.passed else "FAIL",
            "errors": verification.errors,
            "warnings": verification.warnings,
        }

    def generate(self, *, check_only: bool = False) -> bool:
        rendered = self.render_gitignore()

        if check_only:
            return (
                self.gitignore_path.exists()
                and self.gitignore_path.read_text(encoding="utf-8") == rendered
            )

        fd, temporary_name = tempfile.mkstemp(
            prefix=".gitignore.",
            suffix=".tmp",
            dir=self.root,
            text=True,
        )
        temporary = Path(temporary_name)

        try:
            with os.fdopen(fd, "w", encoding="utf-8", newline="\n") as stream:
                stream.write(rendered)
                stream.flush()
                os.fsync(stream.fileno())

            temporary.replace(self.gitignore_path)
        finally:
            temporary.unlink(missing_ok=True)

        return True

    @staticmethod
    def _run_check_ignore(
        root: Path,
        path: str,
    ) -> tuple[bool, str]:
        completed = subprocess.run(
            [
                "git",
                "check-ignore",
                "--no-index",
                "-v",
                "--",
                path,
            ],
            cwd=root,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=False,
        )

        if completed.returncode == 0:
            return True, completed.stdout.strip()

        if completed.returncode == 1:
            return False, ""

        detail = completed.stderr.strip() or completed.stdout.strip()
        raise RuntimeError(
            f"git check-ignore failed for {path}: {detail}"
        )

    def check_ignore(
        self,
        path: str,
    ) -> tuple[bool, str]:
        return self._run_check_ignore(self.root, path)

    def tracked_ignored(self) -> list[str]:
        completed = self._run_git(
            ["ls-files", "-ci", "--exclude-standard"]
        )
        return [
            line
            for line in completed.stdout.splitlines()
            if line.strip()
        ]

    def _validate_generated_policy(
        self,
        result: VerificationResult,
    ) -> None:
        policy = self.load_document()["policy"]
        rendered = self.render_gitignore()

        with tempfile.TemporaryDirectory(
            prefix="wl-repository-policy-check-"
        ) as temporary_directory:
            temporary_root = Path(temporary_directory)

            initialized = subprocess.run(
                ["git", "init", "-q"],
                cwd=temporary_root,
                text=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                check=False,
            )

            if initialized.returncode != 0:
                detail = (
                    initialized.stderr.strip()
                    or initialized.stdout.strip()
                )
                raise RuntimeError(
                    "unable to initialize isolated policy repository: "
                    f"{detail}"
                )

            generated_ignore = temporary_root / ".gitignore"
            generated_ignore.write_text(
                rendered,
                encoding="utf-8",
                newline="\n",
            )

            for path in policy.get("must_ignore", []):
                ignored, detail = self._run_check_ignore(
                    temporary_root,
                    path,
                )

                if ignored:
                    result.add(
                        "PASS",
                        "MUST_IGNORE",
                        detail or "path ignored",
                        path,
                    )
                else:
                    result.add(
                        "ERROR",
                        "MUST_IGNORE",
                        "required generated path is not ignored",
                        path,
                    )

            for path in policy.get("must_track", []):
                ignored, detail = self._run_check_ignore(
                    temporary_root,
                    path,
                )

                if ignored:
                    result.add(
                        "ERROR",
                        "MUST_TRACK",
                        detail or "protected source path is ignored",
                        path,
                    )
                else:
                    result.add(
                        "PASS",
                        "MUST_TRACK",
                        "protected source path remains trackable",
                        path,
                    )

    def verify(self) -> VerificationResult:
        result = VerificationResult()

        try:
            self.load_document()
            result.add("PASS", "POLICY", "repository policy is valid")
        except RuntimeError as exc:
            result.add("ERROR", "POLICY", str(exc))
            return result

        try:
            self._validate_generated_policy(result)
        except RuntimeError as exc:
            result.add("ERROR", "POLICY_CHECK", str(exc))
            return result

        if self.generate(check_only=True):
            result.add(
                "PASS",
                "GENERATED_FILE",
                ".gitignore matches declarative policy",
                ".gitignore",
            )
        else:
            result.add(
                "ERROR",
                "GENERATED_FILE",
                ".gitignore is stale; run: wl repo generate",
                ".gitignore",
            )

        try:
            tracked_ignored = self.tracked_ignored()
        except subprocess.CalledProcessError as exc:
            detail = exc.stderr.strip() or str(exc)
            result.add("ERROR", "GIT_INDEX", detail)
            return result

        if tracked_ignored:
            result.add(
                "WARN",
                "TRACKED_IGNORED",
                (
                    f"{len(tracked_ignored)} tracked files match "
                    "current ignore rules"
                ),
            )
        else:
            result.add(
                "PASS",
                "TRACKED_IGNORED",
                "no tracked files match current ignore rules",
            )

        return result

    def status(self) -> dict[str, Any]:
        document = self.load_document()
        tracked_ignored = self.tracked_ignored()
        verification = self.verify()

        return {
            "engine": document["engine"],
            "policy_path": str(self.policy_path.relative_to(self.root)),
            "gitignore_path": str(
                self.gitignore_path.relative_to(self.root)
            ),
            "generated_digest": self.generated_digest(),
            "current_digest": self.current_digest(),
            "policy_digest": self.policy_digest(),
            "verification": verification.as_dict(),
            "synchronized": self.generate(check_only=True),
            "tracked_ignored": len(tracked_ignored),
        }
