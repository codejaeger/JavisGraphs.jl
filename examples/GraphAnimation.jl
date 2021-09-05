mutable struct GraphAnimation
    graph::AbstractGraph
    ordering::Vector{Union{Int, Tuple{Int, Int}}}
    animated_graph::MetaGraph
    mode::Symbol
    frames::Int
end

const CURRENT_GRAPH = Array{GraphAnimation,1}()

function GraphAnimation(graph::AbstractGraph, mode::Symbol)
    animated_graph = MetaGraph(graph)
    ordering = Vector{Union{Int, Tuple{Int, Int}}}()
    if mode != :incremental
        ordering = get_order(LightGraphs.bfs_tree(graph, 1))
    end
    return GraphAnimation(graph, ordering, animated_graph, mode, 0)
end
