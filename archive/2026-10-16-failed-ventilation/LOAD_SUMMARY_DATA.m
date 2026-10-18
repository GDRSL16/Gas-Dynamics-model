%This function asks the user for the data array and inputs it into an array, these modified data files 
function y=LOAD_SUMMARY_DATA
disp('Please provide the name of for depth summary data.');
[filename,pathname]=uigetfile('*.txt','File for row for each dive file Name');%gives the name of file and path
disp(['Data file name: ' filename]);%displays the file name chosen
fullfilename=[pathname filename];%file has 4 columns: 1=dive number, 2=row for start of dive, 3=row for end of dive, 4=row for max dive depth
y=load(fullfilename);
return
