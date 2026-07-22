from .models import EngineNode


class DependencyGraph:


    def __init__(self):

        self.nodes = {}


    def add_engine(
        self,
        name,
        depends_on=None
    ):

        self.nodes[name] = EngineNode(
            name=name,
            depends_on=depends_on or []
        )


    def get_dependencies(
        self,
        name
    ):

        return self.nodes[name].depends_on
