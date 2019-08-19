function y = meanelement(x,dim,flag,flag2)

% M = MEANELEMENT(A)
% M = MEANELEMENT(A,dim)
%   MEANELEMENT returns the mean of the each adjoining element.
% 
% see also: mean

% 20190410 Yuasa

isDimSet = nargin > 1 && ~ischar(dim);
isFlag2Set = nargin >= 4;

if nargin == 1 || (nargin == 2 && isDimSet)
    
    flag = 'default';
    omitnan = false;
    
else % nargin >= 3 || (nargin == 2 && ~isDimSet)
        
    if nargin == 2
        flag = dim;
    elseif nargin == 3
        if ~isDimSet
            flag2 = dim;
            isFlag2Set = true;
        end
    elseif nargin == 4 && ~isDimSet
        error(message('MATLAB:mean:nonNumericSecondInput'));
    end
    
    if ~isFlag2Set
        flag2 = '';
    end
    
    [flag, omitnan] = parseInputs(flag, flag2, isFlag2Set);
        
end

if ~isDimSet
    % preserve backward compatibility with 0x0 empty
    if isequal(x,[])
        y = [];
        return
    end
    
    dim = find(size(x)~=1,1);
    if isempty(dim), dim = 1; end
end

%-- construct new matrix
setelmnt1 = '';  setelmnt2 = '';
for idim = 1:ndims(x)
    if idim == dim
        setelmnt1 = [setelmnt1, '1:(end-1),'];
        setelmnt2 = [setelmnt2, '2:end,'];
    else
        setelmnt1 = [setelmnt1, ':,'];
        setelmnt2 = [setelmnt2, ':,'];
    end
end
setelmnt1(end) = [];  setelmnt2(end) = [];
eval(sprintf('x1 = x(%s);',setelmnt1));
eval(sprintf('x2 = x(%s);',setelmnt2));

%-- update 'x' & 'dim'
dim = max(ndims(x),dim)+1;
x   = cat(dim,x1,x2);

if ~isobject(x) && isinteger(x) 
    isnative = (lower(flag(1)) == 'n');
    if intmin(class(x)) == 0  % unsigned integers
        y = sum(x,dim,flag);
        if (isnative && all(y(:) < intmax(class(x)))) || ...
                (~isnative && all(y(:) <= flintmax))
            % no precision lost, can use the sum result
            y = y/size(x,dim);
        else  % throw away and recompute
            y = intmean(x,dim,isnative);
        end
    else  % signed integers
        ypos = sum(max(x,0),dim,flag);
        yneg = sum(min(x,0),dim,flag);
        if (isnative && all(ypos(:) < intmax(class(x))) && ...
                all(yneg(:) > intmin(class(x)))) || ...
                (~isnative && all(ypos(:) <= flintmax) && ...
                all(yneg(:) >= -flintmax))
            % no precision lost, can use the sum result
            y = (ypos+yneg)/size(x,dim);
        else  % throw away and recompute
            y = intmean(x,dim,isnative);
        end
    end
else
    if omitnan
        
        % Compute sum and number of NaNs
        m = sum(x, dim, flag, 'omitnan');
        nr_nonnan = size(x, dim) - matlab.internal.math.countnan(x, dim);
        
        % Divide by the number of non-NaNs.
        y = m ./ nr_nonnan;
    else
        y = sum(x, dim, flag)/size(x,dim);
    end
end
    
end


function y = intmean(x, dim, isnative)
% compute the mean of integer vector

shift = [dim:ndims(x),1:dim-1];
x = permute(x,shift);

xclass = class(x);
if ~isnative
    outclass = 'double';
else
    outclass = xclass;
end

if intmin(xclass) == 0
    accumclass = 'uint64';
else
    accumclass = 'int64';
end
xsiz = size(x);
xlen = cast(xsiz(1),accumclass);

y = zeros([1 xsiz(2:end)],outclass);
ncolumns = prod(xsiz(2:end));
int64input = isa(x,'uint64') || isa(x,'int64');

for iter = 1:ncolumns
    xcol = cast(x(:,iter),accumclass);
    if int64input
        xr = rem(xcol,xlen);
        ya = sum((xcol-xr)./xlen,1,'native');
        xcol = xr;
    else
        ya = zeros(accumclass);
    end
    xcs = cumsum(xcol);
    ind = find(xcs == intmax(accumclass) | (xcs == intmin(accumclass) & (xcs < 0)) , 1);
    
    while (~isempty(ind))
        remain = rem(xcs(ind-1),xlen);
        ya = ya + (xcs(ind-1) - remain)./xlen;
        xcol = [remain; xcol(ind:end)];
        xcs = cumsum(xcol);
        ind = find(xcs == intmax(accumclass) | (xcs == intmin(accumclass) & (xcs < 0)), 1);
    end
    
    if ~isnative
        remain = rem(xcs(end),xlen);
        ya = ya + (xcs(end) - remain)./xlen;
        % The latter two conversions to double never lose precision as
        % values are less than FLINTMAX. The first conversion may lose
        % precision.
        y(iter) = double(ya) + double(remain)./double(xlen);
    else
        y(iter) = cast(ya + xcs(end) ./ xlen, outclass);
    end
end
y = ipermute(y,shift);

end


function [flag, omitnan] = parseInputs(flag, flag2, isFlag2Set)
% Process flags, return boolean omitnan and string flag

    if ~isrow(flag)
        error(message('MATLAB:mean:invalidFlags'));
    end
    s = strncmpi(flag, {'omitnan', 'includenan'}, max(length(flag), 1));
    
    if ~isFlag2Set
        omitnan = s(1);
        if any(s)
           flag = 'default';
        end
    else
        if ~isrow(flag2)
            error(message('MATLAB:mean:invalidFlags'));
        end
        s2 = strncmpi(flag2, {'omitnan', 'includenan'}, max(length(flag2), 1));
        
        % Make sure one flag is from the set {'omitnan', 'includenan'},
        % while the other is from {'default', 'double', 'native'}.        
        if ~xor( any(s), any(s2) )
            error(message('MATLAB:mean:invalidFlags'));
        end
        
        if any(s) % flag contains 'includenan' or 'omitnan'
            omitnan = s(1);
            flag = flag2;
        else
            omitnan = s2(1);
        end
    end
end