% ========================================================================
% Second-round internal documentation review: 2026-10-18 | Batch 02
% File: N2_extract_before_EOD.m
% Review focus: Post-processing extraction. Verify array indexing, output units and assumptions about dive boundaries.
% Documentation only: original MATLAB source follows unchanged.
% ========================================================================
% ============================================================
% Code documentation review: 2026-10-18 (Batch 03)
% Purpose: Extracts N2 tension measurements near the end of dives.
% Interface: Loads dive summaries, simulation outputs, and depth records.
% Notes: Original code assumes a two-second sampling interval; verify source-data alignment.
% Review scope: Documentation only; model logic unchanged.
% ============================================================
function y=N2_extract_before_EOD %extracts N2 tensions 5, 10, 15 and 30 sec before the end of the dive
t=2;%the time between data points
z=LOAD_SUMMARY_DATA;%file has 5 columns: 1=dive number, 2=row for start of dive, 3=row for end of dive, 4=row for max dive depth, 5=max depth
u=LOAD_SIMULATION_DATA; %loads the data file consisting of 14 columns of simulation data, this is the summary file 
depth=LOAD_DEPTH_DATA;%loads the depth data
depth=depth(:,1); %extract the first column
my=GET_MY_FOR_PENGUIN(length(depth),depth,t);

pn2_data(:,1)=u(:,1);%heart N2 tension
pn2_data(:,2)=u(:,2);%muscle N2 tension
pn2_data(:,3)=u(:,3);%brain N2 tension
pn2_data(:,4)=u(:,4);%fat N2 tension
pn2_data(:,5)=u(:,11);%arterial tension
pn2_data(:,6)=u(:,12);%venous tension
pn2_data(:,7)=u(:,13);%ambient pressure
pn2_data(:,8)=depth;%depth in meter
pamb_surface=pn2_data(1,7);%the water vapour corrected pressure in ATA for surface value, i.e. 0 m or 1 ATA

row=length(z);%row is the number of dives in the data set
col=8;%the number of columns of new data, 1=HeartPN2, 2=musclePN2, 3=brainPN2, 4=fatPN2, 5=arterialPN2, 6=venousPN2, 7=ascent rate last 10 sec, 8=ascent rate last 20 sec
end_dive5=ones(row,col)*-9;%array for simualtion data at the end of the dive
end_dive10=ones(row,col)*-9;%array for simualtion data at the end of the dive
end_dive15=ones(row,col)*-9;%array for simualtion data at the end of the dive
end_dive30=ones(row,col)*-9;%array for simualtion data at the end of the dive
end_dive60=ones(row,col)*-9;%array for simualtion data at the end of the dive

for i=1:row %for each row
   r_end=z(i,3);%row for end of dive
   r_start=z(i,2);%row for start of dive
   if r_end-r_start>30
      for d=1:col%for column 1 to 8
         end_dive5(i,d)=mean(pn2_data(r_end-5:r_end-3,d),1);%grabs the PN2 at the end of the dive
         end_dive10(i,d)=mean(pn2_data(r_end-10:r_end-8,d),1);%grabs the PN2 at the end of the dive
         end_dive15(i,d)=mean(pn2_data(r_end-15:r_end-13,d),1);%grabs the PN2 at the end of the dive
         end_dive30(i,d)=mean(pn2_data(r_end-30:r_end-28,d),1);%grabs the PN2 at the end of the dive
         end_dive60(i,d)=mean(pn2_data(r_end-60:r_end-58,d),1);%grabs the PN2 at the end of the dive
      end
   end
end
save end_dive5 end_dive5 -ascii -tabs -double
save end_dive10 end_dive10 -ascii -tabs -double
save end_dive15 end_dive15 -ascii -tabs -double
save end_dive30 end_dive30 -ascii -tabs -double
save end_dive60 end_dive60 -ascii -tabs -double

y=[end_dive5; end_dive10; end_dive15; end_dive30];
return
