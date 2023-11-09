function datamat = replelement(datamat, idx, vals)

% B = REPLELEMENT(A,idx,p)
%   replaces elements in the matrix A indicated by the indices in idx with
%   the value p. The p should be a scalar or a vector with the same length
%   as A(idx). 
% 
%   If p is empty, elements at the specified indices are removed, and the
%   size of the output matrix B may differ from the input matrix A.
% 
%   This function is equivalent to the following operation:
%       B = A;
%       B(idx) = p;
% 
%   Example:
%       A = randn(3,4);
%       p = 0;    idx = A<p;
%       B = A;    B(idx) = p;
%       isequal(B, replelement(A,idx,p))
% 
% See also NANFILL.

% 20200129 Yuasa

narginchk(3,3);
assert( (numel(vals)<=1) || ...
        (islogical(idx) && sum(idx(:)) == numel(vals)) || ...
        (numel(idx) == numel(vals)), ...
    'The size of p is invalid' );

if isempty(vals)
    datamat(idx) = [];
else
    datamat(idx) = vals;
end