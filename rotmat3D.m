function rot = rotmat3D(ax, th)

% Rodrigues' rotation formula
% 
% Usage:
%   rot = rotmat3D(axis, theta)
% 
%       rot:    3D rotation matrix
%       axis:   rotation axis  [1x3 unit vector]
%       theta:  rotation angle [rad]
% 
% See also: invrotmat3D

% 20180329 Yuasa

narginchk(2,2);
assert(length(ax)==3 && numel(ax)==3, 'axis is invalid');

%-- unit vector
ax = ax./norm(ax);
th   = th(1);

%-- Rodrigues
rot = [cos(th) + ax(1)*ax(1)*(1-cos(th)),        ax(1)*ax(2)*(1-cos(th)) - ax(3)*sin(th),  ax(1)*ax(3)*(1-cos(th)) + ax(2)*sin(th);
       ax(2)*ax(1)*(1-cos(th)) + ax(3)*sin(th),  cos(th) + ax(2)*ax(2)*(1-cos(th)),        ax(2)*ax(3)*(1-cos(th)) - ax(1)*sin(th);
       ax(3)*ax(1)*(1-cos(th)) - ax(2)*sin(th),  ax(3)*ax(2)*(1-cos(th)) + ax(1)*sin(th),  cos(th) + ax(3)*ax(3)*(1-cos(th))
      ];
  
rot(abs(rot)<=eps) = 0;