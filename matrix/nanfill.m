function datamat = nanfill(datamat, idx)

% B = NANFILL(A,idx)
%   fills NaN values at the indices specified by idx in the matrix A.
%
%   This function is equivalent to the following operation:
%       B = A;
%       B(idx) = nan;
% 
% See also REPLELEMENT.

% 20231108 Yuasa

narginchk(2,2);

datamat(idx) = nan;