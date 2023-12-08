classdef spline_lens < general_lens
    properties
        Points
        kind  %'nat','compl' oder 'per' -- Randbedingungen
        param % Vektor mit zwei Einträgen spezifiziert die Randbedingung
        Coeffs %Koeffizienten der Splines
    end
    methods
        function obj = spline_lens(Points,kind,param,typ,eta_1,eta_2)
            if nargin == 4
                eta_1 = 1.00027717;
                eta_2 = 1.5168;            
            end
            sortMatrix = sortrows(Points',1)';
            obj = obj@general_lens(sortMatrix(:,1),sortMatrix(:,end),typ,eta_1,eta_2);
            obj.Points = sortMatrix(:,2:end-1);
            obj.kind = kind;
            obj.param = param(:);
            obj.Coeffs = obj.coeffSpline();
            obj.draw_lens()
        end
        
        function draw_lens(obj)
            if isequal(obj.typ,"wall")
                color = "k";
            elseif isequal(obj.typ,"mirror") || isequal(obj.typ,"fibre")
                color = "c";
            else
                color = "b";
            end
            obj.draw_points
            hold on
            % draws start and end point
            x = linspace(obj.start_point(1),obj.end_point(1),1000);
            y = obj.evalSpline(x);
            plot(x,y,"Color",color)
        end
            
        function coeff = coeffSpline(obj)
            allPoints = [obj.start_point, obj.Points, obj.end_point];
            t = allPoints(1,:);
            y = allPoints(2,:);
            t = t(:);
            y = y(:);

            % param(1,1)=f'(a) bzw. f''(a) (abhaengig von der Wahl von kind)
            % param(2,1)=f'(b) bzw. f''(b)
            n=length(t);
            % Berechnung des "Kerns" von A und b
            h1 = t(2:n)-t(1:n-1);
            h2 = t(3:end)-t(1:end-2);
            A = sparse(n,n);
            B = [h1,[2*h2;0],[h1(2:end);0]];
            A(2:n-1,:)=spdiags(B,[0,1,2],n-2,n);
            b = zeros(n,1);
            b(2:n-1)=6*((y(3:n)-y(2:n-1))./h1(2:n-1)-...
                (y(2:n-1)-y(1:n-2))./h1(1:n-2));
            % Erweiterung von A und b fuer unterschiedliche Randbedingungen
            switch obj.kind
                case 'nat'
                    A(1,1)=1; A(n,n)=1; b(1)=obj.param(1); b(end)=obj.param(2);
                case 'per'
                    if y(1) ~= y(end)
                        error('This data is not applicable for periodic splines')
                    end
                    A(1,[1,2,n-1])=[2*(h1(1)+h1(end)),h1(1),h1(end)];
                    A(n,[1,n])=[1,-1];
                    b(1)=6*((y(2)-y(1))/h1(1)-(y(1)-y(end-1))/h1(end));
                case 'compl' 
                    A(1,[1,2])=[2*h1(1),h1(1)];
                    A(n,[n-1,n])=[h1(end),2*h1(end)];
                    b(1)=6*((y(2)-y(1))/h1(1) - obj.param(1));
                    b(n)=-6*((y(end)-y(end-1))/h1(end) - obj.param(2));
                otherwise
                    error('This kind does not exist!')
            end
            % Berechnung der y''
            y2d=A\b;
            % Berechnung der Koeffizienten a,b,c,d
            coeff = [y(1:end-1),...
            (y(2:end)-y(1:end-1))./h1(1:end)-h1(1:end).*(y2d(2:end) + ...
            2*y2d(1:end-1))/6,y2d(1:end-1)/2,...
            (y2d(2:end)-y2d(1:end-1))./(6*h1(1:end)) ]';
        end

        function sfx = evalSpline(obj,x)
            allPoints = [obj.start_point, obj.Points, obj.end_point];
            t = (allPoints(1,:))';
            C = obj.Coeffs;
            % define output variable
            sfx = zeros(size(x));
        
            % all values shall be in the given interval
            if any(x < t(1))
                error('Alle Werte von x muessen >= %g sein', t(1))
            elseif any(x > t(end))
                error('Alle Werte von x muessen <= %g sein', t(end))
            end
        
            % evaluate spline
            for k = 1:length(t)-1       % evaluate each subinterval
                p   = C(:,k);           % coefficients on current subinterval 
        
                ind = find(x>=t(k) & x<=t(k+1));    % find all x-values in 
                                                    % current interval
                sfx(ind) = polyval(p(end:-1:1), x(ind)-t(k));     % evaluate for these x-values
            end   
        end

        function [p,normal,t] =  intersect(obj,light)
            %schreibe Lichtsrahl als Polynom -- Koeffizienten
            c = polyfit([double(light.source(1)),double(light.source(1))+double(light.direction(1))],[double(light.source(2)),double(light.source(2)+light.direction(2))],1);
            
            allPoints = [obj.start_point, obj.Points, obj.end_point];

            %Wie viele Punkte sind vorgegeben?
            n = size(allPoints,2);
            
            %Suche Nst:
            Nst = NaN*zeros(3,n-1);

            for k = 1:n-1       % evaluate each subinterval
                coeffs   = obj.Coeffs(:,k);
                coeffs(1) = coeffs(1)- c(2)-c(1)*allPoints(1,k);
                coeffs(2) = coeffs(2)-c(1);% coefficients on current subinterval 
                tmp_nst = roots(coeffs(end:-1:1));
                tmp_nst = tmp_nst(:)+allPoints(1,k);
                tmp_nst(real(tmp_nst) < allPoints(1,k) | real(tmp_nst) > allPoints(1,k+1)) = allPoints(1,1) -1;
                Nst(1:length(tmp_nst),k) = tmp_nst;
            end  
            nst = Nst(:);
            %betrachte nur relevante nst
            nst = nst(abs(imag(nst))<0.001);
            nst = nst(nst >= allPoints(1,1) & nst <= allPoints(1,end));
            
            %Vgl. Parameter t
            fnst = obj.evalSpline(nst);
            t_all = zeros(length(fnst),1);
            for i = 1:length(fnst)
                if light.direction(1) ~= 0
                    t_all(i) = (nst(i)-light.source(1))/light.direction(1);
                else
                    t_all(i) = (fnst(i)-light.source(2))/light.direction(2);
                end
            end
            if  isempty(t_all) || max(t_all)< 0.001 
                p = NaN;
                normal = NaN;
                t = NaN;
                return
            end
            [t,idx] = min(t_all(t_all>0.001));
            nst = nst(t_all >0.001);
            fnst = fnst(t_all >0.001);
            p = [nst(idx);fnst(idx)];
            %in welchem Abschnitt ist die gefundene Nst?
            idx02 = max(Nst == nst(idx));
            rel_coeffs = obj.Coeffs(:,idx02);
            %Ableitung
            dcoeff = polyder(rel_coeffs(end:-1:1));
            dfp = polyval(dcoeff,real(nst(idx))-allPoints(1,logical([idx02 0])));
            %Normale
            if dfp ~= 0
                normal = [1;-1/dfp];
                normal = normal/norm(normal);
            else
                normal = [0;1];
            end
        end
    end  
end