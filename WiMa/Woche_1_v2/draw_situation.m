function draw_situation()
    % this allows to save the previous points and draw a lense or light in
    % two steps
    previous_lense_point = [-1;-1];
    light_source = [-1;-1];

    lenses = [];
    
    collect_lenses = true;
    
    while true
        [x,y,button] = ginput(1);

        % no more lenses, collect lights
        if button == 32 && collect_lenses
            % exit ginput with space bar
            collect_lenses = false;
            
        % no more input
        elseif button == 32 && ~collect_lenses
            break;

        elseif button == 1 && collect_lenses
            % collect lenses
            % draw endpoint
            plot(x,y,"b+")
            % if there is one unmatched endpoint, match it
            if ~isequal(previous_lense_point, [-1;-1])
                % plots lense
                plot([x,previous_lense_point(1)], [y, previous_lense_point(2)], "b")
                lense_vector = previous_lense_point - [x;y];
                % normal vector to lense
                orthogonal = [lense_vector(2); -lense_vector(1)];
                % normalize normal vector
                norm_orthogonal = orthogonal/norm(orthogonal);
                % each lense is classified by three vectors
                lenses(:,end+1:end+3) = [[x;y],previous_lense_point, norm_orthogonal];
                % back to default value
                previous_lense_point = [-1;-1];
                % lights = plot_all_reflections(lights, lenses);
                % draw(lights, lenses)
            else
                previous_lense_point = [x;y];
            end

        elseif button == 1 && ~collect_lenses
            % draw light source
            if ~isequal(light_source, [-1;-1])
                % calculate Richtungsvektor
                direction = [x;y]-light_source;
                % normalize
                norm_direction = direction/norm(direction);
                % append to lights matrix
                light = [light_source, norm_direction];
                % back to default
                light_source = [-1;-1];
                % lights = plot_all_reflections(lights, lenses);
                % draw(lights, lenses)
                num_lenses = size(lenses,2);
                j = 1;
                % boolean that checks whether beam hits any lense
                flag = false;
                while j <= num_lenses-2
                    lense = lenses(:,j:j+2);
                    p = detect_intersection(light, lense);
                    if ~isequal(p, [-1;-1])
                        % if there is intersection, go further
                        reflect_refract(light, lense, p, lenses)
                        flag = true;
                    end
                    j = j + 3;
                end
                if ~flag
                    % else just plot beam
                    endpoint = light(:,1) + 2*norm_direction;
                    plot([light(1,1), endpoint(1)], [light(2,1), endpoint(2)], "y")  
                end
            else
                light_source = [x;y];
                plot(x,y, "yo")
            end
            
        else
            % no other button is assigned a function
            continue;
        end     
    end
end