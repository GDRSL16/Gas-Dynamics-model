% ========================================================================
% Documentation reviewed: 2026-10-18 | Batch 01
% Purpose: Load per-dive and surface-interval summary information.
% Interface: whale_id selects a summary file; column descriptions follow in the original header.
% Review note: Summary start/end rows must be consistent with the time-series input.
% Scope: Documentation only; all pre-existing lines remain unchanged.
% ========================================================================

% ============================================================
% Documentation review: 2026-10-18 | Batch 01
% Scope: Review tracking header only; original code preserved.
% Numerical calculations, logic, and existing comments unchanged.
% ============================================================
function data = GET_DIVE_SUMMARY_DATA_METABOLIC_RATES(whale_id)
% Input contract: selected summary rows define dive and surface intervals.
% Indexing note: these intervals must refer to the same sampling grid as the depth series.
% GET_DIVE_SUMMARY_DATA_METABOLIC_RATES_MAC - Load summary metabolic rate data for a specific whale.
%
% This function loads summary data for a given whale based on its ID.
% Data files contain the following columns:
%   1. SI number
%   2. SI duration (seconds)
%   3. Row for start of SI
%   4. Row for end of SI
%   5. Average metabolic rate (L O2 min^-1) during SI
%   6. Dive number
%   7. Dive duration (seconds)
%   8. Row for start of dive
%   9. Row for end of dive
%  10. Average metabolic rate (L O2 min^-1) during dive
%  11. Maximum depth (meters)
%  12. Mean depth (meters)
%  13. Depth cutoff for bottom (meters), not used now
%
% Input:
%   whale_id - Integer representing the whale's ID (1 to 12).
%
% Output:
%   data - Array containing the summary data from the corresponding CSV file.

    % Map whale IDs to their corresponding file names
    file_map = {
        '1-Zica-20191012-144029_surfacings_1Hz-summary.csv', ...
        '2-Zica-20191012-145101_surfacings_1Hz-summary.csv', ...
        '3-Zica-20191111-94810_surfacings_1Hz-summary.csv', ...
        '4-Zica-20191117-195993_surfacings_1Hz-summary.csv', ...
        '5-Zica-20211112-94819_surfacings_1Hz-summary.csv', ...
        '6-Zica-20211113-195993_surfacings_1Hz-summary.csv', ...
        '7-Zica-20220112-195994_surfacings_1Hz-summary.csv', ...
        '8-Zica-20230518-233391_surfacings_1Hz-summary.csv' ...
        '9-Zica-20230519-232950_surfacings_1Hz-summary.csv' ...
        '10-Zica-20230723-233394_surfacings_1Hz-summary.csv' ...
        '11-Zica-20240227-233396_surfacings_1Hz-summary.csv' ...
        '12-Zica-20240227-240128_surfacings_1Hz-summary.csv' ...
        '13-shallow_20x600s_20m_summary.csv' ...
        '14-intermediate_10x1200s_400m_summary.csv' ...
        '15-deep_5x3000s_1200m_summary.csv' ...
        '16-1A-intermediate_20x1200s_400m_2h_pre_180s_SI_1h_post_summary.csv' ...
        '17-1B-intermediate_20x1200s_400m_2h_pre_180s_SI_1h_post_summary.csv' ...
        '18-1C-intermediate_20x1200s_400m_2h_pre_360s_SI_1h_post_summary.csv' ...
        '19-1D-intermediate_20x1200s_400m_2h_pre_180s_SI_1h_post_summary.csv' ...
        '20-1E-intermediate_20x1200s_400m_10h_pre_3bpm_180s_SI_10h_post_summary.csv' ...
        '21-1F-intermediate_20x1200s_400m_2h_pre_1bpm_180s_SI_1h_post_summary.csv' ...
    };

    % Validate whale ID
    if whale_id < 1 || whale_id > length(file_map)
        error('Invalid whale ID. Must be an integer between 1 and %d.', length(file_map));
    end

    % Load data using the appropriate file name
    file_name = file_map{whale_id};
    fprintf('Loading summary data from: %s\n', file_name);

    % Read the data from the file (skipping the header)
    data = readmatrix(file_name, 'NumHeaderLines', 1);

    % Ensure data is loaded correctly
    if isempty(data)
        error('Failed to load data from file: %s', file_name);
    end
end
