function p = detect_intersection(light, lense)
    % light: source, normalized direction
    % lense: start point, end point, orthogonal vector
    connection_lense = lense(:,2) - lense(:,1);
    A = [[light(1,2);light(2,2)], [-connection_lense(1); -connection_lense(2)]];
    b = [lense(1,1)-light(1,1); lense(2,1)-light(2,1)];
    sol = linsolve(A,b);

    % no intersection if:
    % 1. crossing point right of lense
    % 2. crossing point left of lense
    % 3. crossing point in source of light
    if sol(2) >= 1 || sol(2) <= 0 || sol(1) < 1e-4
        p = [-1;-1];
        return
    end
    p = light(:,1) + sol(1)*light(:,2);
    % plot intersection
    plot(p(1),p(2), "k+")
    % plots normal vector in both directions for good measure
    plot([p(1) + lense(1,3)/10, p(1)], [p(2) + lense(2,3)/10, p(2)], "r")
    plot([p(1) - lense(1,3)/10, p(1)], [p(2) - lense(2,3)/10, p(2)], "r--")
end