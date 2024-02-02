function covered_by_box = intersectsBox(corners,walls,source,covered_by_box)
    % span all connecting vectors between the walls and the light
    connectors = walls-source;
    x_max = corners(1,1);
    x_min = corners(2,1);
    y_max = corners(1,2);
    y_min = corners(2,2);
    z_max = corners(1,3);
    z_min = corners(2,3);

    % for five sides of the box, check if the connector intersects
    full_index = zeros(size(walls,1),1);

    % this calculates the intersection of light rays with the y_max wall
    scaling = (y_max-source(2))./connectors(:,2);
    scaled = scaling.*connectors+source;
    intersectors = (scaled(:,1)<=x_max &...
                    scaled(:,1)>=x_min &...
                    scaled(:,3)<=z_max &...
                    scaled(:,3)>=z_min);
    full_index(intersectors) = 1;
    
    % this calculates the intersection of light rays with the z_max wall
    scaling = (z_max-source(3))./connectors(:,3);
    scaled = scaling.*connectors+source;
    intersectors = (scaled(:,2)<=y_max &...
                    scaled(:,2)>=y_min &...
                    scaled(:,1)<=x_max &...
                    scaled(:,1)>=x_min);
    full_index(intersectors) = 1;

    % this calculates the intersection of light rays with the x_min wall
    scaling = (x_min-source(1))./connectors(:,1);
    scaled = scaling.*connectors+source;
    intersectors = (scaled(:,2)<=y_max &...
                    scaled(:,2)>=y_min &...
                    scaled(:,3)<=z_max &...
                    scaled(:,3)>=z_min);
    full_index(intersectors) = 1;

    % this calculates the intersection of light rays with the y_min wall
    scaling = (y_min-source(2))./connectors(:,2);
    scaled = scaling.*connectors+source;
    intersectors = (scaled(:,1)<=x_max &...
                    scaled(:,1)>=x_min &...
                    scaled(:,3)<=z_max &...
                    scaled(:,3)>=z_min);
    full_index(intersectors) = 1;

    % this calculates the intersection of light rays with the z_min wall
    scaling = (z_min-source(3))./connectors(:,3);
    scaled = scaling.*connectors+source;
    intersectors = (scaled(:,2)<=y_max &...
                    scaled(:,2)>=y_min &...
                    scaled(:,1)<=x_max &...
                    scaled(:,1)>=x_min);
    full_index(intersectors) = 1;

    %covered_by_box(logical(index)) = 1;
    %vis(logical(index)) = 0;
    %intersections(intersectors,:) = scaled(intersectors,:);
    covered_by_box(covered_by_box == 1) = full_index; 