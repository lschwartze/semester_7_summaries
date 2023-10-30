classdef lens < handle
    properties
        start_point
        end_point
        normal_vec
    end
    
    methods
        function obj = set_start(obj,a)
            obj.start_point = a; 
        end
        function obj = set_end(obj,b)
            obj.end_point = b; 
        end
        function obj = set_normal(obj,c)
            obj.normal_vec = c; 
        end
    end
end