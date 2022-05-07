"""
    GraphEdge

# Examples
```julia
function draw(;position_1, position_2, line_width=5)
    setline(line_width)
    line(position_1, position_2, action=:stroke)
    return O
end
function e(g, node1, node2, attr)
    return g[node1][node2]
end

# g mimics an adjacency list with edge weights
g = [Dict(2=>5),
     Dict(1=>3)]
ga = GraphAnimation(g, true, 100, 100, O; get_edge_attribute=e)
node1 = Object(1:30, GraphNode(ga, 1; animate_on=:scale))
node2 = Object(10:40, GraphNode(ga, 2; animate_on=:scale))
edge = Object(30:60, GraphEdge(ga, 1, 2, draw; animate_on=:scale, property_style_map=Dict(""=>:line_width)))
render(video; pathname="graph_node.gif")
```
"""
struct GraphEdge <: AbstractGraphEdge
    from_vertex::AbstractGraphVertex
    to_vertex::AbstractGraphVertex
    object::AbstractObject
    animate_on::Symbol
    style_property_map::Dict{Symbol, Any}
    opts::Dict{Symbol, Any}
end

Base.convert(::Type{Pair}, x::AbstractGraphEdge) = Pair(x.from_vertex.vertex_id, x.to_vertex.vertex_id)

GRAPH_EDGES = Vector{AbstractGraphEdge}()
CURRENT_GRAPH_EDGE = Array{AbstractGraphEdge, 1}()

# """
#     GraphEdge(graph::AbstractObject, from_node::Int, to_node::Int, draw::Function; <keyword arguments>)

# Create a graph edge with additional drawing function and options.

# # Arguments
# - `graph::AbstractObject`: The graph created using [`Graph`](@ref) to which this edge should be added to.
# - `from_node::Int`
# - `to_node::Int`
# - `draw::Function`: The drawing function used to draw the edge.
#     - Implementing the drawing function in a special way to expose the drawing parameters helps in better animation.

# # Keywords
# - `animate_on::Symbol`: Control the animation effect on the edges using pre-defined drawing parameters
#     - For edges, it can be 
#         - `:opacity`
#         - `:line_width`
#         - `:length`
#     - For known graph types, it can additionally be 
#         - `:color`
#         - `:weights`: only possible for weighted graphs i.e. `SimpleWeightedGraphs`.
# - `properties_to_style_map::Dict{Any,Symbol}`: A mapping to of how edge attributes map to edge drawing styles.
# """
GraphEdge(from_vertex, to_vertex, args...; kwargs...) =
    GraphEdge(CURRENT_GRAPH[1], from_vertex, to_vertex, args...; kwargs...)

function GraphEdge(
    jg::JGraph,
    from_vertex::AbstractGraphVertex,
    to_vertex::AbstractGraphVertex,
    args...;
    kwargs...
)
    return GraphEdge(jg, from_vertex.vertex_id, to_vertex.vertex_id, args...; kwargs...)
end

function GraphEdge(
    jg::JGraph,
    from_vertex::Integer,
    to_vertex::Integer,
    frames;
    kwargs...
)
    check_frames_within(jg.object.frames, frames, from_vertex => to_vertex)
    object = Object(frames, get_draw(:edge); kwargs...)
    return GraphEdge(jg, from_vertex, to_vertex, object; kwargs...)
end

function GraphEdge(
    jg::JGraph,
    from_vertex::Integer,
    to_vertex::Integer,
    object::AbstractObject;
    animate_on::Symbol = :opacity,
    style_property_map::Dict{Any,Symbol} = Dict{Any,Symbol}()
)
    if jg.mode == :static
        if has_edge(jg.graph.adjacency_graph, from_vertex, to_vertex)
            @warn "Edge $(from_vertex)=>$(to_vertex) is already created on canvas. Recreating it will leave orphan edges in the animation. To undo, call `rem_edge!`"
        end
        object.opts[:_graph_idx] = jg.object.opts[:_graph_idx]
        object.opts[:_edge_idx] = length(GRAPH_EDGES) + 1
        opts = Dict{Symbol, Any}()
        opts[:styles] = OrderedDict{Symbol, Function}()
        object.opts[:_style_opts_cache] = Dict{Symbol, Any}()
        add_edge!(jg.graph.adjacency_graph, from_vertex, to_vertex)
        set_prop!(jg.graph.adjacency_graph, from_vertex, to_vertex, length(jg.ordering)+1)
        if !is_directed(jg.graph.adjacency_graph)
            set_prop!(jg.graph.adjacency_graph, to_vertex, from_vertex, length(jg.ordering)+1)
        end
        if from_vertex == to_vertex
            object.opts[:self_loop] = true
        elseif is_directed(jg.graph.adjacency_graph) && has_edge(jg.graph.adjacency_graph, to_vertex, from_vertex)
            object.opts[:loop] = true
            other_edge = jg.ordering[get_prop(jg.graph.adjacency_graph, to_vertex, from_vertex)]
            other_edge.object.opts[:loop] = true
        end
        from_vertex_object = jg.ordering[get_prop(jg.graph.adjacency_graph, from_vertex)]
        to_vertex_object = jg.ordering[get_prop(jg.graph.adjacency_graph, to_vertex)]
        edge = GraphEdge(from_vertex_object, to_vertex_object, object, animate_on, style_property_map, opts)
        push!(GRAPH_EDGES, edge)
        push!(jg.ordering, edge)
        if isempty(CURRENT_GRAPH_EDGE)
            push!(CURRENT_GRAPH_EDGE, edge)
        else
            CURRENT_GRAPH_EDGE[1] = edge
        end
        return edge
    elseif jg.mode == :dynamic
    end
end
