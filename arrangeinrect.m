function [nx,ny,nrate] = arrangeinrect(num,bestrate,allowrate,strict)

% ARRANGEINRECT gives x and y length to arrange N items in a rectangle.
% If 'strict' is set, this function outputs error when appropriate x,y pair
% is not found. Otherwise, this function run through even if the rate of
% x/y is out of the range between best_rate and allow_rate.
% 
% Usage: 
%   [x,y]     = arrangeinrect(N,best_rate,allow_rate)
%   [x,y,x/y] = arrangeinrect(N,best_rate,allow_rate,'strict')
% 
% Inputs: 
%   N:          vector, numbers of items to arrange
%   best_rate:  number, desired rate of x/y (default=1.0)
%   allow_rate: [min max], the rate of x/y between the numbers of allow_rate
%               is adopted preferentially (default=[best_rate 2.0])

% 20170330 Yuasa
% 20190423 Yuasa: change usage of allow_rate

%-- set parameters
assert(nargin>=1,message('MATLAB:minrhs'));
if nargin>=4 && strcmp(strict,'strict')
    isstrict = true;
else
    isstrict = false;
end
if nargin<2 || isempty(bestrate),
    bestrate = 1.0;
elseif isnumeric(bestrate)
    bestrate = bestrate(1);
elseif ischar(bestrate) && strcmp(strict,'strict')
    isstrict = true;
    bestrate = 1.0;
else
    error('MATLAB:arrangeinrect:nonNumericInput','''bestrate'' must be a number')
end
if nargin<3 || isempty(allowrate),
    allowrate = [bestrate 2.0];
elseif isnumeric(allowrate)
    if numel(allowrate)<2
        allowrate = [bestrate allowrate];
    else
        allowrate = reshape(allowrate(1:2),1,[]);
    end
elseif ischar(allowrate) && strcmp(strict,'strict')
    isstrict = true;
    allowrate = [bestrate 2.0];
else
    error('MATLAB:arrangeinrect:nonNumericInput','''allowrate'' must be a number')
end

nx    = zeros(numel(num),1);
ny    = nx;     nrate    = nx;

dirc  = 2*(diff(allowrate)>=0)-1;

try
curwarn = warning('off','backtrace');

for ilp=1:numel(num)

    begnx   = max(1,round(sqrt(num(ilp)*allowrate(1)))-dirc);
    endnx   = max(1,round(sqrt(num(ilp)*allowrate(2)))+dirc);

    %-- get mod list
    listnx   = reshape(begnx:dirc:endnx,[],1);
    listny   = ceil(num(ilp)./listnx);
      [listny,listidx]   = unique(listny,'stable');
      if dirc == -1,    listidx  = [reshape(listidx(2:end)-1,1,[]) length(listnx)];   end
      listnx    = listnx(listidx);
    listrate = listnx./listny;
    valididx = listrate>=min(allowrate)&listrate<=max(allowrate);
    if ~isempty(find(valididx, 1))
        listnx(~valididx)   = [];
        listny(~valididx)   = [];
        listrate(~valididx) = [];
        listmod  = mod(num(ilp),listny);
        
        if bestrate>=min(allowrate)&&bestrate<=max(allowrate)
            %-- test output values
            if min(listmod)==0
                bestidx = find(listmod==0,1);
            elseif max(listmod./listny)>=0.5
                bestidx = find((listmod./listny)>=0.5,1);
            else
                bestidx = 1;
            end
        else
            warning('best_rate (%g) is out of allow_rate ([%g %g])',bestrate,allowrate);
            %-- get nearest x/y rate pair
            diffrate = abs(listrate-bestrate);
            bestidx = find(diffrate == min(diffrate),1);
        end
    elseif isstrict
        error_backtraceoff(sprintf('Indicated limitation of rate is too strict (i=%d num=%d)',ilp,num(ilp)));
    else
        warning('allow_rate ([%g %g]) is too strict (i=%d num=%d)',allowrate,ilp,num(ilp));
        %-- get nearest x/y rate pair
        diffrate = abs(listrate-bestrate);
        bestidx = find(diffrate == min(diffrate),1);
    end
    nx(ilp)     = listnx(bestidx);
    ny(ilp)     = listny(bestidx);
    nrate(ilp)  = listrate(bestidx);
end

if nargout < 2
    nx = [nx ny];
end

warning(curwarn);
catch ME
    warning(curwarn);
    rethrow(ME);
end
