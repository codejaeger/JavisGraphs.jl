using JavisGraphs
using LaTeXStrings

function ground(args...)
    background("white")
    sethue("black")
end

demo = Video(500, 500)
Background(1:100, ground)
g = JGraph(true, 400, 400, O, 1:100; layout=:spring)
for i in 1:6
    v = GraphVertex(i, 1:100)
    @add_styles v [node_shape(:circle, true; dimensions=(30)), node_text_style(fontsize=20), node_text(string(L"""\sqrt{5}"""), :inside, angle=10.0), node_fill(:image, "/Users/mac/Jan-Jun-22/julia/packages/JavisGraphs/JavisGraphs/examples/football.png"), node_border()]
end
for (i, j) in [(1, 1), (1, 2), (2, 1), (1, 3), (2, 2), (1, 4), (2, 5), (3, 5), (2, 6), (1, 6)]
    e = GraphEdge(i, j, 2:100)
    @add_styles e [edge_style(), edge_shape(:curved), edge_arrow(start=true), edge_text("$i->$j", position=0.6)]
end
# GraphVertex(2, 1:200)
# GraphVertex(3, 1:200)
# GraphVertex(4, 1:200)
# GraphVertex(5, 1:200)
# GraphVertex(6, 1:200)
# GraphEdge(1, 2, 1:200)
# GraphEdge(1, 3, 1:200)
# GraphEdge(1, 4, 1:200)
# GraphEdge(2, 5, 1:200)
# GraphEdge(3, 5, 1:200)
# GraphEdge(2, 6, 1:200)
# GraphEdge(1, 6, 1:200)
# animate_graph(g, :spring, :whole)
# animate_graph(g, :tree, :whole)
render(demo; pathname="examples/example1.gif")


# demo = Video(500, 500)
# function ground(args...)
#     background("white")
#     sethue("black")       
# end
# Background(1:200, ground)
# g = JGraph(true, 100, 100, 1:200)
# v = GraphVertex(1, 1:200)
# @add_styles v [node_shape(;dimensions=Tuple(5)), node_border()]
# v = GraphVertex(2, 1:200)
# @add_styles v [node_shape(;dimensions=Tuple(5)), node_border()]
# v = GraphVertex(3, 1:200)
# @add_styles v [node_shape(;dimensions=Tuple(5)), node_border()]
# v = GraphVertex(4, 1:200)
# @add_styles v [node_shape(;dimensions=Tuple(5)), node_border()]
# v = GraphVertex(5, 1:200)
# @add_styles v [node_shape(;dimensions=Tuple(5)), node_border()]
# v = GraphVertex(6, 1:200)
# @add_styles v [node_shape(;dimensions=Tuple(5)), node_border()]
# v = GraphVertex(7, 1:200)
# @add_styles v [node_shape(;dimensions=Tuple(5)), node_border()]
# v = GraphVertex(8, 1:200)
# @add_styles v [node_shape(;dimensions=Tuple(5)), node_border()]
# e = GraphEdge(1, 2, 1:200)
# @add_styles e [edge_shape()]
# e = GraphEdge(2, 3, 1:200)
# @add_styles e [edge_shape()]
# e = GraphEdge(1, 1, 1:200)
# @add_styles e [edge_shape()]
# render(demo; pathname="example1.gif")
