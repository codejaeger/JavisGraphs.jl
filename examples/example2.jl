include("examples/graph_animations/animate_graph.jl")

function ground(args...)
    background("white")
    sethue("black")
end

demo = Video(300, 300)
Background(1:300, ground)
g = SimpleDiGraph(6)
add_edge!(g, 1, 2)
add_edge!(g, 1, 3)
add_edge!(g, 1, 4)
add_edge!(g, 1, 5)
add_edge!(g, 1, 6)
animate_graph(g, :spring, :incremental)
animate_node(1)
for j in 2:6
    animate_node(j)
    animate_edge(1, j)
end
render(demo; pathname="example2.gif")