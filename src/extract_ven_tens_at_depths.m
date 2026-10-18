% ============================================================
% Documentation review: 2026-10-18 | Batch 05
% File: extract_ven_tens_at_depths.m
% MATLAB function: y=extract_ven_tens_at_depths
% Review scope: documentation only; numerical model unchanged.
% Original source preserved verbatim below this header.
% ============================================================
function y=extract_ven_tens_at_depths
t=2;%the time between data points
z=LOAD_SUMMARY_DATA;%file has 14 columns: 1=row for depth150-100, 2=row for depth100-80, 3=row for depth80-50, 4=row for depth50-30, 5=row for depth30-10
%6=row for depth10-5 7=row for depth5-0, 8=ven PN2 for row 1, 9=ven PN2 for row 2, 10=ven PN2 for row 3, 11=ven PN2 for row 4, 12=ven PN2 for row 5, 
%13=ven PN2 for row 6, 14=ven PN2 for row 7
u=LOAD_SIMULATION_DATA; %loads the data file consisting of 14 columns of PN2 simulation data, this is the summary file 
depth=LOAD_DEPTH_DATA;%loads the depth data
depth=depth(:,1); %extract the first column
%my=GET_MY_FOR_PENGUIN(length(depth),depth,t);


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
col=7;%the number of columns of depth ranges 1-7 in z above
pn2asc=ones(row,col)*-9;% this is the new array with venous PN2 values

start_dive=zeros(row,col);%array for simualtion data at the start of the dive
end_dive=zeros(row,col);%array for simualtion data at the end of the dive


for i=1:row
   for p=1:col
      if z(i,p)~=-9
         if p==7
            start_asc=z(i,p);
            end_asc=start_asc+2;z(i,p+1);
         else  
            start_asc=z(i,p);
            end_asc=z(i,p+1);
         end
         pn2asc(i,p)=mean(pn2_data(start_asc:end_asc,6));
      end
   end
end
save pn2asc pn2asc -ascii -tabs -double
y=pn2asc;

return
