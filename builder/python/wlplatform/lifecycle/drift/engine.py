

class DriftDetectionEngine:


    def __init__(
        self,
        analyzer
    ):

        self.analyzer = analyzer



    def detect(
        self,
        component,
        desired,
        actual
    ):

        return self.analyzer.analyze(
            component,
            desired,
            actual
        )
