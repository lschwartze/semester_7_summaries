function [r,c,s] = givens(a1)
%Pa2 = a2(:,2:3) - beta.*sum(w(:,2:3).*a2(:,2:3),2).*w(:,2:3);
n = size(a1,1);
c = zeros(n,1);
s = ones(n,1);
r = c;


%r = vecnorm(sa1,2,2);

idx01 = a1(:,1) ~=0;
idx02 = a1(:,2) ==0;
idx = idx01 & ~idx02;

c(idx02)=1;
s(idx02)=0;


r(idx02)= a1(idx02,1);
r(~idx01) = -a1(~idx01,2);
%r(idx) = vecnorm(sa1(idx),2,2);
tmp = vecnorm(a1(idx,:),2,2);

a1= a1(idx,:);
p = a1(:,1);
q = a1(:,2);


c(idx) = abs(p)./tmp;
s(idx) = -sign(p).*q./tmp; 
r(idx) = sign(a1(:,1)).*tmp;

end