function [vis,elem_vis] = getVisibilityTriangleVec(coord,elem,elem2obj,coord2obj,s,n)

    light = s(1,:);
    visMatrix = true(size(s,1),size(s,1));
    %calculate connecting vector between light and triangles
    s = s - light;

    %calculate normal vectors on all planes between two corners of a
    %triangle and the center of the light
    vec1 = cross(coord(elem(:,1),:)-light,coord(elem(:,2),:)-light);
    vec2 = cross(coord(elem(:,2),:)-light,coord(elem(:,3),:)-light);
    vec3 = cross(coord(elem(:,3),:)-light,coord(elem(:,1),:)-light);
    
    %calculate if a triangle is above all planes of a triangle
    dot1 = (sign(s*vec1') == 1);
    dot2 = (sign(s*vec2') == 1);
    dot3 = (sign(s*vec3') == 1);
    dotAll = logical(dot1 .* dot2 .* dot3)';
    %if so it is invisible
    visMatrix(dotAll) = false;
    
    %a triangle can't hide itself
    visMatrix(1:size(visMatrix,1)+1:end) = 1;
    %triangles where two coordinates are the same cant hide anything
    filter = 2:size(s,1);
    filter = (coord(elem(filter,1)) == coord(elem(filter,2)) | coord(elem(filter,2)) == coord(elem(filter,3)) | coord(elem(filter,3)) == coord(elem(filter,1)));
    visMatrix(filter,:) = true;
    %if one entry in a column is zero, set the value of visibility to zero
    vis = logical(prod(visMatrix));
    %elem_vis= visMatrix;
    elem_vis = elem(vis,:);

end
