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

function get_draw(custom_draw::Function)
    return (args...) -> begin
        custom_draw(args...)
        get_draw()(args...)
    end
end

function get_draw()
    return (video, object, frames; kwargs...) -> begin
        g = GRAPH[object.opts(_graph_idx)]
        for style in g.opts[:styles]
            style(video, object, frames; kwargs...)
        end
    end
end