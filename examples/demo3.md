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
Background(1:150, ground)

g = @Object 1:150 JGraph(true, 100, 100, :spring) Point(60, 60)

adjacency_list = [[1, 2, 3, 4, 5, 6],
                  [7, 8],
                  [7, 8],
                  [],[],[],[],[]]
coords = []
for i in 1:length(adjacency_list)
    if i%2 == 0
        @Graph g i*10:150 GraphVertex(i, [node(Point(-(9-i)*10, -(i+5)*(i+5))), node_shape(:circle, true, radius=12), node_fill(:color, "red"), node_text("1", :top)]) O
    else
        @Graph g i*10:150 GraphVertex(i, [node(Point((9-i)*10, (i+5)*(i+5))), node_shape(:rectangle, true, width=20, height=20), node_fill(:color, "yellow"), node_text(L"""%$i""", :inside), node_border("green", 2)]) O
    end
end
count = 0
for i in 1:length(adjacency_list)
    for j in adjacency_list[i]
        @Graph g 15+count*10:150 GraphEdge(i, j, [edge_shape(:line, center_offset=16, end_offsets=(2, 2)), edge_style(color="blue", linewidth=2), edge_arrow(), edge_label("$(i)->$(j)")]) O
        count+=1
    end
end

render(video; pathname="demo3.gif")
```

![Demo](demo3.gif)