classdef lights < handle
    properties
        source
        direction
    end
    
    methods
        function obj = lights(source, direction)
            if nargin == 0
                 obj.source= [0;1];
                 obj.direction = [1;-1]/sqrt(2);
            else
                 obj.source = source(:);
                 obj.direction = direction(:);
            end
        end
    end
end