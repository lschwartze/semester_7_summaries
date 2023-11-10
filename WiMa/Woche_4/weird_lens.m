classdef weird_lens < general_lens
    properties
        range
        fun
        rot 
        shift
    end
    methods
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
            obj.draw_points
            hold on
            % draws start and end point
            plot([obj.start_point(1),obj.end_point(1)], [obj.start_point(2), obj.end_point(2)], "--",'color', [.5 .5 .5])
            x = linspace(0,norm(obj.end_point-obj.start_point),100);
            fx = obj.fun(x);
            % rotate matrix to be drawn on virtual x-axis
            rotFun = obj.rotateVec([x;fx],1)+ obj.shift;
            plot(rotFun(1,:),rotFun(2,:),"b")
            
        end
        function [p,normal,t] =  intersect(obj,light)
             %transform the light source and direction
             rotated_source = obj.rotateVec(light.source-obj.shift,0);
             rotated_direction = obj.rotateVec(light.direction,0);
             light_transform = lights(rotated_source,rotated_direction);
             
             %find intersection
             syms z;            
             a = light_transform.direction(2)/light_transform.direction(1);
             b = light_transform.source(2) - a*light_transform.source(1);
             intersec = vpasolve(a*z+b == obj.fun(z), z, obj.range);
             if isempty(intersec) 
                 p = NaN;
                 normal = NaN;
                 t = NaN;
                 return
             end
             %intersec = intersec(1);
             for int = intersec'
                p_temp = [int;obj.fun(int)];
                tmp = dot(light_transform.direction, [int;obj.fun(int)]-light_transform.source);
                if (p_temp(1)-light_transform.source(1))/light_transform.direction(1) < 1e-5 || tmp <=0 %toleranz
                    p = NaN;
                    normal = NaN;
                    t = NaN;
                    if int == intersec(end)
                        return
                    end    
                else
                    intersec = int;
                    break
                end   
             end
             %t = dot(light_transform.direction, [int;obj.fun(int)]-light_transform.source);
             iterator = intersec;
             count = 0;
             while true
                 count = count +1;
                 if iterator(1) < light_transform.source(1)
                     iterator = vpasolve(a*z+b == obj.fun(z), z, [iterator+eps,obj.range(2)]);
                 else
                     iterator = vpasolve(a*z+b == obj.fun(z), z, [obj.range(1), iterator-eps]);
                 end
                 if isempty(iterator)
                     break;
                 end 
                 intersec = iterator;
                 if count == 100
                    break
                 end
             end
             p = [intersec;obj.fun(intersec)];

             %find normal and transform the intersection back
             syms x;
             %df = matlabFunction(diff(obj.fun(x)))
             df = eval(['@(x)' char(diff(obj.fun(x)))]);
             tang = df(p(1));
             
             lens_vector = -[1;tang];
             normal = [lens_vector(2); -lens_vector(1)];
             normal = double(normal/norm(normal));

             if dot(light_transform.direction, normal) < 0
                 normal = -normal; 
             end
             %t = (t(1)-light_transform.source(1))/light_transform.direction(1);
             %In case we rotated the lense we have to rotate back
             p = obj.rotateVec(p,1)+obj.shift;
             normal = obj.rotateVec(normal,1);
             t = (p(1)-light.source(1))/light.direction(1);
            
         end
    end
    
end