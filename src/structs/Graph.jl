"""
    JGraph

Maintain the graph state comprising of nodes, edges, layout, animation ordering etc.

This will be a part of the Javis [`Object`](@ref) metadata, when a new graph is created.

# Fields
- `adjacency_list`: A light internal representation of the graph structure. Can be initialized with a known graph type.
    - For undirected graphs the underlying graph type used is `SimpleGraph` from [Graphs.jl]() and for directed graphs it is `SimpleDiGraph`.
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
JGraph(directed::Bool, width::Int, height::Int, frames=:same; layout::Symbol=:spring) =
    directed ? JGraph(ReferenceGraph(Graphs.SimpleDiGraph()), width, height, frames; layout=layout) :
    JGraph(ReferenceGraph(Graphs.SimpleGraph()), width, height, frames; layout=layout)

JGraph(directed::Bool, width::Int, height::Int, start_pos::Point, frames=:same; layout::Symbol=:spring) =
    directed ? JGraph(ReferenceGraph(Graphs.SimpleDiGraph()), width, height, frames, start_pos; layout=layout) :
    JGraph(ReferenceGraph(Graphs.SimpleGraph()), width, height, frames, start_pos; layout=layout)

"""
    JGraph(graph, width::Int, height::Int; <keyword arguments>)

Creates a Javis object for the graph and assigns its `Metadata` field to the object created by this struct.

# Arguments
- `graph`: A known data structure storing information about nodes, edges, properties, etc.
    - Graph types of type `AbstractGraph` from the [Graphs.jl]() package are supported.
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
    frames=:same,
    start_pos::Point=O;
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
    object = Object(frames, get_draw(:graph), start_pos; _graph_idx = length(GRAPHS)+1)
    opts = Dict{Symbol, Any}()
    opts[:styles] = styles
    object.opts[:_style_opts_cache] = Dict{Symbol, Any}()
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
        for (k, _) in el.style_property_map
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

function Graphs.edges(g::JGraph, in_order=false)
    e = []
    if !in_order
        return g.ordering[map(e -> get_prop(g.graph.adjacency_graph, src(e), dst(e)), edges(g.graph.adjacency_graph))]
    end
    for el in g.ordering
        if el isa AbstractGraphEdge
            push!(e, el)
        end
    end
    return e
end

function Graphs.vertices(g::JGraph, in_order=false)
    if !in_order
        return g.ordering[map(v -> get_prop(g.graph.adjacency_graph, v), vertices(g.graph.adjacency_graph))]
    end
    v = []
    for el in g.ordering
        if el isa AbstractGraphVertex
            push!(v, el)
        end
    end
    return v
end

function Graphs.neighbors(g::JGraph, v::Integer; strict=false)
    n = copy(Graphs.neighbors(g.graph.adjacency_graph, v))
    if strict
        filter!(x -> x ≠ v, n)
    end
    return map(x -> g.ordering[x], get_prop.([g.graph.adjacency_graph], n))
end

function _global_layout(video, object, frame; kwargs...)
    g = GRAPHS[object.opts[:_graph_idx]]
    if frame == first(get_frames(object))
        layout_x = []
        layout_y = []
        if g.layout == :none
            object.opts[:layout_coords] = Vector{Point}()
            for v in vertices(g)
                push!(object.opts[:layout_coords], v.object.opts[:position])
            end
        else
            if nv(g.graph.adjacency_graph) <= 1
                layout_x, layout_y = [O], [O]
            elseif g.layout == :spring
                layout_x, layout_y = spring_layout(g.graph.adjacency_graph.graph)
            elseif g.layout == :spectral
                # Check special property layout_weight is defined on edges and collect weights
                weights = map(
                    (e) -> get(e.object.opts, :weight, 1),
                    edges(g, true),
                )
                # ToDo: Why does just g.graph.adjacency_graph not work? (is_directed not implemented error)
                layout_x, layout_y = spectral_layout(g.graph.adjacency_graph.graph, weights)
            end
            # Coordinates are between -1 and 1
            coords = map((p) -> Point(p), collect(zip(layout_x, layout_y)))
            # Scale to graph dimensions
            coords = coords .* [(g.width/2, g.height/2)]
            object.opts[:layout_coords] = coords
        end
    end
    # Now assign positions back to all nodes
    for (idx, v) in  enumerate(vertices(g))
        v.object.opts[:position] = object.opts[:layout_coords][idx] + object.start_pos
    end
    # Define keyword arguments for edges defining endpoint position
    for e in edges(g)
        from_vertex = g.ordering[get_prop(g.graph.adjacency_graph, e.from_vertex.vertex_id)]
        to_vertex = g.ordering[get_prop(g.graph.adjacency_graph, e.to_vertex.vertex_id)]
        # ToDo: Do we need to set these?
        e.object.opts[:p1] = from_vertex.object.opts[:position]
        e.object.opts[:p2] = to_vertex.object.opts[:position]
        e.object.opts[:from_vertex_bbx] = get(from_vertex.object.opts, :bounding_box, (O, O) .+ e.object.opts[:p1])
        e.object.opts[:to_vertex_bbx] = get(to_vertex.object.opts, :bounding_box, (O, O) .+ e.object.opts[:p2])
    end
end
