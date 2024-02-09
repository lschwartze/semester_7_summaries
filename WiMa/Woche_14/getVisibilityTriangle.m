function vis = getVisibilityTriangle(beam_source,occluder)

    light = beam_source.pos;
    s=occluder.s;
    elem = occluder.elem;
    coord = occluder.coord;

    visTemp = true(size(s,1),1);
    %calculate connecting vector between light and triangles
    s = s - light;
    
    %sort triangles by distance to light
    sNew = [s,(1:size(s,1))',sqrt(sum(s.^2,2))];
    sNew = sortrows(sNew,5,'ascend');
    s = sNew(:,1:3);
    sSortingArray = sNew(:,4);
    
    %iterate over triangles
    for i=2:size(s,1)
            %calculate normal vectors of planes  between two corners of
            %the triangle and the light
            vec1 = cross(coord(elem(sSortingArray(i),1),:)-light,coord(elem(sSortingArray(i),2),:)-light);
            vec2 = cross(coord(elem(sSortingArray(i),2),:)-light,coord(elem(sSortingArray(i),3),:)-light);
            vec3 = cross(coord(elem(sSortingArray(i),3),:)-light,coord(elem(sSortingArray(i),1),:)-light);
            
            %calculate all triangles which are above all the planes of
            %triangle i
            dot1 = (sign(s*vec1') == 1);
            dot2 = (sign(s*vec2') == 1);
            dot3 = (sign(s*vec3') == 1);
            dotAll = logical(dot1 .* dot2 .* dot3);
            
            %only a closer triangle can hide a further one
            dotAll(1:i) = false;
            
            %if a triangle is hidden by any other triangle set it's
            %visiblity to zero
            visTemp(dotAll) = false;
    end
    
    %triangles where two coordinates are the same cant hide anything
    %not needed but afraid to delete
    %filter = 2:size(s,1);
    %filter = (coord(elem(filter,1)) == coord(elem(filter,2)) | coord(elem(filter,2)) == coord(elem(filter,3)) | coord(elem(filter,3)) == coord(elem(filter,1)));
    %visMatrix(filter,:) = true;
    
    %unsort this mess
    vis = false(size(visTemp));
    vis(sSortingArray) = visTemp;
    vis = ~vis;
end
