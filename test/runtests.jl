using Test
using JavisGraphs
using Graphs
using GraphPlot
using LaTeXStrings

include("graph.jl")
include("vertex.jl")
include("edge.jl")

@testset "Constructions" begin
    @test create_weighted_graph()
    @test create_reference_graph()
    @test check_graph_build()
    @test check_vertex_build()
    @test check_edge_build()
end

function create_dummy_graph()
    g = create_graph()
    v1 = GraphVertex(1, 1:2)
    v2 = GraphVertex(2, 1:2)
    e1 = GraphEdge(1, 2, 1:2)
    e2 = GraphEdge(2, 1, 1:2)
    return g
end

include("utils.jl")
@testset "Utils" begin
    @test check_get_edges()
    @test check_get_edges_unordered()
    @test check_get_edges_ordered()
    @test check_get_vertices()
    @test check_get_draw()
    @test check_graph_from_matrix()
    check_vertex_out_of_parent_range()
    check_edge_out_of_parent_range()
end

include("render.jl")
@testset "Render" begin
    @test check_graph_render()
end

@testset "Layout" begin 
    check__global_layout()
end

@testset "Style utils" begin
    @test check_add_styles()
    @test check_register_style_opts()
end

include("styles.jl")
@testset "vertex styles" begin
    @test check_vertex_shape()
    @test check_vertex_text()
    @test check_vertex_fill()
    @test check_vertex_border()
end

@testset "Edge styles" begin
    @test check_edge_shape()
    @test check_edge_style()
    @test check_edge_arrow()
    @test check_edge_text()
end