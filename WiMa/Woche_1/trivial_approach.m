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

num_of_input_points = 0;
%for num_of_input_points = 1:4
while num_of_input_points < 4
    num_of_input_points = num_of_input_points + 1;
    
    [x,y,button] = ginput(1);

    if button == 32
        % exit ginput with space bar
        break;
    elseif button == 1
        % left mouse click
        switch num_of_input_points
            % first lense point
            case 1
                plot(x,y,"b+")
                previous_lense_point = [x;y];
            % second lense point
            case 2
                plot(x,y,"b+")
                % plot lense
                plot([x,previous_lense_point(1)], [y, previous_lense_point(2)], "b")
                lense_vector = previous_lense_point - [x;y];
                % orhtogonal vector of lense
                orthogonal = [lense_vector(2); -lense_vector(1)];
                % normalize
                normalized = orthogonal/norm(orthogonal);
                % plot lense
                lense = [[x;y], previous_lense_point, normalized];
            case 3
                % plot light source
                plot(x,y,"yo")
                light_source = [x;y];
            case 4
                % calculate Richtungsvektor
                direction = [x;y]-light_source;
                % normalize
                norm_direction = direction/norm(direction);
                
                % this ensures that the lense's normalvector points away from the light
                if dot(norm_direction, normalized) < 0
                    normalized = -normalized;
                end
                
                light = [light_source, norm_direction];
                lense(:,3) = normalized;
                % find intersection of beam and lense
                p = detect_intersection(light, lense);
                if ~isequal(p, [-1;-1])
                    % if there is intersection, go further
                    reflect_refract(light, lense, p)
                else
                    % else just plot beam
                    endpoint = light_source + 2*norm_direction;
                    plot([light_source(1), endpoint(1)], [light_source(2), endpoint(2)], "y") 
                end
            otherwise
                continue
        end   
    end
end