function tableOut = tblnoutlier(tableIn, varargin)
    % Check if tableIn is a valid table
    if ~istable(tableIn)
        error('Input tableIn must be a valid table.');
    end

    % Set default values
    variableName = '';
    percentiles = [];

    % Parse input arguments in pairs
    for i = 1:2:numel(varargin)
        paramName = varargin{i};
        paramValue = varargin{i+1};

        % Check and assign the input parameters
        switch paramName
            case 'NumericDataName'
                variableName = paramValue;
            case 'CategoryName'
                categoryName = paramValue;
            case 'Percentile'
                percentiles = paramValue;
                percentiles = sort(percentiles);
            otherwise
                error('Unknown input parameter: %s', paramName);
        end
    end

    % Check for missing arguments
    if isempty(variableName) || ~ischar(variableName)
        error('VariableName must be a non-empty string.');
    end
    if isempty(percentiles) || ~isnumeric(percentiles) || numel(percentiles) ~= 2
        error('Percentile must be a non-empty 2-element numeric vector.');
    end

    % Check if the variableName exists in the table
    if ~any(strcmp(variableName, tableIn.Properties.VariableNames))
        error('VariableName not found in the table.');
    end
    % Check if the variable data is numeric
    if ~isnumeric(tableIn.(variableName))
        error('Variable data must be numeric for outlier removal.');
    end
    
    %% actual function
    if exist('categoryName','var')
        if ~isempty(categoryName)
        % Check if the category data is categorical
        if ~iscategorical(tableIn.(categoryName))
            error('Categorical data is %s, must be categorical', class(tableIn.(categoryName)));
        end
        categories = unique(tableIn.(categoryName))';
        for ca = categories
            index1  = tableIn.(categoryName) == ca;
            index2  = find(index1);
            data    = tableIn.(variableName)(index1,:);
            [~,index3] = rmoutliers(data,'percentiles',percentiles);
            tableIn.(variableName)(index2(index3),:) = nan;
        end
        else
            warning('categorical data looks empty: outliers will be removed across whole table')
        end
    else
        data    = tableIn.(variableName)(:,1);
        [~,index3] = rmoutliers(data,'percentiles',percentiles);
        tableIn.(variableName)(index3,:) = nan;
    end
    tableOut = tableIn;
end