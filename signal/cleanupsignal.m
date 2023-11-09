function odata = cleanupsignal(idata,r,varargin)

% CS = EASYFILT(RS,R,[N=8])
%   cleans up the input signal using an N'th order Chebyshev Type I lowpass
%   filter with cutoff frequency .8*(Fs/2)/R. In default, 8th order filter
%   is selected.
% 
% CS = EASYFILT(RS,R,N,dim)
%   decimates signal matrix RS along dim'th dimension.
% 
% See also DECIMATE_COL, DECIMATE, CHEBY1.

%   Author(s): L. Shure, 6-4-87
%              L. Shure, 12-11-88, revised
%   Copyright 1988-2018 The MathWorks, Inc.

%   References:
%    [1] "Programs for Digital Signal Processing", IEEE Press
%         John Wiley & Sons, 1979, Chap. 8.3.

% 20231108 Yuasa: modified from DECIMATE_COL based on DECIMATE


narginchk(2,6);
nargoutchk(0,1);

%-- Validate required inputs 
validateinput(idata,r);

if fix(r) == 1
    odata = idata;
    return
end

varargin = cellfun(@convertStringsToChars,varargin,'UniformOutput',false);

%--- Setup character options
ischaropt = cellfun(@(v) ischar(v),varargin);
charopts  = lower(varargin(ischaropt));
omitnan   = ismember('omitnan',charopts);
nfilt     = charopts(~ismember(charopts,{'omitnan','includenan'}));
assert(length(nfilt)<=1, 'Invalid option. Nanflag must be ''omitnan'' or ''includenan''.');
nfilt     = cell2mat(nfilt);
if isempty(nfilt) || ( nfilt(1) == 'i' || nfilt(1) == 'I' )
    fopt  = 1;
elseif ( nfilt(1) == 'f' || nfilt(1) == 'F' )
    fopt  = 0;
else
    error(message('signal:decimate:InvalidEnum'))
end

%--- Setup other options
[nfilt,dim] = parseInputs(varargin{~ischaropt});
if nargin > 2 && isempty(dim) && ischaropt(1)
    dim   = nfilt;
    nfilt = [];
end
if isempty(nfilt)
    nfilt = 8*fopt + 30*(1-fopt);
end
empdim = isempty(dim);
if empdim
    if isrow(idata) 	% row data
        dim = 2;
    else
        dim  = 1;
    end
elseif strcmpi(dim,'all')
    dim  = 1:ndims(idata);
end
if fopt == 1 && nfilt > 13
    warning(message('signal:decimate:highorderIIRs'));
end

if isscalar(dim)  % main process
fulldim = max(ndims(idata),dim);
if omitnan
    idata = fillmissing(idata,'pchip',dim);
end
idata  = permute(idata,[dim setdiff(1:fulldim,dim)]);
datsiz = size(idata);
nd = datsiz(1);
nout = nd;
idata = reshape(idata,nd,[]);
nancol = all(isnan(idata),1);
idata(:,nancol) = 0;

if fopt == 0	% FIR filter
    b = fir1(nfilt,1/r);
    % prepend sequence with mirror image of first points so that transients
    % can be eliminated. then do same thing at right end of data sequence.
    nfilt = nfilt+1;
    itemp = 2*idata(1,:) - idata((nfilt+1):-1:2,:);
    [itemp,zi]=filter(b,1,itemp); %#ok
    [odata,zf] = filter(b,1,idata,zi);
    itemp = 2*idata(nd,:)-idata((nd-1):-1:(nd-2*nfilt),:);
    itemp = filter(b,1,itemp,zf);
    % finally, select only every r'th point from the interior of the lowpass
    % filtered sequence
    gd = grpdelay(b,1,8);
    list = round(gd(1)+1.25):nd;
    odata = odata(list,:);
    lod = length(list);
    nlen = nout - lod;
    nbeg = 1 - (nd - list(length(list)));
    odata = [odata; itemp(nbeg:nbeg+nlen-1,:)];
else	% IIR filter
    rip = .05;	% passband ripple in dB
    [b,a] = cheby1(nfilt, rip, .8/r);
    while all(b==0) || (abs(filtmag_db(b,a,.8/r)+rip)>1e-6)
        nfilt = nfilt - 1;
        if nfilt == 0
            break
        end
        [b,a] = cheby1(nfilt, rip, .8/r);
    end
    if nfilt == 0
        error(message('signal:decimate:InvalidRange'))
    end

    % be sure to filter in both directions to make sure the filtered data has zero phase
    % make a data vector properly pre- and ap- pended to filter forwards and back
    % so end effects can be obliterated.
    odata = filtfilt(b,a,idata);
end
odata(:,nancol) = nan;
odata = permute(reshape(odata,[size(odata,1),datsiz(2:end)]),[2:dim,1,(dim+1):fulldim]);

else  % loop for dimenstions
odata = idata;
if fopt,    option  = 'IIR';
else,       option  = 'FIR';
end
if omitnan, nanflag = 'omitnan';
else,       nanflag = 'includenan';
end
for idim = reshape(dim,1,[])
    odata = decimate_col(odata,r,nfilt,option,idim,nanflag);
end
end

%--------------------------------------------------------------------------
function H = filtmag_db(b,a,f)
%FILTMAG_DB Find filter's magnitude response in decibels at given frequency.

nb = length(b);
na = length(a);
top = exp(-1i*(0:nb-1)*pi*f)*b(:);
bot = exp(-1i*(0:na-1)*pi*f)*a(:);

H = 20*log10(abs(top/bot));

%--------------------------------------------------------------------------
function validateinput(x,r)
% Validate 1st two input args: signal and decimation factor

if isempty(x) || issparse(x) || ~isa(x,'double')
    error(message('signal:decimate:invalidInput', 'X'));
end

if (abs(r-fix(r)) > eps) || (r <= 0)
    error(message('signal:decimate:invalidR', 'R'));
end

%--------------------------------------------------------------------------
function varargout = parseInputs(varargin)
narginchk(0,nargout);
%-- passthrough inputs 
varargout = cell(1,nargout);
varargout(1:min(nargout,nargin)) = varargin(1:min(nargout,nargin));

