# function edge_shape(shape::Symbol=:line; center_offset::Real = 3, end_offsets::Tuple{Real, Real} = (0, 0))
#     opts = Dict{Symbol,Any}()
#     opts[:shape] = shape
#     draw = (video, object, frame; shape=shape, p1=O, p2=O, self_loop=false, from_node_bbx=(O, O), to_node_bbx=(O, O), styling=false, kwargs...) -> begin
#         if frame <= first(get_frames(object))+2
#             return
#         end
#         # Calculate edge segment outside of node boundaries
#         _, ip1, ip2 = intersectionlinecircle(p1, p2, p1, distance(O, (from_node_bbx[2]-from_node_bbx[1])/2))
#         _p1 = ispointonline(ip1, ip2, (p1+p2)/2; extended=false) ? ip1 : ip2
#         _, ip1, ip2 = intersectionlinecircle(p1, p2, p2, distance(O, (to_node_bbx[2]-to_node_bbx[1])/2))
#         _p2 = ispointonline(ip1, ip2, (p1+p2)/2; extended=false) ? ip1 : ip2
#         if self_loop
#             # TODO: Need to reset the CURRENT_GRAPH to be consistent during the video rendering
#             # Works right now only when a single graph is created
#             neighbor_obj = neighbors(CURRENT_GRAPH[1], object.meta.from_node.meta.node, strict=true)
#             neighbor_pos = Vector{Point}(map(obj -> obj.meta.opts[:position], neighbor_obj))
#             idx, sector = largest_circle_sector(p1, neighbor_pos)
#             angle = slope(p1, neighbor_pos[idx])+sector/2
#             direction = Point(cos(angle), sin(angle))
#             outline = draw_self_loop_edge(p1, from_node_bbx, center_offset, end_offsets, direction)
#         elseif shape == :curved
#             outline = draw_curved_edge(_p1, _p2, center_offset, end_offsets)
#         else
#             outline = draw_straight_edge(_p1, _p2, center_offset, end_offsets)
#         end
#         !styling ? poly(outline, :stroke) : nothing
#         object.meta.opts[:outline] = outline
#     end
#     return opts, draw
# end

# function edge_style(; color="red", linewidth::Real=2, dash::String="solid", blend="on")
#     opts = Dict{Symbol,Any}()
#     opts[:styling] = true
#     draw = (video, object, frame; outline=[O, O], linewidth=linewidth, dash=dash, color=color, kwargs...) -> begin
#         #TODO Allow a list of colors, linewidths, dash to be specified.
#         # Interpolate in between when blend option is turned on
#         sethue(color)
#         setline(linewidth)
#         setdash(dash)
#         poly(outline, :stroke)
#     end
#     return opts, draw
# end

# function edge_arrow(; start=nothing, finish=nothing, color="black")
#     draw = (video, object, frame; outline=[O, O], start=start, finish=finish, color=color, kwargs...) ->  begin
#         sethue(color)
#         # Skip the default case
#         if frame <= first(get_frames(object))+2 || outline == [O, O]
#             return
#         end
#         if is_directed(CURRENT_GRAPH[1]) && finish === nothing
#             finish = true
#         end
#         l = length(outline)
#         if start !== nothing
#             Luxor.arrow(reverse(outline[0:1]))
#         end
#         if finish !== nothing
#             Luxor.arrow(outline[l-1:l]...)
#         end
#     end
#     return draw
# end

# function edge_label(text = ""; position::Real = 0.5, offset::Real = 2)
#     draw = (video, object, frame; outline=[O, O], position=position, offset=offset, kwargs...) ->  begin
#         #TODO What to do for bezier curved edges?
#         # Align text along edge
#         if frame <= first(get_frames(object))+2 || outline == [O, O]
#             return
#         end
#         l = length(outline)
#         idx = floor(Int, l * position)
#         if l%2 == 0
#             pt = (outline[idx] + outline[idx+1])/2
#             sl = slope(outline[idx], outline[idx+1])
#         else
#             pt = outline[idx]
#             sl = idx == l ? slope(outline[idx%l+1], outline[idx]) : slope(outline[idx], outline[idx+1])
#         end
#         translate(pt)
#         rotate(sl)
#         label(text, :N, O, leader=false, offset=offset)
#         sl == 0 ? rotate(1/sl) : nothing
#         translate(-pt)
#     end
#     return draw
# end

