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
Background(1:150, ground)

g = JGraph(true, 300, 300, O, 1:150; layout=:spring)

adjacency_list = [[2, 3, 4, 5, 6],
                  [7, 8],
                  [7, 8],
                  [],[],[],[],[]]
v1 = GraphVertex(1, 1*10:100)
v2 = GraphVertex(2, 1*10:100)
v3 = GraphVertex(3, 1*10:100)
v4 = GraphVertex(4, 1*10:100)
v5 = GraphVertex(5, 1*10:100)
v6 = GraphVertex(6, 1*10:100)
v7 = GraphVertex(7, 1*10:100)

jCircle(v1, GFrames(1:100))
jcircle([v2, v3, v4, v5, v6, v7], repeat([GFrames(1:100)], 6); random=true)

render(video; pathname="demo5.gif")
```

![Demo](demo5.gif)