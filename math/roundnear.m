function    outmat = roundnear(inpmat, roundlist, rtype)
% B = ROUNDNEAR(A, list, [rounrdtype])
%   B is a matrix of the same size as A.
%   The elements are replaced with the nearest values in the list.
% 
%   You can select rounrdtype from: 'round(default)', 'ceil', 'floor', 'fix'.
%   See also round, ceil, floor, fix.
%   

% 20170912 Yuasa

narginchk(2,3)
if nargin < 3
    rtype = 'round';
end

%-- for faster computation by saving memory
maxsize = 1e5;

%-- get input info
inpdim  = size(inpmat);
inpvec  = reshape(inpmat,[],1);
listvec = reshape(roundlist,1,[]);
ninp    = length(inpvec);
nlist   = length(listvec);

%-- loop for memory saving
outvec  = nan(ninp,1);
nloop   = ceil(ninp*nlist/maxsize);
inpblk  = floor(ninp/nloop);

for ilp=1:inpblk:ninp
    tmpvec  = inpvec(ilp:min(ilp+inpblk-1,ninp));
    ntmp    = length(tmpvec);
    inpmat = repmat(tmpvec,1,nlist);
    listmat = repmat(listvec, ntmp,1);

    %-- get distance
    distmat = inpmat - listmat;
    switch rtype
        case 'ceil'
            distmat(distmat>0) = distmat(distmat>0) + 2*max(abs(distmat(:)));
        case 'floor'
            distmat(distmat<0) = distmat(distmat<0) - 2*max(abs(distmat(:)));
        case 'fix'
            %-- floor for positive; ceil for negative
            distmat(distmat<0 & inpmat>0) = distmat(distmat<0 & inpmat>0) - 2*max(abs(distmat(:)));
            distmat(distmat>0 & inpmat<0) = distmat(distmat>0 & inpmat<0) - 2*max(abs(distmat(:)));
    end
    distmat = abs(distmat);
    hitmat  = distmat == repmat(min(distmat,[],2),1,nlist);
    
    %-- make output data
    listmat(~hitmat) = nan;
    outvec(ilp:(ilp+ntmp-1))  = max(listmat,[],2);
end

%-- make output matrix
outmat  = reshape(outvec, inpdim);
