function    [filelist] = getfilelist(name)
% [filelist] = GETFILELIST(name)
% 
% MATLAB function 'ls' works different in Windows and UNIX (Mac/Linax).
% This function returns filelist with directory path as cellstr array.
% 
% See also: ls

% 20190312: Yuasa

if ispc     % Windows
    name = strrep(name,'/',filesep);
    [tardir, filename, ext] = fileparts(name);
    
    if isempty(filename)    % target is dir
        %-- specify parent directory
        isepdir = strfind(tardir,filesep);
        if isepdir(end)==length(tardir) && isepdir(end)>1
            if isepdir(end-1)==(length(tardir)-1) && isepdir(end-1)>1
                isepdir = isepdir(end-2);
            else
                isepdir = isepdir(end-1);
            end
        else
            isepdir = isepdir(end);
        end
        %-- check wildcard
        iswc    = strfind(tardir(isepdir:end),'*');
        filelist = ls(tardir);
        if ~isempty(filelist)
            if isempty(iswc)        % no wildcard
                filelist = fullfile(tardir,cellstr(filelist));
            else                    % wildcard in directory name
                filelist = fullfile(tardir(1:isepdir),cellstr(filelist));
            end
        end
        
    else                    % target is file
        filelist = ls([tardir, filesep, filename, ext]);
        if ~isempty(filelist)
            filelist = fullfile(tardir,cellstr(filelist));
        end
    end
    
else    % UNIX
    filelist = strsplit(ls(name));
    if ~isempty(filelist)
        isdummy  = cellfun(@isempty,cellstr(filelist));
        filelist(isdummy) = [];
    end
end
    
    