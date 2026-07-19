class RealityGraph:

    def __init__(self):
        self.nodes = {}
        self.edges = []

    def add(self, node):
        self.nodes[node.id] = node

    def connect(self, source, target, relation):
        self.edges.append(
            {
                "source": source,
                "target": target,
                "relation": relation
            }
        )

    def export(self):
        return {
            "nodes": self.nodes,
            "edges": self.edges
        }
