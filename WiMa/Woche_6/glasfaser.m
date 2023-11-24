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

cable_width = 0.08;
kind = 'nat';
param = [1;1];
x_values = linspace(0,1,10); 
y_values = rand(1,10)./10 + 0.5-cable_width;
Points = [x_values; y_values];
lower_lens = spline_lens(Points,kind,param,"fibre");
y_values = y_values+cable_width;
Points = [fliplr(x_values); fliplr(y_values)];
upper_lens = spline_lens(Points,kind,param,"fibre");
fibre = [upper_lens; lower_lens];
lenses = [lower_lens;upper_lens];

for i=1:3
    % build light source
    source = [x_values(1);y_values(1)-cable_width*i/4];
    % calculate Richtungsvektor
    direction = [1;0];
    % normalize
    light = lights(source,direction,1,1);
    sit = situation(lenses,light);
    sit.plot_sit()
end

