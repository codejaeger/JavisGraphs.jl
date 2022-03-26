function edge_shape(shape::Symbol=:line; center_offset::Real = 3, end_offsets::Tuple{Real, Real} = (0, 0))
    draw = (video, object, frame; shape=shape, center_offset=center_offset, end_offsets=end_offsets, p1, p2, from_vertex_bbx, to_vertex_bbx, kwargs...) -> begin
        # Calculate  edge segment outside of vertex boundaries
        # ToDo: 
        #   1. For curved edges choose _p1 and _p2 using intersection circle-arc
        #   2. For node objects other than circle find a intersection of polygon and line
        #   3. [FIX] When ther are self loops sometimes self loop passes through the node
        # Known bug: If the gap between nodes are too less neither of the intersection 
        #   points lie within the line connecting p1 and p2 hence ispointline fails
        # Temporary fix: Make sure there is enough gaps within 2 node objects
        self_loop = get(Dict(collect(kwargs)...), :self_loop, false)
        _, ip1, ip2 = intersectionlinecircle(p1, p2, p1, distance(O, (from_vertex_bbx[2]-from_vertex_bbx[1])/2))
        _p1 = ispointonline(ip1, ip2, (p1+p2)/2; extended=false) ? ip1 : ip2
        _, ip1, ip2 = intersectionlinecircle(p1, p2, p2, distance(O, (to_vertex_bbx[2]-to_vertex_bbx[1])/2))
        _p2 = ispointonline(ip1, ip2, (p1+p2)/2; extended=false) ? ip1 : ip2
        if self_loop
            neighbor_vertices = neighbors(GRAPHS[object.opts[:_graph_idx]], GRAPH_EDGES[object.opts[:_edge_idx]].from_vertex.vertex_id, strict=true)
            neighbor_pos = Vector{Point}(map(nv -> nv.object.opts[:position], neighbor_vertices))
            idx, sector = largest_circle_sector(p1, neighbor_pos)
            angle = slope(p1, neighbor_pos[idx])+sector/2
            direction = Point(cos(angle), sin(angle))
            outline = draw_self_loop_edge(p1, from_vertex_bbx, center_offset, end_offsets, direction)
        elseif shape == :curved
            outline = draw_curved_edge(_p1, _p2, center_offset, end_offsets)
        else
            outline = draw_straight_edge(_p1, _p2, center_offset, end_offsets)
        end
        poly(outline, :stroke)
        @register_style_opts object shape center_offset end_offsets outline
    end
    return draw
end

function edge_style(; color="red", linewidth::Real=2, dash::String="dotted", blend="on")
    styling = true
    draw = (video, object, frame; linewidth=linewidth, dash=dash, color=color, blend=blend, styling=styling, kwargs...) -> begin
        # ToDo: Allow a list of colors, linewidths, dash to be specified.
        # Interpolate in between when blend option is turned on
        sethue(color)
        setline(linewidth)
        setdash(dash)
        @register_style_opts object color linewidth dash blend styling
    end
    return draw
end

function edge_arrow(; start=nothing, finish=nothing, color="black")
    draw = (video, object, frame; arrow_start=start, arrow_finish=finish, arrow_color=color, outline, kwargs...) ->  begin
        sethue(arrow_color)
        # Skip the default case
        if outline == [O, O]
            return
        end
        if is_directed(GRAPHS[object.opts[:_graph_idx]].graph.adjacency_graph) && arrow_finish === nothing
            arrow_finish = true
        end
        l = length(outline)
        if arrow_start !== nothing
            Luxor.arrow(reverse(outline[1:2])...)
        end
        if arrow_finish !== nothing
            Luxor.arrow(outline[l-1:l]...)
        end
        @register_style_opts object arrow_start arrow_finish arrow_color
    end
    return draw
end

function edge_text_style(; color="black", fonttype="Times Roman", fontsize=10, opacity=0.8)
    draw = (video, object, frame; text_color=color, fonttype=fonttype, fontsize=fontsize, text_opacity=opacity, kwargs...) -> begin
        sethue(text_color)
        setfont(fonttype, fontsize)
        setopacity(text_opacity)
        @register_style_opts object text_color fonttype fontsize text_opacity
    end
    return draw
end

