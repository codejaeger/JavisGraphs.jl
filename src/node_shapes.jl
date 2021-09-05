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
# function node_shape(shape::Symbol, clip::Bool=false; kwargs...)
#     kw = Dict(collect(kwargs)...)
#     opts = Dict{Symbol, Any}()
#     opts[:shape] = shape
#     opts[:clip] = clip
#     if shape == :rectangle
#         opts[:width] = get(kw, :width, 5)
#         opts[:height] = get(kw, :height, 5)
#     elseif shape == :circle
#         opts[:radius] = get(kw, :radius, 5)
#     end
#     draw = (video, object, frame; shape=:circle, position=O, clip=false, kwargs...) -> begin
#         opts = Dict(collect(kwargs)...)
#         if shape == :rectangle
#             w, h = get(opts, :width, 5), get(opts, :height, 5)
#             rect(position[1]-w/2, position[2]-h/2, w, h, clip ? :clip : :stroke)
#             bounding_box = (position-(w/2, h/2), position+(w/2, h/2))
#         elseif shape == :circle
#             r = get(opts, :radius, 5)
#             circle(position, r, clip ? :clip : :stroke)
#             bounding_box = (position-r, position+r)
#         end
#         object.meta.opts[:bounding_box] = bounding_box
#     end
#     return opts, draw
# end

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
# function node_text(text::AbstractString, align::Symbol, color="black", shift::Real=1)
#     opts = Dict{Symbol, Any}()
#     opts[:text_align] = align
#     draw = (video, object, frame; text=text, bounding_box=(O, O), text_box=(O, O), text_align=:inside, text_color=color, clip=false, kwargs...) -> begin
#         sethue(text_color)
#         ext = textextents(text)
#         w, h = ext[3], ext[4]
#         text_dims = last(bounding_box)-first(bounding_box)
#         if text_align == :inside
#             scl = text_dims/(w*1.8, h*1.8)
#         else
#             scl = Point(1, 1)
#             clip ? clipreset() : nothing
#         end
#         # TODO: Work around for the frame gap caused due to the unavailability of the keyword bounding box until the end of first frame
#         if frame > first(get_frames(object))+1
#             scale(scl...)
#             Luxor.text(text, (text_box[1]+text_box[2])/(Tuple(scl).*2), halign=:center, valign = :middle)
#             scale(1/scl[1], 1/scl[2])
#         end
#         # Update for next frame
#         shift = _node_text_shift(text_align, text_dims, shift)
#         object.meta.opts[:text_box] = bounding_box .+ shift
#     end
#     return opts, draw
# end

# function node_text(text::LaTeXString, align::Symbol, color="black", shift::Real=1)
#     opts = Dict{Symbol, Any}()
#     opts[:text_align] = align
#     draw = (video, object, frame; text=text, bounding_box=(O, O), text_box=(O, O), text_align=:inside, text_color=color, clip=false, kwargs...) -> begin
#         sethue(text_color)
#         svg = get_latex_svg(text)
#         w, h = svgwh(svg)
#         text_dims = last(bounding_box)-first(bounding_box)
#         if text_align == :inside
#             scl = text_dims/(w*1.8, h*1.8)
#         else
#             scl = Point(1, 1)
#             clip ? clipreset() : nothing
#         end
#         # TODO: Work around for the frame gap caused due to the unavailability of the keyword bounding box until the end of first frame
#         # Otherwise 1/scl causes division by zero since bounding_box is (O, O) by default
#         if frame > first(get_frames(object))+1
#             scale(scl...)
#             latex(text, (text_box[1]+text_box[2])/(Tuple(scl).*2), :middle, :center)
#             scale(1/scl[1], 1/scl[2])
#         end
#         # Update for next frame
#         shift = _node_text_shift(text_align, text_dims, shift)
#         object.meta.opts[:text_box] = bounding_box .+ shift
#     end
#     return opts, draw
# end

