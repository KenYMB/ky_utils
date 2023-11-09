function t = readtablestr(filename,varargin)
%READTABLESTR creates table from file.
%   All input data are regarded as strings (or numbers).
%   Default format is strings.
%   If 'Format' is indicated, this function repeat the option.
% 
% See also: READTABLE

% 20160803 Yuasa

%-- read table and count number of columns
hdr      = readtable(filename);
ncolumn  = size(hdr,2);

%-- specify the location of Format option & default setting
idxFormat = cellfind(varargin,'Format');
if isempty(idxFormat)
    varargin = [varargin {'Format','%q'}];
    idxFormat = length(varargin);
else
    idxFormat = idxFormat + 1;
end

%-- repeat Format option
idxstrformats = strfind(varargin{idxFormat},'%');
nstrformats   = length(idxstrformats);
strformats    = repmat(varargin{idxFormat},1,ceil(ncolumn/nstrformats));

%-- reject over repeat options
idxstrformats = strfind(strformats,'%');
nstrformats   = length(idxstrformats);
if nstrformats > ncolumn
    idxcutformats = idxstrformats(ncolumn+1) - 1;
    strformats    = strformats(1:idxcutformats);
end
varargin{idxFormat} = strformats;

%-- readtable
readtableoptions = [];
for j = 1:length(varargin);
    readtableoptions = sprintf('%s, varargin{%d}',readtableoptions,j);
end
eval(['t = readtable(filename' readtableoptions ');']);
