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
                            %plot(x,y,"b+")
                            previous_lens_point = [x;y];
                            lens.set_start(previous_lens_point);
                        % second lens point
                        case 2
                            %plot(x,y,"b+")
                            fun = @(z) sin(z)^4;
                            if x > previous_lens_point(1)
                                wl = weird_lens([previous_lens_point(1), x], fun);
                            else
                                wl = weird_lens([x, previous_lens_point(1)], fun);
                            end
                            wl.draw_lens();
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

                            % find intersection of beam and lense
                            p = obj.get_intersection(light, wl);

                            if ~isequal(p, [-1;-1])
                                lens = obj.get_tangent(light,wl,p);
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
        
        function p = get_intersection(~,light,wl)
            syms z;            
            a = light.direction(2)/light.direction(1);
            b = light.source(2) - a*light.source(1);
            intersec = vpasolve(a*z+b == wl.fun(z), z, wl.range);
            tmp = dot(light.direction, [intersec;wl.fun(intersec)]-light.source);
            if isempty(intersec) || tmp < 0
                p = [-1;-1];
                return
            end
            iterator = intersec;
            while true
                if iterator(1) < light.source(1)
                    iterator = vpasolve(a*z+b == wl.fun(z), z, [iterator+eps,wl.range(2)]);
                else
                    iterator = vpasolve(a*z+b == wl.fun(z), z, [wl.range(1), iterator-eps]);
                end
                if isempty(iterator)
                    break;
                end 
                intersec = iterator;
            end
            p = [intersec;wl.fun(intersec)];
        end
        
        function l = get_tangent(~,light,wl,p)
            syms x;
            df = eval(['@(x)' char(diff(wl.fun(x)))]);
            tang = df(p(1));
            l = lens();
            l.set_start(p+[1;tang])
            l.set_end(p-[1;tang]);
            lens_vector = l.end_point - l.start_point;
            normal = [lens_vector(2); -lens_vector(1)];
            normal = normal/norm(normal);
            l.set_normal(normal);
            if dot(light.direction, l.normal_vec) < 0
                l.set_normal(-l.normal_vec); 
            end
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