# function draw_self_loop_edge(p1, from_node_bbx, center_offset, end_offsets, direction)
#     r = max((from_node_bbx[2]-from_node_bbx[1])/2..., center_offset)
#     offset = min((from_node_bbx[2]-from_node_bbx[1])/2..., center_offset)
#     c = p1 + r * direction
#     # Might replace by a clipping region to remove the extra edge remnants appearing inside a node
#     # pt1, pt2 = intersectioncircleboundingbox(c, r, from_node_bbx...)
#     # A temporary solution unless intersectioncircleboundingbox is fixed
#     _, pt1, pt2 = intersectioncirclecircle(c, r, p1, distance(O, (from_node_bbx[2]-from_node_bbx[1])/2))
#     pt1, pt2 = isarcclockwise(c, pt1, pt2) ? (pt1, pt2) : (pt2, pt1)
#     angles = slope(c, pt2), slope(c, pt1)
#     angle_offsets = end_offsets./r
#     new_angles = angles .+ (angle_offsets[1], -angle_offsets[2])
#     Luxor.newpath()
#     Luxor.arc(c, r, new_angles..., :path)
#     Luxor.closepath()
#     return first(pathtopoly())
# end

# function draw_curved_edge(p1, p2, center_offset, end_offsets)
#     center_pt = Luxor.perpendicular((p1+p2)/2, p1, center_offset)
#     c, r = center3pts(p1, center_pt, p2)
#     angles = slope(c, p1), slope(c, p2)
#     angle_offsets = end_offsets./r
#     new_angles = angles .+ (angle_offsets[1], -angle_offsets[2])
#     Luxor.newpath()
#     Luxor.arc(c, r, new_angles..., :path)
#     Luxor.closepath()
#     return first(pathtopoly())
# end

# function draw_straight_edge(p1, p2, center_offset, end_offsets)
#     d = Luxor.distance(p1, p2)
#     t1 = end_offsets[1]/d
#     t2 = (d-end_offsets[2])/d
#     new_p1 = t1*p1 + (1-t1)*p2
#     new_p2 = t2*p1 + (1-t2)*p2
#     Luxor.newpath()
#     line(new_p1, new_p2, :path)
#     Luxor.closepath()
#     return first(pathtopoly())
# end

# function largest_circle_sector(c::Point, pts::Vector{Point})
#     idx = 1
#     sector = 0
#     n = length(pts)
#     if n==1
#         return 1, 2*pi
#     end
#     slopes = sort(Vector{Tuple}([(slope(c, pts[i]), i) for i in 1:n]))
#     for i in 1:n
#         s = slopes[i%n+1][1]-slopes[i][1]+(i==n)*2*pi
#         if sector < s
#             sector = s
#             idx = slopes[i][2]
#         end
#     end
#     return idx, sector
# end

# # TODO
# # function intersectioncircleboundingbox(c::Point, radius::Real, upperleft::Point, lowerright::Point)
# #     # Find the closest corner of box to the center of the circle
# #     px = abs(lowerright[1] - c[1]) < abs(upperleft[1] - c[1]) ? lowerright[1] : upperleft[1]
# #     py = abs(lowerright[2] - c[2]) < abs(upperleft[2] - c[2]) ? lowerright[2] : upperleft[2]
# #     # Find the other 2 corner points joining this point
# #     o1 = Point(upperleft[1]+lowerright[1]-px, py)
# #     o2 = Point(px, upperleft[2]+lowerright[2]-py)
# #     # Calculate intersection points
# #     nints, ip1, ip2 = zip(intersectionlinecircle.(Point(px, py), [o1, o2], c, radius)...)
# #     p = Point(px, py)
# #     intersection_points = ispointonline.(ip1, [p, p], [o1, o2]; extended=false).*ip1 + ispointonline.(ip2, [p, p], [o1, o2]; extended=false).*ip2
# #     # throw(ErrorException("$nints, $ip1, $ip2, $intersection_points"))
# #     return intersection_points
# # end
