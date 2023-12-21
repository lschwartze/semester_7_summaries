function lighting = lightingPhong(coord,elem,elem2obj,auge,s,n,vis,lightingParameters)

    v1 = n(elem2obj(2):end,:);  %only take elements that aren't the light
    v2 = repmat(n(1,:),size(v1,1),1);   %only take the light and adjust it's dimension
    visTemp = repmat(vis(2:end),1,3);   %putting visibility in the correct format
    v2 = visTemp.*v2;   %setting all invisible triangles to zero
    dotProduct = dot(v1,v2,2);  %used twice so save it for later use
    einfallswinkel = abs(atan2(sqrt(sum(cross(v1,v2).^2,2)),dotProduct)-pi/2);  %calculate angle between the normals of the triangles and the light direction
    einfallswinkel(einfallswinkel == pi/2) = 0; %set all unused triangles to zero again, maybe redundant
    
    v1 = v2 - 2 * v1 .* repmat(dotProduct,1,3); %calculate reflected beam for every triangle
    v2 = repmat(auge,size(v1,1),1);
    v2 = s(2:end,:) - v2; %get vector between auge and triangles
    otherAngle = abs(atan2(sqrt(sum(cross(v1,v2).^2,2)),dotProduct)-pi/2);  %calculate angle between refelcted beams and the eye direction
    otherAngle(otherAngle == pi/2) = 0; %set all unused to zero
    
    %apply formulas from moodle
    IAmbient = lightingParameters.IA*lightingParameters.kappaA;
    IDiffuse = lightingParameters.IQ*lightingParameters.kappaD*cos(einfallswinkel).*vis(2:end);
    IIdeal = lightingParameters.IQ*lightingParameters.kappaS*(lightingParameters.m + 2)*(cos(otherAngle).^lightingParameters.m).*vis(2:end)/(2*pi);
    lighting = IAmbient+IDiffuse+IIdeal;

end
