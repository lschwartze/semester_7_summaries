function plotGrid(coord,elem,~,auge,s,n)
figure
x = coord(:,1);
y = coord(:,2);
z = coord(:,3);

trimesh(elem, x, y, z,"EdgeColor","k")
hold on 

if nargin ==6
    n = -n;
    quiver3(s(:,1),s(:,2),s(:,3),n(:,1),n(:,2),n(:,3),"Color","r")
end

view(auge)
axis equal
