function boundingVisibility(boxes,elem,s2,beam_source,s1,coord,n)
    for i=1:2:size(boxes,1)
        max_corner = boxes(i,:);
        min_corner = boxes(i+1,:);
        inside_box = (s1(1,:) <= max_corner(1) & ...
                      s1(1,:) >= min_corner(1) & ...
                      s1(2,:) <= max_corner(2) & ...
                      s1(2,:) >= min_corner(2) & ...
                      s1(3,:) <= max_corner(3) & ...
                      s1(3,:) >= min_corner(3));
        doesIntersect(elem(inside_box,:), s2, beam_source, s1(inside_box,:), coord,n(inside_box,:));

    end
end