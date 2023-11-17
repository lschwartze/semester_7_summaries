classdef situation < handle
    properties
        %Brechungs Indizes
        eta_1; 
        eta_2; 
        
        %Linsen, Licht, Wände und Spiegel
        lenses
        light
        walls 
        mirrors
    end
    methods
        %Konstruktor
function obj = situation(lenses,light,walls,mirrors,refra_index_med,refra_index_lens)
            if nargin == 0
                 obj.eta_1 = 1.00027717;
                 obj.eta_2 = 1.5168;
                 obj.lenses = plane_lens();
                 obj.light = lights();
                 obj.walls = wall();
                 obj.mirrors = mirror();
            elseif nargin == 4
                 obj.eta_1 = 1.00027717;
                 obj.eta_2 = 1.5168;
                 obj.lenses = lenses(:);
                 obj.light = light;
                 obj.walls = walls(:);
                 obj.mirrors = mirrors(:);
            else
                 obj.eta_1 = refra_index_med;
                 obj.eta_2 = refra_index_lens;
                 obj.lenses = lenses(:);
                 obj.light = light(:);
                 obj.walls = walls(:);
                 obj.mirrors = mirrors(:);
            end
        end

        function [d_refl,d_refra] = reflexion_refraction(obj,normal)  
            % does the normal vector go away from the light source
            % this fixes the denser medium and the lighter one
            % rule: denser medium is on that side of lense where the normal
            % vector is a dashed line; totalrefelction is possible here
            if dot(obj.light.direction, normal) < 0
                normal = -normal;
                eta1 = obj.eta_1;
                eta2 = obj.eta_2;
            else
                eta1 = obj.eta_2;
                eta2 = obj.eta_1;
            end

            % calculate reflection
            prod = dot(obj.light.direction,normal);
            d_refl = obj.light.direction - 2 * normal * prod;
            d_refl = d_refl/norm(d_refl);

            % plot refracted beam
            v_1 = obj.light.direction;
            v_2 = normal/norm(normal);

            % this angle can be positive and negative
            alpha = acos(dot(v_1,v_2));

            radical = 1-(eta1/eta2)^2*(1-cos(alpha)^2);
            if radical < 0
                d_refra = d_refl;
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

            %alle statische Objekte
            lenses_walls_mirrors = [obj.lenses;obj.walls;obj.mirrors];

            %all intersections of the light with lenses
            p = cell(1,length(lenses_walls_mirrors));

            %all normal Vectors
            normal= cell(1,length(lenses_walls_mirrors));

            %all parameters t
            t = cell(1,length(lenses_walls_mirrors));
            
            for i = 1:length(lenses_walls_mirrors)
                %search for intersections
                [p{i},normal{i},t{i}] = lenses_walls_mirrors(i).intersect(obj.light);
            end
            %search for closest intersection
            [~,idx]=min([t{:}]);
            
            if ~isnan([p{idx}]) 
                if isa(lenses_walls_mirrors(idx),'wall')
                    p = [p{idx}];
                    normal = [normal{idx}];
                    obj.light.draw_light(p,normal);
                elseif isa(lenses_walls_mirrors(idx),'mirror')
                    p = [p{idx}];
                    normal = [normal{idx}];
                    [d_refl,~]=obj.reflexion_refraction(normal);
                    obj.light.draw_light(p,normal);
                    op = obj.light.opacity*0.9;
                    if op > 0.15
                        light01 = lights(p,d_refl,0,op);
                        sit01 = situation(obj.lenses,light01,obj.walls,obj.mirrors,obj.eta_1,obj.eta_2);
                        sit01.plot_sit()
                    end
                else
                    p = [p{idx}];
                    normal = [normal{idx}];
                    [d_refl,d_refra]=obj.reflexion_refraction(normal);
                    obj.light.draw_light(p,normal);
                    % and reflection
                    op = obj.light.opacity*0.9;
                    if op > 0.15
                        light01 = lights(p,d_refl,0,op);
                        light02 = lights(p,d_refra,0,op);
                        sit01 = situation(obj.lenses,light01,obj.walls,obj.mirrors,obj.eta_1,obj.eta_2);
                        sit02 = situation(obj.lenses,light02,obj.walls,obj.mirrors,obj.eta_1,obj.eta_2);
                        sit01.plot_sit()
                        sit02.plot_sit()
                    end
                end
            else
                % else just plot beam
                endpoint = obj.light.source + 2*obj.light.direction;
                plot([obj.light.source(1), endpoint(1)], [obj.light.source(2), endpoint(2)],"color",[1 0.8 0 0.9*obj.light.opacity]) 
            end
        end
    end
end