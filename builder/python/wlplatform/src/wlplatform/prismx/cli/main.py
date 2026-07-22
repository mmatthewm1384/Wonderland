"""
PRISMX CLI Entry
"""

import argparse

from .commands import play_stream
from .commands import (
    status,
    list_streams,
    play,
    certify,
    recover,
)


def main():

    parser = argparse.ArgumentParser(
        prog="wl prismx"
    )

    sub = parser.add_subparsers(
        dest="command"
    )


    sub.add_parser(
        "status"
    )

    sub.add_parser(
        "streams"
    )

    play_cmd = sub.add_parser(
        "play"
    )

    play_cmd.add_argument(
        "source"
    )


    sub.add_parser(
        "certify"
    )

    sub.add_parser(
        "recover"
    )


    args = parser.parse_args()


    if args.command == "status":

        print(status())


    elif args.command == "play":

        print(
            play_stream(
                args.source
            )
        )

    elif args.command == "streams":

        print(list_streams())


    elif args.command == "play":

        print(
            play(
                args.source
            )
        )


    elif args.command == "certify":

        print(certify())


    elif args.command == "recover":

        print(recover())


if __name__ == "__main__":

    main()
