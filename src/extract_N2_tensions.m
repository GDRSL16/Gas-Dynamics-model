function y=extract_N2_tensions(zx,u,depth)
t=1;%the time between data points
z=LOAD_SIMULATION_DATA(zx);%file has 5 columns: 1=dive number, 2=row for start of dive, 3=row for end of dive, 4=row for max dive depth, 5=max depth
%u=LOAD_SIMULATION_DATA; %loads the data file consisting of 14 columns of simulation data, this is the summary file 
%depth=LOAD_DEPTH_DATA;%loads the depth data
depth=depth(:,1); %extract the first column
my=GET_MY_FOR_PENGUIN(length(depth),depth,t);

pn2_data(:,1)=u(:,1);%heart N2 tension
pn2_data(:,2)=u(:,2);%muscle N2 tension
pn2_data(:,3)=u(:,3);%brain N2 tension
pn2_data(:,4)=u(:,4);%fat N2 tension
pn2_data(:,5)=u(:,16);%arterial tension
pn2_data(:,6)=u(:,17);%venous tension
pn2_data(:,7)=u(:,22);%ambient pressure
pn2_data(:,8)=depth;%depth in meter
pamb_surface=pn2_data(1,7);%the water vapour corrected pressure in ATA for surface value, i.e. 0 m or 1 ATA

row=length(z);%row is the number of dives in the data set
col=8;%the number of columns of new data, 1=HeartPN2, 2=musclePN2, 3=brainPN2, 4=fatPN2, 5=arterialPN2, 6=venousPN2, 7=ascent rate last 10 sec, 8=ascent rate last 20 sec
start_dive=zeros(row,col);%array for simualtion data at the start of the dive
end_dive=zeros(row,col);%array for simualtion data at the end of the dive


for vu=1:row %for each row
   r_start=z(vu,2);%row for start of dive
   r_end=z(vu,3);%row for end of dive
   for d=1:col-2%for column 1 to 6
      start_dive(vu,d)=pn2_data(r_start,d);%grabs the PN2 at the start of the dive
      end_dive(vu,d)=pn2_data(r_end,d);%grabs the PN2 at the end of the dive
      
   end
   if r_end-r_start>50
       end_dive(vu,7)=(sum(my(r_end-10:r_end)))/10;%gets the average ascent rate during the last 10 sec in m/sec, only for dives > 40 sec
      end_dive(vu,8)=(sum(my(r_end-40:r_end-20)))/20;%gets the average ascent rate during the last initial portion of the ascent sec in m/sec
   else  
   	end_dive(vu,7)=-9;
      end_dive(vu,8)=-9;
   end
   start_dive(vu,7:8)=-9;
end
%e=extract_max_N2_tensions(z, u, depth);%calls the extract_max function that extract maximum PN2s during each dive
%save start_dive start_dive -ascii -tabs -double
%save end_dive.txt end_dive -ascii -tabs -double

if zx==1
    save end_dive_N2_gm09_138aprh end_dive -ascii -tabs
    save start_dive_N2_gm09_138aprh start_dive -ascii -tabs
elseif zx==2
    save end_dive_N2_gm09_138bprh end_dive -ascii -tabs
    save start_dive_N2_gm09_138bprh start_dive -ascii -tabs
elseif zx==3
    save end_dive_N2_gm09_156bprh end_dive -ascii -tabs
    save start_dive_N2_gm09_156bprh start_dive -ascii -tabs
elseif zx==4
    save end_dive_N2_sw09_141aprh end_dive -ascii -tabs
    save start_dive_N2_sw09_141aprh start_dive -ascii -tabs
elseif zx==5
    save end_diveN2_sw09_142aprh end_dive -ascii -tabs
    save start_diveN2_sw09_142aprh start_dive -ascii -tabs
elseif zx==6
    save end_dive_N2_sw160aprh end_dive -ascii -tabs
    save start_dive_N2_sw160aprh start_dive -ascii -tabs
elseif zx==7
    save end_dive_N2_oo09_143aprh end_dive -ascii -tabs
    save start_dive_N2_oo09_143aprh start_dive -ascii -tabs
elseif zx==8
    save end_dive_N2_oo09_144aprh end_dive -ascii -tabs
    save start_dive_N2_oo09_144aprh start_dive -ascii -tabs
elseif zx==9
    save end_dive_N2_oo09_144bprh end_dive -ascii -tabs
    save start_dive_N2_oo09_144bprh start_dive -ascii -tabs
elseif zx==10
    save end_dive_oo08_149aprh end_dive -ascii -tabs
    save start_dive_N2_oo08_149aprh start_dive -ascii -tabs
elseif zx==11
     save end_dive_gm09_137aprh end_dive -ascii -tabs
    save start_dive_N2_gm09_137aprh start_dive -ascii -tabs
elseif zx==12
     save end_dive_gm09_137bprh end_dive -ascii -tabs
    save start_dive_N2_gm09_137bprh start_dive -ascii -tabs
elseif zx==13
     save end_dive_gm09_137cprh end_dive -ascii -tabs
    save start_dive_N2_gm09_137cprh start_dive -ascii -tabs
elseif zx==14
     save end_dive_gm08_154dprh end_dive -ascii -tabs
    save start_dive_N2_gm08_154dprh start_dive -ascii -tabs
elseif zx==15
     save end_dive_sw08_152aprh end_dive -ascii -tabs
    save start_dive_N2_sw08_152aprh start_dive -ascii -tabs
elseif zx==16
     save end_dive_sw09_153aprh end_dive -ascii -tabs
    save start_dive_N2_sw09_153aprh start_dive -ascii -tabs
elseif zx==17
    save end_dive_md07_245a end_dive -ascii -tabs
    save start_dive_md07_245a start_dive -ascii -tabs
elseif zx==18
    save end_dive_md06_296a end_dive -ascii -tabs
    save start_dive_md06_296a start_dive -ascii -tabs
elseif zx==19
    save end_dive_md07_227a end_dive -ascii -tabs
    save start_dive_md07_227a start_dive -ascii -tabs
elseif zx==20
    save end_dive_md07_248a end_dive -ascii -tabs
    save start_dive_md07_248a start_dive -ascii -tabs
elseif zx==21
    save end_dive_zc10_272a end_dive -ascii -tabs
    save start_dive_zc10_272a start_dive -ascii -tabs
end
y=[start_dive end_dive];
return
