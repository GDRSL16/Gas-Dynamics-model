% ============================================================
% Documentation review: 2026-10-18 | Batch 05
% File: extract_ascent_rates.m
% MATLAB function: y=extract_ascent_rates
% Review scope: documentation only; numerical model unchanged.
% Original source preserved verbatim below this header.
% ============================================================
function y=extract_ascent_rates
t=2;%the time between data points
z=LOAD_SUMMARY_DATA;%file has 5 columns: 1=dive number, 2=row for start of dive, 3=row for end of dive, 4=row for max dive depth, 5=max depth
depth=LOAD_DEPTH_DATA_ASCENT;
depth=depth(:,1); %extract the first column
my=GET_MY_FOR_PENGUIN(length(depth),depth,t);


row=length(z);%row is the number of dives in the data set
col=5;%the number of columns of new data, 1=last 6 sec, 2=8-20sec, 3=22-30 sec, 4=32-40sec, 5=42-50 sec
ascent_rates=zeros(row,col);%array for simualtion data at the end of the dive


for i=1:row %for each row
   r_end=z(i,3);%row for end of dive
   r_start=z(i,2);%row for start of dive
   if z(i,5)>50%depth deeper than 50 m
      ascent_rates(i,5)=(sum(my(r_end-25:r_end-21)))/5;%gets the average ascent rate during 42-50 sec before surfacing, only for dives > 42 sec
      ascent_rates(i,4)=(sum(my(r_end-20:r_end-16)))/5;%gets the average ascent rate during 32-40 sec before surfacing, only for dives > 32 sec
      ascent_rates(i,3)=(sum(my(r_end-15:r_end-11)))/5;%gets the average ascent rate during 22-30 sec before surfacing, only for dives > 22 sec
      ascent_rates(i,2)=(sum(my(r_end-10:r_end-4)))/6;%gets the average ascent rate during 8-20 sec before surfacing, only for dives > 8 sec
      ascent_rates(i,1)=(sum(my(r_end-4:r_end-1)))/4;%gets the average ascent rate during 8-2 sec before surfacing, only for dives > 2 sec
   end
end   

y=ascent_rates;
return
