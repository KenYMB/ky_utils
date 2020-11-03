function    sethistzero(h,BinWidth)
% SETHISTZERO(h)
% SETHISTZERO(h,BinWidth)
%   adjust axis limits of histogram so that no bin is placed over zero.
%   Not appicable for bivariate histograms.

% 201103: Yuasa

narginchk(1,inf);
assert(isgraphics(h,'histogram'), 'h must be a hundle of histogram');

if nargin > 1
    roundunit = BinWidth;
else
    roundunit = h.BinWidth;
end
hA   = h.Parent;
llul = hA.XLim;
ll   = floor(min(llul)/roundunit)*roundunit;
ul   = ceil(max(llul)/roundunit)*roundunit;
hA.XLim = [ll ul];
h.BinWidth = roundunit;

