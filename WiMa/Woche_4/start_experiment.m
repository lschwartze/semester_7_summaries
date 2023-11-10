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
titles = ["set function lenses", "set planar lenses", "set lights", "final experiment"];
title(titles(1))
hold on

% define the function type of the lens
f = @(x) x.*(x-0.5);
use_weird_lens = 0;
lenses = plane_lens.empty();
num_of_input_points = 0;

% collect as many points as desired
while true
    [x,y,button] = ginput(1);
    % each time space is pressed, the input ascends one step
    % first, one can set weird lenses
    % after one press, one sets normal lenses
    % lastly one sets a light
    if button == 32
        use_weird_lens = use_weird_lens + 1;
        title(titles(use_weird_lens+1));
        if use_weird_lens == 3
            break;
        end
        num_of_input_points = 0;
    elseif button == 1
        % left mouse click
        switch mod(num_of_input_points,2)
            % first lens point
            case 0
                previous_lens_point = [x;y];
            % second lens point
            case 1
                % find out what has been set (<=> how often space was
                % pressed)
                if use_weird_lens == 0
                    wl = weird_lens(f,previous_lens_point,[x;y]);
                    %wl.draw_lens
                    % append to array
                    lenses(end+1) = wl;
                elseif use_weird_lens == 1
                    l = plane_lens(previous_lens_point, [x;y]);
                    %l.draw_lens
                    % append to array
                    lenses(end+1) = l;
                else
                    % build light source
                    source = previous_lens_point;
                    % calculate Richtungsvektor
                    direction = [x;y]-source;
                    % normalize
                    norm_direction = direction/norm(direction);
                    light = lights(source,norm_direction);
                    % the function to calculate all reflections belongs to
                    % the lights class
                    sit = situation(lenses,light);
                    sit.plot_sit()
                end
            otherwise
                % this cannot mathematically happen
                disp("what the happs is fuckening")
                continue
        end
        num_of_input_points = num_of_input_points+1;
    end
end