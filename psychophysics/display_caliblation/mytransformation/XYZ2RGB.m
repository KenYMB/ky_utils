function RGB=XYZ2RGB(XYZ,phosphorXYZ, flaresXYZ)

% Converts XYZ tristimulus values to RGB video inputs.
% function RGB=XYZ2RGB(XYZ,phosphorXYZ, flaresXYZ)
%
% Compute phosphor coodinates RGB(0 - 1) from XYZ.
%
% [input]
% XYZ         : XYZ values, [3 x n] matrix
% phosphorXYZ : a 3 by 3 matrix. Each column is
%               tristimulus coordinates of a phosphor:
%               [RX GX BX;RY GY BY; RZ GZ BZ]
%
% [output]
% RGB        : RGB values, [3 x n] matrix
%
%
% Created    : "2012-04-09 20:51:42 ban"
% Last Update: "2013-12-11 22:08:13 ban"
% change flare: "2016-06-27 yuasa"

if nargin<3, flaresXYZ=[]; end

if ~isempty(flaresXYZ) && (size(XYZ,1)~=size(flaresXYZ,1))
  error('sizes of XYZ and flaresXYZ mismatch. check input variable.');
end

% subtract flares
if ~isempty(flaresXYZ)
  XYZ=XYZ-repmat(flaresXYZ,1,size(XYZ,2));
  phosphorXYZ=phosphorXYZ-repmat(flaresXYZ,1,size(phosphorXYZ,2));
end

RGB=phosphorXYZ\XYZ;

return
