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
    return (video, object, frame; kwargs...) -> begin
        l = s == :graph ? GRAPHS[object.opts[:_graph_idx]] : 
                          s == :vertex ? GRAPH_VERTICES[object.opts[:_vertex_idx]] :
                                          GRAPH_EDGES[object.opts[:_edge_idx]]
        kw = merge(object.opts, Dict(collect(kwargs)...))
        for style in l.opts[:styles]
            style(video, object, frame; kw...)
            if frame == first(get_frames(object))
                kw = merge(object.opts[:_style_opts_cache], kw)
            end
        end
        Luxor.clipreset()
        object.opts = merge(object.opts, object.opts[:_style_opts_cache])
    end
end

"""
    @add_styles(component::AbstractJavisGraphElement, draw)

Aggregate all the drawing styles and store as part of the current object.
"""
macro add_styles(component, draw...)
    # Process drawing functions
    return quote
        # Inside a quote - end block
        # $(d) will turn Expr([a, b, c]) to [a, b, c]
        # $(d...) will turn [Expr(a()), Expr(b())] to [a(), b()]
        # $(d...)... further expanded the generated list above
        # since component is a variable which might be created inside a function
        # we need to escape (with esc()) it since it is not a global variable
        # if !haskey($(esc(component)).opts, :styles)
        #     $(esc(component)).opts[:styles] = Function[(args...; kw...) -> Luxor.clipreset()]
        # end
        append!($(esc(component)).opts[:styles], [$(esc(draw...))...])
    end
end

"""
    @register_style_opts(component::AbstractObject, styles...)

Register the style for the current object
"""
macro register_style_opts(component, style_opts...)
    return quote
        # Get the name and the value for the arguments passed
        for (n, v) in zip([$(style_opts)...], [$(map(esc, style_opts)...)])
            $(esc(component)).opts[:_style_opts_cache][n] = v
        end
    end 
end


function degreetoradians(angle::Float64)
    return angle/180 * pi
end