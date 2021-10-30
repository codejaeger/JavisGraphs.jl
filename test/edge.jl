function check_edge_build()
    g = create_graph()
    v1 = GraphVertex(1, 1:2)
    v2 = GraphVertex(2, 1:2)
    e1 = GraphEdge(1, 2, 1:2)
    e2 = GraphEdge(v2, v1, 1:2)
    return e1.object.opts[:_edge_idx] == 1 && e2.object.opts[:_edge_idx] == 2
end