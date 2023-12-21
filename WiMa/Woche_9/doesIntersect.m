function intersect = doesIntersect(elem2obj, vis, t2, beam_source, s, coord)
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

coord = coord';
for i=elem2obj(2):elem2obj(3)-1
    % don't consider triangles that have been ruled out
    if vis(i) == 0
        continue
    end
    
    beam_direction = s(i,:)-beam_source;
    A = [-beam_direction(:), coord(:,t2(2))-coord(:,t2(1)), coord(:,t2(3))-coord(:,t2(1))];
    b = beam_source(:)-coord(:,t2(1));
    sol = A\b;
    
    if sol(2) >= 0 || sol(3) >= 0 || sol(2)+sol(3)<=1
        intersect = 1;
        return
    end
end
intersect = 0;
return
end