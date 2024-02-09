classdef Object3D < handle & matlab.mixin.Heterogeneous
    properties
        coord
        elem
        color

        x1, x2, x3 % triangle vertices
        s % center of mass of triangles
        a, b % sides spanning the triangles from x1
        n % normal of triangles

        center % center of the bounding box
        diam % longest diagonal of the bounding box
        numTri % number of triangles the object consists of

        % data for phong calculations / rendering
        shadow % numTri x numLights boolean array indicating which triangles are hit by a shadow (for each light source)
        intensity % numTri x 3 - separate R, G, B intensities
        plotData % to address individual objects inside a plot
    end
    
    methods
        function obj = Object3D(arg1, arg2, arg3)
            if nargin==3
                obj.coord = arg1; obj.elem = arg2; obj.color = arg3(:)';
            else
                [obj.coord, obj.elem] = read_off(arg1);
                obj.color = arg2(:)';
            end

            % object data
            obj.center = (max(obj.coord) + min(obj.coord)) / 2;
            obj.diam = vecnorm(max(obj.coord) - min(obj.coord));
            obj.numTri = size(obj.elem, 1);

            obj.intensity = zeros(obj.numTri, 3);

            % triangle data
            obj.x1 = obj.coord(obj.elem(:,1),:);
            obj.x2 = obj.coord(obj.elem(:,2),:);
            obj.x3 = obj.coord(obj.elem(:,3),:);
            
            obj.s = (obj.x1 + obj.x2 + obj.x3) / 3;
            
            obj.a = obj.x2 - obj.x1;
            obj.b = obj.x3 - obj.x1;
            
            obj.n = cross(obj.b,obj.a);
            
            obj.n = obj.n ./ vecnorm(obj.n, 2, 2);
        end

        function obj = moveToPos(obj, targetPos)
            obj.moveByOffset(targetPos - obj.center);
        end

        function obj = moveByOffset(obj, offset)
            obj.coord = obj.coord + offset;
            obj.center = obj.center + offset;
            obj.x1 = obj.x1 + offset;
            obj.x2 = obj.x2 + offset;
            obj.x3 = obj.x3 + offset;
            obj.s = obj.s + offset;
        end

        function obj = scaleByFactor(obj, alpha)
            obj.diam = alpha * obj.diam;
            obj.coord = alpha * (obj.coord - obj.center) + obj.center;
            obj.x1 = alpha * (obj.x1 - obj.center) + obj.center;
            obj.x2 = alpha * (obj.x2 - obj.center) + obj.center;
            obj.x3 = alpha * (obj.x3 - obj.center) + obj.center;
            obj.a = alpha * obj.a;
            obj.b = alpha * obj.b;
            obj.s = alpha * (obj.s - obj.center) + obj.center;
        end

        function obj = scaleToDiam(obj, diam)
            obj.scaleByFactor(diam / obj.diam);
        end

        %  phong / rendering stuff

        % pre-allocat shadow matrix with correct size
        function init(obj, nofLights)
            obj.shadow = false(obj.numTri, nofLights);
        end

        function resetShadow(obj, lightIdx)
            obj.shadow(:, lightIdx) = false;
        end

        % to collect all shadows in the for-loop over the occluders
        function updateShadow(obj, lightIdx, occluded)
            obj.shadow(:, lightIdx) = obj.shadow(:, lightIdx) | occluded;
        end
    end
end