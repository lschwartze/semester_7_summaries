function vis = boundingBoxes(corners,s,inside_box,covered_by_box,vis,elem,coord,n)
    % if there are no triangles within the box or the box has no triangles
    % in its shadow, continue
    if sum(inside_box) == 0 || sum(covered_by_box) == 0
        return 
    end

    % if only a small number of triangles is in the box, use the naive
    % appraoch
    if sum(inside_box) <= 64
        out = doesIntersect(inside_box, elem, s(covered_by_box,:), s(1,:), s, coord,n);
        vis(covered_by_box) = vis(covered_by_box)&~out;

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
        inside_next_box = inside_box & s(:,dim)<=mid_point;
        
        % points in the shadow of the next box must be in the shadow of the
        % previous box and their intersection point with the previous point
        % must be smaller than the midpoint on the edge

        walls = s(covered_by_box,:);
        
        corners_smaller = [corners(1,:)-max_length*scaler/2; corners(2,:)];
        covered_by_next_box = intersectsBox(corners_smaller,walls,s(1,:),covered_by_box);
        vis=boundingBoxes(corners_smaller,s,inside_next_box,covered_by_next_box,vis,elem,coord,n);
        
        % this is exactely the same but values must be larger
        inside_next_box = inside_box & s(:,dim)>mid_point;
        
        corners_bigger = [corners(1,:); corners(2,:)+max_length*scaler/2];
        covered_by_next_box = intersectsBox(corners_bigger,walls,s(1,:),covered_by_box);
        vis=boundingBoxes(corners_bigger,s,inside_next_box,covered_by_next_box,vis,elem,coord,n);
    end
end