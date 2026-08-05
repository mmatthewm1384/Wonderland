from pathlib import Path
import json

from .chain import CertificateChain
from .hash import RegistryHasher


class RegistryCertificateVerifier:

    def __init__(self, root):

        self.root = Path(root)

        self.registry_index = (
            self.root /
            "vault" /
            "05-Registry" /
            "auto-drop" /
            "package-index.json"
        )


    def verify(self):

        chain = CertificateChain(
            self.root
        )

        chain_result = chain.verify()


        if not chain_result["passed"]:

            return {
                "passed": False,
                "reason": "certificate chain invalid",
                "chain": chain_result,
            }


        certificates = chain.certificates()


        if not certificates:

            return {
                "passed": False,
                "reason": "no certificates",
            }


        certificate = certificates[-1]


        if not self.registry_index.exists():

            return {
                "passed": False,
                "reason": "registry missing",
            }


        registry = json.loads(
            self.registry_index.read_text()
        )


        current_hash = (
            RegistryHasher.hash_model(
                registry
            )
        )


        certified_hash = (
            certificate.get(
                "registry_hash"
            )
        )


        if current_hash != certified_hash:

            return {
                "passed": False,
                "reason": "registry hash mismatch",
                "certified_hash": certified_hash,
                "current_hash": current_hash,
            }


        return {
            "passed": True,
            "certificate_position":
                certificate.get(
                    "chain_position"
                ),
            "registry_hash":
                current_hash,
            "status":
                certificate.get(
                    "status"
                ),
        }
