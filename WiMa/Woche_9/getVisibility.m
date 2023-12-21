function [vis,elem_vis] = getVisibility(coord,elem,elem2obj,coord2obj,s,n)
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
    
    vis = logical(vis);
    
    % build the largest ball inside of object
    innerball = s(elem2obj(2):elem2obj(3)-1,:);
    innercentre = mean(innerball);
    innerradius = min(sqrt(sum((innerball-innercentre).^2,2)));
    
    % build the smallest ball outside of object
    outerball = coord(coord2obj(2):coord2obj(3)-1,:);
    outercentre = mean(outerball);
    outerradius = max(sqrt(sum((outerball-outercentre).^2,2)));
    
    walls = s(elem2obj(3):elem2obj(5)-1,:);
    connector = light_centroid-walls;
    connector_norm = sqrt(sum(connector.^2,2));
    unnormalized_dist = cross((innercentre-walls),connector,2);
    dist_to_inner = sqrt(sum(unnormalized_dist.^2,2))./connector_norm;
    
    unnormalized_dist = cross((outercentre-walls),connector,2);
    dist_to_outer = sqrt(sum(unnormalized_dist.^2,2))./connector_norm;
        
    for i=1:length(dist_to_inner)
        if dist_to_outer(i) > outerradius
            vis(elem2obj(3)+i-1) = 1;
        elseif dist_to_inner(i) < innerradius
            vis(elem2obj(3)+i-1) = 0;
        else
            t2 = elem(i,:);
            vis(elem2obj(3)+i-1) = doesIntersect(elem2obj, vis, t2, light_centroid, s, coord);
        end
    end
    elem_vis = elem(vis == 1, :);
end
