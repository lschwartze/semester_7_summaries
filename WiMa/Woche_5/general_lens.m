classdef (Abstract) general_lens < matlab.mixin.Heterogeneous & handle
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
            end
        end
        function draw_points(obj,color)
            if nargin == 1
                color = "b";
            end
            plot(obj.start_point(1),obj.start_point(2),'Color',color,'Marker','+')
            plot(obj.end_point(1),obj.end_point(2),'Color',color,'Marker','+')
        end
        
        function rotated = rotateVec(obj, vector, inverse)
            rotMat = [cosd(obj.rot),sind(obj.rot);-sind(obj.rot),cosd(obj.rot)];
            if ~inverse
                rotated = rotMat*vector;
            else
                rotated = rotMat\vector;
            end
        end

        %Muss für jeden Linsen-Typ einzeln implementiert werden
        [p,normal,t] = intersect(obj,light) %Rückgabe ist der Schnittpunkt, die Normale und t: start_light+t*d_light=p
        draw_lens(obj) %Plottet Linse -- abhängig von der  Linsenart
        
    end
end