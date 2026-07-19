class RealitySimulation:

    def __init__(self, model):
        self.model = model

    def run(self, steps=1):
        return {
            "model": self.model.name,
            "steps": steps,
            "status": "complete"
        }
