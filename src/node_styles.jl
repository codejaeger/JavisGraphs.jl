# """
#     node_shape(shape::Symbol, clip::Bool; <keyword arguments>)

# Create an outline for the graph node. Also, can define a clipping region for the node region.

# Returns a dictionary of drawing options and a callable draw function (in this order).

# # Arguments
# - `shape::Symbol`: Specify a node shape among `:circle`, `:rectangle` or a `:polygon` (to be implemented).
# - `clip::Bool`: Define a clipping region over the region defined by `shape`.

# # Keywords
# - `radius`: Specify if shape is `:circle`.
# - `width`: Specify if shape is `:rectangle`.
# - `height`: Specify if shape is `:rectangle`.
# """
function node_shape(shape::Symbol, clip::Bool=false; dimensions::Tuple=())
    if shape == :rectangle && length(dimensions) != 2
        throw(ArgumentError("Rectangle must have 2 dimensions (width, height) provided for node shape."))
    elseif shape == :circle && length(dimensions) != 1
        throw(ArgumentError("Circle must have 1 dimension (radius) provided for node shape."))
    end
    draw = (video, object, frame; shape=shape, dimensions=dimensions, clip=clip, position, kwargs...) -> begin
        if shape == :rectangle
            w, h = dimensions
            rect(position[1]-w/2, position[2]-h/2, w, h, clip ? :clip : :stroke)
            bounding_box = (position-(w/2, h/2), position+(w/2, h/2))
        elseif shape == :circle
            r = dimensions[1]
            circle(position, r, clip ? :clip : :stroke)
            bounding_box = (position-r, position+r)
        end
        @register_style_opts object shape dimensions clip bounding_box
    end
    return draw
end

# """
#     node_text(text::AbstractString, align::Symbol, color, offset::Real)
#     node_text(text::LaTeXString, align::Symbol, color, offset::Real)

# Label a node with text or latex.

# # Arguments
# - `align::Symbol`: Specify the alignment of the text label with respect to the node.
#     - This position is determined with respect to the node `bounding_box` returned as a drawing option by [`node_shape`](@ref).
#     - Can take the values `:inside`, `:top`, `:bottom`, `:left`, `:right`. Default is `:inside`.
# - `color`: The color of the text. Default is "black".
# - `shift`: Used only when `align` is not `:inside`. Specifies an offset in the direction of `align`.
# """
function node_text(text_content, align::Symbol=:inside, color="black", shift::Real=1)
    draw = (video, object, frame; text_content=text_content, text_box=(O, O), text_align=align, text_color=color, text_shift=shift, clip, bounding_box, kwargs...) -> begin
        sethue(text_color)
        if text_content isa AbstractString
            ext = textextents(text_content)
            w, h = ext[3], ext[4]
        elseif text_content isa Javis.LaTeXStrings
            svg = get_latex_svg(text_content)
            w, h = svgwh(svg)
        end
        text_dims = last(bounding_box)-first(bounding_box)
        if text_align == :inside
            scl = text_dims/(w*1.8, h*1.8)
        else
            scl = Point(1, 1)
            clip ? clipreset() : nothing
        end
        scale(scl...)
        if text_content isa AbstractString
            text(text_content, (text_box[1]+text_box[2])/(Tuple(scl).*2), halign=:center, valign = :middle)
        elseif text_content isa Javis.LaTeXStrings
            # ToDo: Make use of clip; latex takes stroke type as :path or :stroke (default)
            latex(text, (text_box[1]+text_box[2])/(Tuple(scl).*2), :middle, :center)
        end
        scale(1/scl[1], 1/scl[2])
        # Update for next frame
        shift = _node_text_shift(text_align, text_dims, shift)
        text_box = bounding_box .+ shift
        @register_style_opts object text_content text_box text_align text_color text_shift
    end
    return draw
end

function _node_text_shift(text_align, text_dims, shift)
    _shift = (O, O)
    if text_align == :top
        _shift = ((0, -text_dims[2]-shift), (0, -text_dims[2]-shift))
    elseif text_align == :bottom
        _shift = ((0, text_dims[2]+shift), (0, text_dims[2]+shift))
    elseif text_align == :left
        _shift = ((-text_dims[1]-shift, 0), (-text_dims[1]-shift, 0))
    elseif text_align == :right
        _shift = ((text_dims[1]+shift, 0), (text_dims[1]+shift, 0))
    end
    return shift
