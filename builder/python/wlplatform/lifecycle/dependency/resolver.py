class DependencyResolver:


    def __init__(self, graph):

        self.graph = graph


    def startup_order(self):

        visited = set()
        order = []


        def visit(node):

            if node in visited:

                return

            visited.add(node)

            for dep in self.graph.get_dependencies(node):

                visit(dep)

            order.append(node)


        for node in self.graph.nodes:

            visit(node)


        return order



    def shutdown_order(self):

        return list(
            reversed(
                self.startup_order()
            )
        )
