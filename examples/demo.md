```julia
using Javis, LaTeXStrings

function edge(; p1, p2, kwargs...)
    # sethue("black")
    # ob = blend(p1, p2, "orange", "blue")
    # setblend(ob)
    line(p1, p2, :clip)
    rect(p1, (p2-p1)..., :fill)
    # rect(p1, p2, :fill)
    clipreset()
end

function node(p=O, color="black")
    sethue(color)
    circle(p, 10, :fill)
    return p
end

function ground(args...) 
    background("white")
    sethue("black")
end

video = Video(400, 400)
Background(1:150, ground)

g = @Object 1:150 JGraph(true, 100, 100) O

adjacency_list = [[2, 3, 4, 5, 6],
                  [7, 8],
                  [7, 8],
                  [],[],[],[],[]]
for i in 1:length(adjacency_list)
    if i%2 == 0
        @Graph g i*10:150 GraphVertex(i, [node_shape(:circle, true, radius=12), node_fill(:image, "football.png")]) O
    else
        @Graph g i*10:150 GraphVertex(i, [node_shape(:rectangle, true, width=20, height=20), node_fill(:color, "yellow"), node_text(L"""%$i""", :inside), node_border("green", 2)]) O
    end
end
# , node_text("$(i)", :top)
global count = 0
for i in 1:length(adjacency_list)
    for j in adjacency_list[i]
        @Graph g 15+count*10:150 GraphEdge(i, j, [edge_shape(:curved, false; center_offset=5, end_offsets=(15, 15))]) O
        count+=1
    end
end

# c = 5
# i = 1
# j = 2
# g2 = @Object 1:150 JGraph(true, 100, 100) O
# @Graph g2 c*10:150 GraphVertex(i, (args...; kw...)->node()) O
# @Graph g2 c*10:150 GraphVertex(j, (args...; kw...)->node()) O
# @Graph g2 c*10:150 GraphEdge(i, j, (args...; kw...)->edge(; kw...)) O

render(video; pathname="demo.gif")
```

![Demo](demo.gif)