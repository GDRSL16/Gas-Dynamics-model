function y=extract_max_N2_tensions(z, u, depth) %this program takes the rows for where a dive is occuring and looks for max PN2 for each tissue and also the PN2 for each tissue at max depth
t=2;%the time between data points
%z=LOAD_SUMMARY_DATA;%file has 3 columns: 1=dive number 2=row for start of dive, 3=row for end of dive, 4=row for max dive depth, 5=max depth 
%u=LOAD_SIMULATION_DATA; %loads the data file consisting of 14 columns of simulation data, this is the summary file 
%depth=LOAD_DEPTH_DATA;%loads the depth data
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
col=6;%the number of columns of new data, 1=HeartPN2, 2=musclePN2, 3=brainPN2, 4=fatPN2, 5=arterialPN2, 6=venousPN2, 
max_PN2=zeros(row,col);%array for maximum PN2 for each dive and tissue
PN2_max_depth=zeros(row,col);%array for tissue PN2 at max depth

%start_dive=zeros(row,col);%array for simualtion data at the start of the dive
%end_dive=zeros(row,col);%array for simualtion data at the end of the dive


for i=1:row %for each row
   r_start=z(i,2);%row for start of dive
   r_end=z(i,3);%row for end of dive
   max_depth=z(i,4);%row for where max depth occurs in each dive
   for d=1:col%for column 1 to 6
      max_PN2(i,d)=max(pn2_data(r_start:r_end,d));%grabs the maximum PN2 during the dive
      PN2_max_depth(i,d)=pn2_data(max_depth,d);%grabs the PN2 at the maximum depth,
   end
end

save max_PN2 max_PN2 -ascii -tabs -double
save PN2_max_depth PN2_max_depth -ascii -tabs -double

y=[max_PN2 PN2_max_depth ];
return
