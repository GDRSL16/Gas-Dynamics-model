% ========================================================================
% Second-round internal documentation review: 2026-10-18 | Batch 02
% File: LOAD_DEPTH_DATA_ASCENT.m
% Review focus: Input loader. File format, indexing, time alignment and missing-data behavior should be documented from the calling workflow.
% Documentation only: original MATLAB source follows unchanged.
% ========================================================================
% ========================================================================
% Documentation reviewed: 2026-10-18 | Batch 02
% Purpose: Interactively load depth-related data used for ascent analysis.
% Interface: No arguments; returns the selected file as a numeric array.
% Review note: The original file filter and loader behavior are retained.
% Scope: Documentation only; all pre-existing lines remain unchanged.
% ========================================================================

function y=LOAD_DEPTH_DATA_ASCENT
disp('Please provide the name of the array of dive depth data.');
[filename,pathname]=uigetfile('*.*','Depth Data File Name');%gives the name of file and path
disp(['Data file name: ' filename]);%displays the file name chosen
fullfilename=[pathname filename];%file has 4 columns: 1=dive number, 2=row for start of dive, 3=row for end of dive, 4=row for max dive depth
y=load(fullfilename);
return
