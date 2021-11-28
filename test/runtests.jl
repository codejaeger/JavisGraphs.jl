using Test
using JavisGraphs
using LightGraphs
using GraphPlot

include("graph.jl")
include("vertex.jl")
include("edge.jl")

@test create_weighted_graph()
@test create_reference_graph()
@test check_graph_build()
@test check_vertex_build()
@test check_edge_build()

function create_dummy_graph()
    g = create_graph()
    v1 = GraphVertex(1, 1:2)
    v2 = GraphVertex(2, 1:2)
    e1 = GraphEdge(1, 2, 1:2)
    e2 = GraphEdge(2, 1, 1:2)
    return g
end

include("utils.jl")
# @testset "Foo tests" begin
@test check_get_edges()
@test check_get_edges_unordered()
@test check_get_edges_ordered()
@test check_get_vertices()
@test check_get_draw()
# end;

include("render.jl")
@test check_graph_render()

@testset "Layout" begin check__global_layout() end
@test check_add_styles()
@test check_register_style_opts()
