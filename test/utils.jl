function check_get_edges()
    g = create_dummy_graph()
    el = edges(g)
    return length(el) == 2
end

function check_get_edges_unordered()
    g = create_dummy_graph()
    v1 = GraphVertex(3, 1:2)
    v2 = GraphVertex(4, 1:2)
    e1 = GraphEdge(4, 3, 1:2)
    e2 = GraphEdge(3, 4, 1:2)
    el = edges(g)
    return Base.convert(Pair, el[1]) == (1 => 2) && Base.convert(Pair, el[3]) == (3 => 4)
end

function check_get_edges_ordered()
    g = create_dummy_graph()
    v1 = GraphVertex(3, 1:2)
    v2 = GraphVertex(4, 1:2)
    e1 = GraphEdge(4, 3, 1:2)
    e2 = GraphEdge(3, 4, 1:2)
    el = edges(g, true)
    return Base.convert(Pair, el[3]) == (4 => 3) && convert(Pair, el[4]) == (3 => 4)
end

function check_get_vertices()
    g = create_dummy_graph()
    _ = GraphVertex(3, 1:2)
    _ = GraphVertex(4, 1:2)
    v1 = vertices(g)
    v2 = vertices(g, true)
    return length(v1) == length(v2) == 4
end

function check_get_draw()
    g = create_dummy_graph()
    v = GraphVertex(3, 1:2)
    v.opts[:styles] = [test_style1]
    d = get_draw(:vertex)
    d(:video, v.object, :frames)
    return v.object.opts[:dummy] == true
end

function test_style1(video, object, args...; kw...)
    object.opts[:dummy] = true
end

function dummy_vertex_shape()
    return (args...; kwargs...) -> ()
end

function check_add_styles()
    g = create_graph()
    v = GraphVertex(1, 1:2)
    style = (args...; kw...) -> ()

    @add_styles v [(() -> ((args...; kw...) -> test_style1(args...; kw...)))()]

    @add_styles v [(() -> ((args...; kw...) -> ()))()]

    @add_styles v [(() -> ((args...; kw...) -> style(args...; kw...)))()]

    @add_styles v [dummy_vertex_shape()]

    return length(v.opts[:styles]) == 4
end

global c = 3

function check_register_style_opts()
    g = create_graph()
    v = GraphVertex(1, 1:2)
    a = 1
    b = 2
    @register_style_opts v.object a b c
    return v.object.opts[:_style_opts_cache][:a] == 1 && v.object.opts[:_style_opts_cache][:b] == 2 && v.object.opts[:_style_opts_cache][:c] == 3
end

function check_graph_from_matrix()
    directed_adjacency_matrix = [[1 1]; [0 0]]
    g1 = graph_from_matrix(directed_adjacency_matrix)
    ref_g1 = SimpleDiGraph(2)
    add_edge!(ref_g1, 1, 1)
    add_edge!(ref_g1, 1, 2)

    undirected_adjacency_matrix = [[1 0]; [0 1]]
    g2 = graph_from_matrix(undirected_adjacency_matrix)
    ref_g2 = SimpleGraph(2)
    add_edge!(ref_g2, 1, 1)
    add_edge!(ref_g2, 2, 2)
    return g1 == ref_g1 && g2 == ref_g2
end

function check_vertex_out_of_parent_range()
    v = Video(10, 10)
    Background(1:100, (args...)->O)
    jg = JGraph(true, 200, 200, 1:50)
    warn_string = "Child 1 frame range 1:80 out of parent graph range 1:50"
    @test_warn warn_string GraphVertex(1, 1:80)
end

function check_edge_out_of_parent_range()
    v = Video(10, 10)
    Background(1:100, (args...)->O)
    jg = JGraph(true, 200, 200, 1:50)
    v1 = GraphVertex(1, 1:2)
    v2 = GraphVertex(2, 1:2)
    warn_string = "Child 1 => 2 frame range 1:80 out of parent graph range 1:50"
    @test_warn warn_string GraphEdge(1, 2, 1:80)
end