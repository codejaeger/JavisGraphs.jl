mutable struct ReferenceGraph
    graph
    adjacency_graph::WeightedGraph
    get_vertex_property::Function
    get_edge_property::Function
    edge_property_limits::Dict{Symbol,Any} # Any to allow lists, ranges, tuples (first and second must be defined on it)
    vertex_property_limits::Dict{Symbol,Any}
end

function ReferenceGraph(
    g::AbstractGraph;
    get_vertex_property=(args...)->nothing,
    get_edge_property=(args...)->nothing,
    edge_property_limits=Dict{Symbol, Any}(),
    vertex_property_limits=Dict{Symbol, Any}()
)
    adjacency_graph = is_directed(g) ? SimpleDiGraph(g) : SimpleGraph(g)
    return ReferenceGraph(g, deepcopy(adjacency_graph), get_vertex_property, get_edge_property, vertex_property_limits, edge_property_limits)
end

function ReferenceGraph(
    g,
    adjacency_matrix;
    get_vertex_property=(args...)->nothing,
    get_edge_property=(args...)->nothing,
    edge_property_limits=Dict{Symbol, Any}(),
    vertex_property_limits=Dict{Symbol, Any}()
)
    adjacency_graph = graph_from_matrix(adjacency_matrix)
    return ReferenceGraph(g, adjacency_graph, get_vertex_property, get_edge_property, vertex_property_limits, edge_property_limits)
end

