% ========================================================================
% Documentation reviewed: 2026-10-18 | Batch 01
% Purpose: Legacy selector for ODBA and associated dive time-series data.
% Interface: i selects a recording; returns the selected numeric input array.
% Review note: Contains a machine-specific pathname and legacy file mappings; not changed here.
% Scope: Documentation only; all pre-existing lines remain unchanged.
% ========================================================================

% ============================================================
% Documentation review: 2026-10-18 | Batch 01
% Scope: Review tracking header only; original code preserved.
% Numerical calculations, logic, and existing comments unchanged.
% ============================================================
%This function asks the user for the data array and inputs it into an array, these modified data files 
function y=GET_DIVE_ODBA(i);
% Legacy input selector: numeric recording indices and file paths are fixed in this routine.
% Portability note: machine-specific paths should be configured separately in a future functional revision.
%disp('Please provide the name of for the array of outcome data.');
%[filename,pathname]=uigetfile('*.txt','Outcome Data File Name');%gives the name of file and path
%disp(['Data file name: ' filename]);%displays the file name chosen
%fullfilename=[pathname filename];
pathname='C:\Users\afahl\WORK\proposals\ONR\ONR-2024\Marine Mammal Biology\Beaked whale modeling-activity and gas dynamics\full proposal\Model\Model and data';
%4 columns, 1:time sec in atm, 2:depth m, 3=odba (g), 4-odba converted to cost of locomotion (COL, watts)
if i==1
    y=csvread('1-Zica-20191012-144029_surfacings_1Hz-data.csv',1,0);%beaked whale
elseif i==2
    y=csvread('2-Zica-20191012-145101_surfacings_1Hz-data.csv',1,0);%beaked whale
elseif i==3
    y=csvread('3-Zica-20191111-94810_surfacings_1Hz-data.csv',1,0);%beaked whale
elseif i==4
    y=csvread('4-Zica-20191117-195993_surfacings_1Hz-data.csv',1,0);%beaked whale
elseif i==5
    y=csvread('5-Zica-20211112-94819_surfacings_1Hz-data.csv',1,0);%beaked whale
elseif i==6
    y=csvread('6-Zica-20211113-195993_surfacings_1Hz-data.csv',1,0);%beaked whale
elseif i==7
      y=csvread('7-Zica-20220112-195994_surfacings_1Hz-data.csv',1,0);%beaked whale
elseif i==8
     y=csvread('8-Zica-20230518-233391_surfacings_1Hz-data.csv',1,0);%s
elseif i==9
     y=csvread('9-Zica-20230519-232950_surfacings_1Hz-data.csv',1,0);%s
elseif i==10
     y=csvread('10-Zica-20230723-233394_surfacings_1Hz-data.csv',1,0);%s
elseif i==11
     y=csvread('11-Zica-20240227-233396_surfacings_1Hz-data.csv',1,0);%s
elseif i==12
     y=csvread('12-Zica-20240227-240128_surfacings_1Hz-data.csv',1,0);%s
elseif i==13
     y=csvread('13-shallow_20x600s_20m_data.csv',1,0);%s
elseif i==14
     y=csvread('14-intermediate_10x1200s_400m_data.csv',1,0);%s
elseif i==15
     y=csvread('15-deep_5x3000s_1200m_data.csv',1,0);%s
elseif i==16
     y=csvread('16-1A-intermediate_20x1200s_400m_2h_pre_180s_SI_1h_post_data.csv',1,0);%s
elseif i==17
     y=csvread('17-1B-intermediate_20x1200s_400m_2h_pre_180s_SI_1h_post_data.csv',1,0);%s
elseif i==18
     y=csvread('18-1C-intermediate_20x1200s_400m_2h_pre_360s_SI_1h_post_data.csv',1,0);%
elseif i==19
     y=csvread('19-1D-intermediate_20x1200s_400m_2h_pre_180s_SI_1h_post_data.csv',1,0);%s
elseif i==20
     y=csvread('20-1E-intermediate_20x1200s_400m_10h_pre_3bpm_180s_SI_10h_post_data.csv',1,0);%s
elseif i==21
     y=csvread('21-1F-intermediate_20x1200s_400m_2h_pre_1bpm_180s_SI_1h_post_data.csv',1,0);%s
end
%fullfilename=[pathname,filename];
  
 %y=csvread(fullfilename,1,0); %reads in the data file without the header
return



                       