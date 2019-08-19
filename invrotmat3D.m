function [ax, th] = invrotmat3D(rot)

% Rodrigues' rotation formula
% 
% Usage:
%   [axis, theta] = invrotmat3D(rot)
% 
%       rot:    3D rotation matrix or translation matrix
%       axis:   rotation axis  [1x3 unit vector]
%       theta:  rotation angle [rad]
% 
% See also: rotmat3D

% Using: isorth

% 20180329 Yuasa
% 20180523 Yuasa: minor fix for irregular

narginchk(1,1);
if numel(rot)==16
    rot = reshape(rot,4,4);
    %-- pick up rotation matrix from translation matrix
    if all(rot(4,:)==[0 0 0 1]),   rot = rot(1:3,1:3);   end
end
assert(numel(rot)==9, 'rotation matrix is invalid');

%-- rotation matrix
rot = reshape(rot,3,3);
rot = rot/norm(rot);
ax  = zeros(1,3);
if ~isorth(rot,0,1)
    warning('rotation matrix is invalid');
end

%-- estimate cos(theta) using Rodrigues
costh = [(rot(2,1)-rot(1,2)).*(rot(1,3)-rot(3,1))./(rot(3,2)+rot(2,3))/2 - 1, ...       % rot(3,2)+rot(2,3) ~= 0
         (rot(3,2)-rot(2,3)).*(rot(2,1)-rot(1,2))./(rot(1,3)+rot(3,1))/2 - 1, ...       % rot(1,3)+rot(3,1) ~= 0
         (rot(1,3)-rot(3,1)).*(rot(3,2)-rot(2,3))./(rot(2,1)+rot(1,2))/2 - 1];          % rot(2,1)+rot(1,2) ~= 0
costh(isinf(costh))=nan;
costh = nanmean(costh);
if isnan(costh)
  if rot(3,2)-rot(2,3) ~= 0                     % rotate around x-axis
    costh = (rot(2,2)+rot(3,3))/2;
  elseif rot(1,3)-rot(3,1) ~= 0                 % rotate around y-axis
    costh = (rot(3,3)+rot(1,1))/2;
  elseif rot(2,1)-rot(1,2) ~= 0                 % rotate around z-axis
    costh = (rot(1,1)+rot(2,2))/2;
  else                                          % no rotation
    costh = 1;
  end
end
costh(abs(costh)<=eps)=0;
costh((abs(costh)-1)<=eps & (abs(costh)-1)>0)=sign(costh);
th    = acos(costh);

%-- estimate axis (rotation axis don't exist for no rotation)
if th ~= 0
  %-- axis.^2
  ax = (diag(rot)'-costh)./(1-costh);
  ax(abs(ax)<=sqrt(eps))=0;
  
  %-- determin sign of axis
  isneg = [(rot(1,3)+rot(3,1)<0) * (rot(2,1)+rot(1,2)<0), ...
           (rot(2,1)+rot(1,2)<0) * (rot(3,2)+rot(2,3)<0), ...
           (rot(3,2)+rot(2,3)<0) * (rot(1,3)+rot(3,1)<0)];
  ax    = sqrt(ax) .* (-1).^isneg;
  
  %-- check rotation angle and axis
  if abs(costh-1)<=1e-5 || ~isreal(ax) || abs(norm(ax)-1)>1e-2
      warning('Low accuracy of computation');
  end
  
  %-- determin sign of theta
  sinth = [(rot(3,2)-rot(2,3))/ax(1)/2, ...         % ax(1)~=0
           (rot(1,3)-rot(3,1))/ax(2)/2, ...         % ax(2)~=0
           (rot(2,1)-rot(1,2))/ax(3)/2];            % ax(3)~=0
  if isreal(rot), sinth(real(ax)==0) = nan;
  else            sinth(norm(ax)==0) = nan;
  end
  sinth = nanmean(sinth);
  if isnan(sinth),  sinth = 0;  end
  if asin(sinth) < 0
      th = -th;
  end
  
  %-- update axis (avoid complex value)
  ax = [(rot(3,2)-rot(2,3))/2, ...
       (rot(1,3)-rot(3,1))/2, ...
       (rot(2,1)-rot(1,2))/2] ./ sin(th);
  
end