# # Extend the graph utility functions to support Javis objects having metadata of type `JGraph`
# for extend in [
#     :is_directed,
#     :edgetype,
#     :ne,
#     :nv,
#     :vertices,
#     :edges,
#     :outneighbors,
#     :inneighbors,
#     :has_vertex,
#     :has_edge,
# ]
#     eval(
#         quote
#             local func = $extend
#             LightGraphs.$extend(o::AbstractObject, args...) =
#                 typeof(o.meta) <: JGraph ? $extend(o.meta.adjacency_list, args...) :
#                 throw(
#                     "Cannot call $(func) on a object with meta of type $(typeof(o.meta))",
#                 )
#         end,
#     )
# end

# """
#     add_vertex!()

# Add a vertex to the canvas. The layout is regenerated depending upon the `mode` of the graph selected.

# The function syntax chosen is similar to `LightGraphs.add_vertex!`.
# """
# function add_vertex!() end

# """
#     rem_vertex!()

# Remove a vertex from the canvas. The layout is regenerated depending upon the `mode` of the graph selected.

# The function syntax chosen is similar to `LightGraphs.rem_vertex!`.
# """
# function rem_vertex!() end

# """
#     add_edge!()

# Add an edge to the canvas.

# The function syntax chosen is similar to `LightGraphs.add_edge!`.
# """
# function add_edge!() end

# """
#     rem_edge!()

# Remove an edge from the canvas.

# The function syntax chosen is similar to `LightGraphs.add_vertex!`.
# """
# function rem_edge!() end
