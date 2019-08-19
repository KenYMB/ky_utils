function data = nearlyeq(x,d,mode,k)
% 
% data = NEARLYEQ(x,d,mode,k)
% 
% �w�肵�����l�ɍł��߂����l���f�[�^�Q����T���o���A�C���f�b�N�X��Ԃ�
% 
% x       : ��������f�[�^�Q
% d       : �������������l
% k       : �Y���������������ꍇ�̏o�͐� (default = 1)
%           'all'   �S�����o��
% data    : ���ʂƂȂ鐔�l��x�ɂ�����v�f�ԍ�
%           'k��1'����cell�o��
%           'mode=both'����cell�o��
% mode    : 'normal' �ł��߂����l (default)
%           'small'  k��菬�������l
%           'large'  k���傫�����l
%           'both'   k������ŗ��T�C�h�̐��l
%                    data��3�����ڂɏo��
% 

% 2014/07/28 Yuasa
% 2015/04/08 d�̕������͂ɑΉ�

narginchk(2,4);

if ~exist('k','var') || isempty(k),    k = 1;   end

if ~exist('mode','var') || isempty(mode),    mode = 'normal'; end

if ~strcmp(mode,'normal') && ~strcmp(mode,'small') && ~strcmp(mode,'large') && ~strcmp(mode,'both'),
    error('nearly equal direction must be ''normal'', ''small'', ''large'' or ''both''.');
end

inpsiz  = size(d);
inpdim  = length(inpsiz);

if inpdim > 2, error('input data must be 2-dim matrix'); end

if strcmp(mode,'both'),  data = cell([inpsiz 2]);
else                     data = cell(inpsiz);
end

% main
for icol = 1:inpsiz(2)
    for irow = 1:inpsiz(1)

        xs = sort(x(x<=d(irow,icol)),'descend');
        xl = sort(x(x>=d(irow,icol)),'ascend');

        switch mode
            case 'normal'
                if isempty(xs), xs=xl(end); end
                if isempty(xl), xl=xs(end); end
                nearestN = abs(xs(1)-d(irow,icol)) <= abs(xl(1)-d(irow,icol));
                data{irow,icol} = find(x == (xs(1)*nearestN + xl(1)*~nearestN));
            case 'small'
                if min(x(:)) > d(irow,icol)
                    data{irow,icol}=[];
                else
                    data{irow,icol} = find(x == xs(1));
                end
            case 'large'
                if max(x(:)) < d(irow,icol)
                    data{irow,icol}=[];
                else
                    data{irow,icol} = find(x == xl(1));
                end
            case 'both'
                if min(x(:)) > d(irow,icol)
                    data{irow,icol,1}=[];
                else
                    data{irow,icol,1} = find(x == xs(1));
                end
                if max(x(:)) < d(irow,icol)
                    data{irow,icol,2}=[];
                else
                    data{irow,icol,2} = find(x == xl(1));
                end
        end

        if ~strcmp(k,'all'),
            if k < 1, k = 1; end
            k = floor(k(1));
            if strcmp(mode,'both'),
                if length(data{irow,icol,1}) > k,   data{irow,icol,1}=data{irow,icol,1}(1:k); end
                if length(data{irow,icol,2}) > k,   data{irow,icol,2}=data{irow,icol,2}(1:k); end
            elseif length(data{irow,icol}) > k
                data{irow,icol}=data{irow,icol}(1:k);
            end
        end
    end
end

if (k(1) == 1) && ~strcmp(mode,'both')
    data = cell2mat(data);
end