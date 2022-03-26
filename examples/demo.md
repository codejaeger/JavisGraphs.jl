```julia
using JavisGraphs, LaTeXStrings

function edge(; p1, p2, kwargs...)
    # sethue("black")
    # ob = blend(p1, p2, "orange", "blue")
    # setblend(ob)
    line(p1, p2, :clip)
    rect(p1, (p2-p1)..., :fill)
    # rect(p1, p2, :fill)
    clipreset()
end

function vertex(position=O, color="black")
    sethue(color)
    circle(position, 10, :fill)
    return position
end

function ground(args...) 
    background("white")
    sethue("black")
end

video = Video(400, 400)
Background(1:300, ground)

g = JGraph(true, 300, 300, O, 1:150; layout=:spring)

adjacency_list = [[2, 3, 4, 5, 6],
                  [7, 8],
                  [7, 8],
                  [],[],[],[],[]]

for i in 1:length(adjacency_list)
    if i%2 == 0
        v = GraphVertex(i, i*10:300)
        @add_styles v [vertex_shape(:circle, true; dimensions=Tuple(12)),
                       vertex_fill(:image, "./examples/football.png"),
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
        @add_styles e [edge_style(), edge_shape(:curved)]
        count+=1
    end
end

render(video; pathname="demo.gif")
```

![Demo](demo.gif)