classdef lights < handle
    properties
        source
        direction
    end
    
    methods
        function obj = set_source(obj, s)
            obj.source = s;
        end
        
        function obj = set_dir(obj, d)
            obj.direction = d; 
        end
    end
end