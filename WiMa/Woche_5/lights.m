classdef lights < handle
    properties
        source
        direction
        opacity
    end
    
    methods
        function obj = lights(source, direction, to_plot, opacity)
            if nargin == 0
                 obj.source= [0;1];
                 obj.direction = [1;-1]/sqrt(2);
            else
                 obj.source = source(:);
                 obj.direction = direction(:);
                 obj.opacity = opacity;
            end
            
            if to_plot
                % plot light source
                plot(source(1),source(2),"yo")
            end
        end
        function draw_light(obj,p,normal)
            plot([obj.source(1),p(1)], [obj.source(2), p(2)], "Color",[1, 0.8, 0, obj.opacity])
            %plot normal
            plot([p(1)-0.1*normal(1), p(1)], [p(2)- 0.1*normal(2), p(2)], "r--")
            plot([p(1), p(1) + 0.1*normal(1)], [p(2), p(2) + 0.1*normal(2)], "r-")
        end
    end
end