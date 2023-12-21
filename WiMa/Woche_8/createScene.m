function [coord, elem, coord2obj, elem2obj] = createScene(res)

%*** LichtElement
coord = [3  , 1  , 4;...
         3.2, 1  , 3.8;...
         3  , 1.2, 4];
     
elem = [1,2,3];

% x2obj codiert, welche Indexbereiche zu welchem Objekt gehören. Zu Objekt
% i gehören etwa die Elemente im Indexbereich
% elem2obj(i):(elem2obj(i+1)-1). Für das erste Element wäre das also der
% Indexbereich 1:(2-1), d.h. lediglich das Element mit Index 1 - das ist
% die Lichtquelle.
coord2obj = [1;4];
elem2obj = [1;2];

%*** Objekt
[coordtmp, elemtmp] = mysphere(res);
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
elemtmp = [];
nn = size(x,1)-1;
for i=1:nn      % in x
  for j=1:nn    % in y
    elemtmp = [elemtmp;[(i-1)*(nn+1)+j,(i-1)*(nn+1)+j+1,i*(nn+1)+j+1]];    
    elemtmp = [elemtmp;[i*(nn+1)+j+1,i*(nn+1)+j,(i-1)*(nn+1)+j]]; 
  end
end

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

