% ========================================================================
% Documentation reviewed: 2026-10-18 | Batch 01
% Purpose: Load a breath-event schedule for a selected animal or synthetic profile.
% Interface: whale_id selects the file; returned data contain time and breath flags.
% Review note: Confirm file mapping and row alignment before interpreting breath timing.
% Scope: Documentation only; all pre-existing lines remain unchanged.
% ========================================================================

% ============================================================
% Documentation review: 2026-10-18 | Batch 01
% Scope: Review tracking header only; original code preserved.
% Numerical calculations, logic, and existing comments unchanged.
% ============================================================
function data = GET_BREATH_FLAGS(whale_id)
% Input contract: whale_id indexes file_map; output rows must align with the model time steps.
% Validation note: this loader checks selection and nonempty data, not the physiological timing of breaths.
% GET_BREATH_FLAGS - Load breath data for a specific whale.
%
% This function loads breath data for a given whale based on its ID.
% Data files contain the following columns:
%   1. Time (seconds)
%   2. Breath flag (0-no brath, 1-breath)
% Input:
%   whale_id - Integer representing the whale's ID (1 to 15).
%
% Output:
%   data - Array containing the breath data from the corresponding CSV file.

    % Map whale IDs to their corresponding file names
    %AS of October 2026, whales 1-12 do not have data
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
        '13-shallow_20x600s_20m_breath_flag.csv' ...
        '14-intermediate_10x1200s_400m_breath_flag.csv' ...
        '15-deep_5x3000s_1200m_breath_flag.csv' ...
        '16-1A-intermediate_20x1200s_400m_2h_pre_180s_SI_1h_post_breath_flag.csv' ...
        '17-1B-intermediate_20x1200s_400m_2h_pre_180s_SI_1h_post_breath_flag.csv' ...
        '18-1C-intermediate_20x1200s_400m_2h_pre_360s_SI_1h_post_breath_flag.csv' ...
        '19-1D-intermediate_20x1200s_400m_2h_pre_180s_SI_1h_post_breath_flag.csv' ...
        '20-1E-intermediate_20x1200s_400m_10h_pre_3bpm_180s_SI_10h_post_breath_flag.csv' ...
        '21-1F-intermediate_20x1200s_400m_2h_pre_1bpm_180s_SI_1h_post_breath_flag.csv' ...

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