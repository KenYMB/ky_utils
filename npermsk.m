function outp = npermsk(inp,kval)

% NPERMSK(N,K)
% 
% calculate nPk
% N!/(N-K)!
% 
% NPERMSK(V,K)
% 
% show all Partial Permutation

% 20160524 Yuasa @MATLAB2013b


if length(inp)==1
    outp = factorial(inp) ./ factorial(inp - kval);
else
    inp = reshape(inp,1,[]);
    PP  = factorial(length(inp)) ./ factorial(length(inp) - kval);
    outp = zeros(PP,kval);
    
    inp_vec = 1:length(inp);
    
    WP = perms(inp_vec);
    WPs = sortrows(WP(:,1:kval));
    WPs = unique(WPs,'rows');
    
    outp = inp(WPs);
    
    assert(size(WPs,1)==PP,'Error!');
end
    
    