using Test
using JavisGraphs

include("graph.jl")

@test check_graph_build()

# @test check_graph_render()