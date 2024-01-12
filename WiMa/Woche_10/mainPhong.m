clc, clear, close all

% WS 23/24

%% Parameter fuer die Berechnung der Szene
geometry_resolution = 50; % Feinheit der Diskretisierung der Szene


%% Setze Parameter fuer Beleuchtung

lightingParameter = struct( ...
    'C', 1,        ... Konstante fuer Distanzfunktion
    'IA', 0.3,     ... Intensitaet des Umbegungslichts
    'IQ', 1.0,     ... Intensitaet der Lichtquelle
    'kappaA', 0.1, ... Reflexionsgrad fuer Ambiente Reflexion
    'kappaD', 0.9, ... Reflexionsgrad fuer Ideal Difuse Reflexion
    'kappaS', 0.5, ... Reflexionsgrad fuer Ideal Spiegelnde Reflexion
    'm', 5        ... Exponent, steuert Schaerfe der spegelnden Refl.
);  

%% Position des Auges des Betrachters

auge = [2,2,1];

%% Colormaps fuer alle Objekte (inkl. Lichtquelle) erstellen

% Cyan-map: Kugel
myMap{1} = [zeros(256,1),linspace(0,1,256)',linspace(0,1,256)'];
% Grau-map: Wände
myMap{2} = [linspace(0,1,256)',linspace(0,1,256)',linspace(0,1,256)'];
myMap{3} = [linspace(0,1,256)',linspace(0,1,256)',linspace(0,1,256)'];

%% Lade Szene
[coord, elem, coord2obj, elem2obj] = createScene(geometry_resolution);

% Plotte Ausgangs-Szene (nur das Gitter!)

plotGrid(coord,elem,elem2obj,auge)

%% Berechne s (Schwerpunkt),n (Normale) und area2 (2*Flaeche)

[s,n,area2] = getGeomParam(coord,elem);

% Plotte Ausgangs-Szene (Gitter inkl. Normalenvektoren)
plotGrid(coord,elem,elem2obj,auge,s,n)

%% Berechne Sichtbarkeit aller Dreiecke zueinander

tic
[vis, elem_vis] = getVisibilityBB(coord,elem,elem2obj,coord2obj,s,n);
toc

% Plotte Ausgangs-Szene (nur die sichtbaren Elemente)

% elem2obj is now useless, so we plug in a general thing instead.
plotGrid(coord,elem_vis,[1;2;length(elem_vis)+1],auge)
%% Lichtintensitaet fuer jedes Dreieck berechnen mit Phong

I = lightingPhong(elem2obj,auge,s,n,vis,lightingParameter);

% solange lightingPhong noch nicht implementiert ist, kann die Helligkeit I
% aller Dreiecke einfach auf 1 gesetzt werden

%% plotte Szenen
plotScene(coord, elem, elem2obj, coord2obj, myMap, I, auge)

%plotte interaktiv
interactive_Plot(coord,elem,elem2obj,I,auge,s,n,vis,lightingParameter,myMap)