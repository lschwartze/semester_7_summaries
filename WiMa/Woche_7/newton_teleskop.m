clc;
clear;
close all;
% this fixes the plot position
% if removed, window will resize after each plot() call
axis equal;
xlim([0,1]);
ylim([0,1]);
% removes tick marks and numbers
xticklabels([]);
yticklabels([]);
xticks([]);
yticks([]);
title("Newton Teleskop")
hold on

%start parameters
length = 1; %fest lassen
width = 0.25;
focalLength = 0.2;
mirrorDepth = 0.25;

%redefine focalLength because I used a dumb format
focalLength = 1-focalLength;

%calculate location of bottom mirror point
coefficients = polyfit([(1-focalLength)*length, length], [0.5*width, 0], 1);
firstPointx = mirrorDepth*length;
firstPointy = mirrorDepth*coefficients(1) + coefficients(2);
firstPoint = [firstPointx;firstPointy];

%calculate location of top mirror point
coefficients = polyfit([(1-focalLength)*length, length], [0.5*width, width], 1);
secondPointx = linsolve(coefficients(1)-1,firstPointy - firstPointx - coefficients(2));
secondPointy = secondPointx + firstPointy - firstPointx;
secondPoint = [secondPointx; secondPointy];

%calculate right end of ocular
direction = [length;0] - [firstPointx;firstPointy];
normal = [1;-1]/sqrt(2);
reflected = direction - 2*dot(direction,normal)*normal;
m = reflected(2)/reflected(1);
coefficients = polyfit([firstPointx, firstPointx + 1], [firstPointy, firstPointy + m], 1);
rightOcular = roots(coefficients);

%calculate left end of ocular
direction = [length;width] - [secondPointx;secondPointy];
normal = [1;-1]/sqrt(2);
reflected = direction - 2*dot(direction,normal)*normal;
m = reflected(2)/reflected(1);
coefficients = polyfit([secondPointx, secondPointx + 1], [secondPointy, secondPointy + m], 1);
leftOcular = roots(coefficients);

%flip ocular borders if in the wrong order
if rightOcular < leftOcular
    temp = rightOcular;
    rightOcular = leftOcular;
    leftOcular = temp;
end

%add a bit of leeway
rightOcular = rightOcular + (rightOcular - leftOcular)*0.2;
leftOcular = leftOcular - (rightOcular - leftOcular)*0.2;

%set walls
lenses(1) = plane_lens([0;0],[leftOcular;0],"wall");
lenses(2) = plane_lens([rightOcular;0],[length;0],"wall");
lenses(3) = plane_lens([0;width],[length;width],"wall");
lenses(4) = plane_lens([length;0],[length;width],"wall");

%set mirrors
f = @(x) (x-width/2).^(2)/(4*focalLength*length);
lenses(5) = weird_lens(f,[length;0],[length;width],"fibre");
lenses(6) = plane_lens(firstPoint,secondPoint,"fibre");

%set lights
for i=0.1:0.1:0.9
    if i*width > secondPointy || i*width < firstPointy
        light = lights([0;i*width],[1;-0.0001],1,1);
        sit = situation(lenses,light);
        sit.plot_sit()
    end
end

disp('Laurin ist ein Gnom')
