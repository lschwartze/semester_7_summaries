classdef Phong    
    methods(Static)
        function lighting(object, lights, lightIdx, observerPos, lp)
            light = lights(lightIdx);
            d = object.s - light.pos;
            d = d ./ vecnorm(d, 2, 2); % normalize
            
            cosphi = dot(d, object.n, 2);

            dr = d - 2*object.n .*cosphi;
            dr = dr ./ sqrt(sum(dr.^2, 2));
            
            u = observerPos - object.s;
            u = u ./ sqrt(sum(u.^2, 2));
            
            costheta = max(0, dot(dr, u, 2));

            % compute intensities for R, G, B, taking into account both the
            % color of the object and the color of the light (i pulled this
            % out of my ass, i think that's how it's supposed to work?)
            object.intensity = object.intensity + ~object.shadow(:, lightIdx) .* (lp.kappaD * light.intensity * abs(cosphi) + ...
                                  light.intensity * lp.kappaS * (lp.m + 2) / (2*pi) * power(costheta, lp.m)) .* object.color .* light.color;
        end

        function initAmbient(object, lp)
            object.intensity = repmat(object.color, object.numTri, 1) * lp.kappaA * lp.IA;
        end

        % hands off - this doesn't work yet (i think)
        function lightingVector(object, lightPos, lightColor, observerPos, lp)
            numTri = size(object.s, 1);
            numLights = size(lightPos, 1);
            d = reshape(object.s, [numTri, 1, 3]) ...
                - reshape(lightPos', [1, numLights, 3]);
            d = d ./ vecnorm(d, 2, 3); % normalize
            
            cosphi = dot(d, repmat(reshape(object.n, [numTri, 1, 3]), 1, numLights, 1), 3);

            dr = d - 2*reshape(object.n, [numTri, 1, 3]) .*cosphi;
            dr = dr ./ vecnorm(dr, 2, 3);
            
            u = observerPos - object.s;
            u = u ./ vecnorm(u, 2, 2);
            
            costheta = max(0, dot(dr, repmat(reshape(u, [numTri, 1, 3]), 1, numLights, 1), 3));

            intensity = lp.kappaD * lp.IQ * abs(cosphi) + ...
                                  lp.IQ * lp.kappaS * (lp.m + 2) / (2*pi) * power(costheta, lp.m);
            
            intensity = intensity .* object.vis + lp.kappaA * lp.IA;

            weights = reshape(lightColor .* object.color(:)', [1, numLights, 3]);

            object.intensity = reshape(sum(reshape(intensity, [numTri, numLights, 1]) .* weights, 2), [numTri, 3]);
        end
    end
end