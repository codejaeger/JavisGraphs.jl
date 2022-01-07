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
