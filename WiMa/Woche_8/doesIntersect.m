function intersect = doesIntersect(~, ~, t2, n2, beam_source, beam_direction, coord)
%{
t1: first triangle
d: distance of beam source to centroid of t1
t2: second triangle
n2: normal of second triangle
beam_source: source of light
beam_direction: vector of light
-> light can be written as beam_source + t*beam_direction

returns: boolean array [a,b]
-> a stores if t2 covers t1
-> b stores if t1 covers t2
%}
    intersect = 0;
    coord = coord';
    % beam is parallel to second triangle
    if dot(beam_direction,n2) == 0
        return
    end
    A = [-beam_direction(:), coord(:,t2(2))-coord(:,t2(1)), coord(:,t2(3))-coord(:,t2(1))];
    b = beam_source(:)-coord(:,t2(1));
    sol = A\b;
    t = sol(1);
    
    if sol(2) < 0 || sol(3) < 0 || sol(2)+sol(3)>1 || t < 0 || t>1
        return
    end
    intersect = 1;

end