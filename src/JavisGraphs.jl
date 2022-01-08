module JavisGraphs

import Base
using Javis: isempty, Frames, get_frames, AbstractObject
using Javis
import Javis: text
using LightGraphs
import LightGraphs: weights, add_vertex!, rem_vertex!, add_edge!, rem_edge!
using LaTeXStrings
using GraphPlot

abstract type AbstractJavisGraphElement end
abstract type AbstractJavisGraph <: AbstractJavisGraphElement end
abstract type AbstractGraphElement <: AbstractJavisGraphElement end
abstract type AbstractGraphVertex <: AbstractGraphElement end
abstract type AbstractGraphEdge <: AbstractGraphElement end

include("utils.jl")

include("structs/WeightedGraph.jl")
include("structs/ReferenceGraph.jl")
include("structs/Graph.jl")
include("structs/GraphVertex.jl")
include("structs/GraphEdge.jl")

include("node_styles.jl")
include("edge_styles.jl")
include("graph_animations.jl")

# Export each function from Javis
for func in names(Javis; imported = true)
    eval(Meta.parse("import Javis." * string(func)))
    eval(Expr(:export, func))
end

export JGraph, WeightedGraph, ReferenceGraph, GraphVertex, GraphEdge

export edges, vertices, register_style_opts, add_styles, get_draw

export node_shape, node_text, node_fill, node_border

export edge_shape, edge_style, edge_arrow, edge_text

# Export each function from Luxor
for func in names(LightGraphs; imported = true)
    eval(Meta.parse("import LightGraphs." * string(func)))
    eval(Expr(:export, func))
end

export convert, @add_styles, @register_style_opts

end # module