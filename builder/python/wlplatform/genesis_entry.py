#!/usr/bin/env python3

import sys
import os

from wlplatform.genesis.cli import main


if __name__ == "__main__":
    os.environ.setdefault(
        "WL_ROOT",
        os.getcwd()
    )

    main()
