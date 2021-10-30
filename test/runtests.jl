using Test
using JavisGraphs
using LightGraphs

include("graph.jl")
include("vertex.jl")
include("edge.jl")

@test create_weighted_graph()
@test create_reference_graph()
@test check_graph_build()
@test check_vertex_build()
@test check_edge_build()

# @test check_graph_render()