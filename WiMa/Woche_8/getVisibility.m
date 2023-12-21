function [vis,elem_vis] = getVisibility(coord,elem,elem2obj,~,s,n)
    light_index = elem2obj(1):(elem2obj(2)-1);
    light = elem(light_index,:);
    light_centroid = s(1,:);
        
    connectors = s-light_centroid;
    vis = dot(n,connectors,2);
    % we want non-positive values to map to 1 and positive to 0
    % first make 0 values slightly negative
    vis = vis-eps;
    % only save negative values, positive ones are mapped to 0
    vis = max(vis,0);
    % transform negative values to 1
    vis = sign(vis);
    % light has been deleted, simply add again
    vis(1) = 1;
    
    for j = elem2obj(3):elem2obj(5)-1
        if vis(j) == 0
            continue
        end
        t1 = elem(j,:);
        beam_source = light_centroid;
        beam_direction = s(j,:)-beam_source;
        d = norm(beam_direction);
        for k = 2:elem2obj(3)-1
            if vis(k) == 0
                continue
            end
            
            t2 = elem(k,:);
            n2 = n(k,:);

            intersect = doesIntersect(t1, d, t2, n2, beam_source, beam_direction, coord);

            if intersect == 1
                vis(j) = 0;
                break
            end
        end
    end
    
    elem_vis = elem(vis == 1, :);
end