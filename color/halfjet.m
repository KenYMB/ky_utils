function J = halfjet(m)
%JET    Variant of HSV
%   HALFJET(M), a variant of HSV(M), is an M-by-3 matrix containing
%   the default colormap used by CONTOUR, SURF and PCOLOR.
%   The colors begin with green, range through shades of
%   yellow and red, and end with dark red.
%   HALFJET, by itself, is the same length as the current figure's
%   colormap. If no figure exists, MATLAB uses the length of the
%   default colormap.
%
%   See also JET, PARULA, HSV, HOT, PINK, FLAG, COLORMAP, RGBPLOT.

%   Copyright 1984-2015 The MathWorks, Inc.

%  20180828 Yuasa: modified from jet

if nargin < 1
   f = get(groot,'CurrentFigure');
   if isempty(f)
      m = size(get(groot,'DefaultFigureColormap'),1);
   else
      m = size(f.Colormap,1);
   end
end

n = ceil(m/4);
n2= 2*n;
u = [(1:1:n2)/n2 ones(1,n2-1) (n2:-1:1)/n2]';
g = -3*n2/2 + 1 + (1:length(u))';
r = g + n2;
b = g - n2;
g(g<1) = [];
r(r<1) = [];
r(r>m) = [];
b(b<1) = [];
J = zeros(m,3);
J(r,1) = u((1:length(r))+n-1);
J(g,2) = u(end-length(g)+1:end);
J(b,3) = u(end-length(b)+1:end);
