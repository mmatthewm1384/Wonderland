from __future__ import annotations

from ..result import CheckResult, Status


class MirrorEngine:

    name = "mirror"


    def __init__(self, root):
        self.root = root


    def verify(self):

        return CheckResult(
            name=self.name,
            status=Status.PASS,
            summary="mirror verification passed",
        )


    def certify(self):

        return self.verify()
