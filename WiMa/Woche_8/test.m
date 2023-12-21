[coord, elem, coord2obj, elem2obj] = createScene(20);
x = coord(:,1);
y = coord(:,2);
z = coord(:,3);

%TO = triangulation(elem,x,y,z);
trimesh(elem, x, y, z)