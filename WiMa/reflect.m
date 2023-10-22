function reflect(lenses, light, lense, p)
    % light: source, normalized direction
    % lense: start point, end point, orthogonal vector
    % p: point of intersection of lense and beam

    prod = dot(light(:,2),lense(:,3));
    refl = light(:,2) - 2 * lense(:,3) * prod;
    plot([p(1), p(1) + refl(1)], [p(2), p(2) + refl(2)], "y")
    
    % the reflected light might reflect from another lense
    % figure this out recursively
    % vector_direction = refl-p;
    % normalized = vector_direction/norm(vector_direction);
    normalized = refl/norm(refl);
    new_light = [p, normalized];
    % disp(new_light)
    plot_all_reflections(new_light, lenses);
end
