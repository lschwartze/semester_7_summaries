function boxes = surrogateBoxes(beam_source,occluder, target)
    s1 = occluder.s;
    s2 = target.s;
    elem = occluder.elem;
    coord = occluder.coord;
    n = occluder.n;
    % inside_box stores the indices of all triangles that are inside the
    % current bounding box and are visible
    inside_box = true(size(s1,1),1);
    
    % bounds in both directions of every coordinate
    x_max = max(s1(:,1));
    x_min = min(s1(:,1));
    y_max = max(s1(:,2));
    y_min = min(s1(:,2));
    z_max = max(s1(:,3));
    z_min = min(s1(:,3));
        
    % building volume. max and min point are all that is needed
    corners = [x_max,y_max,z_max; ...
               x_min,y_min,z_min];
           
    % covered_by_box stores all triangles that are potentially in the
    % shadow of the bounding box. intially this is all triangles of the
    % wall
    covered_by_box = true(size(s2,1),1);
    
    source = beam_source.pos;
    walls = s2;
    
    % this returns a logical vector indicating whether a triangle is in the 
    % shadow of our box 
    covered_by_box = intersectsBox(corners,walls,source,covered_by_box);
    
    boxes = getBoxes(corners,s1,s2,inside_box,covered_by_box,elem,coord,n,source,[]);    
end