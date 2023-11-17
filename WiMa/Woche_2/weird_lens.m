classdef weird_lens < handle
    properties
        range
        fun
    end
    methods
        function obj = weird_lens(range, fun)
             obj.range = range;
             obj.fun = fun;
        end
        
        function draw_lens(obj)
             fplot(obj.fun, obj.range)
        end
    end
    
end