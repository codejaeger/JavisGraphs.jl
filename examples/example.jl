include("animate_graph.jl")

demo = Video(300, 200)
Background(1:1, ground)
g = SimpleDiGraph(6)
add_edge!(g, 1, 2)
add_edge!(g, 1, 3)
add_edge!(g, 1, 4)
add_edge!(g, 2, 5)
add_edge!(g, 3, 5)
add_edge!(g, 2, 6)
add_edge!(g, 1, 6)
animate_graph(g, :spread, :whole)