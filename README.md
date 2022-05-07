# JavisGraphs
A network graph plotting utility based on Javis

![WIP](./assets/wip.jpg "Development takes time :)")

**Development**

`cd` into the JavisGraphs directory and `dev .`

**Testing**

`test JavisGraphs`

ToDo:

##### Most significants
* Support multiple interfaces for iterators, indexing, broadcasting for JavisGraph
* Add support for arbitrary node ids types
* Add support for indexing on Javis Graph based on node id or edge id (which is just a pair of node ids)
* ~~Add test~~ & cleanup
* ~~Rename node to vertex everywhere~~
* Add a :scale parameter for drawing - node_shape and edge_shape
* Change layout package to networklayout.jl
* ~~Update examples with new API~~
* ~~Rename package to JavisGraphs.jl~~
* Add convenience functions for JGraph - provide a full defualt mode

##### Least significants
* Add option for a automatic frame counter/tracker
* Add more layout options after refinement
* Start with animation API
* Support/API for appear-into/disappear-out animation for edges/vertex/full-graph
* Compute node layout based on user's choice - Graph.jl
* Rename adjacency_graph to adjacency
* Other random tasks labelled as `ToDo` inside code
* Support any vertex id format. Store a hash map for that purpose.

Done
* ~~Add meta function to get_draw() to update CURRENT_* during rendering~~
* ~~Add API to specify styles on nodes and edges~~
* ~~Aggregate styling functions for nodes and edges~~
* ~~Solve global layout issue~~
* [OBE] ~~Make frames argument first for JGraph~~
* ~~JGraph option to specify graph position~~
* [OBE] ~~Specialised structs for rectangle, circle etc. and other shapes.~~

#### Notes
* Edge flicker happens when edge frame range preceedes the node frame range. Fix - throw a warning or fix this issue.
* When distance between 2 nodes very small curved edge throws error "2 points are same" - :spring layout is an immediate solution to this. Investigate and fix.
* What to do when graph elements out of parent frame range?
* could not import errors when `using Revise; using JavisGraphs`


#### Common Errors
* `these two points are the same` - This error is very common when you have self-loops in graph and did not create a node of large enough size or completely forgot to define a shape for the node. The center and the end points of the node collapse into a single point and the error comes from arc function of Luxor.jl.




