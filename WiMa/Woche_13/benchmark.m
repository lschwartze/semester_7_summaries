clc, clear, close all

iter = 10:10:50;

timeCreateScene = zeros(size(iter));
timeGetVisibility = zeros(size(iter));
timeGetVisibilityBB = zeros(size(iter));
timeGetVisibilityTriangle = zeros(size(iter));
timeGetVisibilityNaive = zeros(size(iter));

for i=1:size(iter,2)
    
    tic();
    [coord, elem, coord2obj, elem2obj] = createScene(iter(i));
    timeCreateScene(i) = toc();
    
    [s,n,area2] = getGeomParam(coord,elem);
    
    tic();
    getVisibility(coord,elem,elem2obj,coord2obj,s,n);
    timeGetVisibility(i) = toc();
    
    tic();
    getVisibilityBB(coord,elem,elem2obj,coord2obj,s,n);
    timeGetVisibilityBB(i) = toc();
    
    tic();
    getVisibilityTriangle(coord,elem,elem2obj,coord2obj,s,n);
    timeGetVisibilityTriangle(i) = toc();
    
    tic();
    vis = ones(size(s,1),1);
    doesIntersect(vis,elem,s(2:end,:), s(1,:), s, coord,n);
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
