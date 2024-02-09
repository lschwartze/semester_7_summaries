classdef Parallelogramm < Object3D
    properties
        corners
    end
    % ^
    methods
        % e.g. parallelogramm ABCD (ccw.) -> pass corners = [A, B, D]
        % column-wise, C gets inferred automatically
        function obj = Parallelogramm(corners, nof_divisions, color)


            idx = reshape(1:(nof_divisions + 1)^2, [nof_divisions+1, nof_divisions+1]);

            ll_vertex = idx(1:end-1, 1:end-1);
            lu_vertex = idx(1:end-1, 2:end);
            rl_vertex = idx(2:end, 1:end-1);
            ru_vertex = idx(2:end, 2:end);

            left_elem = [ll_vertex(:), rl_vertex(:), lu_vertex(:)];
            right_elem = [rl_vertex(:), ru_vertex(:), lu_vertex(:)];

            elem = zeros(2*nof_divisions^2, 3);
            elem(1:2:end,:) = left_elem;
            elem(2:2:end,:) = right_elem;

            [s, t] = meshgrid(linspace(0,1,nof_divisions+1), linspace(0,1,nof_divisions+1));

            coord = corners(1,:) + (corners(2,:) - corners(1,:)) .* s(:) + (corners(3,:) - corners(1,:)) .* t(:);

            obj@Object3D(coord, elem, color)
            obj.corners = corners;%[corners;-corners(1,:)+corners(2,:)+corners(3,:)];
        end
        
    end
end