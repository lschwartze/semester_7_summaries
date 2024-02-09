classdef Scene < handle
    properties
        numLights
        lights
        totalIntensity

        lightingParameter
        observerPos

        numObjects
        objects

        shadowFunc % see function setShadowFunc below
    end
    
    methods
        function obj = Scene(objects, lights)
            obj.numLights = length(lights);
            
            obj.lights = lights;

            % compute sum of intensities for scaling
            obj.totalIntensity = 0;
            for light=lights
                obj.totalIntensity = obj.totalIntensity + light.intensity;
            end

            obj.objects = objects;
            obj.numObjects = length(objects);


            for object = objects
                object.init(numel(lights))
            end

            obj.lightingParameter = struct( ...
                'C', 1,        ... Konstante fuer Distanzfunktion
                'IA', 0.3,     ... Intensitaet des Umbegungslichts
                'IQ', 1.0,     ... Intensitaet der Lichtquelle
                'kappaA', 0.1, ... Reflexionsgrad fuer Ambiente Reflexion
                'kappaD', 0.9, ... Reflexionsgrad fuer Ideal Difuse Reflexion
                'kappaS', 0.2, ... Reflexionsgrad fuer Ideal Spiegelnde Reflexion
                'm', 20        ... Exponent, steuert Schaerfe der spegelnden Refl.
            );
            obj.observerPos = [5, 5, 5];
        end

        % signature: shadowFunc(scene, lightIdx, occluder, target)
        % parameters:
        %    scene: object of class Scene (to fetch lightingParameter etc.)
        %    lightIdx: scene.lights(lightIdx) is the relevant light
        %    occluder: object of class Object3D casting the shadow
        %    target: object of class Object3D possibly being occluded
        % returns: boolean COLUMN vector indicating which triangles are
        %          occluded by a shadow (does NOT return the visibility
        %          vector!)
        function setShadowFunc(obj, shadowFunc)
            obj.shadowFunc = shadowFunc;
        end

        function computeVisibility(obj)
            for lightIdx = 1:obj.numLights
                for targetIdx = 1:obj.numObjects
                    target = obj.objects(targetIdx);
                    target.resetShadow(lightIdx)
                    for occluderIdx = 1:obj.numObjects
                        occluder = obj.objects(occluderIdx);
                        shadow = obj.shadowFunc(obj, lightIdx, occluder, target);
                        target.updateShadow(lightIdx, shadow);
                    end
                end
            end
        end

        function computeLighting(obj)
            lp = obj.lightingParameter;
            for objectIdx = 1:obj.numObjects
                object = obj.objects(objectIdx);

                Phong.initAmbient(object, lp)
                for lightIdx = 1:obj.numLights
                    Phong.lighting(object, obj.lights, lightIdx, obj.observerPos, lp);
                end

                % theoretical max intensity
                %tmi = lp.kappaA * lp.IA + obj.totalIntensity * lp.kappaD + obj.totalIntensity * lp.kappaS * (lp.m + 2) / ( 2*pi);
                %object.intensity = object.intensity / tmi;
            end
        end

        % pass interactiveLighting = true to enable the event handler that
        % recalculates Phong.lighting every time the camera is moved
        function plotData = plot(obj, interactiveLighting)
            % plot objects
            for idx = 1:obj.numObjects
                o = obj.objects(idx);
    
                o.plotData = trisurf(o.elem, o.coord(:,1), o.coord(:,2), o.coord(:,3), ...
                    'LineStyle', 'none', 'FaceColor', 'flat', 'FaceVertexCData', o.intensity);

                if idx == 1
                    hold on
                    plotData = o.plotData;
                    if interactiveLighting
                        % calls the handler every time the mouse is moved
                        % over the plot window
                        set(gcf, 'windowbuttonmotionfcn', @(src, event) handler(src, event, obj));
                    end
                end
            end

            % plot lights
            for i = 1:obj.numLights
                light = obj.lights(i);
                plot3(light.pos(1), light.pos(2), light.pos(3), 'o', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', light.color)
            end
            hold off
            axis equal
            rotate3d on
            campos(obj.observerPos);
        end
    end
end

function handler(~, ~, scene)
    axes = gca;
    newCamPos = axes.CameraPosition;

    % prevent lighting computation when the mouse moves over the plot
    % without dragging
    if all(newCamPos == scene.observerPos)
        return;
    end
    
    scene.observerPos = newCamPos;

    scene.computeLighting();

    for i = 1:scene.numObjects
        object = scene.objects(i);

        set(object.plotData, 'FaceVertexCData', object.intensity);
    end
end