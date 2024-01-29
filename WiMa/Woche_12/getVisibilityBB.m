function [vis,elem_vis] = getVisibilityBB(coord,elem,elem2obj,~,s,n)
    vis = true(size(s,1),1);
    % inside_box stores the indices of all triangles that are inside the
    % current bounding box and are visible
    inside_box = logical([0; ones(elem2obj(3)-elem2obj(2),1); zeros(elem2obj(5)-elem2obj(3),1)]);

    % bounds in both directions of every coordinate
    x_max = max(s(inside_box,1));
    x_min = min(s(inside_box,1));
    y_max = max(s(inside_box,2));
    y_min = min(s(inside_box,2));
    z_max = max(s(inside_box,3));
    z_min = min(s(inside_box,3));
        
    % building volume. max and min point are all that is needed
    corners = [x_max,y_max,z_max; ...
               x_min,y_min,z_min];
           
    % covered_by_box stores all triangles that are potentially in the
    % shadow of the bounding box. intially this is all triangles of the
    % wall
    covered_by_box = logical([zeros(elem2obj(3)-1,1); ones(elem2obj(5)-elem2obj(3),1)]);
    
    source = s(1,:);
    walls = s(covered_by_box,:);
    
    % this returns a logical vector indicating whether a triangle is in the 
    % shadow of our box 
    covered_by_box = intersectsBox(corners,walls,source,covered_by_box);
    
    vis=boundingBoxes(corners,s,inside_box,covered_by_box,vis,elem,coord,n,elem2obj);
    vis = logical(vis);
    elem_vis = elem(vis, :);
end