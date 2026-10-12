function adjust_Q_tachycardia(perf_adjust,frac_heart,frac_muscle,frac_brain,frac_fat,frac_avshunt, SI_no)%the fractional flow of initial flow for total and then the fractional for each tissue       %ADD
%perf_adjust must be a fraction of initial blood flow i.e. of perfusion goes to 150% of initial value then perf_adjust=1.5

global  BLOOD_PARTITIONS_ART
global BLOOD_PARTITIONS_VEN B_VOL_PACKAGE_ART BLOOD_PARTITIONS_VEN deltaT V_BLOOD_ART  Q_TOT
global Q_TOT Q_HEART Q_FAT Q_MUSCLE Q_BRAIN TEMP_ARRAY deltaT  V_BLOOD_ART B_VOL_PACKAGE_VEN Q_AVSHUNT QTOTARRAY


%Q_TOT=Q_TOT_INIT*perf_adjust;
%TRANSIT_ART=(V_BLOOD_ART/Q_TOT);%transit time (s) of arterial blood equal to arterial blood volume/Q_tot 
%TRANSIT_VEN=(V_BLOOD_VEN/Q_TOT);%transit time (s) of venous blood equal to venous blood volume/Q_tot
%The "round" below makes sure that the packages below always become whole numbers
blood_part_art_old=BLOOD_PARTITIONS_ART;
blood_part_ven_old=BLOOD_PARTITIONS_VEN;
BLOOD_PARTITIONS_ART=BLOOD_PARTITIONS_ART/perf_adjust;%the number of "small" packages of blood from lung to tissue
BLOOD_PARTITIONS_VEN=BLOOD_PARTITIONS_ART*2; %round(TRANSIT_VEN/deltaT);%the number of "small" packages of blood from tissue to lung
B_VOL_PACKAGE_ART=V_BLOOD_ART/BLOOD_PARTITIONS_ART;%The volume of blood (L) in each little package, arterial blood volume/number of packages
B_VOL_PACKAGE_VEN=B_VOL_PACKAGE_ART;%forcing blood volumes in each package to be the same
Q_TOT=(B_VOL_PACKAGE_VEN)/deltaT;%total blood flow gets modified to fit the assumption of a certain number of packages, l/s
dilution_factor=perf_adjust;
%B_VOL_PACKAGE_ART=perf_adjust*(V_BLOOD_ART/BLOOD_PARTITIONS_ART);%The volume of blood (L) in each little package, the number of packages remain constant
%but rather the volume of each package is adjusted. This allows for more molecules to be transported which in essence is the same
%B_VOL_PACKAGE_VEN=B_VOL_PACKAGE_ART;%forcing blood volumes in each package to be the same
%Q_TOT=(B_VOL_PACKAGE_VEN)/deltaT;%total blood flow gets modified to fit the assumption of a certain number of packages, l/s
Q_HEART=Q_TOT*frac_heart;%0.61*Q_TOT; %fraction of blood flow to heart, relative to VO2 to each organ
Q_FAT=Q_TOT*frac_fat;%0.11*Q_TOT;
Q_MUSCLE=Q_TOT*frac_muscle; 
Q_BRAIN=Q_TOT*frac_brain;%
Q_AVSHUNT=Q_TOT*frac_avshunt; 
QTOTARRAY(SI_no+1,6)=Q_TOT; %tota diving heart rate in l/s
QTOTARRAY(SI_no+1,7)=Q_HEART;%see QTOTARRAY above where Q_tot is defined and initiliazed 
QTOTARRAY(SI_no+1,8)=Q_MUSCLE;
QTOTARRAY(SI_no+1,9)=Q_BRAIN;
QTOTARRAY(SI_no+1,10)=Q_FAT;
%ADD
%%%%%%%%%%%%%%%EXPAND OR CONTRACT THE TEMPORARY ARRAY
total_blood_part=BLOOD_PARTITIONS_ART+BLOOD_PARTITIONS_VEN;
temp_blood_old=TEMP_ARRAY;
%temp_array=TEMP_ARRAY;
temp_array=zeros(total_blood_part,3,3);
l=total_blood_part;%do for each of the new temporary arrays
for t=1:l
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%N2%%%%%%%%%%%%%%%%%%%%%%%%%%
      temp_array(t,1,1)=mean(temp_blood_old(((t-1)*dilution_factor+1):dilution_factor*t,1,1));%blood tension of N2 is the same as before
      temp_array(t,2,1)=sum(temp_blood_old(((t-1)*dilution_factor+1):dilution_factor*t,2,1));%number of moles N2
      temp_array(t,3,1)=mean(temp_blood_old(((t-1)*dilution_factor+1):dilution_factor*t,3,1));%blood pH, unchanged
     
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%O2%%%%%%%%%%%%%%%%%%%%%%%%%%
      temp_array(t,1,2)=mean(temp_blood_old(((t-1)*dilution_factor+1):dilution_factor*t,1,2));%blood tension of O2 is the same as before
      temp_array(t,2,2)=sum(temp_blood_old(((t-1)*dilution_factor+1):dilution_factor*t,2,2));%number of moles O2
      temp_array(t,3,2)=mean(temp_blood_old(((t-1)*dilution_factor+1):dilution_factor*t,3,2));%blood pH, unchanged
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%CO2%%%%%%%%%%%%%%%%%%%%%%%%%%
      temp_array(t,1,3)=mean(temp_blood_old(((t-1)*dilution_factor+1):dilution_factor*t,1,3));%blood tension of CO2 is the same as before
      temp_array(t,2,3)=sum(temp_blood_old(((t-1)*dilution_factor+1):dilution_factor*t,2,3));%number of moles CO2
      temp_array(t,3,3)=mean(temp_blood_old(((t-1)*dilution_factor+1):dilution_factor*t,3,3));%blood pH, unchanged
end
TEMP_ARRAY=temp_array;
return