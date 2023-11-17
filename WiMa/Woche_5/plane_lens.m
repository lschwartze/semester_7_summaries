classdef plane_lens < general_lens
    methods
        function obj = plane_lens(start_point, end_point)
            obj@general_lens(start_point,end_point);
            obj.draw_lens()
        end

        function draw_lens(obj,color)
            if nargin == 1
                color = "b";
            end
            plot([obj.start_point(1),obj.end_point(1)],[obj.start_point(2),obj.end_point(2)],color)
            obj.draw_points(color)
        end
        function [p,normal,t] =  intersect(obj,light)
            % light: source, normalized direction
            % lense: start point, end point
            %calculate normal vector
            lense_vector = obj.start_point - obj.end_point;
            % orhtogonal vector of lense
            normal = [lense_vector(2); -lense_vector(1)];
            normal = normal/norm(normal);
            
            connection_lense = obj.end_point - obj.start_point;
            A = [[light.direction(1);light.direction(2)], [-connection_lense(1); -connection_lense(2)]];
            b = [obj.start_point(1)-light.source(1); obj.start_point(2)-light.source(2)];
            t = linsolve(A,b);
        
            % no intersection if:
            % 1. crossing point right of lense
            % 2. crossing point left of lense
            % 3. crossing point in source of light
            if t(2) >= 1 || t(2) <= 0 || t(1) < 1e-4
                p = nan;
                t = nan;
                return
            end
            %intersection
            p = light.source + t(1)*light.direction;
            t = t(1);
            end
        end
end