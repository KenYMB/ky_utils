function outp = normalizeV(inp)

% outp = NORMALIZEV(inp)
% 
%   inp/sum(inp)

% 20160803 Yuasa

outp = inp ./ sum(inp(:));