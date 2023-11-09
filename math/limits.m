function output = limits(inputs,minL,maxL)

% output = LIMITS(inputs,min,max)
% 
%   apply upper and lower limits on input components
% 
%   inputs      : input values (scalar, vector, matrix)
%   min         : lower limits
%   max         : upper limits
%                 same size as inputs or scalar

% 2016/06/28 Yuasa

narginchk(3,3);

limcheck = true;
if isempty(minL),    minL = inputs;  limcheck = false;     end
if isempty(maxL),    maxL = inputs;  limcheck = false;     end

inpdim = ndims(inputs);
dimerror = 'size of input vaiables mismatch!';
assert((ndims(minL) <= inpdim) && (ndims(maxL) <= inpdim),dimerror);
if numel(minL) == 1
    minL = repmat(minL,size(inputs));
else
    limelements = size(minL);
    for icheck = 1:inpdim
        if limelements(icheck) == 1
            repvec = ones(1,inpdim);
            repvec(icheck) = size(inputs,icheck);
            minL = repmat(minL,repvec);
        else
            assert(limelements(icheck) == size(inputs,icheck),dimerror);
        end
    end
end
if numel(maxL) == 1
    maxL = repmat(maxL,size(inputs));
else
    limelements = size(maxL);
    for icheck = 1:inpdim
        if limelements(icheck) == 1
            repvec = ones(1,inpdim);
            repvec(icheck) = size(inputs,icheck);
            maxL = repmat(maxL,repvec);
        else
            assert(limelements(icheck) == size(inputs,icheck),dimerror);
        end
    end
end

if limcheck
    assert(min(minL(:) <= maxL(:)), 'lower limit is larger than upper limit!');
end
    

output = max(min(inputs, maxL), minL);