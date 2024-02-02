%erstellt die Triangulierung mit gewünschter Auflösung res
function [coord, elem, coord2obj, elem2obj] = createSceneVector(res)

%*** LichtElement
coord = [3  , 1  , 4;...
         3.2, 1  , 3.8;...
         3  , 1.2, 4];
  
% das hier ist in createScene nicht, ich entferne das mal i guess     
% coord(:,3) = coord(:,3) - 1.5;
     
elem = [1,2,3];
coord2obj = [1;4];
elem2obj = [1;2];

%*** Objekt
[coordtmp, elemtmp] = mysphere(res);%read_off("../off_copies/toilet.off ");
coordtmp = coordtmp*0.25;
coordtmp(:,2) = coordtmp(:,2)+1;
coordtmp(:,3) = coordtmp(:,3)+1;
coordtmp(:,1) = coordtmp(:,1)+1;

elem = [elem;elemtmp+size(coord,1)];
coord = [coord;coordtmp];
coord2obj = [coord2obj;size(coord,1)+1];
elem2obj  = [elem2obj ;size(elem,1)+1];

%*** Hintergrundflaechen
[x,y] = meshgrid(linspace(0,1.5,fix(res)),linspace(0.5,1.5,fix(res)));
coordtmp = [x(:),y(:),zeros(size(x(:)))]; % [x,y,z(nullen)]
nn = size(x,1)-1;

% for i=1:nn      % in x
%   for j=1:nn    % in y
%     elemtmp = [elemtmp;[(i-1)*(nn+1)+j,(i-1)*(nn+1)+j+1,i*(nn+1)+j+1]];    
%     elemtmp = [elemtmp;[i*(nn+1)+j+1,i*(nn+1)+j,(i-1)*(nn+1)+j]]; 
%   end
% end

elemtmp = zeros(2*nn*nn, 3);

i = 1:nn;
j = (1:nn)';
x1a = (i-1)*(nn+1)+j;
x1b = i*(nn+1)+j+1;
x2a = (i-1)*(nn+1)+j+1;
x2b = i*(nn+1)+j;
x3a = i*(nn+1)+j+1;
x3b = (i-1)*(nn+1)+j;

elemtmp(1:2:end,1) = reshape(x1a, [], 1);
elemtmp(2:2:end,1) = reshape(x1b, [], 1);
elemtmp(1:2:end,2) = reshape(x2a, [], 1);
elemtmp(2:2:end,2) = reshape(x2b, [], 1);
elemtmp(1:2:end,3) = reshape(x3a, [], 1);
elemtmp(2:2:end,3) = reshape(x3b, [], 1);

%*** x,y Flaeche
elem = [elem;elemtmp+size(coord,1)]; 
coord = [coord;coordtmp];
coord2obj = [coord2obj;size(coord,1)+1];
elem2obj  = [elem2obj ;size(elem,1)+1];

%*** yz flaeche
coordtmp = [zeros(size(x(:))),y(:),x(:)]; % [x(null),y,z(alt x)]
elem = [elem;elemtmp(:,[1,3,2])+size(coord,1)];
coord = [coord;coordtmp];
coord2obj = [coord2obj;size(coord,1)+1];
elem2obj  = [elem2obj ;size(elem,1)+1];


function [coordinates,elements] = mysphere(n)
[xx,yy,zz] = sphere(n);
coordinates = [xx(:),yy(:),zz(:)];
elements = [];

%*** setze elements :
% gegen den Uhrzeigersinn nummeriert + erster Punkt am rechten Winkel!
for i=1:n
  for j=2:n-1   
    elements = [elements;[(i-1)*(n+1)+j+1,i*(n+1)+j+1,(i-1)*(n+1)+j]];    
    elements = [elements;[i*(n+1)+j,(i-1)*(n+1)+j,i*(n+1)+j+1]]; 
  end
end
%*** setze elemente fuer oben und unter separat
for j=1:n
  elements = [elements;[(j-1)*(n+1)+2,j*(n+1)+2,1]];    
  elements = [elements;[(j+1)*(n+1)-1,j*(n+1)-1,n+1]]; 
end



