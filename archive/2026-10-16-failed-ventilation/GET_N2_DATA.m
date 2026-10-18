function y=GET_N2_DATA
disp('Please provide the name of for the array of outcome data.');
[filename,pathname]=uigetfile('*.*','Outcome Data File Name');%gives the name of file and path
disp(['Data file name: ' filename]);%displays the file name chosen
fullfilename=[pathname filename];
y=load(fullfilename);
end