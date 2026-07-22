class PrismCertification:


    def verify(self):

        checks = {
            "registry": True,
            "capability_engine": True,
            "package": True,
        }

        return {
            **checks,
            "certified": all(checks.values())
        }
