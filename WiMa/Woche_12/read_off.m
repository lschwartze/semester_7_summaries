function [coordinates, elements] = read_off(filename)
    file_id = fopen(filename, 'r');
    
    line = fgetl(file_id);
    
    if strcmpi(line, 'OFF')
        line = fgetl(file_id);
    end
    
    ret = sscanf(line, '%d %d %d');
    
    Nc = ret(1);
    Ne = ret(2);
    % ignore ret(3);  nof edges
    
    coordinates = zeros(Nc, 3);
    for i=1:Nc
        line = fgetl(file_id);
        coordinates(i,:) = sscanf(line, '%f %f %f');
    end
    
    elements = zeros(Ne, 3);
    for i=1:Ne
        line = fgetl(file_id);
        elements(i,:) = sscanf(line, '3 %d %d %d');
    end
    elements = elements + 1; % 1-based indexing in Matlab! ugh...

    fclose(file_id);
end