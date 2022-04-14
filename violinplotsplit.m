function violins = violinplotsplit(data, cats, varargin)
%Violinplotssplit plots violin plots of some data and categories 
%   VIOLINPLOTSPLIT(3D-DATAMATRIX) plots violins for each column in
%   DATAMATRIX. If DATAMATRIX is three-dimensional, first component of the
%   third dimension is shown in left side, and second component in right
%   side.
%
%   VIOLINPLOTSPLIT(TABLE), VIOLINPLOT(STRUCT), VIOLINPLOT(DATASET)
%   plots violins for each column in TABLE, each field in STRUCT, and
%   each variable in DATASET. The violins are labeled according to
%   the table/dataset variable name or the struct field name.
%
%   VIOLINPLOTSPLIT(3D-DATAMATRIX, CATEGORYNAMES) plots violins for each
%   column in DATAMATRIX and labels them according to the names in the
%   cell-of-strings CATEGORYNAMES.
%
%   VIOLINPLOTSPLIT(2D-DATAMATRIX, CATEGORIES) where double vector DATA and
%   vector CATEGORIES are of equal length; plots violins for each category
%   in DATA. If DATAMATRIX is not vector, first component of the second
%   dimension is shown in left side, and second component in right side.
%
%   violins = VIOLINPLOTSPLIT(...) returns an object array of
%   <a href="matlab:help('Violin')">Violin</a> objects.
%
%   VIOLINPLOTSPLIT(..., 'PARAM1', val1, 'PARAM2', val2, ...)
%   specifies optional name/value pairs for all violins:
%     'Width'        Width of the violin in axis space.
%                    Defaults to 0.3
%     'Bandwidth'    Bandwidth of the kernel density estimate.
%                    Should be between 10% and 40% of the data range.
%     'ViolinColor'  Fill color of the violin area and data points.
%                    Defaults to the next default color cycle.
%     'ViolinAlpha'  Transparency of the violin area and data points.
%                    Defaults to 0.3.
%     'EdgeColor'    Color of the violin area outline.
%                    Defaults to [0.5 0.5 0.5]
%     'BoxColor'     Color of the box, whiskers, and the outlines of
%                    the median point and the notch indicators.
%                    Defaults to [0.5 0.5 0.5]
%     'MedianColor'  Fill color of the median and notch indicators.
%                    Defaults to [1 1 1]
%     'ShowData'     Whether to show data points.
%                    Defaults to true
%     'ShowNotches'  Whether to show notch indicators.
%                    Defaults to false
%     'ShowMean'     Whether to show mean indicator
%                    Defaults to false
%     'GroupOrder'   Cell of category names in order to be plotted.
%                    Defaults to alphabetical ordering

% Copyright (c) 2016, Bastian Bechtold
% This code is released under the terms of the BSD 3-clause license
%     
% Modified by K.Yuasa, 20211214    

    hascategories = exist('cats','var') && not(isempty(cats));
    
    %parse the optional grouporder argument 
    %if it exists parse the categories order 
    % but also delete it from the arguments passed to Violin
    grouporder = {};
    idx=find(strcmp(varargin, 'GroupOrder'));
    if ~isempty(idx) && numel(varargin)>idx
        if iscell(varargin{idx+1})
            grouporder = varargin{idx+1};
            varargin(idx:idx+1)=[];
        else
            error('Second argument of ''GroupOrder'' optional arg must be a cell of category names')
        end
    end

    % tabular data
    if isa(data, 'dataset') || isstruct(data) || istable(data)
        if isa(data, 'dataset')
            colnames = data.Properties.VarNames;
        elseif istable(data)
            colnames = data.Properties.VariableNames;
        elseif isstruct(data)
            colnames = fieldnames(data);
        end
        catnames = {};
        for n=1:length(colnames)
            if isnumeric(data.(colnames{n}))
                catnames = [catnames colnames{n}];
            end
        end
        for n=1:length(catnames)
            thisData = data.(catnames{n});
            violins(n) = Violin(thisData, n, varargin{:});
        end
        set(gca, 'XTick', 1:length(catnames), 'XTickLabels', catnames);

    % 1D data, one category for each data point
    elseif hascategories && numel(data) == numel(cats)

        if isempty(grouporder)
            cats = categorical(cats);
        else
            cats = categorical(cats, grouporder);
        end

        catnames = (unique(cats)); % this ignores categories without any data
        catnames_labels = {};
        for n = 1:length(catnames)
            thisCat = catnames(n);
            catnames_labels{n} = char(thisCat);
            thisData = data(cats == thisCat);
            violins(n) = Violin(thisData, n, varargin{:});
        end
        set(gca, 'XTick', 1:length(catnames), 'XTickLabels', catnames_labels);

    % 1D data, no categories
    elseif isvector(data)
        violins = Violin(data, 1, varargin{:});
        set(gca, 'XTick', 1);
        if hascategories && numel(cats) == 1
            set(gca, 'XTickLabels', cats);
        end

    % 2D data
    elseif ismatrix(data)
        % 2D data, one category for each column
        if size(data,2) == 2 && hascategories && size(data,1) == numel(cats)
            colorList = get(gcf,'defaultAxesColorOrder');
            
            if isempty(grouporder)
                cats = categorical(cats);
            else
                cats = categorical(cats, grouporder);
            end
            
            catnames = (unique(cats)); % this ignores categories without any data
            catnames_labels = {};
            for m=1:size(data, 2)
                if m==1,   AddVar = {'Side','left'};
                else,      AddVar = {'Side','right'};
                end
                for n=1:length(catnames)
                    thisCat = catnames(n);
                    catnames_labels{n} = char(thisCat);
                    thisData = data(cats == thisCat, m);
                    violins((m-1)*size(data, 2)+n) = ViolinHalf(thisData, n, 'ViolinColor',colorList(m,:),varargin{:}, AddVar{:});
                end
            end
            set(gca, 'XTick', 1:length(catnames), 'XTickLabels', catnames_labels);
            
        % 2D data with categorynames or without categories
        else
            for n=1:size(data, 2)
                thisData = data(:, n);
                violins(n) = Violin(thisData, n, varargin{:});
            end
            set(gca, 'XTick', 1:size(data, 2));
            if hascategories && length(cats) == size(data, 2)
                set(gca, 'XTickLabels', cats);
            end
        end
        
    % 3D data
    elseif ndims(data)==3 && size(data,3)==2
        colorList = get(gcf,'defaultAxesColorOrder');
        for m=1:size(data, 3)
            if m==1,   AddVar = {'Side','left'};
            else,      AddVar = {'Side','right'};
            end
            for n=1:size(data, 2)
                thisData = data(:, n, m);
                violins((m-1)*size(data, 2)+n) = ViolinHalf(thisData, n, 'ViolinColor',colorList(m,:),varargin{:}, AddVar{:});
            end
        end
        set(gca, 'XTick', 1:size(data, 2));
        if hascategories && length(cats) == size(data, 2)
            set(gca, 'XTickLabels', cats);
        end

    end

end
