function reflect_refract(light, lense, p, lenses)
    % light: source, normalized direction
    % lense: start point, end point, orthogonal vector
    % p: point of intersection of lense and beam
    
    eta_1 = 1.00027717;
    eta_2 = 1.5168;
    
    % this ensures that the lense's normalvector points away from the light
    if dot(lense(:,3), light(:,2)) < 0
        lense(:,3) = -lense(:,3);
    end
    
    % plot incoming beam
    plot([light(1,1), p(1)], [light(2,1), p(2)], "color",[1 0.8 0])

    % calculate reflected beam
    prod = dot(light(:,2),lense(:,3));
    refl = light(:,2) - 2 * lense(:,3) * prod;
    refl = refl/norm(refl);
    reflected_beam = [p, refl];
    
    % calculate refracted beam
    v_1 = light(:,2);
    v_2 = lense(:,3);
    alpha = acos(dot(v_1,v_2));
    
    radical = 1-(eta_1/eta_2)^2*(1-cos(alpha)^2);
    if radical < 0
        % totalreflexion
        return
    else
        % gives gamma in radians
        gamma = acos(sqrt(radical));

        rotational_matrix = [[cos(gamma), sin(gamma)]; [-sin(gamma), cos(gamma)]];
        refracted_direction = rotational_matrix * lense(:,3);
        
        % alpha might have been negative, so check that here
        test_rot = [[cos(alpha), sin(alpha)]; [-sin(alpha), cos(alpha)]];
        rotated = test_rot*light(:,2);
        
        % if alpha was initially negative, rotate in the other direction
        if norm(rotated-lense(:,3)) < 1e-4
            rotational_matrix = [cos(gamma),-sin(gamma);sin(gamma),cos(gamma)];  
            refracted_direction = rotational_matrix*lense(:,3);
        end

        refr = refracted_direction/norm(refracted_direction);
        end_point = p+2*refr;
        refracted_beam = [p, refr];
    end
    
    % reflected and refracted beam might hit lense as well,
    % figure this out recursively
    num_lenses = size(lenses, 2);
    j = 1;
    % these keep track if any lenses were hit
    flag_refl = false;
    flag_refr = false;
    
    %check for each lense
    while j <= num_lenses-2
        lense_rec = lenses(:,j:j+2);
        % get intersection point
        p_new = detect_intersection(reflected_beam, lense_rec);
        % if hit, draw recursively
        if ~isequal(p_new, [-1;-1])
            reflect_refract(reflected_beam, lense_rec, p_new, lenses)
            flag_refl = true;            
        end
        % get intersection point
        p_new = detect_intersection(refracted_beam, lense_rec);
        if ~isequal(p_new, [-1;-1])
            % if hit, draw recursively
            reflect_refract(refracted_beam, lense_rec, p_new, lenses)
            flag_refr = true;
        end
        j = j+3;
    end
    % no hits, draw to infinity
    if ~flag_refl
        plot([p(1), p(1) + refl(1)], [p(2), p(2) + refl(2)], "color",[1 0.8 0])
    end
    if ~flag_refr
        plot([p(1), end_point(1)], [p(2), end_point(2)], "color",[1 0.8 0])
    end
    return
end

