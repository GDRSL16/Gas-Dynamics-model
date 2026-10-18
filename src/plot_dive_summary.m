% ============================================================
% Documentation review: 2026-10-18 | Batch 06
% File: plot_dive_summary.m
% Function signature: plot_dive_summary(whichRun, folder)
% Scope: documentation only; numerical model unchanged.
% Original source preserved verbatim below this header.
% ============================================================
function plot_dive_summary(whichRun, folder)
% PLOT_DIVE_SUMMARY Plot tissue, blood and ambient-pressure traces.
%   plot_dive_summary(1) : shallow
%   plot_dive_summary(2) : intermediate
%   plot_dive_summary(3) : deep
%   plot_dive_summary(2,'C:\path\to\results')
%
% Expects two header rows and numerical data starting at row 3.
% Columns: 1:5 N2 tissue/lung; 6:10 O2; 11:15 CO2;
%          16:17 N2 arterial/venous; 18:19 O2; 20:21 CO2;
%          22 ambient pressure. EDIT mappings below if needed.
% All values are plotted in the units stored in SUMMARY_ARRAY.

if nargin < 2 || isempty(folder)
    folder = fileparts(mfilename('fullpath')); % Same folder as this function
end
names = {'shallow-SUMMARY_ARRAY.txt', ...
         'intermed-SUMMARY_ARRAY.txt', ...
         'deep-SUMMARY_ARRAY.txt'};
labels = {'Shallow', 'Intermediate', 'Deep'};
validateattributes(whichRun, {'numeric'}, {'scalar','integer','>=',1,'<=',3});
file = fullfile(folder, names{whichRun});
if ~isfile(file)
    [f,p] = uigetfile({'*.txt;*.csv','Summary files'}, ...
        sprintf('Select %s SUMMARY_ARRAY', labels{whichRun}), folder);
    if isequal(f,0), return; end
    file = fullfile(p,f);
end

% Two nonnumeric header rows. readmatrix handles text headers and tab/CSV.
opts = detectImportOptions(file, 'FileType','text');
opts.DataLines = [3 Inf];
X = readmatrix(file, opts);
if size(X,2) < 22
    error('Expected at least 22 numeric columns; found %d in %s',size(X,2),file);
end
% Delete fully blank trailing rows, but retain genuine missing data.
X = X(~all(isnan(X),2),:);
rows = (1:size(X,1))';

% Explicit column map, according to the supplied summary description.
gases = {'N2','O2','CO2'};
tissueCols = {1:5, 6:10, 11:15};
bloodCols  = {[16 17], [18 19], [20 21]};
tissueNames = {'Heart','Muscle','Brain','Fat','Lung'};

for g = 1:3
    fig = figure('Name',sprintf('%s - %s',labels{whichRun},gases{g}), ...
                 'Color','w');
    ax(1) = subplot(3,1,1,'Parent',fig);
    plot(rows,X(:,tissueCols{g}),'LineWidth',1);
    ylabel(sprintf('%s tissues / lung',gases{g}));
    legend(tissueNames,'Location','eastoutside');
    title(sprintf('%s dive profile - %s',labels{whichRun},gases{g}));
    grid on;

    ax(2) = subplot(3,1,2,'Parent',fig);
    plot(rows,X(:,bloodCols{g}),'LineWidth',1.1);
    ylabel(sprintf('%s blood',gases{g}));
    legend({'Arterial','Venous'},'Location','eastoutside');
    grid on;

    ax(3) = subplot(3,1,3,'Parent',fig);
    plot(rows,X(:,22),'k','LineWidth',1);
    ylabel('Ambient pressure');
    xlabel('Data row (time step)');
    legend('Ambient pressure','Location','eastoutside');
    grid on;

    % Legends outside all three panels; enforce identical plot widths.
    % Set positions AFTER creating the legends, which otherwise resize axes.
    drawnow;
    for k = 1:3
        pos = ax(k).Position;
        pos(1) = 0.12;
        pos(3) = 0.64;
        ax(k).Position = pos;
    end

    linkaxes(ax,'x');
    xlim(ax(3),[1 size(X,1)]);
end
end
