from pathlib import Path
import hashlib
import json


class CertificateChain:

    def __init__(self, root):

        self.root = Path(root)

        self.chain_dir = (
            self.root /
            "vault" /
            "08-Operations" /
            "certifications" /
            "registry" /
            "history"
        )



    def hash_certificate(self, certificate):

        payload = dict(certificate)

        payload.pop(
            "certificate_hash",
            None
        )

        encoded = json.dumps(
            payload,
            sort_keys=True
        ).encode()

        return hashlib.sha256(
            encoded
        ).hexdigest()


    def certificates(self):

        if not self.chain_dir.exists():

            return []


        result = []

        for certificate in sorted(
            self.chain_dir.glob("*.json")
        ):

            result.append(
                json.loads(
                    certificate.read_text()
                )
            )

        return result



    def latest(self):

        certificates = self.certificates()

        if not certificates:

            return None

        return certificates[-1]



    def append(self, certificate):

        self.chain_dir.mkdir(
            parents=True,
            exist_ok=True
        )

        previous = self.latest()


        chain = {
            **certificate,

            "previous_certificate_hash":
                (
                    previous.get(
                        "certificate_hash"
                    )
                    if previous
                    else None
                ),

            "chain_position":
                (
                    previous.get(
                        "chain_position",
                        0
                    ) + 1
                    if previous
                    else 1
                )
        }


        chain["certificate_hash"] = (
            self.hash_certificate(
                chain
            )
        )


        output = (
            self.chain_dir /
            f"{chain['chain_position']:06}.json"
        )


        output.write_text(
            json.dumps(
                chain,
                indent=2
            )
        )


        return chain


    def verify(self):

        certificates = self.certificates()


        if not certificates:

            return {
                "passed": True,
                "certificates": 0,
                "issues": []
            }


        issues = []

        previous = None


        for expected_position, cert in enumerate(
            certificates,
            start=1
        ):

            stored_hash = cert.get(
                "certificate_hash"
            )


            payload = dict(cert)

            payload.pop(
                "certificate_hash",
                None
            )

            calculated_hash = (
                self.hash_certificate(
                    payload
                )
            )


            if stored_hash != calculated_hash:

                issues.append(
                    {
                        "certificate":
                            expected_position,
                        "issue":
                            "hash mismatch"
                    }
                )


            if cert.get(
                "chain_position"
            ) != expected_position:

                issues.append(
                    {
                        "certificate":
                            expected_position,
                        "issue":
                            "invalid chain position"
                    }
                )


            if previous:

                if cert.get(
                    "previous_certificate_hash"
                ) != previous.get(
                    "certificate_hash"
                ):

                    issues.append(
                        {
                            "certificate":
                                expected_position,
                            "issue":
                                "broken previous hash link"
                        }
                    )


            else:

                if cert.get(
                    "previous_certificate_hash"
                ) is not None:

                    issues.append(
                        {
                            "certificate":
                                expected_position,
                            "issue":
                                "genesis certificate has parent"
                        }
                    )


            previous = cert


        return {
            "passed":
                len(issues) == 0,

            "certificates":
                len(certificates),

            "issues":
                issues
        }
