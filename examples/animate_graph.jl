using Javis
using LightGraphs
using GraphPlot
using NetworkLayout:Buchheim
using SparseArrays
using MetaGraphs

include("GraphAnimation.jl")
include("utils.jl")

function animate_graph(graph::AbstractGraph, layout::Symbol, mode::Symbol)
    if size(CURRENT_GRAPH)[1] == 0 || CURRENT_GRAPH[1].graph != graph
        ga = GraphAnimation(graph, mode)
        push!(CURRENT_GRAPH, ga)
    else
        mode = :rearrange
    end
    w = 300
    h = 300
    if layout == :spring
        lx, ly = spring_layout(graph).*(w/5, h/5)
    elseif layout == :tree
        a, b, _ = findnz(adjacency_matrix(graph))
        adj = adjacency_list([i for i in zip(a, b)], nv(graph))
        pts = Buchheim.layout(adj)
        lx = [i[2] for i in pts].*(w/8)
        ly = [i[1] for i in pts].*(h/8)
    end
    setlayout(lx, ly)
    if mode == :rearrange
        # Add easing between 2 network graph arrangements
        g = CURRENT_GRAPH[1]
        startframe = g.frames
        for elem in g.ordering
            if typeof(elem)==Int
                # translate_anim = rotate_anim = Animation(
                #     [0, 1],
                #     [0, Point(lx[elem], ly[elem])],
                #     [sineio()],
                # )
                act!(get_prop(g.animated_graph, elem, :object), Action(RFrames(startframe:startframe+5), anim_translate(lx[elem], ly[elem])))

            else
                act!(get_prop(g.animated_graph, Edge(elem[1], elem[2]), :object), Action(RFrames(startframe:startframe+1), disappear(:fade)))
                act!(get_prop(g.animated_graph, Edge(elem[1], elem[2]), :object), Action(RFrames(startframe+4:startframe+5), appear(:fade)))
            end
        end
    elseif mode == :whole
        # Default graph animation
        ordering = ga.ordering
        for elem in ordering
            if typeof(elem) == Int
                animate_node(elem)
            else
                animate_edge(elem[1], elem[2])
            end
        end
    elseif mode == :incremental
        # Do nothing for incremental
    elseif mode == :dynamic
        # Dynamically create graph using NetworkLayout's Layout iterator
        # https://github.com/JuliaGraphs/NetworkLayout.jl#iterator 
    end
end

function draw_node(pos)
    sethue("black")
    circle(pos, 5, :fill)
    return pos
end

function animate_node(node_id::Int)
    node = Object(RFrames(5:500, true), (args...)->draw_node(O), get_prop(CURRENT_GRAPH[1].animated_graph, node_id, :position))
    act!(node, Action(1:5, appear(:fade)))
    set_prop!(CURRENT_GRAPH[1].animated_graph, node_id, :object, node)
    if CURRENT_GRAPH[1].mode == :incremental
        push!(CURRENT_GRAPH[1].ordering, node_id)
    end
    CURRENT_GRAPH[1].frames += 5
    return node
end

function draw_edge(a, b)
    setdash("solid")
    sethue("black")
    line(a, b, :stroke)
end

function animate_edge(from_node::Int, to_node::Int)
    # If node not present in animated grtah create later for ordering
    g = CURRENT_GRAPH[1].animated_graph
    a = get_prop(g, from_node, :object)
    b = get_prop(g, to_node, :object)
    edge = Object(RFrames(5:500, true), (args...) -> draw_edge(pos(a), pos(b)))
    act!(edge, Action(1:5, appear(:fade)))
    set_prop!(CURRENT_GRAPH[1].animated_graph, Edge(from_node, to_node), :object, edge)
    if CURRENT_GRAPH[1].mode == :incremental
        push!(CURRENT_GRAPH[1].ordering, (from_node, to_node))
    end
    CURRENT_GRAPH[1].frames += 5
    return edge
end
