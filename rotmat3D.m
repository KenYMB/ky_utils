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
% 20210804 Yuasa: allow charactor inputs for axis, add 2D option

narginchk(2,2);
if ischar(ax)
    switch lower(ax)
        case 'x',   ax = [1,0,0];
        case 'y',   ax = [0,1,0];
        case 'z',   ax = [0,0,1];
        case '2d',  ax = [0,0,0];
    end
end
assert(length(ax)==3 && numel(ax)==3, 'axis is invalid');

%-- unit vector
isrot2d = ~any(ax);
ax = ax./norm(ax);
th   = th(1);

%-- Rodrigues
if isrot2d  % 2D
rot = [cos(th),  -sin(th);
       sin(th),  cos(th)];
else        % 3D
rot = [cos(th) + ax(1)*ax(1)*(1-cos(th)),        ax(1)*ax(2)*(1-cos(th)) - ax(3)*sin(th),  ax(1)*ax(3)*(1-cos(th)) + ax(2)*sin(th);
       ax(2)*ax(1)*(1-cos(th)) + ax(3)*sin(th),  cos(th) + ax(2)*ax(2)*(1-cos(th)),        ax(2)*ax(3)*(1-cos(th)) - ax(1)*sin(th);
       ax(3)*ax(1)*(1-cos(th)) - ax(2)*sin(th),  ax(3)*ax(2)*(1-cos(th)) + ax(1)*sin(th),  cos(th) + ax(3)*ax(3)*(1-cos(th))
      ];
end
    
  
rot(abs(rot)<=eps) = 0;