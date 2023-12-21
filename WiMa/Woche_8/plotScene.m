function plotScene(coord,elem,elem2obj,coord2obj,myMap,E,eye)

figure
%*** plotte Lichtquelle
%*** TODO

hold on;
for k=2:length(elem2obj)-1
    
    %*** plotte Objekt k
    %*** TODO
    

    caxis([0,max(E(2:end))])
    view(eye)        
    colormap(myMap{k-1})
    freezeColors
    axis equal
    hold on
end
