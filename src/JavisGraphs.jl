module JavisGraphs

import Base
#=
This funny mix of using and imports is required due to a coding style followed in JavisGraphs.
* When 'using' something from an external package, never make use of qualifiers like `Javis.` or `Graph.` for simplicity and to make sure there is no naming conflict introduced by JavisGraphs itself. Thus method calls in JavisGraphs.jl are distinguished by argument lists solely and not namespaces. (As of this date, Javis.jl and Graphs.jl are single moduled packages i.e. no intra-naming conflicts exists, and they have no inter-naming conflicts either.)
- Hence unexported types/functions like Javis.get_frames, Javis.Frames has to be used with `using Javis: Frames, ...`
- Rest of the exported names can be brought in simply with `using Javis`
* Only when writing methods for exported Javis/Graphs functions use the namespace qualifiers for clarity.
* ref - https://docs.julialang.org/en/v1/manual/modules/#using-and-import-with-specific-identifiers,-and-adding-methods
=#
using Javis: isempty, svgwh, get_frames, get_latex_svg, Frames, AbstractObject, LaTeXString
using Javis
import Javis: text, setopacity, setline, setdash, setfont, sethue
using Graphs
import Graphs: weights, add_vertex!, rem_vertex!, add_edge!, rem_edge!
using LaTeXStrings
using GraphPlot
using LinearAlgebra
using Random
using Colors: colormap
using OrderedCollections
using SparseArrays: SparseMatrixCSC

abstract type AbstractJavisGraphElement end
abstract type AbstractJavisGraph <: AbstractJavisGraphElement end
abstract type AbstractGraphElement <: AbstractJavisGraphElement end
abstract type AbstractGraphVertex <: AbstractGraphElement end
abstract type AbstractGraphEdge <: AbstractGraphElement end

include("constants.jl")
include("utils.jl")

include("structs/WeightedGraph.jl")
include("structs/ReferenceGraph.jl")
include("structs/Graph.jl")
include("structs/GraphVertex.jl")
include("structs/GraphEdge.jl")

include("styles/style.jl")
include("styles/shape.jl")

# include("vertex_styles.jl")
include("vertex_animations.jl")
# include("edge_styles.jl")
include("edge_animations.jl")

include("animations.jl")
include("overrides.jl")

# Export each function from Javis
for func in names(Javis; imported = true)
    eval(Meta.parse("import Javis." * string(func)))
    eval(Expr(:export, func))
end

export JGraph, WeightedGraph, ReferenceGraph, GraphVertex, GraphEdge

export edges, vertices, get_draw

# export vertex_shape, vertex_text_style, vertex_text, vertex_fill, vertex_border

# export edge_shape, edge_style, edge_arrow, edge_text

# Export each function from Luxor
for func in names(Graphs; imported = true)
    eval(Meta.parse("import Graphs." * string(func)))
    eval(Expr(:export, func))
end

export convert, @add_styles, @register_style_opts, graph_from_matrix

end # module