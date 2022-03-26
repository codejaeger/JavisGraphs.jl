# JavisGraphs
A network graph plotting utility based on Javis

**Development**
`cd` into the JavisGraphs directory and `dev .`

**Testing**
`test JavisGraphs`

ToDo:

##### Most significants
* Add tests & cleanup
* Rename node to vertex everywhere
* Add a :scale parameter for drawing - node_shape and edge_shape
* Change layout package to networklayout.jl
* Update examples with new API
* Rename package to JavisGraphs.jl
* Add convenience functions for JGraph - provide a full defualt mode

##### Least significants
* Add option for a automatic frame counter/tracker
* Start with animation API
* Support/API for appear-into/disappear-out animation for edges/vertex/full-graph
* Compute node layout based on user's choice - Graph.jl
* Rename adjacency_graph to adjacency
* Other random tasks labelled as `ToDo` inside code

Done
* ~~Add meta function to get_draw() to update CURRENT_* during rendering~~
* ~~Add API to specify styles on nodes and edges~~
* ~~Aggregate styling functions for nodes and edges~~
* ~~Solve global layout issue~~
* [OBE] ~~Make frames argument first for JGraph~~
* ~~JGraph option to specify graph position~~
* [OBE] ~~Specialised structs for rectangle, circle etc. and other shapes.~~








