```julia
using Javis, LaTeXStrings

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

g = JGraph(true, 200, 200, Point(60, 60), :same; layout=:spring)

adjacency_list = [[1, 2, 3, 4, 5, 6],
                  [7, 8],
                  [7, 8],
                  [],[],[],[],[]]
coords = []
for i in 1:length(adjacency_list)
    if i%2 == 0
        v = GraphVertex(i, i*10:300)
        @add_styles v [vertex_shape(:circle, true; dimensions=Tuple(12)),
                        vertex_fill(:color, "red"),
                        vertex_text("1", :top)
                       ]
    else
        v = GraphVertex(i, 15+i*10:300)
        @add_styles v [vertex_shape(:rectangle, true; dimensions=(20, 20)),
                        vertex_text(L"""%$i""", :inside),
                        vertex_fill(:color, "yellow"),
                       vertex_border("green", 2)
                       ]
    end
end

count = 0
for i in 1:length(adjacency_list)
    for j in adjacency_list[i]
        e = GraphEdge(i, j, 50+count*10:300)
        @add_styles e [edge_style(color="blue", linewidth=2), 
                        edge_shape(:line, center_offset=16, end_offsets=(2, 2)),
                        edge_arrow(),
                        edge_text("$(i)->$(j)")
                        ]
        count+=1
    end
end

render(video; pathname="demo3.gif")
```

![Demo](demo3.gif)