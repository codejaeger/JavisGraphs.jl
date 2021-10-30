"""
    JGraph

Maintain the graph state comprising of nodes, edges, layout, animation ordering etc.

This will be a part of the Javis [`Object`](@ref) metadata, when a new graph is created.

# Fields
- `adjacency_list`: A light internal representation of the graph structure. Can be initialized with a known graph type.
    - For undirected graphs the underlying graph type used is `SimpleGraph` from [LightGraphs.jl]() and for directed graphs it is `SimpleDiGraph`.
- `width::Int`: The width of the graph on the canvas.
- `height::Int`: The height of the graph on the canvas.
- `mode::Symbol`: The animation of the graph can be done in two ways.
    - `static`: A lightweight animation which does not try to animate every detail during adding and deletion of nodes.
    - `dynamic`: The graph layout change is animated on addition of a new node. Can be computationally heavy depending on the size of graph.
- `layout::Symbol`: The graph layout to be used. Can be one of :-
    - `:none`
    - `:spring`
    - `:spectral`
- `get_node_attribute`: A function that enables fetching properties defined for nodes in the input graph data structure.
    - Required only when a node property like `cost` needs to be mapped to a drawing property like `radius`.
- `get_edge_attribute`: Similar to `get_node_attribute` but for edge properties.
- `ordering`: Store the relative ordering used to add nodes and edges to a graph using [`GraphNode`](@ref) and [`GraphEdge`](@ref)
    - If input graph is of a known type, defaults to a simple BFS ordering starting at the root node.
- `node_property_limits`: The minima and maxima calculated on the node properties in the input graph.
    - This is internally created and updated when [`updateGraph`](@ref) or the final render function is called.
    - This is skipped for node properties of non-numeric types.
    - Used to scale drawing property values within sensible limits.
- `edge_property_limits`: The minima and maxima calculated on the edge properties in the input graph.
    - Similar to `node_attribute_fn`.
"""
struct JGraph <: AbstractJavisGraph
    width::Int
    height::Int
    mode::Symbol
    layout::Symbol
    graph::ReferenceGraph
    object::AbstractObject
    opts::Dict{Symbol, Any}
    ordering::Vector{AbstractGraphElement}
end

GRAPHS = Vector{AbstractJavisGraph}()
CURRENT_GRAPH = Array{AbstractJavisGraph, 1}()

"""
    JGraph(directed::Bool, width::Int, height::Int)

Create an empty graph on the canvas.
"""
JGraph(directed::Bool, width::Int, height::Int, frames=:same) =
    directed ? JGraph(ReferenceGraph(LightGraphs.SimpleDiGraph()), width, height, frames) :
    JGraph(ReferenceGraph(LightGraphs.SimpleGraph()), width, height, frames)

JGraph(directed::Bool, width::Int, height::Int, frames=:same; layout::Symbol=:none) =
    directed ? JGraph(ReferenceGraph(LightGraphs.SimpleDiGraph()), width, height, frames; layout=layout) :
    JGraph(ReferenceGraph(LightGraphs.SimpleGraph()), width, height, frames; layout=layout)

"""
    JGraph(graph, width::Int, height::Int; <keyword arguments>)

Creates a Javis object for the graph and assigns its `Metadata` field to the object created by this struct.

# Arguments
- `graph`: A known data structure storing information about nodes, edges, properties, etc.
    - Graph types of type `AbstractGraph` from the [LightGraphs.jl]() package are supported.
    - Using this eliminates the requirement to create nodes and edges separately.
- `width::Int`: Size of the graph along the horizontal direction.
- `height::Int`: Size of the graph along the vertical direction.

# Keywords
- `mode`: `:static` or `:dynamic`. Default is `:static`.
- `layout`: `:none`, `:spring` or `:spectral`. Default is `:spring`.
- `get_node_attribute::Function`: A `Function` with a signature `(graph, node::Int, attr::Any)::Any`
    - `graph` is the object containing node properties
    - Returns a value corresponding to the type of the node property `attr`.
        - Must be either a Julia primitive type or `String`.
- `get_edge_attribute::Function`: A `Function` with a signature `(graph, from_node::Int, to_node::Int, attr::Any)::Any`
    - Similar to `get_node_attribute`.

# Examples
```julia
using Javis
function ground()
    background("white")
    sethue("black")
end

video = Video(300, 300)
Background(1:100, ground)
# A star graph
graph = [[2, 3, 4, 5, 6], [], [], [], [], []]
ga = @Object(1:100, JGraph(false, 100, 100), O)
render(video; pathname="graph_animation.gif")
```

# Implementation
To be filled in ...

"""
function JGraph(
    graph::ReferenceGraph,
    width::Int,
    height::Int,
    frames=:same;
    mode::Symbol = :static,
    layout::Symbol = :spring
)
    # Check available layouts
    if !(layout in [:none, :spring, :spectral])
        layout = :spring
        @warn "Unknown layout '$(layout)', defaulting to a spring layout"
    end

    if mode == :static
        styles = [_global_property_limits, _global_layout]
    elseif mode == :dynamic
        styles = [_global_property_limits]
    end
    object = Object(frames, get_draw(:graph); _graph_idx = length(GRAPHS)+1)
    opts = Dict{Symbol, Any}()
    opts[:styles] = styles
    jgraph = JGraph(
        width,
        height,
        mode,
        layout,
        graph,
        object,
        opts,
        Vector{AbstractGraphElement}(),
    )
    push!(GRAPHS, jgraph)
    if isempty(CURRENT_GRAPH)
        push!(CURRENT_GRAPH, jgraph)
    else
        CURRENT_GRAPH[1] = jgraph
    end
    return jgraph
