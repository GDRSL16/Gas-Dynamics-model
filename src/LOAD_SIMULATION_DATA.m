%This function asks the user for the data array and inputs it into an array, these modified data files 
function y=LOAD_SIMULATION_DATA(i)
%disp('Please provide the name of for the summary array of 14 columns of PN2 outcome data.');
%[filename,pathname]=uigetfile('*.*','Summary PN2 Data File Name');%gives the name of file and path
%disp(['Data file name: ' filename]);%displays the file name chosen
%fullfilename=[pathname filename];
%y=load(fullfilename);
pathname='C:\Documents and Settings\Andreas\Desktop\n2 kinetics in deep diving whales\';
if i==1
    filename='Divesummary-gm09_138aprh.txt';%pilot whales
elseif i==2
    filename='Divesummary-gm09_138bprh.txt';%pilot whales
elseif i==3
    filename='Divesummary-gm09_156bprh.txt';%pilot whales
elseif i==4
    filename='Divesummary-sw09_141aprh.txt';%sperm whales
elseif i==5
    filename='Divesummary-sw09_142aprh.txt';
elseif i==6
    filename='Divesummary-sw09_160aprh.txt';
elseif i==7
    filename='Dive-summary-oo09_143aprh.txt';%killer whales
elseif i==8
    filename='Dive-summary-oo09_144aprh.txt';%killer whales
elseif i==9
    filename='Dive-summary-oo09_144bprh.txt';%killer whales
elseif i==10
    filename='Dive-summary-oo08-149aprh.txt';%killer whales
elseif i==11
    filename='Divesummary-gm09_137aprh.txt';%pilot whale
elseif i==12
    filename='Divesummary-gm09_137bprh.txt';%pilot whale
elseif i==13
    filename='Divesummary-gm09_137cprh.txt';%pilot whale
elseif i==14
    filename='Divesummary-gm08_154dprh.txt';%pilot whale
elseif i==15
    filename='Divesummary-sw08_152aprh.txt';%pilot whale
elseif i==16
    filename='Divesummary-sw09_153aprh.txt';%pilot whale
elseif i==17
    filename='Divesummary-md07_245a.txt';%Blainville's beaked whale
elseif i==18
    filename='Divesummary-md06_296a.txt';%Blainville's beaked whale
elseif i==19
    filename='Divesummary-md07_227a.txt';%Blainville's beaked whale
elseif i==20
    filename='Divesummary-md07_248a.txt';%Blainville's beaked whale
elseif i==21
    filename='Divesummary-zc10_272a.txt';%Blainville's beaked whale

end
fullfilename=[pathname,filename];
  
 y=load(fullfilename);
return
