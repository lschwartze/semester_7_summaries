function vis = boundingBoxes(elem2obj, coord2obj, corners, coord, s, n, vis, iter)  
    if iter == 6
        x_max = corners(1,1);
        x_min = corners(2,1);
        y_max = corners(1,2);
        y_min = corners(2,2);
        z_max = corners(1,3);
        z_min = corners(2,3);
        important_s = (s(:,1)<x_max & ...
                       s(:,1)>x_min &...
                       s(:,2)<y_max &...
                       s(:,2)>y_min &...
                       s(:,3)<z_max &...
                       s(:,3)>z_min);

        if sum(important_s) == 0
            return
        else
             source = s(1,:);
             walls = s(elem2obj(3):elem2obj(5)-1,:);
             % span all connecting vectors between the walls and the light
             connectors = walls-source;
             
             % for each side of the box, check if the connector intersects
             zeros_filler = zeros(elem2obj(3)-1,1);
             
             scaling = (x_max-source(1))./connectors(:,1);
             scaled = scaling.*connectors+source;
             intersectors = (scaled(:,2)<y_max &...
                             scaled(:,2)>y_min &...
                             scaled(:,3)<z_max &...
                             scaled(:,3)>z_min);
             index = [zeros_filler; intersectors];
             vis(logical(index)) = 0;
             
             scaling = (y_max-source(2))./connectors(:,2);
             scaled = scaling.*connectors+source;
             intersectors = (scaled(:,1)<x_max &...
                             scaled(:,1)>x_min &...
                             scaled(:,3)<z_max &...
                             scaled(:,3)>z_min);
             index = [zeros_filler; intersectors];
             vis(logical(index)) = 0;
             
             scaling = (z_max-source(3))./connectors(:,3);
             scaled = scaling.*connectors+source;
             intersectors = (scaled(:,2)<y_max &...
                             scaled(:,2)>y_min &...
                             scaled(:,1)<x_max &...
                             scaled(:,1)>x_min);
             index = [zeros_filler; intersectors];
             vis(logical(index)) = 0;
             
             scaling = (x_min-source(1))./connectors(:,1);
             scaled = scaling.*connectors+source;
             intersectors = (scaled(:,2)<y_max &...
                             scaled(:,2)>y_min &...
                             scaled(:,3)<z_max &...
                             scaled(:,3)>z_min);
             index = [zeros_filler; intersectors];
             vis(logical(index)) = 0;
             
             scaling = (y_min-source(2))./connectors(:,2);
             scaled = scaling.*connectors+source;
             intersectors = (scaled(:,1)<x_max &...
                             scaled(:,1)>x_min &...
                             scaled(:,3)<z_max &...
                             scaled(:,3)>z_min);
             index = [zeros_filler; intersectors];
             vis(logical(index)) = 0;
             
             scaling = (z_min-source(3))./connectors(:,3);
             scaled = scaling.*connectors+source;
             intersectors = (scaled(:,2)<y_max &...
                             scaled(:,2)>y_min &...
                             scaled(:,1)<x_max &...
                             scaled(:,1)>x_min);
             index = [zeros_filler; intersectors];
             vis(logical(index)) = 0;

             vis = logical(vis);
        end
    else
        % if maximum iteration number is not reached, we divide the box in
        % 8 subboxes and restart
        for i=0:7
            next_corners = getNextCorners(corners,i);
            vis=boundingBoxes(elem2obj,coord2obj,next_corners,coord,s,n,vis,iter+1);
        end
    end

end