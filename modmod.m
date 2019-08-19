function yy = modmod(xx,mm)

% MODMOD   modulo operation
% 
%   y = MODMOD(x,m)
% 
%   This function outputs 'm' instead of '0',
%   when mod(x,m) = 0.
% 

%  2016/02/03 Yuasa @MATLAB2014b
%  2016/05/25 Bug fix

yy = mod(xx,mm);
yy(yy == 0) = mm;