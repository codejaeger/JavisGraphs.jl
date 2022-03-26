# """
#     vertex_shape(shape::Symbol, clip::Bool; <keyword arguments>)

# Create an outline for the graph vertex. Also, can define a clipping region for the vertex region.

# Returns a dictionary of drawing options and a callable draw function (in this order).

# # Arguments
# - `shape::Symbol`: Specify a vertex shape among `:circle`, `:rectangle` or a `:polygon` (to be implemented).
# - `clip::Bool`: Define a clipping region over the region defined by `shape`.

# # Keywords
# - `radius`: Specify if shape is `:circle`.
# - `width`: Specify if shape is `:rectangle`.
# - `height`: Specify if shape is `:rectangle`.
# """
function vertex_shape(shape::Symbol=:circle, clip::Bool=false; dimensions=())
    if !(dimensions isa Tuple)
        dimensions = Tuple(dimensions)
    end
    dimensions = Tuple(dimensions)
    if shape == :rectangle && length(dimensions) != 2
        throw(ArgumentError("Rectangle must have 2 dimensions (width, height) provided for vertex shape."))
    elseif shape == :circle && length(dimensions) != 1
        throw(ArgumentError("Circle must have 1 dimension (radius) provided for vertex shape."))
    end
    draw = (video, object, frame; shape=shape, dimensions=dimensions, clip=clip, position, kwargs...) -> begin
        Luxor.newpath()
        if shape == :rectangle
            w, h = dimensions
            rect(position[1]-w/2, position[2]-h/2, w, h, :path)
            bounding_box = (position-(w/2, h/2), position+(w/2, h/2))
        elseif shape == :circle
            r = dimensions[1]
            circle(position, r, :path)
            bounding_box = (position-r, position+r)
        end
        if clip
            clippreserve()
        end
        outline = first(pathtopoly())
        strokepath()
        Luxor.closepath()
        @register_style_opts object shape dimensions clip bounding_box outline
    end
    return draw
end

function vertex_text_style(; color="black", fonttype="Times Roman", fontsize=10, opacity=0.8)
    draw = (video, object, frame; text_color=color, fonttype=fonttype, fontsize=fontsize, text_opacity=opacity, kwargs...) -> begin
        sethue(text_color)
        setfont(fonttype, fontsize)
        setopacity(text_opacity)
        @register_style_opts object text_color fonttype fontsize text_opacity
    end
    return draw
end


# """
#     vertex_text(text::AbstractString, offset::Point, color)
#     vertex_text(text::LaTeXString, offset::Point, color)

# Label a vertex with text (or latex), which is also rotated to match the direction specified by `offset`.

# # Arguments
# - `offset::Point`: Specify the offset of the text label with respect to the vertex center.
#     - The text is translated and rotated in the direction of the offset.
# - `color`: The color of the text. Default is "black".
# - `shift::Real`: Indicates the shift w.r.t the offset direction.
#     - Eg. If the offset direction is in the upper or lower left quadrant calculated shift is (`shift`, 0).
#     - Default shift is 1.
# """

function vertex_text(text_content, align::Symbol; shift::Real=10, angle::Float64=0.0, fit_to_bbox=false)
    outside = Tuple(normalize((rand(1, 2))))
    find_shift = (video, object, frame; text_align=align, shift=shift, bounding_box, kwargs...) -> begin
        text_box = bounding_box
        text_dims = last(text_box)-first(text_box)
        if align == :top
            text_shift = (0, -text_dims[2]/2-shift)
        elseif align == :bottom
            text_shift = (0, text_dims[2]/2+shift)
        elseif align == :left
            text_shift = (-text_dims[1]/2-shift, 0)
        elseif align == :right
            text_shift = (text_dims[1]/2+shift, 0)
        elseif align == :inside
            text_shift = O
        elseif align == :outside
            text_shift = outside .* shift
        end
        @register_style_opts object text_shift text_align shift fit_to_bbox
        return text_shift
    end
    
    draw = vertex_text(text_content; angle=angle, fit_to_bbox=fit_to_bbox)

    return (args...; text_shift=(O, O), kwargs...) -> 
        begin 
            text_shift = find_shift(args...; kwargs...);
            draw(args...; text_shift=text_shift, kwargs...)
        end
end

# """
#     vertex_text(text::AbstractString, align::Symbol, color, offset::Real)
#     vertex_text(text::LaTeXString, align::Symbol, color, offset::Real)

# Label a vertex with text or latex.

