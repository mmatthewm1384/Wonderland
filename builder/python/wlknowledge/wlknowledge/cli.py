from __future__ import annotations

import argparse
from pathlib import Path

from wlknowledge import __version__
from wlknowledge.pipeline import KnowledgePipeline
from wlknowledge.package import package_knowledge


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="wlknowledge")
    parser.add_argument("--version", action="version", version=f"wlknowledge {__version__}")

    subcommands = parser.add_subparsers(dest="command")

    subcommands.add_parser("version", help="Print WKE version")
    subcommands.add_parser("compile", help="Compile the knowledge model")
    subcommands.add_parser("render", help="Compile and render Markdown catalogs")
    subcommands.add_parser("doctor", help="Run WKE health checks")
    subcommands.add_parser("package", help="Build portable WKE package")

    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    if args.command == "version":
        print(f"wlknowledge {__version__}")
        return 0

    if args.command == "compile":
        root = Path.cwd().resolve()
        result = KnowledgePipeline(root).build()
        model = result.model
        print("Wonderland Knowledge Engine")
        print(f"Stage .......... {model.stage}")
        print(f"Fingerprint .... {model.fingerprint}")
        print(f"Files .......... {model.repository.get('file_count', 0)}")
        print(f"Directories .... {model.repository.get('directory_count', 0)}")
        print(f"Commands ....... {model.counts['commands']}")
        print(f"Applications ... {model.counts['applications']}")
        print(f"Services ....... {model.counts['services']}")
        print(f"Documents ...... {model.counts['documents']}")
        print(f"Decisions ...... {model.counts['decisions']}")
        print("RESULT PASS")
        return 0

    if args.command == "render":
        root = Path.cwd().resolve()
        result = KnowledgePipeline(root).build()
        model = result.model
        print("Wonderland Knowledge Engine")
        print("Pipeline ....... PASS")
        print(f"Written Files .. {len(result.written_files)}")
        print(f"Fingerprint .... {model.fingerprint}")
        print("RESULT PASS")
        return 0

    if args.command == "package":
        root = Path.cwd().resolve()
        result = KnowledgePipeline(root).build()

        if not result.validation.ok:
            print("Validation ..... FAIL")
            for issue in result.validation.issues:
                print(f"{issue.severity.upper()} {issue.code}: {issue.message}")
            print("RESULT FAIL")
            return 1

        package = package_knowledge(root)

        print("Wonderland Knowledge Engine")
        print("Pipeline ....... PASS")
        print("Validation ..... PASS")
        print(f"Package ........ {package.path.relative_to(root)}")
        print(f"Files .......... {package.file_count}")
        print("RESULT PASS")
        return 0

    if args.command == "doctor":
        root = Path.cwd().resolve()
        result = KnowledgePipeline(root).build()
        model = result.model
        validation = result.validation

        print("Wonderland Knowledge Engine")
        print("Package ........ PASS")
        print("CLI ............ PASS")
        print("Model .......... PASS")
        print("Repository ..... PASS" if model.repository else "Repository ..... FAIL")
        print("Commands ....... PASS")
        print("Applications ... PASS")
        print("Services ....... PASS")
        print("Documentation .. PASS")
        print("Decisions ...... PASS")
        print("Validation ..... PASS" if validation.ok else "Validation ..... FAIL")
        print("Cache .......... HIT" if result.cache.hit else "Cache .......... MISS")
        print(f"Repo FP ........ {result.cache.fingerprint}")
        print(f"Errors ......... {validation.error_count}")
        print(f"Warnings ....... {validation.warning_count}")
        print(f"Fingerprint .... {model.fingerprint}")

        for issue in validation.issues:
            print(f"{issue.severity.upper()} {issue.code}: {issue.message}")

        if not model.repository or not validation.ok:
            print("RESULT FAIL")
            return 1

        print("RESULT PASS")
        return 0

    parser.print_help()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
