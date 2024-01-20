function [vis,elem_vis] = getVisibilityBB(coord,elem,elem2obj,coord2obj,s,n)
    light_centroid = s(1,:);
        
    connectors = s-light_centroid;
    vis = dot(n,connectors,2);
    % we want non-positive values to map to 1 and positive to 0
    % first make 0 values slightly negative
    vis = vis-eps;
    % only save positive values, negative ones are mapped to 0
    vis = max(vis,0);
    % light has been deleted, simply add again
    vis(1) = 1;
    
    vis = logical(vis);
    objects = (elem2obj(2):elem2obj(3)-1);
    % bounds in both directions of every coordinate
    max_x = max(s(objects,1));
    min_x = min(s(objects,1));
    max_y = max(s(objects,2));
    min_y = min(s(objects,2));
    max_z = max(s(objects,3));
    min_z = min(s(objects,3));
    
    % building cylinder. max and min point are all that is needed
    corners = [max_x,max_y,max_z; ...
               min_x,min_y,min_z];
    %disp(sum(vis))
    vis=boundingBoxes(elem2obj,coord2obj,corners,coord,s,n,vis,1);
    %disp(sum(vis))
    elem_vis = elem(vis == 1, :);
end
