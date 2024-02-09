classdef Sphere < Object3D
    methods
        function obj = Sphere(radius, center, n, color)
            center = center(:)';
            [xx,yy,zz] = sphere(n);
            coord = radius * [xx(:),yy(:),zz(:)] + center;
            elem = zeros(2*n*(n-1), 3);
            
            %*** setze elements :
            % gegen den Uhrzeigersinn nummeriert + erster Punkt am rechten Winkel!
            i = 1:n;
            j = (2:(n-1))';
            x1a = (i-1)*(n+1)+j+1;
            x1b = i*(n+1)+j;
            x2a = i*(n+1)+j+1;
            x2b = (i-1)*(n+1)+j;
            x3a = (i-1)*(n+1)+j;
            x3b = i*(n+1)+j+1;
            
            N = 2*n*(n-2);
            elem(1:2:N, 1) = reshape(x1a, [], 1);
            elem(2:2:N, 1) = reshape(x1b, [], 1);
            elem(1:2:N, 2) = reshape(x2a, [], 1);
            elem(2:2:N, 2) = reshape(x2b, [], 1);
            elem(1:2:N, 3) = reshape(x3a, [], 1);
            elem(2:2:N, 3) = reshape(x3b, [], 1);
            
            
            %*** setze elemente fuer oben und unter separat
            j = (1:n)';
            elem((N+1):2:end,:) = [(j-1)*(n+1)+2,j*(n+1)+2,ones(n,1)];    
            elem((N+2):2:end,:) = [(j+1)*(n+1)-1,j*(n+1)-1,n+ones(n,1)];


            obj@Object3D(coord, elem, color)
            obj.center = center;
            obj.diam = 2*radius;
        end
    end
end