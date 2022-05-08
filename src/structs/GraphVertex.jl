"""
    GraphVertex

Store the drawing function and properties individual to the node.

# Examples
```julia
function draw(;position, radius)
    circle(position, radius, :stroke)
    return position
end

g_props = [Dict(:weight=>2, :neighbors=>[2])
     Dict(:weight=>4, :neighbors=>[1])]
ga = @Object(1:100, Graph(true, 100, 100), O)

node1 = @Graph(ga, 1:50, GraphVertex(1, [draw_shape(:square, 12), draw_text(:inside, "123"), fill(:image, "./img.png"), custom_border()];
                                     animate_on=:scale, property_style_map=Dict(:weight=>:radius)))

# each of these draw_* functions return functionsn with specified change keywords like radius, border_color etc.
# expose as many of these props as supported by Luxor drawing
node2 = @Graph(ga, 50:100, GraphVertex(2, draw; animate_on=:scale, property_style_map=Dict(:weight=>:radius)))
render(video; pathname="graph_node.gif")
```
"""
struct GraphVertex <: AbstractGraphVertex
    vertex_id
    object::AbstractObject
    animate_on::Symbol
    style_property_map::Dict{Symbol, Any}
    opts::Dict{Symbol, Any}
end

GRAPH_VERTICES = Vector{AbstractGraphVertex}()
CURRENT_GRAPH_VERTEX = Array{AbstractGraphVertex, 1}()

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

GraphVertex(vertex_id::Integer, frames; kwargs...) =
    GraphVertex(CURRENT_GRAPH[1], vertex_id, frames; kwargs...)

GraphVertex(vertex_id::Integer, object::AbstractObject; kwargs...) =
    GraphVertex(CURRENT_GRAPH[1], vertex_id, object; kwargs...)

function GraphVertex(
    jg::JGraph,
    vertex_id::Integer,
    frames;
    kwargs...
)
    check_frames_within(jg.object.frames, frames, vertex_id)
    object = Object(frames, get_draw(:vertex); kwargs...)
    return GraphVertex(jg, vertex_id, object; kwargs...)
end

function GraphVertex(
    jg::JGraph,
    vertex_id::Integer,
    object::AbstractObject;
    animate_on::Symbol = :opacity,
    start_pos::Point = O,
    style_property_map::Dict{Any,Symbol} = Dict{Any,Symbol}()
)
    if jg.mode == :static
        if has_vertex(jg.graph.adjacency_graph, vertex_id)
            @warn "Vertex $(vertex_id) is already created on canvas. Recreating it will leave orphan vertex objects in the animation. To undo, call `rem_vertex!`"
        end
        object.opts[:_graph_idx] = jg.object.opts[:_graph_idx]
        object.opts[:_vertex_idx] = length(GRAPH_VERTICES) + 1
        if jg.layout == :none
            object.opts[:position] = start_pos
        end
        # ToDo: Create a mapping for vertex ids here
        # vertex id for the graph vertex need not be same as vertex id for adjacency graph
        # vertex_id = object.opts[:_vertex_idx] # this breaks test
        opts = Dict{Symbol, Any}()
        opts[:styles] = OrderedDict{Symbol, Function}()
        object.opts[:_style_opts_cache] = Dict{Symbol, Any}()
        object.opts[:draw_shapes] = Function[]
        object.opts[:shapes] = AbstractStyle[]
        object.opts[:shapes_frames] = GFrames[]
        add_vertex!(jg.graph.adjacency_graph)
        set_prop!(jg.graph.adjacency_graph, vertex_id, length(jg.ordering) + 1)
        vertex = GraphVertex(vertex_id, object, animate_on, style_property_map, opts)
        push!(GRAPH_VERTICES, vertex)
        push!(jg.ordering, vertex)
        if isempty(CURRENT_GRAPH_VERTEX)
            push!(CURRENT_GRAPH_VERTEX, vertex)
        else
            CURRENT_GRAPH_VERTEX[1] = vertex
        end
        return vertex
    elseif g.mode == :dynamic
    end
end
