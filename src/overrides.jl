# Extend the graph utility functions to support Javis `JGraph`
for extend in [
    :is_directed,
    :edgetype,
    :ne,
    :nv,
    :outneighbors,
    :inneighbors,
    :has_vertex,
    :has_edge,
]
    eval(
        quote
            local func = $extend
            Graphs.$extend(jg::JGraph, args...) = $extend(jg.graph.adjacency_graph, args...)
        end
    )
end

"""
    add_vertex!()

Add a vertex to the canvas. The layout is regenerated depending upon the `mode` of the graph selected.

The function syntax chosen is similar to `Graphs.add_vertex!`.
"""
function Graphs.add_vertex!(jg::JGraph)
end

"""
    rem_vertex!()

Remove a vertex from the canvas. The layout is regenerated depending upon the `mode` of the graph selected.

The function syntax chosen is similar to `Graphs.rem_vertex!`.
"""
function Graphs.rem_vertex!(jg::JGraph, node::T) where {T}
end

"""
    add_edge!()

Add an edge to the canvas.

The function syntax chosen is similar to `Graphs.add_edge!`.
"""
function Graphs.add_edge!(jg::JGraph)
end

"""
    rem_edge!()

Remove an edge from the canvas.

The function syntax chosen is similar to `Graphs.rem_edge!`.
"""
function Graphs.rem_edge!(jg::JGraph, from_node::T, to_node::T) where {T}
end