# function _node_text_shift(text_align, text_dims, shift)
#     _shift = (O, O)
#     if text_align == :top
#         _shift = ((0, -text_dims[2]-shift), (0, -text_dims[2]-shift))
#     elseif text_align == :bottom
#         _shift = ((0, text_dims[2]+shift), (0, text_dims[2]+shift))
#     elseif text_align == :left
#         _shift = ((-text_dims[1]-shift, 0), (-text_dims[1]-shift, 0))
#     elseif text_align == :right
#         _shift = ((text_dims[1]+shift, 0), (text_dims[1]+shift, 0))
#     end
#     return shift
# end


# """
#     text(text::LaTeXString)
    
# Override to allow drawing Latex text.
# """
# text(text::LaTeXString, args...; kwargs...) = latex(text, args...; kwargs...)

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
# function node_text(text, offset::Point, color="black"; shift::Real=1)
#     return (args... ; text=text, position=O, text_color=color, clip=false, kwargs...) -> begin
#         clip ? clipreset() : nothing
#         sethue(text_color)
#         if frame > first(get_frames(object))+1
#             shift_x = slope(O, Point(O, offset)) ∉ [pi/2, 3*pi/2] ? sign(cos(slope(O, offset))) : 0
#             shift_y = slope(O, Point(O, offset)) ∈ [pi/2, 3*pi/2] ? sign(sin(slope(O, offset))) : 0
#             translate(position + offset + Point(shift_x, shift_y) * shift)
#             text(text, valign=:middle, halign=:center)
#             translate(-position - offset - Point(shift_x, shift_y) * shift)
#         end
#     end
# end

# """
#     node_fill(fill::Symbol, arg::String)

# Fill in the interior of the node with an image or a color.

# # Arguments
# - `fill::Symbol`: Can be `image` or `color`.
# - `arg`: Can be a color like "red" or a image path in the same directory like "image.png".
# """
# function node_fill(fill::Symbol, arg)
#     opts = Dict{Symbol, Any}()
#     opts[:fill] = fill
#     if fill == :image
#         draw = (video, object, frame; image_path=arg, bounding_box=(O, O), clip=false, kwargs...) -> begin
#             img = readpng(image_path)
#             image_dims = last(bounding_box)-first(bounding_box)
#             scl = image_dims/(img.width, img.height)
#             # TODO: Work around for the frame gap caused due to the unavailability of the keyword bounding box until the end of first frame
#             if frame > first(get_frames(object))+1
#                 scale(scl...)
#                 placeimage(img, bounding_box[1]/Tuple(scl))
#                 scale(1/scl[1], 1/scl[2])
#             end
#             clip ? clipreset() : nothing
#         end
#     elseif fill == :color
#         draw = (args...; fill_color=arg, bounding_box=(O, O), clip=false, kwargs...) -> begin
#             sethue(fill_color)
#             fill_dims = last(bounding_box)-first(bounding_box)
#             circle((bounding_box[1]+bounding_box[2])/2, max(fill_dims...)/2, :fill)
#             clip ? clipreset() : nothing
#         end
#     end
#     return opts, draw
# end

# """
#     node_border(color::String, border_width::Real)

# Create a border around the node shape.

# If the `:shape` is not specified, the `bounding_box` becomes the border.

# # Arguments
# - `color`: The color of the text. Default is "black".
# - `border_width::Real`: The line width used for the border. Defualt is 3.
# """
# function node_border(color="black", border_width::Real=3)
#     draw = (video, object, frame; position=O, border_color=color, border_width=border_width, clip=false, kwargs...) -> begin
#         clip ? clipreset() : nothing
#         kw = Dict{Symbol, Any}(collect(kwargs)...)
#         setline(border_width)
#         sethue(border_color)
#         if object.meta.opts[:shape] == :circle
#             r = get(kw, :radius, 5)
#             circle(position, r, :stroke)
#         elseif object.meta.opts[:shape] == :rectangle
#             w = get(kw, :width, 5)
#             h = get(kw, :height, 5)
#             rect(position[1]-w/2, position[2]-h/2, w, h, :stroke)
#         else
#             bounding_box = get(kw, :bounding_box, (O, O))
#             rect(bounding_box[1], (bounding_box[2]-bounding_box[1])..., :stroke)
#         end
#     end
#     return draw
# end