function edge_text(text_content; position::Real = 0.5, offset::Real = 2)
    draw = (video, object, frame; text_content=text_content, position=position, offset=offset, outline, kwargs...) ->  begin
        # ToDo: What to do for bezier curved edges?
        # ToDo: Add edge label rotation
        # Align text along edge
        if outline == [O, O]
            return
        end
        l = length(outline)
        idx = floor(Int, l * position)
        if l%2 == 0
            pt = (outline[idx] + outline[idx+1])/2
            sl = slope(outline[idx], outline[idx+1])
        else
            pt = outline[idx]
            sl = idx == l ? slope(outline[idx%l+1], outline[idx]) : slope(outline[idx], outline[idx+1])
        end
        translate(pt)
        rotate(sl)
        label(text_content, :N, O, leader=false, offset=offset)
        sl == 0 ? rotate(1/sl) : nothing
        translate(-pt)
        @register_style_opts object text_content position offset
    end
    return draw
end

function draw_self_loop_edge(p1, from_vertex_bbx, center_offset, end_offsets, direction)
    r = max((from_vertex_bbx[2]-from_vertex_bbx[1])/2..., center_offset)
    offset = min((from_vertex_bbx[2]-from_vertex_bbx[1])/2..., center_offset)
    c = p1 + r * direction
    # Might replace by a clipping region to remove the extra edge remnants appearing inside a vertex
    # pt1, pt2 = intersectioncircleboundingbox(c, r, from_vertex_bbx...)
    # A temporary solution unless intersectioncircleboundingbox is fixed
    _, pt1, pt2 = intersectioncirclecircle(c, r, p1, distance(O, (from_vertex_bbx[2]-from_vertex_bbx[1])/2))
    pt1, pt2 = isarcclockwise(c, pt1, pt2) ? (pt1, pt2) : (pt2, pt1)
    angles = slope(c, pt2), slope(c, pt1)
    angle_offsets = end_offsets./r
    new_angles = angles .+ (angle_offsets[1], -angle_offsets[2])
    Luxor.newpath()
    Luxor.arc(c, r, new_angles..., :path)
    Luxor.closepath()
    return first(pathtopoly())
end

function draw_curved_edge(p1, p2, center_offset, end_offsets)
    center_pt = Luxor.perpendicular((p1+p2)/2, p1, center_offset)
    c, r = center3pts(p1, center_pt, p2)
    angles = slope(c, p1), slope(c, p2)
    angle_offsets = end_offsets./r
    new_angles = angles .+ (angle_offsets[1], -angle_offsets[2])
    Luxor.newpath()
    Luxor.arc(c, r, new_angles..., :path)
    Luxor.closepath()
    return first(pathtopoly())
end

function draw_straight_edge(p1, p2, center_offset, end_offsets)
    d = Luxor.distance(p1, p2)
    t1 = end_offsets[1]/d
    t2 = (d-end_offsets[2])/d
    new_p1 = t1*p1 + (1-t1)*p2
    new_p2 = t2*p1 + (1-t2)*p2
    Luxor.newpath()
    line(new_p1, new_p2, :path)
    Luxor.closepath()
    return first(pathtopoly())
end

function largest_circle_sector(c::Point, pts::Vector{Point})
    idx = 1
    sector = 0
    n = length(pts)
    if n==1
        return 1, 2*pi
    end
    slopes = sort(Vector{Tuple}([(slope(c, pts[i]), i) for i in 1:n]))
    for i in 1:n
        s = slopes[i%n+1][1]-slopes[i][1]+(i==n)*2*pi
        if sector < s
            sector = s
            idx = slopes[i][2]
        end
    end
    return idx, sector
end

# # ToDo: Needs fixes
# Add this to Luxor
# function intersectioncircleboundingbox(c::Point, radius::Real, upperleft::Point, lowerright::Point)
#     # Find the closest corner of box to the center of the circle
#     px = abs(lowerright[1] - c[1]) < abs(upperleft[1] - c[1]) ? lowerright[1] : upperleft[1]
#     py = abs(lowerright[2] - c[2]) < abs(upperleft[2] - c[2]) ? lowerright[2] : upperleft[2]
#     # Find the other 2 corner points joining this point
#     o1 = Point(upperleft[1]+lowerright[1]-px, py)
#     o2 = Point(px, upperleft[2]+lowerright[2]-py)
#     # Calculate intersection points
#     nints, ip1, ip2 = zip(intersectionlinecircle.(Point(px, py), [o1, o2], c, radius)...)
#     p = Point(px, py)
#     intersection_points = ispointonline.(ip1, [p, p], [o1, o2]; extended=false).*ip1 + ispointonline.(ip2, [p, p], [o1, o2]; extended=false).*ip2
#     # throw(ErrorException("$nints, $ip1, $ip2, $intersection_points"))
#     return intersection_points
# end
