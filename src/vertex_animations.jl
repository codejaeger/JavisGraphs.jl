function change!(v::GraphVertex, style::Symbol, to::Any; frames=:automatic)
end

function change_prop!(v::GraphVertex, property, to::Any; frames=:automatic)
end

function settheme(v::GraphVertex, theme; frames=:automatic)
end

function Javis.setopacity(v::GraphVertex, opacity; frames=:automatic)
end

"""
add a :scale property to node_shape and edge_shape
"""
function setscale(v::GraphVertex, opacity; frames=:automatic)
end

function highlightvertex(v::GraphVertex; frames=:automatic)
end
