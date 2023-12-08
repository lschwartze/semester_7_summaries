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
titles = ["set spline lens","set function lenses", "set planar lenses", "set circular lenses","set walls","set mirrors", "set lights", "set light bundels", "final experiment"];
title(titles(1))
hold on

% define the function type of the lens
f = @(x) x.*(x-0.5);
angle = 45;
use_weird_lens = 0;
lenses = plane_lens.empty();
num_of_input_points = 0;

%Spline_lens
Points = [0;0];
kind = 'nat';
param = [1;1];

% collect as many points as desired
while true
    [x,y,button] = ginput(1);
    % each time space is pressed, the input ascends one step
    % first, one can set weird lenses
    % after one press, one sets normal lenses
    % after two presses, circular lens
    % lastly one sets a light
    if button == 32
        use_weird_lens = use_weird_lens + 1;
        title(titles(use_weird_lens+1));
        if use_weird_lens == 1 && size(Points,2)>2
            lenses(1) = spline_lens(Points(:,2:end),kind,param,"lens");
        end
        if use_weird_lens == 8
            break;
        end
        num_of_input_points = 0;
    elseif button == 1
        % left mouse click
        if use_weird_lens == 0
                Points = [Points, [x;y]];
                plot(x,y,"b+")
        else
            switch mod(num_of_input_points,2)
                % first lens point
                case 0
                    previous_lens_point = [x;y];
                % second lens point
                case 1
                    % find out what has been set (<=> how often space was
                    % pressed)
                    if use_weird_lens == 1
                        wl = weird_lens(f,previous_lens_point,[x;y],"lens");
                        % append to array
                        lenses(end+1) = wl;
                    elseif use_weird_lens == 2
                        l = plane_lens(previous_lens_point, [x;y],"lens");
                        % append to array
                        lenses(end+1) = l;
                    elseif use_weird_lens == 3
                        circ = circular_lens(previous_lens_point,[x;y], angle,"lens");
                        % append to array
                        lenses(end+1) = circ;
                    elseif use_weird_lens == 4
                        lenses(end+1) = plane_lens(previous_lens_point,[x;y],"wall");
                    elseif use_weird_lens == 5
                        lenses(end+1) = plane_lens(previous_lens_point,[x;y],"mirror");
                    elseif use_weird_lens == 6
                        % build light source
                        source = previous_lens_point;
                        % calculate Richtungsvektor
                        direction = [x;y]-source;
                        % normalize
                        norm_direction = direction/norm(direction);
                        light = lights(source,norm_direction,1,1);
                        % the function to calculate all reflections belongs to
                        % the lights class
                        sit = situation(lenses,light);
                        sit.plot_sit()
                    else
                        % build light bundle
                        dist = 0.02;
                        first_source = [previous_lens_point(1); previous_lens_point(2) - 2*dist];
                        for translation = 0:4
                             source = [first_source(1); first_source(2) + translation*dist];
                             direction = [x;y]-previous_lens_point;
                            % normalize
                            norm_direction = direction/norm(direction);
                            light = lights(source,norm_direction,1,1);
                            % the function to calculate all reflections belongs to
                            % the lights class
                            sit = situation(lenses,light);
                            sit.plot_sit()
                        end
                    end
                otherwise
                    % this cannot mathematically happen
                    disp("what the happs is fuckening")
                    continue
            end
            num_of_input_points = num_of_input_points+1;
        end
    end
end