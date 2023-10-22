function draw_situation()
    % this allows to save the previous points and draw a lense or light in two
    % steps
    previous_lense_point = [-1;-1];
    light_source = [-1;-1];

    lenses = [];
    lights = [];
    
    while true
        [x,y,button] = ginput(1);

        if button == 32
            % exit ginput with space bar
            break;

        elseif button == 1
            % left mouse click for lense
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
                plot_all_reflections(lights, lenses)
            else
                previous_lense_point = [x;y];
            end

        elseif button == 3
            % draw light source
            if ~isequal(light_source, [-1;-1])
                % calculate Richtungsvektor
                direction = [x;y]-light_source;
                % normalize
                norm_direction = direction/norm(direction);
                % append to lights matrix
                lights(:,end+1: end+2) = [light_source, norm_direction];
                % plots beam. Length 2 makes it exit plot window and
                % makes it look inifinte
                plot([light_source(1), light_source(1)+2*norm_direction(1)], [light_source(2), light_source(2)+2*norm_direction(2)], "y")
                % back to default
                light_source = [-1;-1];
                plot_all_reflections(lights, lenses)
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