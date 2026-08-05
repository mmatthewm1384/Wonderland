class DependencyGraph:

    def __init__(self, index):

        self.index = index


    def packages(self):

        return (
            self.index
            .load()
            .get("packages", {})
        )


    def dependencies_for(self, package):

        packages = self.packages()

        return (
            packages
            .get(package, {})
            .get("dependencies", [])
        )


    def installed(self, package):

        return package in self.packages()


    def build(self):

        graph = {}

        for package in self.packages():

            graph[package] = (
                self.dependencies_for(package)
            )

        return {
            "packages": graph
        }


    def tree(self, package):

        visited = set()

        def walk(node):

            if node in visited:

                return {
                    "package": node,
                    "cycle": True
                }

            visited.add(node)

            return {
                "package": node,
                "dependencies": [
                    walk(dep)
                    for dep in self.dependencies_for(node)
                ]
            }

        return walk(package)


    def dependents(self, package):

        result = []

        for name in self.packages():

            if package in self.dependencies_for(name):

                result.append(name)

        return {
            "package": package,
            "dependents": sorted(result)
        }


    def verify_integrity(self):

        packages = self.packages()

        missing_dependencies = {}

        for package in packages:

            for dependency in self.dependencies_for(package):

                if dependency not in packages:

                    missing_dependencies.setdefault(
                        package,
                        []
                    ).append(
                        dependency
                    )


        cycles = []

        visiting = set()
        visited = set()


        def visit(node, stack):

            if node in visiting:

                index = stack.index(node)

                cycles.append(
                    stack[index:] + [node]
                )

                return


            if node in visited:

                return


            visiting.add(node)


            for dependency in self.dependencies_for(node):

                visit(
                    dependency,
                    stack + [dependency]
                )


            visiting.remove(node)

            visited.add(node)


        for package in packages:

            visit(
                package,
                [package]
            )


        return {

            "passed":
                not (
                    missing_dependencies
                    or cycles
                ),

            "missing_dependencies":
                missing_dependencies,

            "dependency_cycles":
                cycles,

        }
