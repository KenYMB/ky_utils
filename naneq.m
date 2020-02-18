function Eq = naneq(A,B,varargin)
%NANEQ Equality, considering NaNs and Empties.
% EQ = NANEQ(A, B)
%  is similar to 
%  A == B
% 
% EQ = NANEQ(A, B, 'nan', 0, 'empty', 0)
%  treat NaN pair and empty pair as different (return '0')
% 
% See also, ISEQUALN

% Dependency: cellfind

% 20160823 Yuasa

    assert(min(size(A)==size(B)), 'Dimensions of input matrixes must be same');
    
    %-- option
    nancount = chkopt(varargin,'nan',true);
    empcount = chkopt(varargin,'empty',true);
    
    %-- find NaNs
    nan1 = isnan(A);
    nan2 = isnan(B);
    nanidx = or(nan1,nan2);
    
    %-- find empty
    emp1 = isempty(A);
    emp2 = isempty(B);
    empidx = or(emp1,emp2);
    
    Eq = zeros(size(A));
    %-- if NaNs are paired
    if nancount,    Eq(nanidx) = nan1(nanidx) == nan2(nanidx);
    else            Eq(nanidx) = false;
    end
    %-- if empties are paired
    if empcount,    Eq(empidx) = emp1(empidx) == emp2(empidx);
    else            Eq(empidx) = false;
    end
    %-- normal 'eq'
    filidx = and(~nanidx, ~empidx);
    Eq(filidx) = A(filidx) == B(filidx);
end

function opt = chkopt(options, target, default)
% work on function(..., 'target',opt,...)
% find target option and return 'opt'
% if there is not target, then return 'default'

    opt  = cellfind(options,target);
    if ~isempty(opt) && opt(1)~=length(options)
        opt = options{opt(1)+1};
    else
        opt = default;
    end
end