% ============================================================
% Code documentation review: 2026-10-18 (Batch 03)
% Purpose: Prompts for and loads a dive-summary text file.
% Interface: Returns the loaded numeric summary matrix.
% Notes: Uses a graphical file selector; the original comments describe the summary columns.
% Review scope: Documentation only; model logic unchanged.
% ============================================================
%This function asks the user for the data array and inputs it into an array, these modified data files 
function y=LOAD_SUMMARY_DATA
disp('Please provide the name of for depth summary data.');
[filename,pathname]=uigetfile('*.txt','File for row for each dive file Name');%gives the name of file and path
disp(['Data file name: ' filename]);%displays the file name chosen
fullfilename=[pathname filename];%file has 4 columns: 1=dive number, 2=row for start of dive, 3=row for end of dive, 4=row for max dive depth
y=load(fullfilename);
return
