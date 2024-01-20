function plotScene(coord,elem,elem2obj,coord2obj,myMap,E,eye)

figure
%*** plotte Lichtquelle
% lightsource =  [coord(elem(1,:),:);coord(elem(1,1),:)];
% plot3(lightsource(:,1),lightsource(:,2),lightsource(:,3),"Color","k");
% hold on

x = coord(:,1);
y = coord(:,2);
z = coord(:,3);

trisurf(elem(1,:), x, y, z,"EdgeColor","none","FaceColor","r")
hold on
for k=2:length(elem2obj)-1
    
    %*** plotte Objekt k
    %*** TODO

    idx = elem2obj(k):(elem2obj(k+1)-1);
    obj_k = elem(idx,:);
    p = trisurf(obj_k, x, y, z,"EdgeColor","none");   
    p.CData = E(idx);
    caxis([0,max(E(2:end))])
    view(eye)        
    colormap(myMap{k-1})
    freezeColors
    axis equal
end
grid off
xticklabels("")
yticklabels("")
zticklabels("")