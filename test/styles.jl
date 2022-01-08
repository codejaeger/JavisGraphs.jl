style_graph = create_graph()
v = GraphVertex(1, 1:2)
w = GraphVertex(2, 1:2)

function check_node_shape()
    t1 = typeof(@test_throws ArgumentError node_shape(:rectangle)) == Test.Pass
    t2 = typeof(@test_throws ArgumentError node_shape(:circle)) == Test.Pass
    
    style1 = node_shape(:rectangle; dimensions=(1, 2))
    style2 = node_shape(:circle; dimensions=Tuple(1))
    
    l_v = length(v.opts[:styles])
    l_w = length(w.opts[:styles])
    
    @add_styles v [style1]
    @add_styles w [style2]

    render(Javis.CURRENT_VIDEO[1];tempdirectory = "images", pathname = "")

    t3 = length(v.opts[:styles]) - l_v == 1 && v.object.opts[:shape] == :rectangle
    t4 = length(w.opts[:styles]) - l_w == 1 && w.object.opts[:shape] == :circle
    return t1 && t2 && t3 && t4
end

function check_node_text()
    style1 = node_text("text")
    style2 = node_text(L"text")
    
    l_v = length(v.opts[:styles])
    l_w = length(w.opts[:styles])

    @add_styles v [style1]
    @add_styles w [style2]

    render(Javis.CURRENT_VIDEO[1];tempdirectory = "images", pathname = "")

    t1 = length(v.opts[:styles]) - l_v == 1 && haskey(v.object.opts, :text_box)
    t2 = length(w.opts[:styles]) - l_w == 1 && haskey(w.object.opts, :text_box)
    
    return t1 && t2
end

function check_node_fill()
    style1 = node_fill(:image, "julia-logo.png")
    style2 = node_fill(:color, "red")

    l_v = length(v.opts[:styles])
    l_w = length(w.opts[:styles])

    @add_styles v [style1]
    @add_styles w [style2]

    render(Javis.CURRENT_VIDEO[1];tempdirectory = "images", pathname = "")

    t1 = length(v.opts[:styles]) - l_v == 1 && haskey(v.object.opts, :fill_type)
    t2 = length(w.opts[:styles]) - l_w == 1 && haskey(w.object.opts, :fill_type)

    return t1 && t2
end

function check_node_border()
    style = node_border()

    l_v = length(v.opts[:styles])

    @add_styles v [style]

    render(Javis.CURRENT_VIDEO[1];tempdirectory = "images", pathname = "")

    t1 = length(v.opts[:styles]) - l_v == 1 && haskey(v.object.opts, :border_width)

    return t1
end

e = GraphEdge(1, 2, 1:2)
f = GraphEdge(2, 1, 1:2)
g = GraphEdge(2, 2, 1:2)

function check_edge_shape()
    style1 = edge_shape(end_offsets=(1, 1))
    style2 = edge_shape(:curved)
    style3 = edge_shape(:curved, end_offsets=(1, 1))

    l_e = length(e.opts[:styles])
    l_f = length(f.opts[:styles])
    l_g = length(g.opts[:styles])

    @add_styles e [style1]
    @add_styles f [style2]
    @add_styles g [style3]

    render(Javis.CURRENT_VIDEO[1];tempdirectory = "images", pathname = "")

    t1 = length(e.opts[:styles]) - l_e == 1 && haskey(e.object.opts, :shape)
    t2 = length(f.opts[:styles]) - l_f == 1 && f.object.opts[:shape] == :curved
    t3 = length(g.opts[:styles]) - l_g == 1 && g.object.opts[:end_offsets] == (1, 1)
    return t1 && t2 && t3
end

function check_edge_style()
    style = edge_style()

    l_e = length(e.opts[:styles])

    @add_styles e [style]

    render(Javis.CURRENT_VIDEO[1];tempdirectory = "images", pathname = "")

    t1 = length(e.opts[:styles]) - l_e == 1 && haskey(e.object.opts, :color)
    return t1
end

function check_edge_arrow()
    style1 = edge_arrow(start=true, finish=true)
    style2 = edge_arrow(finish=true)
    style3 = edge_arrow(start=true)

    l_e = length(e.opts[:styles])
    l_f = length(f.opts[:styles])
    l_g = length(g.opts[:styles])

    @add_styles e [style1]
    @add_styles f [style2]
    @add_styles g [style3]

    render(Javis.CURRENT_VIDEO[1];tempdirectory = "images", pathname = "")

    t1 = length(e.opts[:styles]) - l_e == 1 && haskey(e.object.opts, :arrow_color)
    t2 = length(f.opts[:styles]) - l_f == 1 && f.object.opts[:arrow_finish] == true
    t3 = length(g.opts[:styles]) - l_g == 1 && g.object.opts[:arrow_start] == true
    return t1 && t2
end

function check_edge_text()
    style1 = edge_text("test")

    l_e = length(e.opts[:styles])

    @add_styles e [style1]

    render(Javis.CURRENT_VIDEO[1];tempdirectory = "images", pathname = "")

    t1 = length(e.opts[:styles]) - l_e == 1 && haskey(e.object.opts, :text_content)
    return t1
end
