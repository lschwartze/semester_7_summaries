clc, clear, close all

iter = 20:10:100;

timeCreateScene = zeros(size(iter));
timeGetVisibility = zeros(size(iter));
timeGetVisibilityBB = zeros(size(iter));
timeGetVisibilityTriangle = zeros(size(iter));
timeGetVisibilityTriangleVec = zeros(size(iter));

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
    
    %tic();
    %getVisibilityTriangleVec(coord,elem,elem2obj,coord2obj,s,n);
    %timeGetVisibilityTriangleVec(i) = toc();
    
end

figure(1)
semilogy(iter,timeCreateScene)
title('Time to create scene')
xlabel('resolution')
ylabel('Time in seconds')
figure(2)
hold on
semilogy(iter,timeGetVisibility)
semilogy(iter,timeGetVisibilityBB)
semilogy(iter,timeGetVisibilityTriangle)
%semilogy(iter,timeGetVisibilityTriangleVec)
legend("bounding ball", "bounding boxes", "triangles")

title('Time to get visiblity')
xlabel('Number of iterations')
ylabel('Time in seconds')
