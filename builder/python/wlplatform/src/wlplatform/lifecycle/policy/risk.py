

RISK_LEVELS = {

    "LOW": 1,

    "MEDIUM": 2,

    "HIGH": 3,

    "CRITICAL": 4

}


class RiskEngine:


    def approved(
        self,
        risk
    ):

        return (
            RISK_LEVELS[risk]
            <= 3
        )
