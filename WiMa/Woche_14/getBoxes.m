function boxes = getBoxes(corners,s1,s2,inside_box,covered_by_box,elem,coord,n,beam_source,boxes) 
    % if there are no triangles within the box or the box has no triangles
    % in its shadow, continue
    if sum(inside_box) == 0 || sum(covered_by_box) == 0
        %vis(covered_by_box) = 1;
        return 
    end

    % if only a small number of triangles is in the box, use the naive
    % appraoch
    if sum(inside_box) <= 128
        boxes = [boxes; [corners(1,:);corners(2,:)]];
    else        
        % otherwise split the box in two
        % for that choose the longest edge and find its mid point
        edge_lengths = corners(1,:)-corners(2,:);
        [max_length, dim] = max(edge_lengths);
        mid_point = corners(1,dim)-max_length/2;
        scaler = zeros(1,3);
        scaler(dim) = 1;
        
        % the first sub box has values smaller than the mid point in this
        % dimension
        % the points within that box must be in the previous box and there
        % coordinate value in the respective dimension must be smaller than
        % the midpoint on the edge
        inside_next_box = inside_box & s1(:,dim)<=mid_point;
        % points in the shadow of the next box must be in the shadow of the
        % previous box and their intersection point with the previous point
        % must be smaller than the midpoint on the edge
        %covered_by_next_box = covered_by_box & intersections(:,dim)<=mid_point;
        %walls = s(covered_by_box,:);
        
        corners_smaller = [corners(1,:)-max_length*scaler/2; corners(2,:)];
        %covered_by_next_box = intersectsBox(corners,walls,s(1,:),covered_by_box);
        boxes = getBoxes(corners_smaller,s1,s2,inside_next_box,covered_by_box,elem,coord,n,beam_source,boxes);
        
        % this is exactely the same but values must be larger
        inside_next_box = inside_box & s1(:,dim)>mid_point;
        %covered_by_next_box = covered_by_box & intersections(:,dim)>mid_point;
        %walls = s(covered_by_next_box);
        
        corners_bigger = [corners(1,:); corners(2,:)+max_length*scaler/2];
        %covered_by_next_box = intersectsBox(corners,walls,s(1,:),covered_by_box);

        boxes = getBoxes(corners_bigger,s1,s2,inside_next_box,covered_by_box,elem,coord,n,beam_source,boxes); 
    end
end