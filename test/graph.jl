function create_graph()
    v = Video(10, 10)
    Background(1:70, (args...)->O)
    return JGraph(true, 200, 200)
end

function create_weighted_graph()
    g = SimpleGraph()
    wg = WeightedGraph(g)
    return nv(wg) == 0
end

function create_reference_graph()
    g = SimpleGraph()
    rg = ReferenceGraph(g)
    return rg.graph !== rg.adjacency_graph
end

function check_graph_build()
    g = create_graph()
    return g.width == 200
end

function check_graph_render()
    
end