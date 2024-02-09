classdef Light
    properties
        pos
        color
        intensity
    end
    
    methods
        function obj = Light(pos, color, intensity)
            obj.pos = pos(:)'; obj.color = color; obj.intensity = intensity;
        end
    end
end

