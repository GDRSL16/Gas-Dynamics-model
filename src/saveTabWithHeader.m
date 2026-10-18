% ========================================================================
% Second-round internal documentation review: 2026-10-18 | Batch 06
% File: saveTabWithHeader.m
% Review focus: Output utility. Preserve exact data formatting and file naming used by downstream scripts.
% Documentation only: original MATLAB source follows unchanged.
% ========================================================================
% ============================================================
% Documentation review: 2026-10-18 | Batch 06
% File: saveTabWithHeader.m
% Function signature: saveTabWithHeader(filename, data, headerRows, varargin)
% Scope: documentation only; numerical model unchanged.
% Original source preserved verbatim below this header.
% ============================================================
function saveTabWithHeader(filename, data, headerRows, varargin)
% saveTabWithHeader  Write numeric matrix to a tab-delimited file with header lines.
%
% Usage:
%   saveTabWithHeader(filename, data, headerRows)
%   saveTabWithHeader(..., 'Delimiter', '\t', 'Precision', '%.10g', 'Force', true)
%
% Inputs:
%   filename   : char/string, output file path (will overwrite if exists)
%   data       : numeric matrix (N x M)
%   headerRows : either
%                   - cell array of full header lines: {'line1','line2',...}
%                   - cell array where each element is a cell array of columns: {{'col1','col2',...}, {...}}
%                   - single string/char for 1 header line
%
% Name-Value:
%   'Delimiter' : default '\t'
%   'Precision' : default '%.10g'
%   'Force'     : default false. If false and shapes mismatch the header, prints warning (still writes).
%
% Example:
%   saveTabWithHeader('out.txt', myMatrix, {'H1','H2','H3'});

    % parse name-value
    p = inputParser;
    p.addParameter('Delimiter', sprintf('\t'), @(x)ischar(x)||isstring(x));
    p.addParameter('Precision', '%.10g', @(x)ischar(x)||isstring(x));
    p.addParameter('Force', false, @(x)islogical(x)||ismember(x,[0,1]));
    p.parse(varargin{:});
    delim = char(p.Results.Delimiter);
    prec  = char(p.Results.Precision);
    doForce = logical(p.Results.Force);

    % normalize filename
    if isstring(filename), filename = char(filename); end

    % normalize headerRows -> cell array of strings (full lines)
    headerLines = {};
    if nargin < 3 || isempty(headerRows)
        headerLines = {};
    elseif ischar(headerRows) || isstring(headerRows)
        headerLines = {char(headerRows)};
    elseif iscell(headerRows)
        % case 1: {'line1','line2',...}
        if all(cellfun(@(c) ischar(c) || isstring(c), headerRows))
            headerLines = cellfun(@char, headerRows, 'UniformOutput', false);
        else
            % case 2: { {'col1','col2',...}, {'c1','c2',...} }
            headerLines = cell(size(headerRows));
            for r = 1:numel(headerRows)
                row = headerRows{r};
                % if row is char/string make single element
                if ischar(row) || isstring(row)
                    row = {char(row)};
                end
                row = cellfun(@(c) char(string(c)), row, 'UniformOutput', false);
                headerLines{r} = strjoin(row, delim);
            end
        end
    else
        error('headerRows must be char, string, or cell array.');
    end

    % validate data
    if ~isnumeric(data)
        error('Data must be a numeric matrix.');
    end
    [nRows, nCols] = size(data);

    % try to infer number of header columns (from last header row)
    headerColsCount = [];
    if ~isempty(headerLines)
        lastHeader = headerLines{end};
        % split on tabs OR runs of whitespace (covers pasted headers)
        parts = regexp(lastHeader, '\t+|\s{2,}|\s+', 'split'); 
        % remove empty parts
        parts = parts(~cellfun('isempty', parts));
        headerColsCount = numel(parts);
        if headerColsCount ~= nCols && ~doForce
            warning(['Header column count (%d) does not match data columns (%d). ', ...
                     'File will still be written. If you want to force-check, set ''Force'',true.'], ...
                     headerColsCount, nCols);
        end
    end

    % open file and write
    fid = fopen(filename, 'w');
    if fid < 0
        error('Could not open file for writing: %s', filename);
    end
    cleaner = onCleanup(@() fclose(fid));

    % write header lines
    for k = 1:numel(headerLines)
        fprintf(fid, '%s\n', headerLines{k});
    end

    % build format string for numeric columns
    if nCols == 0
        % nothing to write
    else
        fmt = [repmat([prec delim], 1, nCols-1) prec '\n'];
        for r = 1:nRows
            fprintf(fid, fmt, data(r, :));
        end
    end
end
