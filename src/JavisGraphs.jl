module JavisGraphs

import Base
using Javis: isempty, Frames, get_frames, AbstractObject
using Javis
import Javis: text, setopacity, setline, setdash, setfont, sethue
using Graphs
import Graphs: weights, add_vertex!, rem_vertex!, add_edge!, rem_edge!
using LaTeXStrings
using GraphPlot
using LinearAlgebra
using SparseArrays: SparseMatrixCSC

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

include("vertex_styles.jl")
include("vertex_animations.jl")
include("edge_styles.jl")
include("edge_animations.jl")

include("animations.jl")
include("overrides.jl")

# Export each function from Javis
for func in names(Javis; imported = true)
    eval(Meta.parse("import Javis." * string(func)))
    eval(Expr(:export, func))
end

export JGraph, WeightedGraph, ReferenceGraph, GraphVertex, GraphEdge

export edges, vertices, register_style_opts, add_styles, get_draw

export vertex_shape, vertex_text_style, vertex_text, vertex_fill, vertex_border

export edge_shape, edge_style, edge_arrow, edge_text

# Export each function from Luxor
for func in names(Graphs; imported = true)
    eval(Meta.parse("import Graphs." * string(func)))
    eval(Expr(:export, func))
end

export convert, @add_styles, @register_style_opts

end # module