function [s,n,area2] = getGeomParam(coord,elem)

buffer = elem';
buffer = coord(buffer(:),:); %Enthält Koordinaten des 1-sten Dreiecks in der 1,2,3 Zeile usw. 

s = (1/3)*(buffer(1:3:end,:)+buffer(2:3:end,:)+buffer(3:3:end,:)); %Matrix mit Schwerpunkt des i-ten Dreiecks in der i-ten Zeile

buffer_A = -buffer(1:3:end,:)+buffer(2:3:end,:); % Vektor in der i-ten Zeile von A und 
buffer_B = -buffer(1:3:end,:)+buffer(3:3:end,:); % Vektor in der i-ten Zeile von B spannen i-tes Dreieck auf

n = cross(buffer_A,buffer_B,2); %Matrix mit Normale des i-ten Dreiecks in der i-ten Zeile
area2 = vecnorm(n,2,2); % Spaltenvektor mit dem Flächeninhalt des i-ten Dreiecks im i-te Eintrag;
n = n./area2;
end