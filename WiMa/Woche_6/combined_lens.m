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
title("Zusammengesetzte Linse")
hold on
experiment = {};
possible_types = ["weird", "plane", "sphere"];
lenses = plane_lens.empty();
num_of_input_points = 0;

for i=1:5
    answer = inputdlg("lens type");
    if answer == ""
        break;
    end
    if ismember(answer, possible_types)
        experiment(end+1) = answer;
    else
        ME = MException('MyComponent:noSuchVariable', ...
        "me fail english? that's unpossible!");
        throw(ME)
    end
end

n = length(experiment);
for i=1:n
     if experiment{i} == "plane"
         points = [[i*0.2; 0.35],[i*0.2; 0.65]];
         first = mod(i,2)+1;
         second = mod(i+1,2)+1;
         lens = plane_lens(points(:,first),points(:,second),"lens");
         lenses(end+1) = lens;
     elseif experiment{i} == "weird"
         points = [[i*0.2; 0.35],[i*0.2; 0.65]];
         first = mod(i,2)+1;
         second = mod(i+1,2)+1;
         fun = @(x) x.^2;
         wl = weird_lens(fun,points(:,first),points(:,second),"lens");
         lenses(end+1) = wl;
     else
         p1 = [i*0.2; 0.5];
         p2 = [i*0.2; 0.5+(-1)^i*0.15];
         angle = 180;
         cl = circular_lens(p1,p2,angle,"lens");
         lenses(end+1) = cl;
     end
end

while true
    [x,y,button] = ginput(1); 
    if button == 32
        break;
    elseif button == 1
        switch mod(num_of_input_points,2)
            % first lens point
            case 0
                previous_lens_point = [x;y];
            % second lens point
            case 1
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
        end
    else
        disp("bal man")
    end
    num_of_input_points = num_of_input_points+1;
end