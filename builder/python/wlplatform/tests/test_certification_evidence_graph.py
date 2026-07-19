"""
Certification Evidence Graph Verification
"""


def test_graph_import():

    from wlplatform.certification.graph import (
        CertificationGraph
    )

    assert CertificationGraph is not None



def test_graph_add_engine():

    from wlplatform.certification.graph import (
        CertificationGraph
    )

    graph = CertificationGraph()

    graph.add_node(
        "runtime",
        "engine"
    )

    engines = graph.find(
        "engine"
    )

    assert len(engines) == 1



def test_graph_relationship_chain():

    from wlplatform.certification.graph import (
        CertificationGraph
    )

    graph = CertificationGraph()


    graph.add_node(
        "runtime",
        "engine"
    )

    graph.add_node(
        "runtime.json",
        "evidence"
    )

    graph.add_node(
        "sha256-runtime",
        "digest"
    )

    graph.add_node(
        "runtime-lineage",
        "lineage"
    )

    graph.add_node(
        "CERTIFIED",
        "trust"
    )


    explanation = graph.explain()


    types = [
        item["type"]
        for item in explanation
    ]


    assert "engine" in types
    assert "evidence" in types
    assert "digest" in types
    assert "lineage" in types
    assert "trust" in types
