function varargout = findarray(INP, vec)

% a = FINDARRAY(A, vector);
% [a, b, ...] = FINDARRAY(A, vector);
% 
% search num-array (vector) from the input matrix (A)
% return 1st index of the target vector

% 20160823 Yuasa

    %-- error
    if ndims(INP) < ndims(vec)
        error('Dimension of input matrix is less than target vector!');
    end
    for idm = 1:ndims(vec)
        if size(INP,idm) < size(vec,idm)
            error('Target vector is larger than input matrix!');
        end
    end
    if nargout > 1
        nargoutchk(ndims(INP),ndims(INP));
    end

    sizdiff = size(INP) - [(size(vec)-1) zeros(ndims(INP) - ndims(vec))];
    culcmat = zeros(size(INP));
    insdim  = sprintf(' ,1:%d',size(vec));
    eval(sprintf('culcmat(%s) = vec;',insdim(3:end)));
    
    outpA = zeros(1,prod(sizdiff));
    for inm = 1:prod(sizdiff);
        compmat = circshiftwhole(culcmat,inm,sizdiff);
        compINP = INP;  compINP(logical(compmat)) = 0;
        compINP = compINP + compmat;
        compmat = naneq(INP,compINP);
        outpA(inm) = min(compmat(:));
    end
    outpA = find(outpA);
    
    if ~isempty(outpA)
        %-- separate for each dimension
        for inm=1:length(outpA)
            for idm = 1:length(sizdiff)
                varargout{idm}(inm) = mod(ceil(outpA(inm) ./ prod(sizdiff(1:(idm-1)))),sizdiff(idm));
                if varargout{idm}(inm) == 0, varargout{idm}(inm) = sizdiff(idm); end
            end
        end

        %-- convert to index
        if nargout <= 1
            idx = 1; dimlim = size(INP);
            for idm = 1:length(dimlim)
                idx = idx + (varargout{idm} - 1) .* prod(dimlim(1:(idm-1)));
            end
            varargout = {idx};
        end
    else
        for idm = 1:nargout
            varargout{idm} = zeros([0,1]);
        end
    end
    
end
    
function Y = circshiftwhole(A,k,dimlim)
% circuler shift of matrix
% interpret k as shift index under dimension limitations
    
    nshiftdims = zeros(1,length(dimlim));
    for idm = 1:length(dimlim)
        x_tmp = mod(ceil(k ./ prod(dimlim(1:(idm-1)))) - 1,dimlim(idm)); % '-1' in mod : fix for shift
        nshiftdims(idm) = x_tmp;
    end
    
    Y = circshift(A, nshiftdims);
    
end

function Eq = naneq(A,B)
%NANEQ Equality, considering NaNs and Empties.
% EQ = NANEQ(A, B)
%  is similar to 
%  A == B

% 20160823 Yuasa

    assert(min(size(A)==size(B)), 'Dimensions of input matrixes must be same');
    
    %-- find NaNs
    nan1 = isnan(A);
    nan2 = isnan(B);
    nanidx = or(nan1,nan2);
    
    %-- find empty
    emp1 = isempty(A);
    emp2 = isempty(B);
    empidx = or(emp1,emp2);
    
    Eq = zeros(size(A));
    %-- if NaNs are paired
    Eq(nanidx) = nan1(nanidx) == nan2(nanidx);
    %-- if empties are paired
    Eq(empidx) = emp1(empidx) == emp2(empidx);
    %-- normal 'eq'
    filidx = and(~nanidx, ~empidx);
    Eq(filidx) = A(filidx) == B(filidx);
end
