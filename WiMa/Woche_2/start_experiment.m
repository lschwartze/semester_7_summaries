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
hold on

s = situation();
lens = lens();
light = lights();
s.draw_situation(lens, lights)