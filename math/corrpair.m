function [r,p,rlo,rup] = corrpair(varargin)
%corrpair 2-D pairwise correlation coefficient.
%   R = CORRPAIR(A,B) computes the correlation coefficient between A
%   and B, where A and B are matrices or vectors of the same size.
%   If A and B are matricies, CORRPAIR operates columnwise on the matricies, 
%   computes the correlation coefficient to each column.
% 
%   E = CORRPAIR(A,B,DIM) operates along the dimension DIM instead of column.
% 
%   [R,P]=CORRPAIR(...) also returns P, a matrix of p-values for testing
%   the hypothesis of no correlation.
% 
%   [R,P,RLO,RUP]=CORRPAIR(...) also returns matrices RLO and RUP, of
%   the same size as R, containing lower and upper bounds for a 95%
%   confidence interval for each coefficient.
%
%   Class Support
%   -------------
%   A and B can be numeric or logical. 
%   R is a vector or matrix double.
%
%   See also CORR2, CORRCOEF.

%   20190711 Yuasa

[a,b,dim] = ParseInputs(varargin{:});

a = bsxfun(@minus, a, mean(a,dim));
b = bsxfun(@minus, b, mean(b,dim));
r = squeeze(sum(a.*b,dim)./sqrt(sum(a.*a,dim).*sum(b.*b,dim)));

% Compute p-value if requested.
if nargout>=2
   % Operate on half of symmetric matrix.
   n = size(a,dim);

   % Tstat = +/-Inf and p = 0 if abs(r) == 1, NaN if r == NaN.
   Tstat = r .* sqrt((n-2) ./ (1 - r.^2));
   p = 2*tcdf(-abs(Tstat),n);

   % Compute confidence bound if requested.
   if nargout>=3
      alpha = 0.05;
      % Confidence bounds are degenerate if abs(r) = 1, NaN if r = NaN.
      z = 0.5 * log((1+r)./(1-r));
      zalpha = NaN(size(n),class(r));
      if n>3
         zalpha = (-erfinv(alpha - 1)) .* sqrt(2) ./ sqrt(n-3);
      end
      rlo = tanh(z-zalpha);
      rup = tanh(z+zalpha);
   end
end


%--------------------------------------------------------
function [A,B,DIM] = ParseInputs(varargin)

narginchk(2,3);

A = varargin{1};
B = varargin{2};
if nargin<3 || isempty(varargin{3}),    DIM = 1;
else,                                   DIM = varargin{3};
end

validateattributes(A, {'logical' 'numeric'}, {'real'}, mfilename, 'A', 1);
validateattributes(B, {'logical' 'numeric'}, {'real'}, mfilename, 'B', 2);
validateattributes(DIM, {'numeric'}, {'positive' 'scalar'}, mfilename, 'DIM', 3);

if any(size(A)~=size(B))
    error(message('images:corr2:notSameSize'))
end

if (~isa(A,'double'))
    A = double(A);
end

if (~isa(B,'double'))
    B = double(B);
end
