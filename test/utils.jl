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

function dummy_node_shape()
    return (args...; kwargs...) -> ()
end

function check_add_styles()
    g = create_graph()
    v = GraphVertex(1, 1:2)
    style = (args...; kw...) -> ()

    @add_styles v [(() -> ((args...; kw...) -> test_style1(args...; kw...)))()]

    @add_styles v [(() -> ((args...; kw...) -> ()))()]

    @add_styles v [(() -> ((args...; kw...) -> style(args...; kw...)))()]

    @add_styles v [dummy_node_shape()]

    print(length(v.opts[:styles]))
    return length(v.opts[:styles]) == 5
end

global c = 3

function check_register_style_opts()
    g = create_graph()
    v = GraphVertex(1, 1:2)
    a = 1
    b = 2
    @register_style_opts v a b c
    return v.object.opts[:a] == 1 && v.object.opts[:b] == 2 && v.object.opts[:c] == 3
end
