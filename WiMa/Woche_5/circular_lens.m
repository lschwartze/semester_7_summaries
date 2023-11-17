classdef circular_lens < general_lens
    properties
        % smaller angle
        phi1
        % larger angle
        phi2
        radius
    end
    methods
        function obj = circular_lens(center,outer_point,angle)
            % creates object of general lens
            obj = obj@general_lens(center,outer_point);
            % connect two given points for their angle
            connector_line = outer_point-center;
            obj.radius = norm(connector_line);
            % angle has to be adjusted according to the rotation
            obj.phi1 = atand(connector_line(2)/connector_line(1));
            if center(1) > outer_point(1)
                obj.phi1 = 180+obj.phi1;
            elseif obj.phi1 < 0 && center(1) < outer_point(1)
                obj.phi1 = 360+obj.phi1;
            else
                % change nothing
            end
            obj.phi2 = obj.phi1+angle;
            obj.draw_lens();
        end
        
        function draw_lens(obj)
            space = (obj.phi1*2*pi/360):pi/50:(obj.phi2*2*pi/360);
            x = obj.radius*cos(space) + obj.start_point(1);
            y = obj.radius*sin(space) + obj.start_point(2);
            plot(obj.start_point(1),obj.start_point(2),"b+")
            plot([obj.start_point(1),x(1)],[obj.start_point(2),y(1)],"-",'color', [.5 .5 .5])
            plot([obj.start_point(1),x(end)],[obj.start_point(2),y(end)],"-",'color', [.5 .5 .5])
            plot(x,y,"b");
        end
        
        function [p,normal,t] =  intersect(obj,light)
            lightDirectionNormed = light.direction/norm(light.direction);
            % compute the shortest distance between the lightray and the center
            dist = norm((light.source - obj.start_point) - (dot((light.source - obj.start_point),lightDirectionNormed))*lightDirectionNormed);
            if dist >= obj.radius
                p = NaN;
                normal = NaN;
                t = NaN;
                return
            end
            % compute the point where this happens
            distanceFromLightToClosest = sqrt(norm(light.source - obj.start_point)^2 - dist^2);
            closestPoint = light.source + lightDirectionNormed*distanceFromLightToClosest;
            if norm(closestPoint-obj.start_point) > dist + 1e-6
                closestPoint = light.source - lightDirectionNormed*distanceFromLightToClosest;
            end
            distToIntersecs = sqrt(obj.radius^2 - dist^2);
            % calculate the intersection points from this information and some Pythagorean stuff
            intersectionPoints = [closestPoint-distToIntersecs*lightDirectionNormed,closestPoint+distToIntersecs*lightDirectionNormed];
            % if the intersections are in the wrong direction remove them
            if light.direction(1) > 0 && (intersectionPoints(1,2)-light.source(1)) < 0
                intersectionPoints(:,2) = [];
            elseif light.direction(1) < 0 && (intersectionPoints(1,2)-light.source(1)) > 0
                intersectionPoints(:,2) = [];
            end
            if light.direction(1) > 0 && (intersectionPoints(1,1)-light.source(1)) < 0
                intersectionPoints(:,1) = [];
            elseif light.direction(1) < 0 && (intersectionPoints(1,1)-light.source(1)) > 0
                intersectionPoints(:,1) = [];
            end
            if isempty(intersectionPoints)
                p = NaN;
                normal = NaN;
                t = NaN;
                return
            end
            % remove points not on the correct part of the circle
            if size(intersectionPoints,2) > 1
                temp = intersectionPoints(:,2)-obj.start_point;
                pointInWeirdFormat1 = temp(2);
                pointInWeirdFormat2 = temp(1);
                angle = atan2(pointInWeirdFormat1,pointInWeirdFormat2)*360/(2*pi);
                if angle < 0
                    angle = angle + 360;
                end
                if obj.phi2 < 360
                    if ~(obj.phi1 < angle && angle < obj.phi2)
                        intersectionPoints(:,2) = [];
                    end
                else
                    if ~(obj.phi1 < angle || obj.phi2 > angle)
                        intersectionPoints(:,2) = [];
                    end
                end
            end
            temp = intersectionPoints(:,1)-obj.start_point;
            pointInWeirdFormat1 = temp(2);
            pointInWeirdFormat2 = temp(1);
            angle = atan2(pointInWeirdFormat1,pointInWeirdFormat2)*360/(2*pi);
            if angle < 0
                angle = angle + 360;
            end
            if obj.phi2 < 360
                if ~(obj.phi1 < angle && angle < obj.phi2)
                    intersectionPoints(:,1) = [];
                end
            else
                if ~((obj.phi1 < angle) || (obj.phi2-360 > angle))
                    intersectionPoints(:,1) = [];
                end
            end
            if isempty(intersectionPoints)
                p = NaN;
                normal = NaN;
                t = NaN;
                return
            end
            % get the closer of the two intersections
            if size(intersectionPoints,2)==1
                trueIntersec = intersectionPoints;
            elseif norm(intersectionPoints(:,1)-light.source) < 1e-4
                trueIntersec = intersectionPoints(:,2);
            elseif norm(intersectionPoints(:,2)-light.source) < 1e-4
                trueIntersec = intersectionPoints(:,1);    
            elseif norm(intersectionPoints(:,1)-light.source) < norm(intersectionPoints(:,2)-light.source)
                trueIntersec = intersectionPoints(:,1);
            else
                trueIntersec = intersectionPoints(:,2);
            end
            p = trueIntersec;
            normal = (trueIntersec-obj.start_point)/norm(trueIntersec-obj.start_point);
            t = (trueIntersec(1)-light.source(1))/light.direction(1);
            if norm(t) < 1e-4
                p = NaN;
                normal = NaN;
                t = NaN;
                return
            end
        end
    end
    
end



