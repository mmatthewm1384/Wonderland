"""
PRISMX End-to-End Lifecycle Controller
"""

from .identity import create_identity
from .security import (
    PrismIdentity,
    PrismSecurityManager,
)

from .certification import (
    PrismCertificationEngine,
    PrismEvidenceStore,
)

from .session import PrismSessionManager
from .player import VLCAdapter


class PrismLifecycleController:


    def __init__(self):

        self.security = (
            PrismSecurityManager()
        )

        self.certification = (
            PrismCertificationEngine()
        )

        self.sessions = (
            PrismSessionManager()
        )

        self.player = VLCAdapter()


    def prepare(
        self,
        name,
        owner,
        origin,
        source,
    ):

        identity = PrismIdentity(
            name=name,
            owner=owner,
            origin=origin
        )

        identity.generate()


        trust = self.security.verify(
            identity
        )


        if not trust["trusted"]:

            raise RuntimeError(
                "PRISMX source not trusted"
            )


        certification = (
            self.certification.certify(
                name,
                {
                    "identity": True,
                    "security": True,
                    "source": True
                }
            )
        )


        return {
            "identity": identity,
            "trust": trust,
            "certification": certification,
            "source": source
        }


    def play(
        self,
        prepared
    ):

        session = self.sessions.create(
            prepared["source"]
        )


        self.player.open(
            prepared["source"]
        )


        self.player.play()


        self.sessions.start(
            session.id
        )


        return session
