mutable struct ReferenceGraph
    graph
    adjacency_graph::WeightedGraph
    get_node_property::Function
    get_edge_property::Function
    edge_property_limits::Dict{Symbol,Any} # Any to allow lists, ranges, tuples (first and second must be defined on it)
    node_property_limits::Dict{Symbol,Any}
end

function ReferenceGraph(g::AbstractGraph)
    adjacency_graph = is_directed(g) ? SimpleDiGraph(g) : SimpleGraph(g)
    return ReferenceGraph(g, deepcopy(adjacency_graph), (args...)->nothing, (args...)->nothing, Dict{Symbol, Any}(), Dict{Symbol, Any}())
end
