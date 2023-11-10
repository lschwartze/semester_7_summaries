classdef situation < handle
    properties
        %Brechungs Indizes
        eta_1; 
        eta_2; 
        
        %Linsen und Licht
        lenses
        light
    end
    methods
        %Konstruktor
        function obj = situation(lenses,light,refra_index_med,refra_index_lens)
            if nargin == 0
                 obj.eta_1 = 1.00027717;
                 obj.eta_2 = 1.5168;
                 obj.lenses = plane_lens();
                 obj.light = lights();
            elseif nargin == 2
                 obj.eta_1 = 1.00027717;
                 obj.eta_2 = 1.5168;
                 obj.lenses = lenses;
                 obj.light = light;
            else
                 obj.eta_1 = refra_index_med;
                 obj.eta_2 = refra_index_lens;
                 obj.lenses = lenses;
                 obj.light = light;
            end
        end

       function [d_refl,d_refra] = reflexion_refraction(obj,normal)    

            % calculate reflection
            prod = dot(obj.light.direction,normal);
            d_refl = obj.light.direction - 2 * normal * prod;
            d_refl = d_refl/norm(d_refl);

            % plot refracted beam
            v_1 = obj.light.direction;
            v_2 = normal/norm(normal);

            % this angle can be positive and negative
            alpha = acos(dot(v_1,v_2));

            radical = 1-(obj.eta_1/obj.eta_2)^2*(1-cos(alpha)^2);
            if radical < 0
                % totalreflexion
                return
            else
                % gives gamma in radians
                gamma = acos(sqrt(radical));

                rotational_matrix = [[cos(gamma), sin(gamma)]; [-sin(gamma), cos(gamma)]];
                d_refra = rotational_matrix * normal;

                % alpha might have been negative, so check that here
                test_rot = [[cos(alpha), sin(alpha)]; [-sin(alpha), cos(alpha)]];
                rotated = test_rot*obj.light.direction;

                % if alpha was initially negative, rotate in the other direction
                if norm(rotated-normal) < 1e-4
                    rotational_matrix = [cos(gamma),-sin(gamma);sin(gamma),cos(gamma)];  
                    d_refra = rotational_matrix*normal;
                end
            end
       end

        %Plotte Situation
        function plot_sit(obj)
            % plot light source
            plot(obj.light.source(1),obj.light.source(2),"yo")

            %all intersections of the light with lenses
            p = cell(1,length(obj.lenses));

            %all normal Vectors
            normal= cell(1,length(obj.lenses));

            %all parameters t
            t = cell(1,length(obj.lenses));

            for i = 1:length(obj.lenses)
                %search for intersections
                [p{i},normal{i},t{i}] = obj.lenses(i).intersect(obj.light);
            end
            %search for closest intersection
            [~,idx]=min([t{:}]);
            %closest_lens = obj.lenses(idx);

            if ~isnan([p{idx}])
                p = [p{idx}];
                normal = [normal{idx}];
                [d_refl,d_refra]=obj.reflexion_refraction(normal);
                % plot incoming beam
                plot([obj.light.source(1),p(1)], [obj.light.source(2), p(2)], "color",[1 0.8 0])
                %plot normal
                plot([p(1)-0.1*normal(1), p(1) + 0.1*normal(1)], [p(2)- 0.1*normal(2), p(2) + 0.1*normal(2)], "r--")
                % are their additional intersections with the refraction
                % and reflection
                light01 = lights(p,d_refl);
                light02 = lights(p,d_refra);
                sit01 = situation(obj.lenses,light01,obj.eta_1,obj.eta_2);
                sit02 = situation(obj.lenses,light02,obj.eta_1,obj.eta_2);
                sit01.plot_sit()
                sit02.plot_sit()
            else
                % else just plot beam
                endpoint = obj.light.source + 2*obj.light.direction;
                plot([obj.light.source(1), endpoint(1)], [obj.light.source(2), endpoint(2)],"color",[1 0.8 0]) 
            end
        end
    end
end