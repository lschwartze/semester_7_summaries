classdef weird_lens < general_lens
    properties
        fun
        rot
        shift
        range
    end
    methods
        % constructor uses only the function, a start and an end point.
        % Everything else is calculated automatically
        function obj = weird_lens(fun,a,b)
            obj = obj@general_lens(a,b);
            obj.fun = fun;
            obj.range = [0,norm(b-a)];
            % calculates rotation as arccos of slope of the linear function
            % connecting start and end point of the lens
            if a(1) == b(1)
                obj.rot = 90;
            elseif a(1) > b(1)
                slope = (a(2)-b(2))/(a(1)-b(1));
                obj.rot = atand(slope);
            else
                slope = (b(2)-a(2))/(b(1)-a(1));
                obj.rot = atand(slope);
            end
            % the shift is equal to the argminimum of the y arguments
            if a(2) <= b(2)
                obj.shift = a;
            else
                obj.shift = b;
            end
            % make rotation positive, otherwise the rotation matrix seems 
            % to be wrong
            if obj.rot < 0
                obj.rot = obj.rot + 180;
            end
            obj.draw_lens();
        end
        
        function draw_lens(obj)
            % draws start and end point
            plot([obj.start_point(1),obj.end_point(1)], [obj.start_point(2), obj.end_point(2)], "--",'color', [.5 .5 .5])
            x = linspace(0,norm(obj.end_point-obj.start_point),100);
            fx = obj.fun(x);
            % rotate matrix to be drawn on virtual x-axis
            rotFun = obj.rotateVec([x;fx],1)+ obj.shift;
            plot(rotFun(1,:),rotFun(2,:),"b")
        end
        
        function [p,u] = get_intersection(obj,light)
            %transform the light source and direction
            rotated_source = obj.rotateVec(light.source-obj.shift,0);
            rotated_direction = obj.rotateVec(light.direction,0);
            light_transform = lights(rotated_source,rotated_direction,0);
             
            %find intersection
            syms z;            
            a = light_transform.direction(2)/light_transform.direction(1);
            b = light_transform.source(2) - a*light_transform.source(1);
            intersec = vpasolve(a*z+b == obj.fun(z), z, obj.range);
%             if light.direction(1) >= 0
%                 intersec = vpasolve(a*z+b == obj.fun(z), z, [max(light.source(1),obj.range(2)), obj.range(2)]);
%             else
%                 intersec = vpasolve(a*z+b == obj.fun(z), z, [obj.range(1), min(light.source(1),obj.range(2))]);
%             end
            if isempty(intersec) 
                p = NaN;
                u = Inf;
                return
            end
            % make sure that intersection is on correct side of light
            % source
            intersec = intersec(1);
            t = dot(light_transform.direction, [intersec;obj.fun(intersec)]-light_transform.source);
            if t <= 0
                p = NaN;
                u = Inf;
                return
            end
            
            % adjust range to find the closest possible intersection to the
            % light source
            iterator = intersec;
            while true
                if iterator(1) < light_transform.source(1)
                    iterator = vpasolve(a*z+b == obj.fun(z), z, [iterator+eps,obj.range(2)]);
                else
                    iterator = vpasolve(a*z+b == obj.fun(z), z, [obj.range(1), iterator-eps]);
                end
                if isempty(iterator)
                    break;
                end 
                intersec = iterator;
            end
            p = [intersec;obj.fun(intersec)];
            % get how often direction vector of light has to be added to
            % source to reach intersection point
            tmp = obj.rotateVec(p,1)+obj.shift;
            u = (tmp(1)-light.source(1))/light.direction(1);
        end
        
        function [l,new_p] = get_tangent(obj,p)
            % calculate tangent at the intersection point
            syms x;
            df = eval(['@(x)' char(diff(obj.fun(x)))]);
            tang = df(p(1));
            % create virtual, normal lens here
            temp_lens = lens(p+[1;tang],p-[1;tang],0);
            % In case we rotated the lense we have to rotate the reflected
            % and refracted beam
            rotated_start = obj.rotateVec(temp_lens.start_point,1)+obj.shift;
            rotated_end = obj.rotateVec(temp_lens.end_point,1)+obj.shift;
            l = lens(rotated_start,rotated_end,0);
            new_p = obj.rotateVec(p,1)+obj.shift;
        end
        
        % this calculates the rotation matrix and rotates the given vector
        % accordingly, parameter inverse also allows to rotate in other
        % direction
        function rotated = rotateVec(obj, vector, inverse)
            rotMat = [cosd(obj.rot),sind(obj.rot);-sind(obj.rot),cosd(obj.rot)];
            if ~inverse
                rotated = rotMat*vector;
            else
                rotated = rotMat\vector;
            end
        end
    end
end