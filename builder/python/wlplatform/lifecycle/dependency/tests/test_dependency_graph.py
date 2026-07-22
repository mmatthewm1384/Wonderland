from wlplatform.lifecycle.dependency.graph import (
    DependencyGraph
)

from wlplatform.lifecycle.dependency.resolver import (
    DependencyResolver
)


def test_startup_order():

    graph = DependencyGraph()

    graph.add_engine(
        "runtime"
    )

    graph.add_engine(
        "services",
        ["runtime"]
    )

    resolver = DependencyResolver(
        graph
    )

    order = resolver.startup_order()

    assert order == [
        "runtime",
        "services"
    ]



def test_shutdown_order():

    graph = DependencyGraph()

    graph.add_engine(
        "runtime"
    )

    graph.add_engine(
        "services",
        ["runtime"]
    )

    resolver = DependencyResolver(
        graph
    )

    assert resolver.shutdown_order() == [
        "services",
        "runtime"
    ]
