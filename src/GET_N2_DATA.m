% ========================================================================
% Documentation reviewed: 2026-10-18 | Batch 01
% Purpose: Interactively load an existing numerical outcome data file.
% Interface: No arguments; returns numeric data loaded from the selected path.
% Review note: This legacy interactive loader has no automatic input validation.
% Scope: Documentation only; all pre-existing lines remain unchanged.
% ========================================================================

% ============================================================
% Documentation review: 2026-10-18 | Batch 01
% Scope: Review tracking header only; original code preserved.
% Numerical calculations, logic, and existing comments unchanged.
% ============================================================
function y=GET_N2_DATA
disp('Please provide the name of for the array of outcome data.');
[filename,pathname]=uigetfile('*.*','Outcome Data File Name');%gives the name of file and path
disp(['Data file name: ' filename]);%displays the file name chosen
fullfilename=[pathname filename];
y=load(fullfilename);
end