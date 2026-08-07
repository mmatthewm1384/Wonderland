from __future__ import annotations

import argparse
import os

from .models import Spark
from .registry import SparkRegistry
from .alpine import create_profile


def main():

    parser = argparse.ArgumentParser(
        prog="spark"
    )

    parser.add_argument(
        "action"
    )

    parser.add_argument(
        "name",
        nargs="?"
    )

    args = parser.parse_args()

    root = os.environ.get(
        "WL_ROOT",
        ".",
    )

    registry = SparkRegistry(root)


    if args.action == "create":

        spark = Spark(
            name=args.name,
            owner=args.name.replace(
                "spark-",
                "",
            ).split("-")[0],
        )

        print(
            registry.create(
                spark
            )
        )

        print(
            create_profile(
                root,
                args.name,
            )
        )


    elif args.action == "status":

        print(
            registry.list()
        )


if __name__ == "__main__":
    main()
