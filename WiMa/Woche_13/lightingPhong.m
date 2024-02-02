function lighting = lightingPhong(elem2obj,auge,s,n,vis,lightingParameters)
    
    v1 = n(elem2obj(2):end,:);  %take the normals of the non light elements
    v1 = v1(vis(2:end),:);
    v2 = s(2:end,:)-s(1,:); %calculate the vectors between the light and the triangles
    v2 = v2(vis(2:end),:);
    v2 = normr(v2); %normalize
    dotProduct01 = dot(v1,v2,2);  %used later 
    
    v1 = v2 - 2 * v1 .*dotProduct01; %calculate reflected beam for every triangle
    v1 = normr(v1);
    v2 = +auge - s(2:end,:); %get vector between auge and triangles
    v2 = v2(vis(2:end),:);
    v2 = normr(v2);
    dotProduct02 = dot(v1,v2,2); %used later 
    
    %apply formulas from moodle
    IAmbient = lightingParameters.IA*lightingParameters.kappaA;
    IDiffuse = lightingParameters.IQ*lightingParameters.kappaD*dotProduct01;
    IIdeal = lightingParameters.IQ*lightingParameters.kappaS*(lightingParameters.m + 2)/(2*pi)*(dotProduct02.^lightingParameters.m);
    lighting = zeros(length(vis)-1,1)+IAmbient;
    lighting(vis(2:end)) = lighting(vis(2:end))+IDiffuse+IIdeal;
    lighting = [1;lighting];
end
