export jCircle, jcircle

@register_style struct jCircle <: AbstractIterativeStyle{AbstractGraphVertex, Shape}
    center::Point
    radius::Real
    color
    linewidth
    action::Symbol
    random::Bool
end

function jCircle(::Type{T}; center::Point=O, radius::Real=10, color = "black", linewidth = 2, action::Symbol = :stroke, random::Bool = false) where {T <: AbstractGraphVertex}
    return jCircle(center, radius, color, linewidth, action, random)
end

function draw(c::jCircle; position::Point, change_shape_args::Dict{Symbol, Any})
    default_args = Dict(fieldnames(jCircle) .=> getfield.(Ref(c), fieldnames(jCircle)))
    updated_args = merge(default_args, change_shape_args)
    updated_args[:center] = position
    sethue(updated_args[:color])
    setline(updated_args[:linewidth])
    # fixed to :path do preserve clipping region
    circle(updated_args[:center], updated_args[:radius], :path)
    return jCircle(AbstractGraphVertex; collect(updated_args)...), (position-updated_args[:radius], position+updated_args[:radius])
end

function add_style(shape::AbstractStyle{T, S}, el::T, f::GFrames) where {T <: AbstractGraphVertex, S <: Shape}
    draw_shape = (sh; kw...) -> draw(sh; kw...)
    jobj = el.object
    push!(jobj.opts[:draw_shapes], draw_shape)
    push!(jobj.opts[:shapes], shape)
    push!(jobj.opts[:shapes_frames], f)
    #=
    these change_*_args are to be defined for each of the add_style added
    when using change_shape!() (similar to change! function of Javis) we update
    this dict with that specific change argument and put it in the list
    of change_keywords
    function change_shape!(key::Symbol, new_value, el::AbstractJavisGraphElement)
        t = get_interpolation(key, new_value) # get a new value based on frame range
        el.object.change_keywords[:change_shape_args][key] = t
    end
    =#
    # the following is a default initialisation for :change_shape_args
    # if change_shape!() has not yet been used then use this
    # else this gets overridden due to the way change_keywords get
    # dominance over object.opts (check get_draw)
    jobj.opts[:change_shape_args] = Dict{Symbol, Any}()
    draw_func = (video, object, frame; shapes, draw_shapes, shapes_frames, position, change_shape_args, kwargs...) -> begin
        Luxor.newpath()
        bounding_box, doclip = nothing, false
        for i in Iterators.reverse(1:length(draw_shapes))
            if frame in shapes_frames[i].frames
                shapes[i], bounding_box = draw_shapes[i](shapes[i]; position=position, change_shape_args=change_shape_args)
                doclip = ((shapes[i].action == :clip) ? true : false)
                break
            end
        end
        # check that at least one draw function was found
        if bounding_box === nothing
            throw("No draw function found for frame $(frame) for graph element $(GRAPH_VERTICES[object.opts[:_vertex_idx]].vertex_id).")
        end
        if doclip
            clippreserve()
        end
        outline = first(pathtopoly())
        strokepath()
        Luxor.closepath()
        @register_style_opts object shapes bounding_box outline
    end
    if !(:shape in keys(el.opts[:styles]))
        el.opts[:styles][:shape] = draw_func
    end
end

function Base.iterate(s::AbstractStyle{T, S}) where {T <: AbstractGraphVertex, S <: Shape}
    state = Dict(
        :center => random_normal_generator((1, 2)),
        :radius => random_uniform_generator(),
        :color => random_uniform_generator(),
        :linewidth => random_uniform_generator(),
    )
    return (s, state)
end

function Base.iterate(s::AbstractStyle{T, S}, state) where {T <: AbstractGraphVertex, S <: Shape}
    center = s.center + Point(state[:center]()...) * s.radius
    radius = s.radius + (2 * state[:radius]()[1] - 1) * s.radius
    color = COLORMAP[Int(floor(state[:color]()[1] * 1000))]
    linewidth = s.linewidth + (2 * state[:linewidth]()[1] - 1) * s.linewidth
    next_s = jCircle(T;
        center = center,
        radius = radius,
        color = color,
        linewidth = linewidth,
        action = s.action,
        random = s.random,
    )
    return (next_s, state)
end