function check_graph_render()
    v = Video(10, 10)
    Background(1:70, (args...)->O)
    g = JGraph(true, 200, 200)
    v1 = GraphVertex(1, 1:2)
    v2 = GraphVertex(2, 1:2)
    e1 = GraphEdge(1, 2, 1:2)
    a = 1
    style1 = (args...; kw...) -> ()
    style2 = (video, object, args...; kw...) -> begin @register_style_opts object a end
    @add_styles v1 [:style1=>style1]
    @add_styles v2 [:style2=>style2]
    @add_styles e1 [:style1=>style1, :style2=>style2]
    path = "/tmp/$(round(Int64, time() * 1000))"
    render(v; pathname="/tmp/$(round(Int64, time() * 1000)).gif", 
              tempdirectory=path, framerate=1)
    return length(readdir(path)) == 71
end
