function create_graph()
    v = Video(10, 10)
    Background(1:10, (args...)->O)
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

function check__global_property_limits()
end

function check__global_layout()
    g = create_graph()
    v1 = GraphVertex(1, 1:2)
    v2 = GraphVertex(2, 1:2)
    e1 = GraphEdge(1, 2, 1:2)
    g.object.frames = 1:70

    layout_x, layout_y = spring_layout(g.graph.adjacency_graph)

    JavisGraphs._global_layout(:video, g.object, 1)
    # for (idx, v) in enumerate(collect(zip(layout_x, layout_y)))
    for v in vertices(g)
        # cannot check exact position due to random seed
        # @test abs(((v.object.opts[:position][1].-(0.5, 0.5)).*(200, 200))[1]) == 1
        @test -1 <= ((v.object.opts[:position][1]/200)+0.5)[1] <= 1
    end
    JavisGraphs._global_layout(:video, g.object, 12)
    for v in vertices(g)
        @test -1 <= ((v.object.opts[:position][1]/200)+0.5)[1] <= 1
    end
end
