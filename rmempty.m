function    output = rmempty(input, varargin)

% B = RMEMPTY(A);
%   RMEMPTY removes empty components from A.
%   If A is cell-array, empty cells are removed.
%   If A is cell-matrix, empty rows and colums are removed.
%   If A is structure, empty fields are removed.
% 
% B = RMEMPTY(A, 'force');
%   If A is cell-matrix, empty cells are removed, and cell-array is output.
% 
% Enhanced option: 
% B = RMEMPTY(A, function);
%   Check A with the 'function' instead of 'isempty'.
% 
% Exsample: 
%   A = num2cell(floor(5*rand(2,3,4)));
%   A = rmempty(A,'force', @(x)x==0);

% 20170814 Yuasa

narginchk(1,inf);

%-- check option
isforce = false;                    % force = false (default)
chkfun  = @(x)isempty(x);           % chkfun = isempty (default)

for ilp=1:(nargin-1)
  if ischar(varargin{ilp}) && strcmp(varargin{ilp},'force')
      isforce = true;
  elseif isa(varargin{ilp},'function_handle')
      chkfun  = varargin{ilp};
  end
end

if iscell(input)
    if isforce, input = reshape(input,[],1);   end  % convert into cell-array
    cellsiz = size(input);
    %-- check empty
    chklist = false(cellsiz);
    for ilp=1:numel(input)
      try       tmpchk  = chkfun(input{ilp});
      catch,    tmpchk  = false;
      end
      chklist(ilp) = ~isempty(tmpchk) && nanmin(tmpchk(:));
    end
    %-- remove empty
    if length(cellsiz)==2 && min(cellsiz)==1        % check cell-array
      input(chklist) = [];        
    else                                            % consider as matrix
      for idim=1:length(cellsiz)
        tmpsiz = size(input);   tmpsiz(idim) = 1;
        rmlist = chklist;
        for irem=1:length(cellsiz)
          if irem~=idim,   rmlist = logical(nanmin(rmlist,[],irem));    end
        end
        input(repmat(rmlist,tmpsiz))   = [];
        chklist(repmat(rmlist,tmpsiz)) = [];
        tmpsiz(idim) = sum(~rmlist);                % repair dims
        input   = reshape(input,tmpsiz);
        chklist = reshape(chklist,tmpsiz);
      end
    end
elseif isstruct(input)
    %-- check & remove empty
    chklist = fieldnames(input);
    for ilp=1:length(chklist)
        try    tmpchk  = chkfun(input.(chklist{ilp}));
        catch, tmpchk  = false;
        end
        if nanmin(tmpchk(:)),
            input = rmfield(input,chklist{ilp});
        end
    end
else
    curwarn = warning('off', 'backtrace');
    warning('Input is not cell-array nor structure. ');
    warning(curwarn);
end

output = input;