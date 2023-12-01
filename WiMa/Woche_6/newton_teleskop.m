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
title("Glasfaser Kabel")
hold on

length = 1;
width = 1;

lenses(1) = plane_lens([0;0],[0.20*length;0],"wall");
secondPointx = ((3/32)*width - 0.25*length)*0.8*length/(0.5*width - 0.8*length);
secondPointy = secondPointx + (15/32)*width-0.25*length;
lenses(2) = plane_lens([secondPointx;0]+0.05*[length;0],[length;0],"wall");
lenses(3) = plane_lens([0;width],[length;width],"wall");
lenses(4) = plane_lens([length;0],[length;width],"wall");
f = @(x) (x-width/2).^(2)/(3.2*length);
lenses(5) = weird_lens(f,[length;0],[length;width],"lens");
lenses(6) = plane_lens([0.25*length;(15/32)*width],[secondPointx;secondPointy],"mirror");
light = lights([0;width*0.8],[1;-0.0001],1,1);
sit = situation(lenses,light);
sit.plot_sit()
light = lights([0;width*0.2],[1;0.0001],1,1);
sit = situation(lenses,light);
sit.plot_sit()
light = lights([0;width*0.9],[1;-0.0001],1,1);
sit = situation(lenses,light);
sit.plot_sit()
light = lights([0;width*0.1],[1;0.0001],1,1);
sit = situation(lenses,light);
sit.plot_sit()
light = lights([0;width*0.7],[1;-0.0001],1,1);
sit = situation(lenses,light);
sit.plot_sit()
light = lights([0;width*0.3],[1;0.0001],1,1);
sit = situation(lenses,light);
sit.plot_sit()

