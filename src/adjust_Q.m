% ============================================================
% Code documentation review: 2026-10-18 (Batch 03)
% Purpose: Adjusts blood-package circulation and tissue perfusion.
% Interface: Inputs: perf_adjust and fractional tissue perfusion values.
% Notes: Uses global blood package sizes and flow variables; package counts can change with perfusion.
% Review scope: Documentation only; model logic unchanged.
% ============================================================
function adjust_Q(perf_adjust,frac_heart,frac_fat,frac_muscle,frac_brain)%the fractional flow of initial flow for total and then the fractional for each tissue
%this function will not work properly if body mass changes as then the expanded or contracted arrays have mismatches
global Q_TOT_INIT Q_HEART_INIT Q_FAT_INIT Q_MUSCLE_INIT Q_BRAIN_INIT TRANSIT_ART TRANSIT_VEN BLOOD_PARTITIONS_ART
global BLOOD_PARTITIONS_VEN B_VOL_PACKAGE_ART BLOOD_PARTITIONS_VEN deltaT V_BLOOD_ART V_BLOOD_VEN Q_TOT
global Q_TOT Q_HEART Q_FAT Q_MUSCLE Q_BRAIN TEMP_ARRAY deltaT BLOOD_PARTITIONS_ART_INIT BLOOD_PARTITIONS_VEN_INIT
%Q_TOT=Q_TOT_INIT*perf_adjust;
%TRANSIT_ART=(V_BLOOD_ART/Q_TOT);%transit time (s) of arterial blood equal to arterial blood volume/Q_tot 
%TRANSIT_VEN=(V_BLOOD_VEN/Q_TOT);%transit time (s) of venous blood equal to venous blood volume/Q_tot
%The "round" below makes sure that the packages below always become whole numbers
blood_part_art_old=BLOOD_PARTITIONS_ART;
blood_part_ven_old=BLOOD_PARTITIONS_VEN;
BLOOD_PARTITIONS_ART=BLOOD_PARTITIONS_ART_INIT/perf_adjust;%the number of "small" packages of blood from lung to tissue
BLOOD_PARTITIONS_VEN=BLOOD_PARTITIONS_ART*2; %round(TRANSIT_VEN/deltaT);%the number of "small" packages of blood from tissue to lung
B_VOL_PACKAGE_ART=V_BLOOD_ART/BLOOD_PARTITIONS_ART;%The volume of blood (L) in each little package, arterial blood volume/number of packages
B_VOL_PACKAGE_VEN=B_VOL_PACKAGE_ART;%forcing blood volumes in each package to be the same
Q_TOT=(B_VOL_PACKAGE_VEN)/deltaT;%total blood flow gets modified to fit the assumption of a certain number of packages, l/s
dilution_factor_art=blood_part_art_old/BLOOD_PARTITIONS_ART;
dilution_factor_ven =blood_part_ven_old/BLOOD_PARTITIONS_VEN;%the dilution or concentration that needs to be made for the temporary array to keep mass balance

%B_VOL_PACKAGE_ART=perf_adjust*(V_BLOOD_ART/BLOOD_PARTITIONS_ART);%The volume of blood (L) in each little package, the number of packages remain constant
%but rather the volume of each package is adjusted. This allows for more molecules to be transported which in essence is the same
%B_VOL_PACKAGE_VEN=B_VOL_PACKAGE_ART;%forcing blood volumes in each package to be the same
Q_TOT=(B_VOL_PACKAGE_VEN)/deltaT;%total blood flow gets modified to fit the assumption of a certain number of packages, l/s
Q_HEART=Q_TOT*frac_heart;%0.61*Q_TOT; %fraction of blood flow to heart, relative to VO2 to each organ
Q_FAT=Q_TOT*frac_fat;%0.11*Q_TOT;
Q_MUSCLE=Q_TOT*frac_muscle; 
Q_BRAIN=Q_TOT*frac_brain;%
%%%%%%%%%%%%%%%EXPAND OR CONTRACT THE TEMPORARY ARRAY
temp_art_old=TEMP_ARRAY(1:blood_part_art_old,:,:); %the old arterial data
temp_ven_old=TEMP_ARRAY(blood_part_art_old:blood_part_art_old+blood_part_ven_old,:,:); %the old venuous data
for y=1:BLOOD_PARTITIONS_ART
TEMP_ARRAY

return