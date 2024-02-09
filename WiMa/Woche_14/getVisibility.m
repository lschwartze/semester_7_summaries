function vis = getVisibility(beam_source,occluder,target)
    
    light_centroid = beam_source.pos;
    s1 = occluder.s;
    s2 = target.s;
    n1 = occluder.n;
    n2 = target.n;
    coord = occluder.coord;
    elem = occluder.elem;
    
    %Fallunterscheidungen, je nach Objekt werden verschiedene
    %get_visibillity Funktonen Verwendet

    if  isa(occluder,"Parallelogramm")
        if isequal(target,occluder)   
            t = dot(n1(1,:),-light_centroid+s1(1,:),2)/dot(n1(1,:),s1(1,:)-light_centroid,2);
            if t == 0
                vis = ones(size(s2,1),1);
            else
                vis = zeros(size(s2,1),1);
            end
        else
            corners = occluder.corners;
            connectors = s2-light_centroid;
            t = dot(n1(1,:),s1(1,:)-light_centroid)./dot(repmat(n1(1,:),size(connectors,1),1),connectors,2);
            idx = 0 < t & t < 1;
            vis = false(size(s2,1),1);
            t = t(idx);
            d = light_centroid + t(idx).*connectors(idx,:);
            A = [corners(2,:)'-corners(1,:)',corners(3,:)'-corners(1,:)'];
            sol = A\(d-corners(1,:))';
            sol(sol<0 | sol > 1) = NaN;
            sol = sol(1,:)+sol(2,:);
            vis(idx) = sol <2;
            
        end
    elseif isa(target,"Sphere") && isequal(target,occluder)
        connectors = s2-light_centroid;
        vis = dot(n2,connectors,2);
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
    
    elseif isa(occluder,"Sphere") && isa(target,"Parallelogramm") 
        % build the largest ball inside of object
        innerball = s1;
        innercentre = mean(innerball);
        innerradius = min(sqrt(sum((innerball-innercentre).^2,2)));
        
        % build the smallest ball outside of object
        outerball = coord;
        outercentre = mean(outerball);
        outerradius = max(sqrt(sum((outerball-outercentre).^2,2)));
        
        walls = s2;
        connector = light_centroid - walls;
        connector_norm = sqrt(sum(connector.^2,2));
        unnormalized_dist = cross((innercentre-walls),connector,2);
        dist_to_inner = sqrt(sum(unnormalized_dist.^2,2))./connector_norm;
        
        unnormalized_dist = cross((outercentre-walls),connector,2);
        dist_to_outer = sqrt(sum(unnormalized_dist.^2,2))./connector_norm;
            

        idx = dist_to_outer>outerradius;
        vis(idx) = 1;

        idx02 = dist_to_inner < innerradius;
        vis(idx02) = 0;

 
        vis(~idx & ~idx02) = doesIntersect(elem,s2(~idx & ~idx02,:),light_centroid,s1,coord,n1);
        vis = ~vis(:);
        
    elseif isa(occluder,"Object3D") && isa(target,"Parallelogramm") 
        vis = getVisibilityBB(beam_source,occluder, target);
    elseif isequal(target,occluder)
        vis = getVisibilityTriangle(beam_source,occluder);
    else
        vis = ~doesIntersect(elem,s2,light_centroid, s1,coord,n1);
    end   
end
