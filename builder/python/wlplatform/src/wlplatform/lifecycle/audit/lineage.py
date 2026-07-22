

class CertificationLineage:


    def build(
        self,
        audit,
        certification
    ):

        return {

            "audit_event":
                audit["id"],

            "certification":
                certification,

            "linked":
                True

        }
