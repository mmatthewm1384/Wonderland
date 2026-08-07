import argparse
import os
import json

from .executor import GenesisExecutor
from .validator import GenesisValidator
from .evidence import EvidenceWriter
from .spark.lifecycle import SparkLifecycle


def main():

    parser = argparse.ArgumentParser(
        prog="wl"
    )

    parser.add_argument(
        "command"
    )

    parser.add_argument(
        "action",
        nargs="?"
    )

    parser.add_argument(
        "target",
        nargs="?"
    )

    args = parser.parse_args()

    root = os.environ.get(
        "WL_ROOT",
        os.getcwd()
    )

    result = None

    if args.command == "crystal":

        GenesisValidator().validate(
            "crystal",
            args.action
        )

        result = GenesisExecutor(
            root
        ).crystal_status()


    elif args.command == "spark":

        if args.action in [
            "create",
            "start",
            "stop",
            "snapshot",
            "destroy"
        ]:

            lifecycle = SparkLifecycle(
                root
            )

            state_map = {
                "create": "created",
                "start": "running",
                "stop": "stopped",
                "snapshot": "snapshot",
                "destroy": "destroyed"
            }

            result = lifecycle.set_state(
                args.target,
                state_map[args.action]
            )


        elif args.action == "state":

            result = SparkLifecycle(
                root
            ).get_state(
                args.target
            )


        elif args.action == "status":

            result = GenesisExecutor(
                root
            ).spark_status()


        else:

            raise ValueError(
                "Unknown spark command"
            )


    elif args.command == "verify":

        result = GenesisExecutor(
            root
        ).verify()


    else:

        raise ValueError(
            f"Unknown command: {args.command}"
        )


    EvidenceWriter(root).write(
        result
    )


    print(
        json.dumps(
            result,
            indent=2
        )
    )


if __name__ == "__main__":
    main()
