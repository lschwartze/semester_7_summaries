classdef (Abstract) general_lens
    properties
        start_point
        end_point
    end
    methods
        function obj = general_lens(a,b)
            if nargin == 0
                obj.start_point = [0;0];
                obj.end_point = [0;0];
            else
                obj.start_point = a;
                obj.end_point = b;
                obj.draw_points();
            end
        end
        function draw_points(obj)
            plot(obj.start_point(1),obj.start_point(2),'b+')
            plot(obj.end_point(1),obj.end_point(2),'b+')
        end
        
        %abstract methods
        [p,u] = get_intersection(obj,light)
        draw_lens(obj)
        
    end
end