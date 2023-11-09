function    V = nearestpoint(Points)
% NP = NEARESTPOINT(Points)
% 
% NEARESTPOINT computes a center location where the total distance from
% all input points is minimum. Points is NxM array with N input point in
% M-dimension coordinate.

% 20181211 Yuasa

assert(ismatrix(Points), 'Input data must be matrix.');

[nP, dim]  = size(Points);

repNitr   = ceil(min(10^dim, 5e3));
itrPoints = repmat(Points,[1,1,repNitr]);

preNitr  = max(1,ceil(3e3 / repNitr));
mainNitr = max(10,ceil(6e4 / repNitr));
postNitr = max(3,ceil(2e4 / repNitr));
preSR    = max(var(Points,1))/1e2;
mainSR   = min(var(Points,1))/1e3;
postSR   = min(var(Points,1))/2e4;

V    = mean(Points,1);
dist = sum(sqrt(sum(abs(Points - repmat(V,nP,1)).^2,2)),1);

for ilp=1:preNitr
    V1    = repmat(V,[1,1,repNitr]) + (fix(rand([size(V),repNitr])*13)-6)/2 * preSR;
    dist1 = sum(sqrt(sum(abs(itrPoints - repmat(V1,nP,1)).^2,2)),1);
    idx1  = find(dist1==min(dist1(:)),1);
    if dist1(idx1) < dist
        dist = dist1(idx1);
        V    = V1(:,:,idx1);
    end
end
for ilp=1:mainNitr
    V1    = repmat(V,[1,1,repNitr]) + (fix(rand([size(V),repNitr])*21)-10)/5 * mainSR;
    dist1 = sum(sqrt(sum(abs(itrPoints - repmat(V1,nP,1)).^2,2)),1);
    idx1  = find(dist1==min(dist1(:)),1);
    if dist1(idx1) < dist
        dist = dist1(idx1);
        V    = V1(:,:,idx1);
    end
end
for ilp=1:postNitr
    V1    = repmat(V,[1,1,repNitr]) + (fix(rand([size(V),repNitr])*11)-5)/5 * postSR;
    dist1 = sum(sqrt(sum(abs(itrPoints - repmat(V1,nP,1)).^2,2)),1);
    idx1  = find(dist1==min(dist1(:)),1);
    if dist1(idx1) < dist
        dist = dist1(idx1);
        V    = V1(:,:,idx1);
    end
end


