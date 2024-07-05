function V = rounddeci(inp,deci)

% ROUNDDECI(INPUT,DECIMAL) round the INPUT to nearest decimal.
% 
% output = decimal .* round(input ./ decimal);
% 
% Example:
%   rounddeci(pi, 0.01) outputs '3.14'.
%   rounddeci(2^14, 1e3) outputs '16e3'.

% 20161220 Yuasa: create

V = deci .* round(inp ./ deci);