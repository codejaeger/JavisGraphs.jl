"""
    WeightedGraph

Utility graph type to store one extra property with vertices and edges.
"""
mutable struct WeightedGraph{T} <: AbstractGraph{T}
    graph::AbstractGraph{T}
    vertex_w::Dict{T,Any}
    edge_w::Dict{Pair{T,T},Any}
end

Base.convert(::Type{WeightedGraph}, g::SimpleGraph) = WeightedGraph(g)
Base.convert(::Type{WeightedGraph}, g::SimpleDiGraph) = WeightedGraph(g)

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
    :add_vertex!,
    :add_edge!,
    :rem_vertex!,
    :rem_edge!
]
    eval(quote
        Graphs.$extend(wg::WeightedGraph, args...) = $extend(wg.graph, args...)
    end)
end

"""
    add_vertex!(wg::WeightedGraph)
    add_vertex!(wg::WeightedGraph, weight::Any)
"""
function Graphs.add_vertex!(wg::WeightedGraph, weight::Any)
    check = add_vertex!(wg.graph)
    if check
        wg.vertex_w[nv(wg.graph)] = weight
    end
    return check
end

"""
    rem_vertex!(wg::WeightedGraph, vertex)
"""
function Graphs.rem_vertex!(wg::WeightedGraph{T}, vertex::T) where {T}
    check = rem_vertex!(wg.graph, vertex)
    if check
        for i in vertex:nv(wg.graph)
            if i == nv(wg.graph)
                delete!(wg.vertex_w, i)
                break
            end
            wg.vertex_w[i] = wg.vertex_w[i + one(T)]
        end
    end
    return check
end

"""
    add_edge!(wg::WeightedGraph, from_vertex, to_vertex)
    add_edge!(wg::WeightedGraph, from_vertex, to_vertex, weight::Any)
"""
function Graphs.add_edge!(wg::WeightedGraph{T}, from_vertex::T, to_vertex::T, weight::Any) where {T}
    check = add_edge!(wg.graph, from_vertex, to_vertex)
    if check
        wg.edge_w[(from_vertex, to_vertex)] = weight
    end
    return check
end

"""
    rem_edge!(wg::WeightedGraph{T}, from_vertex, to_vertex)
"""
function Graphs.rem_edge!(wg::WeightedGraph{T}, from_vertex::T, to_vertex::T) where {T}
    check = rem_edge!(wg.graph, from_vertex, to_vertex)
    if check
        delete!(wg.edge_w, (from_vertex, to_vertex))
    end
    return check
end

"""
    get_prop(wg::WeightedGraph, vertex::Int)
    get_prop(wg::WeightedGraph, from_vertex::Int, to_vertex::Int)
"""
function get_prop(wg::WeightedGraph, vertex::Int)
    return get(wg.vertex_w, vertex, nothing)
end

function get_prop(wg::WeightedGraph, from_vertex::Int, to_vertex::Int)
    return get(wg.edge_w, from_vertex=>to_vertex, nothing)
end

"""
    set_prop!(wg::WeightedGraph, vertex::Int, prop)
    set_prop!(wg::WeightedGraph, from_vertex::Int, to_vertex::Int, prop)
"""
function set_prop!(wg::WeightedGraph, vertex::Int, prop::Any)
    wg.vertex_w[vertex] = prop
end

function set_prop!(wg::WeightedGraph, from_vertex::Int, to_vertex::Int, prop::Any)
    wg.edge_w[from_vertex=>to_vertex] = prop
end

"""
    weights(wg::WeightedGraph)
"""
weights(wg::WeightedGraph) = edge_props(wg)

"""
    vertex_props(wg::WeightedGraph)
"""
function vertex_props(wg::WeightedGraph)
    map((vertex) -> wg.vertex_w[vertex], vertices(wg))
end

"""
    edge_props(wg::WeightedGraph)
"""
function edge_props(wg::WeightedGraph)
    map((e) -> wg.edge_w[Pair(e)], edges(wg))
end
