% ========================================================================
% Documentation reviewed: 2026-10-18 | Batch 02
% Purpose: Calculate dive-level summaries from depth, ODBA and locomotion inputs.
% Interface: depth, odba and vo2_odba are input series; summary arrays are global.
% Review note: Uses dive-boundary information from global DIVE_DURATION.
% Scope: Documentation only; all pre-existing lines remain unchanged.
% ========================================================================

%this function estimates the dive duration, maxdepth, max compression and decompression rate, average (+- SD) depth, 
%max and min heart rate for each dive. It is by necessity long since I want to avoid scrolling through long data sets 
%several times

function GET_odba_summary_N2(depth, odba, vo2_odba)

global N N2  NO_DIVES DIVE_DURATION COLUMN_NO_DEPTH COLUMN_NO_HR COLUMN_NO_dP_dt COLUMN_NO_dHR_dt DIVE_SUMMARY MY ECG1 ECG2 LOGGER OESOPHAGEAL PECTORAL

%%%%%%%%%%%%%%%%%%%%%%%%VARIABLES%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
row_begin=DIVE_DURATION(:,3)-1;%gets the row value for a start of a dive
row_end=DIVE_DURATION(:,4);%gets the row value for an end of a dive
depth_array=0;%array to hold sub_arrays of depth, i.e. the range to be used to compute average etc
dive_num=NO_DIVES;
d=size(DIVE_DURATION);%gets the number
summary_array(dive_num,13)=zeros;%holds 1=maxdepth,2=AV depth,3=SD depth, 4=min comp, 5=mean comp, 6=comp SD, 7=max HR change, 8=mean odba, 9=max odba, 10=SD odba, 11=mean vo2 based on odba, 12=max vo2, 13=sd vo2
%%%%%%%%%%%%%%%%%%%%%%%%VARIABLES%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
if dive_num~=d(1) %if dive_num and d(1) are not equal there is something wrong
   display('ERROR');
   %quit;
end

for i=1:dive_num
   
   %if row_begin(i)==0 %debugging for when data ends in dive.
   %   row_begin(i)=row_end(i)
   %end
   depth_array=depth(row_begin(i):row_end(i)); %extracts the depth data for this dive from DIVE_DURATION
   comp_array=MY(row_begin(i):row_end(i));%extracts the depth data for this dive from DIVE_DURATION
   odba_array=odba(row_begin(i):row_end(i));
   vo2_odba_array=vo2_odba(row_begin(i):row_end(i));
   
   summary_array(i,1)=max(depth_array);
   summary_array(i,2)=mean(depth_array);
   summary_array(i,3)=std(depth_array);
   summary_array(i,4)=max(comp_array);
   summary_array(i,5)=min(comp_array);
   summary_array(i,6)=mean(comp_array);
   summary_array(i,7)=std(comp_array);
   summary_array(i,8)=max(odba_array);
   summary_array(i,9)=mean(odba_array);
   summary_array(i,10)=std(odba_array);
   summary_array(i,11)=max(vo2_odba_arrayy);
   summary_array(i,12)=mean(vo2_odba_array);
   summary_array(i,13)=std(vo2_odba_array);
end
DIVE_SUMMARY=summary_array;
return
