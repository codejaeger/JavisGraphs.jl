function updateGraph!(jg::JGraph, ag::AbstractGraph)
end

function updateGraph!(
    jg::JGraph,
    g,
    adjacency_matrix;
    get_vertex_property=(args...)->nothing,
    get_edge_property=(args...)->nothing,
    edge_property_limits=Dict{Symbol, Any}(),
    vertex_property_limits=Dict{Symbol, Any}()
)
end

function updateGraph!(jg::JGraph, rg::ReferenceGraph)
end

function animate_inneighbors(v::GraphVertex)
end

function animate_outneighbors(v::GraphVertex)
end

function animate_neighbors(v::GraphVertex)
end

function animate_path(jg::JGraph, path::Vector{GraphEdge})
end

function animate_bfs(jg::JGraph, vertex::GraphVertex)
end

function animate_dfs(jg::JGraph, vertex::GraphVertex)
end