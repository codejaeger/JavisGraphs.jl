# """
#     GraphVertex

# Store the drawing function and properties individual to the node.

# # Examples
# ```julia
# function draw(;position, radius)
#     circle(position, radius, :stroke)
#     return position
# end

# g_props = [Dict(:weight=>2, :neighbors=>[2])
#      Dict(:weight=>4, :neighbors=>[1])]
# ga = @Object(1:100, Graph(true, 100, 100), O)

# node1 = @Graph(ga, 1:50, GraphVertex(1, [draw_shape(:square, 12), draw_text(:inside, "123"), fill(:image, "./img.png"), custom_border()];
#                                      animate_on=:scale, property_style_map=Dict(:weight=>:radius)))

# # each of these draw_* functions return functionsn with specified change keywords like radius, border_color etc.
# # expose as many of these props as supported by Luxor drawing
# node2 = @Graph(ga, 50:100, GraphVertex(2, draw; animate_on=:scale, property_style_map=Dict(:weight=>:radius)))
# render(video; pathname="graph_node.gif")
# ```
# """
# struct GraphVertex
#     node::Integer
#     animate_on::Symbol
#     property_style_map::Dict{Any,Symbol}
#     opts::Dict{Symbol, Any}
# end

# """
#     GraphVertex(node::Integer, draw::Function; <keyword arguments>)
#     GraphVertex(graph::AbstractObject, node::Integer, draw::Function; <keyword arguments>)
#     GraphVertex(graph::AbstractObject, node::Integer, draw::Vector{Function}; <keyword arguments>)

# Create a graph node, specifying a drawing function or a property style map or both.

# # Arguments
# - `graph::AbstractObject`: The graph created using [`GraphAnimation`](@ref) to which this node should be added to.
# - `node::Integer`: A unique id representing the node being added to the graph.
#     - Currently, only numeric node ids are supported.
# - `draw::Function`: The drawing function used to draw the node.
#     - Implementing the drawing function in a special way to expose the drawing parameters helps in better animation.

# # Keywords
# - `animate_on::Symbol`: Control the animation effect on the nodes using pre-defined drawing parameters. Default is `:opacity`.
#     - For nodes, it can be 
#         - `:opacity`
#         - `:scale`
#     - For known graph types, it can additionally be 
#         - `:fill_color`
#         - `:border_color`
#         - `:radius`
# - `property_style_map::Dict{Any,Symbol}`: A mapping to of how node attributes map to node drawing styles.
# """
# GraphVertex(node::Integer, draw; kwargs...) =
#     GraphVertex(CURRENT_GRAPH[1], node, compile_draw_funcs(draw)...; kwargs...)

# GraphVertex(node::Integer, draw::Function; kwargs...) =
#     GraphVertex(CURRENT_GRAPH[1], node, draw; kwargs...)

# GraphVertex(graph::AbstractObject, node::Integer, draw; kwargs...) =
#     GraphVertex(graph, node, compile_draw_funcs(draw)...; kwargs...)

# function GraphVertex(
#     graph::AbstractObject,
#     node::Integer,
#     draw::Function,
#     opts::Dict{Symbol, Any} = Dict{Symbol, Any}(); # Make this a kw in the future
#     animate_on::Symbol = :opacity,
#     property_style_map::Dict{Any,Symbol} = Dict{Any,Symbol}(),
# )
#     g = graph.meta
#     if !(typeof(g) <: JGraph)
#         throw(ErrorException("Cannot define node since $(typeof(graph)) is not a `JGraph`"))
#     end
#     if g.mode == :static
#         if get_prop(g.adjacency_list, node) !== nothing
#             @warn "Node $(node) is already created on canvas. Recreating it will leave orphan node objects in the animation. To undo, call `rem_node!`"
#         end
#         draw_fn = draw
#         add_vertex!(g.adjacency_list.graph)
#         set_prop!(g.adjacency_list, nv(g.adjacency_list), length(g.ordering)+1)
#         graph_vertex = GraphVertex(node, animate_on, property_style_map, opts)
#         return draw_fn, graph_vertex
#     elseif g.mode == :dynamic
#     end
# end

# """
#     compile_draw_funcs(draw)

# Aggregate all the draw functions into one.
# """
# function compile_draw_funcs(draw)
#     draw_opts = Dict{Symbol, Any}()
#     draw_fns = Vector{Function}()
#     for d in draw
#         if typeof(d) <: Tuple
#             draw_opts = merge(draw_opts, d[1])
#             push!(draw_fns, d[2])
#         else
#             push!(draw_fns, d)
#         end
#     end
#     # Process drawing functions
#     combined_draw = (args...; kwargs...) -> begin
#         for d in draw_fns
#             d(args...; kwargs...)
#         end
#         clipreset()
#     end
#     return combined_draw, draw_opts
# end
