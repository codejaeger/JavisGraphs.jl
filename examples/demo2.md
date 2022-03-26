```julia
using JavisGraphs, LaTeXStrings

function edge(; p1, p2, kwargs...)
    sethue("black")
    line(p1, p2, :stroke)
end

function node(position)
    # Just return the node position
    return Dict(:position=>position), (args...; kwargs...) -> nothing
end

function ground(args...) 
    background("white")
    sethue("black")
end

video = Video(400, 400)
Background(1:300, ground)

g = JGraph(true, 300, 300, Point(60, 60), :same; layout=:none)

adjacency_list = [[2, 3, 4, 5, 6],
                  [7, 8],
                  [7, 8],
                  [],[],[],[],[]]
coords = []
for i in 1:length(adjacency_list)
    if i%2 == 0
        v = GraphVertex(i, i*10:300; start_pos=Point(-(9-i)*10, -(i+5)*(i+5)))
        @add_styles v [vertex_shape(:circle, true; dimensions=Tuple(12)),
                       vertex_fill(:image, "./examples/football.png"),
                       ]
        # @Graph g i*10:150 GraphVertex(i, [node(Point(-(9-i)*10, -(i+5)*(i+5))), node_shape(:circle, true, radius=12), node_fill(:image, "football.png")]) O
    else
        v = GraphVertex(i, 15+i*10:300; start_pos=Point((9-i)*10, (i+5)*(i+5)))
        @add_styles v [vertex_shape(:rectangle, true; dimensions=(20, 20)),
                        vertex_text(L"""%$i""", :inside),
                        vertex_fill(:color, "yellow"),
                       vertex_border("green", 2)
                       ]
        # @Graph g i*10:150 GraphVertex(i, [node(Point((9-i)*10, (i+5)*(i+5))), node_shape(:rectangle, true, width=20, height=20), node_fill(:color, "yellow"), node_text(L"""%$i""", :inside), node_border("green", 2)]) O
    end
end

count = 0
for i in 1:length(adjacency_list)
    for j in adjacency_list[i]
        e = GraphEdge(i, j, 50+count*10:300)
        @add_styles e [edge_style(), edge_shape(:curved)]
        count+=1
    end
end

render(video; pathname="demo2.gif")
```

![Demo](demo2.gif)