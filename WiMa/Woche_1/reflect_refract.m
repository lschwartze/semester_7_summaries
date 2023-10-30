function reflect_refract(light, lense, p)
    % light: source, normalized direction
    % lense: start point, end point, orthogonal vector
    % p: point of intersection of lense and beam
    
    eta_1 = 1.00027717;
    eta_2 = 1.5168;
    
    % plot incoming beam
    plot([light(1,1), p(1)], [light(2,1), p(2)], "color",[1 0.8 0])

    % plot reflected beam
    prod = dot(light(:,2),lense(:,3));
    refl = light(:,2) - 2 * lense(:,3) * prod;
    plot([p(1), p(1) + refl(1)], [p(2), p(2) + refl(2)], "c")
    
    % plot refracted beam
    v_1 = light(:,2);
    v_2 = lense(:,3);
    % this angle can be positive and negative
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

        end_point = p+2*refracted_direction;
        plot([p(1), end_point(1)], [p(2), end_point(2)], "g--")
    end
    return
end

