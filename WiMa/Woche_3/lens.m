classdef lens < general_lens
    properties
        normal_vec
    end
    methods
        % constructor takes in start and end point. Normal is calculated
        % from that. to_plot signals whether this lens should be plotted or
        % not, for example if it's only a virtual lens
        function obj = lens(a,b,to_plot)
            obj@general_lens(a,b);
            connector_line = b-a;
            obj.normal_vec = [connector_line(2); -connector_line(1)];
            obj.normal_vec = obj.normal_vec/norm(obj.normal_vec);
            if to_plot
                obj.draw_lens()
            end
        end
        
        %draws the lens connecting start and end point
        function draw_lens(obj)
            plot([obj.start_point(1),obj.end_point(1)], [obj.start_point(2), obj.end_point(2)],'b') 
        end
        
        % get intersection as usual, by solving LSE
        function [p,u] = get_intersection(obj,light)
            % light: source, normalized direction
            % lense: start point, end point, orthogonal vector
            connection_lens = obj.end_point-obj.start_point;
            A = [light.direction, -connection_lens];
            b = obj.start_point-light.source;
            sol = linsolve(A,b);

            % no intersection if:
            % 1. crossing point right of lense
            % 2. crossing point left of lense
            % 3. crossing point in source of light
            if sol(2) >= 1 || sol(2) <= 0 || sol(1) < 1e-4
                p = [-1;-1];
                u = Inf;
                return
            end
            p = light.source + sol(1)*light.direction;
            u = sol(1);
        end
        
        % reflect and refract on (virtual) planar lens
        function get_reflection_refraction(obj,light,p,weird_lenses,lenses)
            eta_1 = 1.00027717;
            eta_2 = 1.5168;
            
            % this ensures that the lense's normalvector points away from the light
            if dot(light.direction, obj.normal_vec) < 0
                    obj.normal_vec = -obj.normal_vec;
            end

            % create reflected beam
            prod = dot(light.direction,obj.normal_vec);
            refl = light.direction - 2 * obj.normal_vec * prod;
            refl = refl/norm(refl);
            reflected_beam = lights(p,refl,0); 
            % plot([p(1), p(1) + refl(1)], [p(2), p(2) + refl(2)], "c")

            % plot refracted beam
            v_1 = light.direction;
            v_2 = obj.normal_vec;
            % this angle can be positive and negative
            alpha = acos(dot(v_1,v_2));

            radical = 1-(eta_1/eta_2)^2*(1-cos(alpha)^2);
            if radical > 0
                % gives gamma in radians
                gamma = acos(sqrt(radical));

                rotational_matrix = [[cos(gamma), sin(gamma)]; [-sin(gamma), cos(gamma)]];
                refracted_direction = rotational_matrix * obj.normal_vec;

                % alpha might have been negative, so check that here
                test_rot = [[cos(alpha), sin(alpha)]; [-sin(alpha), cos(alpha)]];
                rotated = test_rot*light.direction;

                % if alpha was initially negative, rotate in the other direction
                if norm(rotated-obj.normal_vec) < 1e-4
                    rotational_matrix = [cos(gamma),-sin(gamma);sin(gamma),cos(gamma)];  
                    refracted_direction = rotational_matrix*obj.normal_vec;
                end
                
                refracted_direction = refracted_direction/norm(refracted_direction);
                refracted_beam = lights(p, refracted_direction,0);
                refracted_beam.calculate_experiment(weird_lenses,lenses);
            end
            plot_experiment(obj,light,p);
            reflected_beam.calculate_experiment(weird_lenses,lenses);
        end
        
        function plot_experiment(obj,light,p)
            % plot incoming beam
            plot([light.source(1), p(1)], [light.source(2), p(2)], "color",[1 0.8 0])
            % plot intersection
            plot(p(1),p(2), "k+")
            % plots normal vector in both directions for good measure
            plot([p(1) + obj.normal_vec(1)/10, p(1)], [p(2) + obj.normal_vec(2)/10, p(2)], "r")
            plot([p(1) - obj.normal_vec(1)/10, p(1)], [p(2) - obj.normal_vec(2)/10, p(2)], "r--") 
        end
    end
end