function varargout = colorMat(inp, color, option)

% outp = colorMat(inp, color (, option))
% 
% inp:      Matrix (0~1)
% color:    Color Vector
% option:   output class
%           'uint8','double','8bit_double','norm','same (as color)'
%           default:'same'
% 
% apply color vector to the input matrix

% 20160622 Yuasa: Created
% 20160627 Yuasa: minor bug fix
% 20160629 Yuasa: add option

MatSiz = [size(inp,1),size(inp,2)];
ColDim = numel(color);

narginchk(2,3);
assert(nargout<=1 || nargout==ColDim, 'Numbers of output variables are WRONG!');
assert(size(inp,3)==1 || size(inp,3)==ColDim, 'Color dimensions are NOT matched!');
if nargin < 3,  option = 'same';    end

classsave = class(inp);

if size(inp,3)==1
    inp = repmat(inp, [1 1 ColDim]);   % reproduct along with color dimension
end
color = repmat(reshape(color,1,1,[]), [MatSiz 1]);

outp = double(inp) .* double(color);

switch option
    case 'uint8'
        classsave = option;
        if max(color(:))<=1;    outp = outp * 255;  end
    case 'double'
        classsave = option;
    case '8bit_double'
        classsave = 'double';
        if max(color(:))<=1;    outp = outp * 255;  end
    case 'norm'
        classsave = 'double';
        if max(color(:))>1;     outp = outp / 255;  end
end
outp = eval([classsave '(outp)']);

if nargout == 1
    varargout{1} = outp;
else
    for ilp=1:ColDim
        varargout{ilp} = outp(:,:,ilp);
    end
end

