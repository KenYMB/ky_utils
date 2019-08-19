function    abspath  = path_rel2abs(relpath)

% PATH_REL2ABS converts relative path into absolute path.
% 
% Usage:
%       absolute_path = PATH_REL2ABS(relative_path);
% 
% See also FILEATTRIB, WHICH.

% 20170322 Yuasa
% 20180522 Yuasa: enable multiple path
% 20181228 Yuasa: enable to apply on ls outputs

narginchk(1,1);

dattype = 'char';
if iscellstr(relpath)
    pathlist = relpath;
    dattype = 'cellstr';
elseif isrow(relpath)
    [pathlist, delim] = strsplit(relpath,{pathsep,'\n','\r','\t','\v'});
    delim{end+1} = '';
else
    pathlist = cellstr(relpath);
    dattype = 'winls';
end

switch dattype
    case 'char'
        abspath = '';
        for ipath=1:length(pathlist)
          if ~isempty(pathlist{ipath})
            [st, pathinfo] = fileattrib(pathlist{ipath});
            if st
                abspath = [abspath pathinfo.Name delim{ipath}];
            else
                st=warning('backtrace','off');
                warning('Input is ''%s''.\n\t%s',pathlist{ipath},pathinfo);
                warning(st);
            end
          end
        end
        %-- remove last ';'
        if ~isempty(abspath) && strcmp(abspath(end),pathsep) && ~isempty(pathlist{end})
            abspath(end) = '';
        end
    case {'cellstr','winls'}
        abspath = cell(length(pathlist),1);
        for ipath=1:length(pathlist)
          if ~isempty(pathlist{ipath})
            [st, pathinfo] = fileattrib(pathlist{ipath});
            if st
                abspath{ipath} = pathinfo.Name;
            else
                st=warning('backtrace','off');
                warning('Input is ''%s''.\n\t%s',pathlist{ipath},pathinfo);
                warning(st);
            end
          end
        end
        %-- convert into cellstr
        abspath(cellfun(@isempty,abspath)) = [];
        %-- convert into char matrix if need
        if strcmp(dattype,'winls')
            abspath = char(abspath);
        end
end    

