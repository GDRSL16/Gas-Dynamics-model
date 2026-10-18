% ========================================================================
% Second-round internal documentation review: 2026-10-18 | Batch 05
% File: extract_boutstartend_N2_tension.m
% Review focus: Post-processing extraction. Verify array indexing, output units and assumptions about dive boundaries.
% Documentation only: original MATLAB source follows unchanged.
% ========================================================================
% ============================================================
% Documentation review: 2026-10-18 | Batch 05
% File: extract_boutstartend_N2_tension.m
% MATLAB function: y=extract_boutstartend_N2_tension
% Review scope: documentation only; numerical model unchanged.
% Original source preserved verbatim below this header.
% ============================================================
function y=extract_boutstartend_N2_tension
t=2;%the time between data points
z=LOAD_SUMMARY_DATA;%file has 2 columns: 1=row for start of bout, 2=row for end of bout
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
col=6;%the number of columns of new data, 1=HeartPN2, 2=musclePN2, 3=brainPN2, 4=fatPN2, 5=arterialPN2, 6=venousPN2
start_bout=zeros(row,col);%array for simualtion data at the start of the dive
end_bout=zeros(row,col);%array for simualtion data at the end of the dive


for i=1:row %for each row
   r_start=z(i,1);%row for start of bout
   r_end=z(i,2);%row for end of bout
   for d=1:col%for column 1 to 6
      start_bout(i,d)=pn2_data(r_start,d);%grabs the PN2 at the start of the bout
      end_bout(i,d)=pn2_data(r_end,d);%grabs the PN2 at the end of the bout
   end
end
save start_bout start_bout -ascii -tabs -double
save end_bout end_bout -ascii -tabs -double

y=[start_bout end_bout];
return
