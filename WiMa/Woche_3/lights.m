classdef lights < handle
    properties
        source
        direction
    end
    
    methods
        function obj = lights(s,d,to_plot)
            obj.source = s;
            obj.direction = d;
            if to_plot
                plot(s(1),s(2),'yo')
            end
        end
        
        function calculate_experiment(obj,weird_lenses,lenses)
            % find the intersection closest to the light source
            closest_point = [-1;-1];
            shortest_distance = Inf;
            closest_lens = 0;
            
            % reflection at all weird lenses
            for i=1:length(weird_lenses)
                l = weird_lenses(i);
                % find intersection of beam and lens
                [p,u] = l.get_intersection(obj);
                % check if this lens is closest to source
                if ~isequal(p,[-1;-1]) && ~isnan(p(1)) && ~isnan(p(2)) && u < shortest_distance && u > 1e-4
                    closest_point = p;
                    shortest_distance = u;
                    closest_lens = weird_lenses(i);
                end
            end
            
            % intersection for all planar lenses
            for i=1:length(lenses)
                l = lenses(i);
                [p,u] = l.get_intersection(obj);
                % check if this lens is closest to light source
                if ~isequal(p,[-1;-1]) && u < shortest_distance
                    closest_point = p;
                    shortest_distance = u;
                    closest_lens = lenses(i);                         
                end
            end
            
            % if closest lens is planar, do the normal stuff
            if isa(closest_lens, "lens")
                closest_lens.get_reflection_refraction(obj, closest_point,weird_lenses,lenses)
            % weird lens, create virtual planar lens and continue as usual
            elseif isa(closest_lens, "weird_lens")
                [tangent_lens,new_p] = closest_lens.get_tangent(closest_point);
                tangent_lens.get_reflection_refraction(obj,new_p,weird_lenses,lenses)
            % no lens at all, just plot the beam
            else
                endpoint = obj.source + 2*obj.direction;
                plot([obj.source(1), endpoint(1)], [obj.source(2), endpoint(2)], "color",[1 0.8 0]) 
            end
                         
        end
    end
end