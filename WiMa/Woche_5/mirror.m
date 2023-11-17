classdef mirror < plane_lens
    methods 
        function obj = mirror(start_point,end_point)
            obj@plane_lens(start_point,end_point);
            obj.draw_lens("c")
        end
    end
end