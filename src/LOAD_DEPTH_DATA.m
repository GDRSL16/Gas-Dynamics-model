% ========================================================================
% Documentation reviewed: 2026-10-18 | Batch 02
% Purpose: Interactively load a dive-depth summary from a text file.
% Interface: No arguments; returns the selected file as a numeric array.
% Review note: The original expected four-column layout is noted beside the loader.
% Scope: Documentation only; all pre-existing lines remain unchanged.
% ========================================================================

function y=LOAD_DEPTH_DATA
disp('Please provide the name of the array of dive depth data.');
[filename,pathname]=uigetfile('*.txt','Outcome Data File Name');%gives the name of file and path
disp(['Data file name: ' filename]);%displays the file name chosen
fullfilename=[pathname filename];%file has 4 columns: 1=dive number, 2=row for start of dive, 3=row for end of dive, 4=row for max dive depth
y=load(fullfilename);
return
