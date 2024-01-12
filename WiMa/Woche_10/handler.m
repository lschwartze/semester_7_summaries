function handler(~, ~, elem2obj,s,n,vis,lightingParameter, vd,myMap)
    axes = gca;
    auge = axes.CameraPosition; % Position des Betrachters
    I=lightingPhong(elem2obj,auge,s,n,vis,lightingParameter);
    if ~isempty(myMap)
        for k=2:length(elem2obj)-1
            idx = elem2obj(k):(elem2obj(k+1)-1);   
            vd(k-1).CData = I(idx);
            colormap(myMap{k-1})
            freezeColors
        end
    else
        vd.CData = I;
    end
end