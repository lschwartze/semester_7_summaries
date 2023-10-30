classdef situation < handle
    methods
        function obj = draw_situation(obj, lens, light)
            for num_of_input_points = 1:4
                [x,y,button] = ginput(1);
                if button == 32
                    % exit ginput with space bar
                    break;
                elseif button == 1
                    % left mouse click
                    switch num_of_input_points
                        % first lens point
                        case 1
                            plot(x,y,"b+")
                            previous_lens_point = [x;y];
                            lens.set_start(previous_lens_point);
                        % second lens point
                        case 2
                            plot(x,y,"b+")
                            lens.set_end([x;y]);
                            % plot lense
                            plot([x,previous_lens_point(1)], [y, previous_lens_point(2)], "b")
                            lens_vector = previous_lens_point - [x;y];
                            % orhtogonal vector of lense
                            orthogonal = [lens_vector(2); -lens_vector(1)];
                            % normalize
                            normalized = orthogonal/norm(orthogonal);
                            % plot lense
                            lens.set_normal(normalized);
                        case 3
                            % plot light source
                            plot(x,y,"yo")
                            light.set_source([x;y]);
                        case 4
                            % calculate Richtungsvektor
                            direction = [x;y]-light.source;
                            % normalize
                            norm_direction = direction/norm(direction);

                            light.set_dir(norm_direction);
                            % this ensures that the lense's normalvector points away from the light
                            if dot(norm_direction, normalized) < 0
                                normalized = -normalized;
                            end

                            lens = lens.set_normal(normalized);
                            % find intersection of beam and lense
                            p = obj.get_intersection(light, lens);
                            if ~isequal(p, [-1;-1])
                                % if there is intersection, go further
                                obj.get_reflection_refraction(light, lens, p)
                            else
                                % else just plot beam
                                endpoint = light.source + 2*light.direction;
                                plot([light.source(1), endpoint(1)], [light.source(2), endpoint(2)], "y") 
                            end
                        otherwise
                            continue
                    end   
                end
            end
        end
        
        function p = get_intersection(~,light,lens)
            connection_lens = lens.end_point - lens.start_point;
            A = [light.direction, -connection_lens];
            b = [lens.start_point(1)-light.source(1); lens.start_point(2)-light.source(2)];
            sol = linsolve(A,b);
            % no intersection if:
            % 1. crossing point right of lense
            % 2. crossing point left of lense
            % 3. crossing point in source of light
            if sol(2) >= 1 || sol(2) <= 0 || sol(1) < 1e-4
                p = [-1;-1];
                disp("here")
                return
            end
            p = light.source + sol(1)*light.direction;
            % plot intersection
            plot(p(1),p(2), "k+")
            % plots normal vector in both directions for good measure
            plot([p(1) + lens.normal_vec(1)/10, p(1)], [p(2) + lens.normal_vec(2)/10, p(2)], "r")
            plot([p(1) - lens.normal_vec(1)/10, p(1)], [p(2) - lens.normal_vec(2)/10, p(2)], "r--")
        end
        
        function get_reflection_refraction(~,light,lens,p)
            eta_1 = 1.00027717;
            eta_2 = 1.5168;

            % plot incoming beam
            plot([light.source(1), p(1)], [light.source(2), p(2)], "color",[1 0.8 0])

            % plot reflected beam
            prod = dot(light.direction,lens.normal_vec);
            refl = light.direction - 2 * lens.normal_vec * prod;
            plot([p(1), p(1) + refl(1)], [p(2), p(2) + refl(2)], "c")

            % plot refracted beam
            v_1 = light.direction;
            v_2 = lens.normal_vec;
            % this angle can be positive and negative
            alpha = acos(dot(v_1,v_2));

            radical = 1-(eta_1/eta_2)^2*(1-cos(alpha)^2);
            if radical < 0
                % totalreflexion
                return
            else
                % gives gamma in radians
                gamma = acos(sqrt(radical));

                rotational_matrix = [[cos(gamma), sin(gamma)]; [-sin(gamma), cos(gamma)]];
                refracted_direction = rotational_matrix * lens.normal_vec;

                % alpha might have been negative, so check that here
                test_rot = [[cos(alpha), sin(alpha)]; [-sin(alpha), cos(alpha)]];
                rotated = test_rot*light.direction;

                % if alpha was initially negative, rotate in the other direction
                if norm(rotated-lens.normal_vec) < 1e-4
                    rotational_matrix = [cos(gamma),-sin(gamma);sin(gamma),cos(gamma)];  
                    refracted_direction = rotational_matrix*lens.normal_vec;
                end

                end_point = p+2*refracted_direction;
                plot([p(1), end_point(1)], [p(2), end_point(2)], "g--")
            end
        end
    end
end