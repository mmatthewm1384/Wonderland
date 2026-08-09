from __future__ import annotations
import argparse
import json
from .normalize import normalize_polarity
from .signature import TransformationSignature


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(prog="wl research correspondence")
    sub = parser.add_subparsers(dest="command", required=True)

    p = sub.add_parser("normalize")
    p.add_argument("--polarity", nargs="+", type=float, required=True)

    p = sub.add_parser("signature")
    p.add_argument("--system-id", required=True)
    p.add_argument("--source", required=True)

    args = parser.parse_args(argv)
    if args.command == "normalize":
        print(json.dumps(normalize_polarity(args.polarity)))
        return 0
    sig = TransformationSignature(args.system_id, args.source, {}, {}, {}, {}, {}, {})
    print(sig.canonical_json())
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
