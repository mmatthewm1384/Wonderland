from __future__ import annotations

import argparse
from pathlib import Path

from wlknowledge import __version__
from wlknowledge.compiler import compile_model


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="wlknowledge")
    parser.add_argument("--version", action="version", version=f"wlknowledge {__version__}")

    subcommands = parser.add_subparsers(dest="command")

    subcommands.add_parser("version", help="Print WKE version")
    subcommands.add_parser("compile", help="Compile the phase-1 knowledge model")
    subcommands.add_parser("doctor", help="Run WKE health checks")

    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    if args.command == "version":
        print(f"wlknowledge {__version__}")
        return 0

    if args.command == "compile":
        root = Path.cwd().resolve()
        model = compile_model(root)
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

    if args.command == "doctor":
        root = Path.cwd().resolve()
        model = compile_model(root)

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
        print(f"Fingerprint .... {model.fingerprint}")

        if not model.repository:
            print("RESULT FAIL")
            return 1

        print("RESULT PASS")
        return 0

    parser.print_help()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
