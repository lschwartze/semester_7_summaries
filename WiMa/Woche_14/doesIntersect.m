function intersect = doesIntersect(elem,s2, beam_source, s, coord,n)
%{
vis: welche Elemente sind sichtbar (falls bereits Sichtbarkeit bestimmt ansonsten wird vis = 1 gesetzt)
s2: welche Dreiecke sollen untersucht werden?, Schwerpunkte zu den Dreiecken
beam_source, s, coord,n: Lichtquelle, Schwerpunkte aller Dreiecke,
Koordinaten und Normalenvektoren aller Dreiecke
%}

intersect = ones(size(s2,1),1);


coord = coord';

% Bestimme Parameter t aus der Geradengleichung beam_source + t* (s2-beam_source)
% Also Schnittpunkte der zu untersuchenden Dreiecke mit allen Ebenen
% aufgespannt von den Dreiecken

t = repmat(dot(n,-beam_source+s,2),size(s2,1),1)./dot(repmat(n,size(s2,1),1),reshape(repmat(s2,1,size(n,1))',3,size(n,1)*size(s2,1))'-beam_source,2);
t = reshape(t,size(n,1),size(s2,1));
if size(t,1)==1
    idx = 0 < t & t < 1; 
else
    idx = max(t > 0 & t< 1); % Falls es ein Dreieck gibt, für welches die Geradengleichung keinen Schnittpunkt für 0< t <1 ergibt, dann ist dieses Sichtbar
end
intersect(~idx)= 1;
t = t(:,idx);
s2 = s2(idx,:);


% Prüfe für die restlichen Dreiecken ob die berechneten Schnittpunkte in
% einem Dreieck liegen oder nicht.
% Struktur: betrachte eine Blockmatrix:
%   a_1,1 a_1,2 0 ...                    - Spannvektor Ebene 1 + Schnittpunkt Ebene 1 mit Gerade 1, - Spannvektor Ebene 1 + Schnittpunkt Ebene 1 mit Gerade 2, ...
%   a_2,1 a_2,2 0 ...                       
% ( a_3,1 a_3,2 0 ...             )*x =(  
%   0     0     a_4,3 a_4,4 0 ...        - Spannvektor Ebene 2 + Schnittpunkt Ebene 2 mit Gerade 1, - Spannvektor Ebene 2 + Schnittpunkt Ebene 2 mit Gerade 2, ...
%   0     0     a_5,3 a_5,4 0 ...
%   0     0     a_6,3 a_6,4 0 ...           ...
% usw. wobei die Blöcke den Spannvektoren der Ebenen entspricht und die
% Spalten der rechten Matrix immer den Schnittpunkten der entsprechenden 
% Geraden mit der entsprechenden Ebene ist (Zeile - Ebene, Spalte - Gerade)


n = size(elem,1);
m = size(s2,1);

idx01= t>0 & t<1;
t = t(idx01);
t = t(:);
aaf = idx01 .*(1:m);
aaf = aaf(aaf~=0);
aaf = aaf(:);


d =s2-beam_source;
d = d(aaf,:);
d = t.*d;
b = (-coord(:,elem(:,1))+beam_source')';
mamp = (1:n)'.*idx01;
mamp = mamp(:);
mamp = mamp(mamp ~=0);


a1 = coord(:,elem(:,2))'-coord(:,elem(:,1))';
a2 = coord(:,elem(:,3))'-coord(:,elem(:,1))';

[r1,c1,s1] = givens(a1(:,1:2));
[r1,c2,s2] = givens([r1 a1(:,3)]);

a2(:,1:2) = [c1.*a2(:,1)-s1.*a2(:,2), s1.*a2(:,1)+c1.*a2(:,2)];
a2(:,[1 3])= [c2.*a2(:,1)-s2.*a2(:,3), s2.*a2(:,1)+c2.*a2(:,3)]; 

[r2,c3,s3] = givens(a2(:,2:3));


b(:,1:2) = [c1.*b(:,1)-s1.*b(:,2), s1.*b(:,1)+c1.*b(:,2)];
b(:,[1 3])= [c2.*b(:,1)-s2.*b(:,3), s2.*b(:,1)+c2.*b(:,3)];
b(:,2) = c3.*b(:,2)-s3.*b(:,3);

repMat =[r1 r2 c1 c2 c3 s1 s2 s3 a2(:,1) b];

repMat = repMat(mamp,:);


d(:,1:2) = [repMat(:,3).*d(:,1)-repMat(:,6).*d(:,2), repMat(:,6).*d(:,1)+repMat(:,3).*d(:,2)];
d(:,[1 3])= [repMat(:,4).*d(:,1)-repMat(:,7).*d(:,3), repMat(:,7).*d(:,1)+repMat(:,4).*d(:,3)];
d(:,2) =repMat(:,5).*d(:,2)-repMat(:,8).*d(:,3);

b = repMat(:,10:12)+d;

sol02 = b(:,2)./repMat(:,2);
sol01 = (b(:,1)-repMat(:,9).*sol02(:))./repMat(:,1);



% Überprüfe Lösungsmatrix auf hinreichende Lösungen
sol01(sol01 < 0) = NaN;
sol02(sol02 < 0) = NaN; 
sol = sol01+sol02;
sol(sol>1)=NaN;
beef = NaN*ones(size(idx01));
beef(idx01) = sol;
intersect(idx) = ~max(~isnan(beef)) ; 
end