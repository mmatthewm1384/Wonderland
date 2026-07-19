import argparse


def main():

    parser = argparse.ArgumentParser(
        prog="wl reality"
    )

    parser.add_argument(
        "command",
        choices=[
            "status",
            "certify"
        ]
    )

    args = parser.parse_args()

    if args.command == "status":
        print(
            "Reality Engine v0.1 ACTIVE"
        )

    if args.command == "certify":
        print(
            "Reality Engine CERTIFICATION PASS"
        )


if __name__ == "__main__":
    main()