end

function _global_property_limits(video, object, frames; kwargs...)
    g = GRAPHS[object.opts[:_graph_idx]]
    for el in g.ordering
        get_property = typeof(el) <: AbstractGraphVertex ? g.graph.get_node_property : g.graph.get_edge_property
        limits = typeof(el) <: AbstractGraphVertex ? g.graph.node_property_limits : g.graph.edge_property_limits
        for (k, _) in el.property_style_map
            val = get_property(k)
            if !(typeof(val) <: Real)
                throw("Cannot calculate limits. Property $(k) of $(typeof(el)) is not of `Real` type")
            end
            if !(k in keys(limits))
                limits[k] = (val, val)
            end
            limits[k] = (min(limits[k][1], val), max(limits[k][2], val))
        end
    end
end

function edges(g::JGraph)
    e = []
    
    for el in g.ordering
        if el isa AbstractGraphEdge
            push!(e, el)
        end
    end
    return e
end

function nodes(g::JGraph)
    e = []
    for el in g.ordering
        if el isa GraphNode
            push!(e, el)
        end
    end
    return e
end

function _global_layout(video, object, frame; kwargs...)
    # g = GRAPHS[object.opts[:_idx]]
    # if frame == first(get_frames(object))
    #     layout_x = []
    #     layout_y = []
    #     if g.layout == :spring
    #         # Check due to some errors in calling spring_layout with an empty graph
    #         if nv(g.adjacency_list.graph) > 0
    #             layout_x, layout_y = spring_layout(g.adjacency_list)
    #         end
    #     elseif g.layout == :spectral
    #         # Check special property layout_weight is defined on edges and collect weights
    #         weights = map(
    #             (e) -> get(e.opts, :layout_weight, 1),
    #             edges(g),
    #         )
    #         if nv(g.adjacency_list) > 0
    #             layout_x, layout_y = spectral_layout(g.adjacency_list, weights)
    #         end
    #     end
    #     if g.layout == :none
    #         object.opts[:layout] = Vector{Point}()
    #         for (idx, n) in enumerate(nodes(g.adjacency_list))
    #             push!(object.opts[:layout], object.opts[:position])
    #         end
    #     else
    #         # Normalize coordinates between -0.5 and 0.5
    #         coords = map((p) -> Point(p), collect(zip(layout_x, layout_y))) .- [(0.5, 0.5)]
    #         # Scale to graph dimensions
    #         coords = coords .* [(g.width, g.height)]
    #         object.opts[:layout] = coords
    #     end
    # end
    # # Now assign positions back to all nodes
    # for (idx, p) in enumerate(nodes(g.adjacency_list))
    #     g.ordering[p].meta.opts[:position] = object.opts[:layout][idx] + object.start_pos
    # end
    # # Define keyword arguments for edges defining endpoint position
    # for (_, p) in enumerate(edges(g.adjacency_list))
    #     from_node = get_prop(g.adjacency_list, g.ordering[p].from_node.node)
    #     to_node = get_prop(g.adjacency_list, g.ordering[p].to_node.node)
    #     g.ordering[p].opts[:p1] = g.ordering[from_node].meta.opts[:position]
    #     g.ordering[p].opts[:p2] = g.ordering[to_node].opts[:position]
    #     g.ordering[p].opts[:from_node_bbx] = get(g.ordering[from_node].opts, :bounding_box, (O, O))
    #     g.ordering[p].opts[:to_node_bbx] = get(g.ordering[to_node].opts, :bounding_box, (O, O))
    # end
end