end

# """
#     node_text(text::AbstractString, offset::Point, color)
#     node_text(text::LaTeXString, offset::Point, color)

# Label a node with text (or latex), which is also rotated to match the direction specified by `offset`.

# # Arguments
# - `offset::Point`: Specify the offset of the text label with respect to the node center.
#     - The text is translated and rotated in the direction of the offset.
# - `color`: The color of the text. Default is "black".
# - `shift::Real`: Indicates the shift w.r.t the offset direction.
#     - Eg. If the offset direction is in the upper or lower left quadrant calculated shift is (`shift`, 0).
#     - Default shift is 1.
# """
function node_text(text_content, offset::Point, color="black"; shift::Real=1)
    return (video, object, frame ; text_content=text_content, text_color=color, text_offset=offset, text_shift=shift, clip, position, kwargs...) -> begin
        clip ? clipreset() : nothing
        sethue(text_color)
        shift_x = slope(O, Point(O, offset)) ∉ [pi/2, 3*pi/2] ? sign(cos(slope(O, offset))) : 0
        shift_y = slope(O, Point(O, offset)) ∈ [pi/2, 3*pi/2] ? sign(sin(slope(O, offset))) : 0
        translate(position + offset + Point(shift_x, shift_y) * shift)
        if text_content isa AbstractString
            text(text_content, (text_box[1]+text_box[2])/(Tuple(scl).*2), halign=:center, valign = :middle)
        elseif text_content isa Javis.LaTeXStrings
            # ToDo: Make use of clip; latex takes stroke type as :path or :stroke (default)
            latex(text_content, (text_box[1]+text_box[2])/(Tuple(scl).*2), :middle, :center)
        end
        translate(-position - offset - Point(shift_x, shift_y) * shift)
        @register_style_opts object text_content text_color text_shift text_offset
    end
end

# """
#     node_fill(fill_type::Symbol, fill_with::String)

# Fill in the interior of the node with an image or a color.

# # Arguments
# - `fill_type::Symbol`: Can be `image` or `color`.
# - `fill_with`: Can be a color like "red" or a image path in the same directory like "image.png".
# """
function node_fill(fill_type::Symbol, fill_with::String)
    draw = (video, object, frame; fill_type=fill_type, fill_with=fill_with, bounding_box, clip, kwargs...) -> begin
        if fill_type == :image
            img = readpng(fill_with)
            image_dims = last(bounding_box)-first(bounding_box)
            scl = image_dims/(img.width, img.height)
            scale(scl...)
            placeimage(img, bounding_box[1]/Tuple(scl))
            scale(1/scl[1], 1/scl[2])
        elseif fill_type == :color
            sethue(fill_with)
            fill_dims = last(bounding_box)-first(bounding_box)
            circle((bounding_box[1]+bounding_box[2])/2, max(fill_dims...)/2, :fill)
        end
        clip ? clipreset() : nothing
        @register_style_opts object fill_type fill_with
    end
    return draw
end

# """
#     node_border(color::String, border_width::Real)

# Create a border around the node shape.

# If the `:shape` is not specified, the `bounding_box` becomes the border.

# # Arguments
# - `color`: The color of the text. Default is "black".
# - `border_width::Real`: The line width used for the border. Defualt is 3.
# """
function node_border(color="black", width::Real=3)
    draw = (video, object, frame; border_color=color, border_width=width, clip, position, shape, kwargs...) -> begin
        clip ? clipreset() : nothing
        kw = Dict{Symbol, Any}(collect(kwargs)...)
        setline(border_width)
        sethue(border_color)
        if shape == :circle
            r = get(kw, :radius, 5)
            circle(position, r, :stroke)
        elseif shape == :rectangle
            w = get(kw, :width, 5)
            h = get(kw, :height, 5)
            rect(position[1]-w/2, position[2]-h/2, w, h, :stroke)
        else
            bounding_box = get(kw, :bounding_box, (O, O))
            rect(bounding_box[1], (bounding_box[2]-bounding_box[1])..., :stroke)
        end
        @register_style_opts object border_color border_width
    end
    return draw
end
