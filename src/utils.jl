struct Styles
    # explore if a nameless field works here
    styles::Vector{Function}
end

struct Attributes
    attributes::Dict{Symbol, Any}
end

struct StyleMap
    stylemap::Dict{Symbol, Symbol}
end

function get_draw(s::Symbol, custom_draw::Function)
    return (args...) -> begin
        custom_draw(args...)
        get_draw(s)(args...)
    end
end

function get_draw(s::Symbol)
    return (video, object, frames; kwargs...) -> begin
        l = s == :graph ? GRAPHS : (s == :vertex ? GRAPH_VERTICES : GRAPH_EDGES)
        g = GRAPH[object.opts(_graph_idx)]
        for style in g.opts[:styles]
            style(video, object, frames; kwargs...)
        end
    end
end