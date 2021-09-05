using Javis
using LightGraphs
using GraphPlot
using NetworkLayout:Buchheim
using SparseArrays
using MetaGraphs
using Animations

mutable struct GraphAnimation
    graph::AbstractGraph
    ordering::Vector{Union{Int, Tuple{Int, Int}}}
    animated_graph::MetaGraph
    mode::Symbol
    frames::Int
end

function GraphAnimation(graph::AbstractGraph, mode::Symbol)
    animated_graph = MetaGraph(graph)
    ordering = Vector{Union{Int, Tuple{Int, Int}}}()
    if mode != :incremental
        ordering = get_order(LightGraphs.bfs_tree(graph, 1))
    end
    return GraphAnimation(graph, ordering, animated_graph, mode, 0)
end

function setlayout(layout_x::Vector{Float64}, layout_y::Vector{Float64})
    for i in 1:size(layout_x)[1]
        set_prop!(CURRENT_GRAPH[1].animated_graph, i, :position, Point(layout_x[i], layout_y[i]))
    end
end

function get_order(tree)
    ordering = Vector{Union{Int, Tuple{Int, Int}}}()
    function bfs(root)
        push!(ordering, root)
        for i in neighbors(tree, root)
            bfs(i)
            push!(ordering, (root, i))
        end
    end
    bfs(1)
    return ordering
end

function adjacency_list(edge_list::Any, nodes::Int)
    adjacency_list = [Any[] for i in range(1; length=nodes)]
    for i in edge_list
        push!(adjacency_list[i[1]], i[2])
    end
    return adjacency_list
end

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

function ground(args...)
    background("white") # canvas background
    sethue("black") # pen color
end


CURRENT_GRAPH = Array{GraphAnimation,1}()
demo = Video(500, 500)
Background(1:700, ground)
g = SimpleDiGraph(6)
add_edge!(g, 1, 2)
add_edge!(g, 1, 3)
add_edge!(g, 1, 4)
add_edge!(g, 2, 5)
add_edge!(g, 3, 5)
add_edge!(g, 2, 6)
add_edge!(g, 1, 6)
animate_graph(g, :spring, :whole)
animate_graph(g, :tree, :whole)
render(demo; pathname="tutorial_1.gif")

# adj_list = Vector{Int}[   # adjacency list
#         [2,3,4],
#         [5,6],
#         [5],
#         [6],
#         [],
#         []
#       ]

# animate_graph(g, :tree, :whole)
# inside_circle = Object((args...) -> nodes(O, "black", :stroke, 140, "longdashed"))
