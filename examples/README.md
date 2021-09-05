# Code examples and animations for project during GSoC 2021

## Demos

![](/examples/graph_animations/example1.gif) ![](/examples/graph_animations/example2.gif)

1. Changing layout
2. Rendered nodes and edges using manual ordering


## Updates
- Created `GraphAnimation` the struct used for maintaining graph layout, Javis object information & animation order for the graph elements.
- Started with a very basic rendering function for graph animation
- Started with very basic node and edge animating functions


## Notes
- Explore `EvolvingGraphs.jl`. Can be useful for maintaining and rendering dynamic network graphs
- Faced a blocker with specifying relative frame range to animate nodes and edges one after the another


## References
- https://discourse.julialang.org/t/ann-animations-jl/30021/4
- http://eprints.ma.man.ac.uk/2376/1/covered/MIMS_ep2015_83.pdf
