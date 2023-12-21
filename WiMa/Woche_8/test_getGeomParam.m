clear 
close all
clc

%Test getGeomParam
hold on
coord = [0 0 1; 1 0 1; 2 0 1; 0 1 1; 1 1 1; 2 1 1;0 2 1;1 2 1];
elem = [1 2 4;2 5 4;5 2 3;3 6 5;4 5 7;5 8 7];
[s,n,area2] = getGeomParam(coord,elem);

for i=1:length(elem)
    t = elem(i,:);
    line([coord(t(1),1),coord(t(2),1)],[coord(t(1),2),coord(t(2),2)])
    line([coord(t(2),1),coord(t(3),1)],[coord(t(2),2),coord(t(3),2)])
    line([coord(t(3),1),coord(t(1),1)],[coord(t(3),2),coord(t(1),2)])
end