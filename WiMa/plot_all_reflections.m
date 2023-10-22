function plot_all_reflections(lights, lenses)
    % light: source, normalized direction
    % lense: start point, end point, orthogonal vector
    num_lights = size(lights, 2);
    num_lenses = size(lenses, 2);

    if num_lights == 0 || num_lenses == 0
        return
    end
    
    i = 1;
    while i <= num_lights-1
        j = 1;
        light = lights(:,i:i+1);
        while j <= num_lenses-2
            lense = lenses(:,j:j+2);
            % find where beam hits lense
            p = detect_intersection(light,lense);
            % disp(p)
            if ~isequal(p, [-1;-1])
                % calculates and plots reflected beam
                reflect(lenses, light, lense, p)
            end
            j = j + 3;
        end
        i = i + 2;
    end
end