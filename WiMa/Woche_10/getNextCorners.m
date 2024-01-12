function next_corners = getNextCorners(corners,i)
    mid = 1/2*(corners(1,:)+corners(2,:));
    min = corners(2,:);
    max = corners(1,:);
    
    % idea: represent i and 7-i as 3-digit binary number
    bin_min = dec2bin(i,3);
    bin_max = dec2bin(7-i,3);
    
    % use these to index the corners of max and min as follows:
    % - if bin_min(j) = 1 the minimum corner of the next bounding box 
    %   has min(j) at position j
    % - if bin_max(j) = 1 the minimum corner of the next bounding box 
    %   has mid(j) at position j
    % same for max and bin_max
    
    min_index = char(num2cell(bin_min));
    min_index = logical(reshape(str2num(min_index),1,[]));
    max_index = char(num2cell(bin_max));
    max_index = logical(reshape(str2num(max_index),1,[]));
    
    next_min = [0,0,0];
    next_min(min_index) = min(min_index);
    next_min(max_index) = mid(max_index);
    
    next_max = [0,0,0];
    next_max(max_index) = max(max_index);
    next_max(min_index) = mid(min_index);
    
    next_corners = [next_max;next_min];
end