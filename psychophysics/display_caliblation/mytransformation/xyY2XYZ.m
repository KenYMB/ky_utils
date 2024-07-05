function XYZ=xyY2XYZ(xyY)

% Converts CIE1931 xyY to XYZ tristimulus values.
% fucntion XYZ=xyY2XYZ(xyY)
% (: is optional)
%
% Compute tristimulus coordinates from
% chromaticity and luminance.
%
% [input]
% xyY : CIE1931 xyY values, [3 x n] matrix
% flares : zero-level xyY (light leaks), 3xn matrix, flares=repmat([x;y;Y],1,size(myxyY,2));
%
% [output]
% XYZ : XYZ values, [3 x n] matrix
%
%
% Created    : "2012-04-09 20:49:52 ban"
% Last Update: "2013-12-11 22:09:50 ban"
% change flare: "2016-06-27 yuasa"

XYZ=zeros(size(xyY));
for i=1:1:size(XYZ,2)
  z=1-xyY(1,i)-xyY(2,i);
  XYZ(1,i)=xyY(3,i)*xyY(1,i)/xyY(2,i);
  XYZ(2,i)=xyY(3,i);
  XYZ(3,i)=xyY(3,i)*z/xyY(2,i);
end

return
