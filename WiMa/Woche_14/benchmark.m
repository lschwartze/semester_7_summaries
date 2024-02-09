clc, clear, close all

iter = 10:10:50;

timeCreateScene = zeros(size(iter));
timeGetVisibility = zeros(size(iter));
timeGetVisibilityBB = zeros(size(iter));
timeGetVisibilityTriangle = zeros(size(iter));
timeGetVisibilityNaive = zeros(size(iter));   

for i=1:size(iter,2)
    
    light = Light([3, 0, 3], [1, 0, 0], 1);
    occluder = Sphere(0.2, [1, 1, 1], iter(i), [0.3, 0.3, 0.3]);
    target1 = Parallelogramm([0,0,0; 1.5,0,0; 0,2,0], iter(i), ones(1,3)); 
    target2 = Parallelogramm([0,0,0; 0,0,1.6; 0,2,0], 50, ones(1,3));%[0.5, 0.5, 0.5]);

    
    tic();
    scene = Scene([target1, occluder], light);
    timeCreateScene(i) = toc();
        
    tic();
    getVisibility(light,occluder,target1);
    getVisibility(light,occluder,target2);
    timeGetVisibility(i) = toc();
    
    boxes1 = surrogateBoxes(light,occluder,target1);
    boxes2 = surrogateBoxes(light,occluder,target2);
    s1 = occluder.s;
    s2 = target1.s;
    elem = occluder.elem;
    coord = occluder.coord;
    n = occluder.n;
    s2_2 = target2.s;
    tic();
        boundingVisibility(boxes1,elem,s2,light.pos,s1,coord,n);
        boundingVisibility(boxes2,elem,s2_2,light.pos,s1,coord,n);
    timeGetVisibilityBB(i) = toc();
    
    tic();
    getVisibilityTriangle(light,occluder);
    timeGetVisibilityTriangle(i) = toc();
    
    elem1 = [[1,1,1];occluder.elem;target1.elem];
    s2 = occluder.s;
    beam_source = light.pos;
    s1 = [light.pos;occluder.s;target1.s];
    coord1 = [light.pos;occluder.coord;target1.coord];
    n1 = [light.pos;occluder.n;target1.n];
    
    elem2 = [[1,1,1];occluder.elem;target2.elem];
    s_2 = [light.pos;occluder.s;target2.s];
    coord2 = [light.pos;occluder.coord;target2.coord];
    n2 = [light.pos;occluder.n;target2.n];


    tic();
    doesIntersect(elem1,s2, beam_source, s1, coord1,n1);
    doesIntersect(elem2,s2, beam_source, s_2, coord2,n2);
    timeGetVisibilityNaive(i) = toc();
    
end

figure(1)
semilogy(iter,timeCreateScene)
title('Time to create scene')
xlabel('resolution')
ylabel('Time in seconds')
figure(2)
loglog(iter,timeGetVisibility)
hold on
loglog(iter,timeGetVisibilityBB)
loglog(iter,timeGetVisibilityTriangle)
loglog(iter,timeGetVisibilityNaive)
hold off

grid on
%semilogy(iter,timeGetVisibilityTriangleVec)
legend("bounding ball", "bounding boxes", "triangles", "naive")

title('Time to get visiblity')
xlabel('resolution')
ylabel('Time in seconds')
