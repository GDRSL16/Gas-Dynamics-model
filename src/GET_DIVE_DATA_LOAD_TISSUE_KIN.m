function data = GET_DIVE_DATA_LOAD_TISSUE_KIN(whale_id)
% GET_DIVE_DATA_LOAD_TISSUE_KIN_MAC - Load dive data for a specific whale.
%
% This function loads dive data for a given whale based on its ID.
% Data files contain the following columns:
%   1. Time (seconds)
%   2. Depth (meters)
%   3. ODBA (g)
%   4. Metabolic conversion to liters/min for a 2000 kg animal
%
% Input:
%   whale_id - Integer representing the whale's ID (1 to 8).
%
% Output:
%   data - Array containing the dive data from the corresponding CSV file.

    % Map whale IDs to their corresponding file names
    file_map = {
        '1-Zica-20191012-144029_surfacings_1Hz-data.csv', ...
        '2-Zica-20191012-145101_surfacings_1Hz-data.csv', ...
        '3-Zica-20191111-94810_surfacings_1Hz-data.csv', ...
        '4-Zica-20191117-195993_surfacings_1Hz-data.csv', ...
        '5-Zica-20211112-94819_surfacings_1Hz-data.csv', ...
        '6-Zica-20211113-195993_surfacings_1Hz-data.csv', ...
        '7-Zica-20220112-195994_surfacings_1Hz-data.csv', ...
        '8-Zica-20230518-233391_surfacings_1Hz-data.csv' ...
        '9-Zica-20230519-232950_surfacings_1Hz-data.csv' ...
        '10-Zica-20230723-233394_surfacings_1Hz-data.csv' ...
        '11-Zica-20240227-233396_surfacings_1Hz-data.csv' ...
        '12-Zica-20240227-240128_surfacings_1Hz-data.csv' ...
        '13-shallow_20x600s_20m_data.csv' ...
        '14-intermediate_10x1200s_400m_data.csv' ...
        '15-deep_5x3000s_1200m_data.csv' ...
    };

    % Validate whale ID
    if whale_id < 1 || whale_id > length(file_map)
        error('Invalid whale ID. Must be an integer between 1 and %d.', length(file_map));
    end

    % Load data using the appropriate file name
    file_name = file_map{whale_id};
    fprintf('Loading data from: %s\n', file_name);

    % Read the data from the file (skipping the header)
    data = readmatrix(file_name, 'NumHeaderLines', 1);

    % Ensure data is loaded correctly
    if isempty(data)
        error('Failed to load data from file: %s', file_name);
    end
end