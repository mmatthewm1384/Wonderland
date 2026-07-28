from __future__ import annotations


class ServiceContract:
    """
    Base Wonderland service contract.
    """

    def status(self) -> dict:
        raise NotImplementedError
