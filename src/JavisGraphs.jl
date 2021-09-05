module JavisGraphs


using Javis: isempty
using Javis
import Javis: render, AbstractObject
using LightGraphs
import LightGraphs: weights, add_vertex!, rem_vertex!, add_edge!, rem_edge!
using GraphPlot

abstract type AbstractJavisGraph end
abstract type AbstractGraphElement end
abstract type AbstractGraphNode <: AbstractGraphElement end
abstract type AbstractGraphEdge <: AbstractGraphElement end

include("utils.jl")
include("structs/Graph.jl")
include("structs/GraphVertex.jl")
include("structs/GraphEdge.jl")
include("structs/WeightedGraph.jl")

include("node_shapes.jl")
include("edge_shapes.jl")
include("graph_animations.jl")

for func in names(Javis; imported = true)
    eval(Meta.parse("import Javis." * string(func)))
    eval(Expr(:export, func))
end

export JGraph, ReferenceGraph

end # module