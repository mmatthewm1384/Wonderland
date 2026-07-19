class PrimitiveEngine:

    def __init__(self):
        self.states = {}

    def create(self, name, value):
        self.states[name] = value
        return self.states

    def inspect(self):
        return self.states
