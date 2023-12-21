function plotGrid(coord,elem,elem2obj,auge,s,n)
figure
x = coord(:,1);
y = coord(:,2);
z = coord(:,3);

trimesh(elem, x, y, z)
view(auge)        
axis equal
hold on 

if nargin == 6
    for k=1:length(elem2obj)-1
        %*** plotte Objekt k
        idx = elem2obj(k):(elem2obj(k+1)-1);
        obj_k = elem(idx,:);
        for i = 1:size(obj_k,1)
                normal = 0.2*(n(idx(i),:)/norm(n(idx(i),:)));
                buffer02 = [s(idx(i),:);s(idx(i),:)-normal];
                plot3(buffer02(:,1),buffer02(:,2),buffer02(:,3),"Color","r");
        end
    end
end

    view(auge)        
    axis equal
end
