function intersect = doesIntersect(vis,elem,s2, beam_source, s, coord,n)
%{
vis: welche Ebenen sollen betrachtet werden
s2: welche Dreiecke sollen untersucht werden?, Schwerpunkte zu den Dreiecken
beam_source, s, coord,n: Lichtquelle, Schwerpunkte aller Dreiecke,
Koordinaten und Normalenvektoren aller Dreiecke
%}

intersect = ones(size(s2,1),1);


coord = coord';
n = n(vis,:); % betrachte nur die relevanten Ebenen
s = s(vis,:);
elem = elem(vis,:);

% Bestimme Parameter t aus der Geradengleichung beam_source + t* (s2-beam_source)
% Also Schnittpunkte der zu untersuchenden Dreiecke mit allen Ebenen
% aufgespannt von den Dreiecken

t = repmat(dot(n,-beam_source+s,2),size(s2,1),1)./dot(repmat(n,size(s2,1),1),reshape(repmat(s2,1,size(n,1))',3,size(n,1)*size(s2,1))'-beam_source,2);
t = reshape(t,size(n,1),size(s2,1));
idx = max(t > 0 & t< 1); % Falls es ein Dreieck gibt, für welches die Geradengleichung keinen Schnittpunkt für 0< t <1 ergibt, dann ist dieses Sichtbar
intersect(~idx)= 0;
t = t(:,idx);
s2 = s2(idx,:);

% Grundidee:
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
% Löse für jeden Block das lineare Ausgleichsproblem A'Ax = A'b
% 

n = size(elem,1);
m = size(s2,1);

idx01= t>0 & t<1; % Nur 0<t<1 relevant
t = t(idx01); 
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
b = b(mamp,:)+d;


%Löse Gleichungssystem
a1 = coord(:,elem(:,2))'-coord(:,elem(:,1))';
a2 = coord(:,elem(:,3))'-coord(:,elem(:,1))';
n_a1 = vecnorm(a1,2,2).^2;
n_a2 = vecnorm(a2,2,2).^2;

a1 = a1(mamp,:);
a2 = a2(mamp,:);
n_a1 = n_a1(mamp,:);
n_a2 = n_a2(mamp,:);


a1tb = sum(a1.*b,2);


a2tb = sum(a2.*b,2);


a1ta2 = sum(a1.*a2,2);

koeff = 1./(n_a1.*n_a2-a1ta2.^2);
sol01 = koeff.*(n_a2.*a1tb-a1ta2.*a2tb);
sol02 = koeff.*(-a1ta2.*a1tb+n_a1.*a2tb);


% Überprüfe Lösung auf hinreichende Lösungen
sol01(sol01 < 0) = NaN;
sol02(sol02 < 0) = NaN; 
sol = sol01+sol02;
sol(sol>1)=NaN;
beef = 2*ones(size(idx01));
beef(idx01) = sol;
beef(beef==2) = NaN;
intersect(idx) = max(~isnan(beef)) ; 
end