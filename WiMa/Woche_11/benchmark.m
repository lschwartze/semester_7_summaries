clc, clear, close all

iter = 20:10:50;

timeCreateScene = zeros(size(iter));
timeGetVisibility = zeros(size(iter));

for i=1:size(iter,2)
    
    tic();
    [coord, elem, coord2obj, elem2obj] = createScene(iter(i));
    timeCreateScene(i) = toc();
    
    [s,n,area2] = getGeomParam(coord,elem);
    
    tic();
    [vis, elem_vis] = getVisibility(coord,elem,elem2obj,coord2obj,s,n);
    timeGetVisibility(i) = toc();
    
end

figure(1)
semilogy(iter,timeCreateScene)
title('Time to create scene')
xlabel('Resolution')
ylabel('Time in seconds')
figure(2)
semilogy(iter,timeGetVisibility)
title('Time to get visiblity')
xlabel('Resolution')
ylabel('Time in seconds')
