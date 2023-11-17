classdef wall < plane_lens
    methods 
        function obj = wall(start_point,end_point)
            obj@plane_lens(start_point,end_point);
            obj.draw_lens("k")
        end
    end
end
