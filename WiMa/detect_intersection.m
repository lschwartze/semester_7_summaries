function p = detect_intersection(lights, lenses)
    % light: source, normalized direction
    % lense: start point, end point, orthogonal vector
    connection_lense = lenses(:,2) - lenses(:,1);
    A = [[lights(1,2);lights(2,2)], [-connection_lense(1); -connection_lense(2)]];
    b = [lenses(1,1)-lights(1,1); lenses(2,1)-lights(2,1)];
    sol = linsolve(A,b);

    % no intersection if:
    % 1. crossing point right of lense
    % 2. crossing point left of lense
    % 3. crossing point in source of light
    if sol(2) >= 1 || sol(2) <= 0 || abs(sol(1)) < 1e-4
        p = [-1;-1];
        return
    end
    p = lights(:,1) + sol(1)*lights(:,2);
    % plot intersection
    plot(p(1),p(2), "k+")
    % plots normal vector in both directions for good measure
    plot([p(1), p(1) + lenses(1,3)/10], [p(2), p(2) + lenses(2,3)/10], "r")
    plot([p(1), p(1) - lenses(1,3)/10], [p(2), p(2) - lenses(2,3)/10], "r")
end