function interactive_Plot(coord,elem,elem2obj,I,auge,s,n,vis,lightingParameter,myMap)
mainPlot = figure;

x = coord(:,1);
y = coord(:,2);
z = coord(:,3);

if nargin == 10
    trisurf(elem(1,:), x, y, z,"EdgeColor","none","FaceColor","r")
    hold on
    for k=2:length(elem2obj)-1  
        idx = elem2obj(k):(elem2obj(k+1)-1);
        obj_k = elem(idx,:);
        p(k-1) = trisurf(obj_k, x, y, z,"EdgeColor","none");   
        p(k-1).CData = I(idx);
        view(auge)        
        colormap(myMap{k-1})
        caxis([0,max(I(2:end))])
        freezeColors
        axis equal
    end
else
    p= trisurf(elem, x, y, z,"EdgeColor","none");
    p.CData = I;
    caxis([0,max(I(2:end))])
    colormap("gray")
    myMap = [];
end
axis equal 
hold on
grid off
xticklabels("")
yticklabels("")
zticklabels("")
rotate3d on
view(auge)

% Event Handler setzen - wird bei jeder Mausbewegung im Plot aufgerufen
set(mainPlot, 'windowbuttonmotionfcn', @(src, event) handler(src, event, elem2obj,s,n,vis,lightingParameter, p,myMap));
end