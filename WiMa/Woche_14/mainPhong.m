clear; close all; clc
opts.Cache = 'on';

% 3D objects
toilet = Object3D('toilet_0420.off', 0.7*ones(1,3)).scaleToDiam(1).moveToPos([1, 1, 1]);

wall1 = Parallelogramm([0,0,0; 1.5,0,0; 0,2,0], 80, ones(1,3));%[0.5, 0.5, 0.5]);
wall2 = Parallelogramm([0,0,0; 0,0,1.6; 0,2,0], 80, ones(1,3));%[0.5, 0.5, 0.5]);
sphere = Sphere(0.2, [1, 1, 1], 20, [0.3, 0.3, 0.3]);
small_sphere = Sphere(0.1,[1.5 1.5 1.5],20,[0.3, 0.3, 0.3]);
%light sources5
light1 = Light([3, 0, 3], [1, 0, 0], 1);
light2 = Light([3, 1, 3], [0, 0, 1], 1);
light3 = Light([2.7, 0.5, 3.3], [0, 1, 0], 1);

light = Light([3, 1, 2], [1, 1, 1], 1);

%scene = Scene([wall1, wall2, toilet], [light1,light2,light3]);
scene = Scene([wall1, wall2, sphere,small_sphere], light);


% wrapper function - read documentation of Scene.setShadowFunc!!!
shadowFunc = @(scene, lightIdx, occluder, target) getVisibility(scene.lights(lightIdx), ...
    occluder, target);

scene.setShadowFunc(shadowFunc)


scene.computeVisibility();

scene.computeLighting();

%Film:
f = figure;
scene.plot(true);
axis tight manual

ax = gca;
ax.NextPlot = 'replaceChildren';

loops = 40;
M(loops) = struct('cdata',[],'colormap',[]);

k = linspace(0,2*pi,loops);
circle = 0.5*[sin(k); cos(k)]+1;
for j = 1:loops
    small_sphere = Sphere(0.1,[circle(:,j)' 1.5],20,[0.3, 0.3, 0.3]);
    scene = Scene([wall1, wall2, sphere,small_sphere], light);
    scene.setShadowFunc(shadowFunc)
    scene.computeVisibility();
    scene.computeLighting();
    scene.plot(true);
    drawnow
    M(j) = getframe;
end

movie(M)
