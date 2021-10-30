function check_vertex_build()
    g = create_graph()
    v1 = GraphVertex(1, 1:2)
    obj = Object(1:2, (args...) -> O)
    v2 = GraphVertex(2, obj)
    return v1.object.opts[:_vertex_idx] == 1 && v2.object.opts[:_vertex_idx] == 2
end