# # Arguments
# - `align::Symbol`: Specify the alignment of the text label with respect to the vertex.
#     - This position is determined with respect to the vertex `bounding_box` returned as a drawing option by [`vertex_shape`](@ref).
#     - Can take the values `:inside`, `:top`, `:bottom`, `:left`, `:right`. Default is `:inside`.
# - `color`: The color of the text. Default is "black".
# - `shift`: Used only when `align` is not `:inside`. Specifies an offset in the direction of `align`.
# """
function vertex_text(text_content; shift=(0, 0), angle::Float64=0.0, fit_to_bbox=false)
    draw = (video, object, frame; text_content=text_content, text_shift=shift, text_angle=angle, clip, bounding_box, kwargs...) -> begin
        kw = Dict{Symbol, Any}(collect(kwargs)...)
        text_align = get(kw, :text_align, :inside)
        fontsize = get(kw, :fontsize, 10)
        # Text box is inistally derived from vertex bounding box
        text_box = bounding_box
        if text_content isa Javis.LaTeXString
            svg = Javis.get_latex_svg(text_content)
            w, h = Javis.svgwh(svg)
        elseif text_content isa AbstractString
            ext = textextents(text_content)
            w, h = ext[3], ext[4]
        end
        text_dims = Tuple(last(text_box)-first(text_box))
        text_marker = (text_box[1]+text_box[2])/2
        scl = Point(1, 1)
        if fit_to_bbox
            # 1.5 is chosen after some visual inspections
            scl = min(text_dims[1]/w, text_dims[2]/h)/1.5 .* (1, 1)
        end
        if text_align == :inside
            text_marker_align = (:center, :middle)
        else
            # ToDo: throw warning - Clip is ignored since text outside bounding box
            text_marker_shift, text_marker_align = _vertex_text_shift(text_box, text_shift, text_align)
            text_marker += text_marker_shift
        end
        scale(scl...)
        object.current_setting.fontsize = 60
        if text_content isa Javis.LaTeXString
            translate(text_marker/Tuple(scl))
            # Change to radians and negate to match rotate's convention
            rotate(-degreetoradians(angle))
            # ToDo: Can we pass fontsize directly into latex?
            _fontsize = object.current_setting.fontsize
            object.current_setting.fontsize = fontsize
            latex(text_content, O, text_marker_align[2], text_marker_align[1])
            object.current_setting.fontsize = _fontsize
            
            rotate(degreetoradians(angle))
            translate(-text_marker/Tuple(scl))
        elseif text_content isa AbstractString
            text(text_content, text_marker/Tuple(scl), halign = text_marker_align[1], valign = text_marker_align[2], angle=angle)
        else
        end
        scale(1/scl[1], 1/scl[2])
        @register_style_opts object text_content text_box text_shift text_angle
    end
    return draw
end

function _vertex_text_shift(text_box, shift, align)
    text_box_center = (text_box[1] + text_box[2])/2
    top_left = text_box[1] - text_box_center
    top_right = Point(text_box[2][1], text_box[1][2]) - text_box_center
    bottom_left = Point(text_box[1][1], text_box[2][2]) - text_box_center
    bottom_right = text_box[2] - text_box_center
    shift = Point(shift)
    if intersection(top_left, top_right, O, shift)[1]
        text_align = (:center, :bottom)
        point1, point2 = top_left, top_right
    elseif intersection(top_right, bottom_right, O, shift)[1]
        text_align = (:left, :middle)
        point1, point2 = top_right, bottom_right
    elseif intersection(bottom_right, bottom_left, O, shift)[1]
        text_align = (:center, :top)
        point1, point2 = bottom_right, bottom_left
    elseif intersection(bottom_left, top_left, O, shift)[1]
        text_align = (:right, :middle)
        point1, point2 = bottom_left, top_left
    end
    intersects, point = intersection(text_box_center, text_box_center+shift, point1, point2)
    if !intersects && align == :outside
        # ToDo: throw warning - inside sector but no intersection of lines was found
        text_marker_shift = (norm(text_box_center-point) + norm(shift)) * shift./norm(shift)
    else
        text_marker_shift = shift
    end
    return text_marker_shift, text_align
end

# """
#     vertex_fill(fill_type::Symbol, fill_with::String)

# Fill in the interior of the vertex with an image or a color.

# # Arguments
# - `fill_type::Symbol`: Can be `image` or `color`.
# - `fill_with`: Can be a color like "red" or a image path in the same directory like "image.png".
# """
function vertex_fill(type::Symbol, with::String, opacity::Float64=0.5)
    draw = (video, object, frame; fill_type=type, fill_with=with, fill_opacity=opacity, bounding_box, kwargs...) -> begin
        kw = Dict{Symbol, Any}(collect(kwargs)...)
        outline = get(kw, :outline, nothing)
        if fill_type == :image
            img = readpng(fill_with)
            image_dims = last(bounding_box)-first(bounding_box)
            scl = min(image_dims[1]/img.width, image_dims[2]/img.height) .* (1, 1)
            scale(scl...)
            placeimage(img, bounding_box[1]/Tuple(scl), fill_opacity)
            scale(1/scl[1], 1/scl[2])
        elseif fill_type == :color
            setopacity(fill_opacity)
            sethue(fill_with)
            fill_dims = last(bounding_box)-first(bounding_box)
            if outline !== nothing
                Luxor.poly([outline..., first(outline)], :fill)
            else
                circle((bounding_box[1]+bounding_box[2])/2, max(fill_dims...)/2, :fill)
            end
        end
        @register_style_opts object fill_type fill_with fill_opacity
    end
    return draw
end

# """
#     vertex_border(color::String, border_width::Real)

# Create a border around the vertex shape.

# If the `:shape` is not specified, the `bounding_box` becomes the border.

# # Arguments
# - `color`: The color of the text. Default is "black".
# - `border_width::Real`: The line width used for the border. Defualt is 3.
# """
function vertex_border(color="black", width::Real=3, opacity=0.7)
    draw = (video, object, frame; border_color=color, border_width=width, border_opacity=opacity, clip, position, shape, kwargs...) -> begin
        kw = Dict{Symbol, Any}(collect(kwargs)...)
        setline(border_width)
        sethue(border_color)
        setopacity(border_opacity)
        dims = get(kw, :dimensions, 5)
        outline = get(kw, :outline, nothing)
        if outline !== nothing
            Luxor.poly([outline..., first(outline)], :stroke)
        elseif shape == :circle
            r = dims[1]
            circle(position, r, :stroke)
        elseif shape == :rectangle
            w = dims[1]
            h = dims[2]
            rect(position[1]-w/2, position[2]-h/2, w, h, :stroke)
        else
            bounding_box = get(kw, :bounding_box, (O, O))
            rect(bounding_box[1], (bounding_box[2]-bounding_box[1])..., :stroke)
        end
        @register_style_opts object border_color border_width border_opacity
    end
    return draw
end
