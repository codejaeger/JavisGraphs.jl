"""
    WeightedGraph

Utility graph type to store one extra property with nodes and edges.
"""
mutable struct WeightedGraph{T<:Number} <: AbstractGraph{T}
    graph::AbstractGraph{T}
    node_w::Dict{T,Any}
    edge_w::Dict{Pair{T,T},Any}
end

function WeightedGraph(graph::AbstractGraph{T}) where {T}
    return WeightedGraph(graph, Dict{T,Any}(), Dict{Pair{T,T},Any}())
end

for extend in [
    :is_directed,
    :edgetype,
    :ne,
    :nv,
    :vertices,
    :edges,
    :outneighbors,
    :inneighbors,
    :has_vertex,
    :has_edge,
]
    eval(quote
        LightGraphs.$extend(wg::WeightedGraph, args...) = $extend(wg.graph, args...)
    end)
end

"""
    add_vertex!(wg::WeightedGraph)
    add_vertex!(wg::WeightedGraph, weight::Any)
"""
add_vertex!(wg::WeightedGraph) = add_vertex!(wg.graph)

function add_vertex!(wg::WeightedGraph, weight::Any)
    check = add_vertex!(wg.graph)
    if check
        wg.node_w[nv(wg.graph)] = weight
    end
    return check
end

"""
    rem_vertex!(wg::WeightedGraph, node)
"""
function rem_vertex!(wg::WeightedGraph{T}, node::T) where {T}
    check = rem_vertex!(wg.graph, node)
    if check
        for i in node:nv(wg.graph)
            if i == nv(wg.graph)
                delete!(wg.node_w, i)
                break
            end
            wg.node_w[i] = wg.node_w[i + one(T)]
        end
    end
    return check
end

"""
    add_edge!(wg::WeightedGraph, from_node, to_node)
    add_edge!(wg::WeightedGraph, from_node, to_node, weight::Any)
"""
add_edge!(wg::WeightedGraph{T}, from_node::T, to_node::T) where {T} =
    add_edge!(wg.graph, from_node, to_node)

function add_edge!(wg::WeightedGraph{T}, from_node::T, to_node::T, weight::Any) where {T}
    check = add_edge!(wg.graph, from_node, to_node)
    if check
        wg.edge_w[(from_node, to_node)] = weight
    end
    return check
end

"""
    rem_edge!(wg::WeightedGraph{T}, from_node, to_node)
"""
function rem_edge!(wg::WeightedGraph{T}, from_node::T, to_node::T) where {T}
    check = rem_egde!(wg.graph, from_node, to_node)
    if check
        delete!(wg.edge_w, (from_node, to_node))
    end
    return check
end

"""
    get_prop(wg::WeightedGraph, node::Int)
    get_prop(wg::WeightedGraph, from_node::Int, to_node::Int)
"""
function get_prop(wg::WeightedGraph, node::Int)
    return get(wg.node_w, node, nothing)
end

function get_prop(wg::WeightedGraph, from_node::Int, to_node::Int)
    return get(wg.edge_w, from_node=>to_node, nothing)
end

"""
    set_prop!(wg::WeightedGraph, node::Int, prop)
    set_prop!(wg::WeightedGraph, from_node::Int, to_node::Int, prop)
"""
function set_prop!(wg::WeightedGraph, node::Int, prop::Any)
    wg.node_w[node] = prop
end

function set_prop!(wg::WeightedGraph, from_node::Int, to_node::Int, prop::Any)
    wg.edge_w[from_node=>to_node] = prop
end

"""
    weights(wg::WeightedGraph)
"""
weights(wg::WeightedGraph) = edge_props(wg)

"""
    node_props(wg::WeightedGraph)
"""
function node_props(wg::WeightedGraph)
    map((node) -> wg.node_w[node], vertices(wg))
end

"""
    edge_props(wg::WeightedGraph)
"""
function edge_props(wg::WeightedGraph)
    map((e) -> wg.edge_w[Pair(e)], edges(wg))
end
