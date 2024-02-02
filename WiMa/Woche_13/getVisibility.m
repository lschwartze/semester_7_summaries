function [vis,elem_vis] = getVisibility(coord,elem,elem2obj,coord2obj,s,n)
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
        
    % full has ones where there are elements that have not yet been
    % considered
    full = [zeros(elem2obj(3)-1,1);ones(elem2obj(5)-elem2obj(3),1)];
    idx = dist_to_outer>outerradius;
    idx = logical([zeros(elem2obj(3)-1,1);idx]);
    full = logical(full-idx);
    % subtract all visible elements
    vis(idx) = 1;
    idx = dist_to_inner<innerradius;
    idx = logical([zeros(elem2obj(3)-1,1);idx]);
    full = logical(full-idx);
    % subtract all invisible elements
    vis(idx) = 0;
    tic
    out = doesIntersect(vis, elem, s(full,:), light_centroid, s, coord,n);
    toc
    vis(full) = ~out;
    elem_vis = elem(vis == 1, :);
end
