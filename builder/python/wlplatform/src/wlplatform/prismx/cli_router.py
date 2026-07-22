from .cli.commands import (
    status,
    list_streams,
    play_stream,
    certify,
    recover,
)


def build_prismx_parser(
    subparsers
):

    prismx = subparsers.add_parser(
        "prismx",
        help="PRISMX media platform"
    )

    prismx_sub = prismx.add_subparsers(
        dest="prismx_action"
    )

    prismx_sub.add_parser(
        "status"
    )

    prismx_sub.add_parser(
        "streams"
    )

    play = prismx_sub.add_parser(
        "play"
    )

    play.add_argument(
        "stream"
    )

    prismx_sub.add_parser(
        "certify"
    )

    prismx_sub.add_parser(
        "recover"
    )

    return prismx
