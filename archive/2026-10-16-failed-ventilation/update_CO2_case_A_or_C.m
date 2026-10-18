function [P_CO2_lung_t,n_CO2_lung_t,P_CO2_art_t,n_CO2_art_t]=update_CO2_case_A_or_C(Vblood, sCO2_blood,rt);;
global CO2_ARRAY ALV_SURFACE_VALUE 
%SURFACE_VALUE is a new global variable that will take the place of N2_ARRAY and will also contain O2 and CO2
%SURFACE_VALUE(row,column) where row 1=N2, 2=O2, 3=CO2 and column
%1=Pressure, 2=moles
%this needs some work as blood is a bit more complex
P_CO2_lung_t=ALV_SURFACE_VALUE(3,1);%CO2_ARRAY(1,5,1); %partial pressure of N2 assuming that lung when at surface is constant  
n_CO2_lung_t=ALV_SURFACE_VALUE(3,2);%CO2_ARRAY(1,5,2);%mol N2 in lung
P_CO2_art_t=P_CO2_lung_t; %immediate and no shunt allowed 
n_CO2_art_t=(Vblood*blood_Cco2(ALV_SURFACE_VALUE(2,1), P_CO2_lung_t))/rt; %the change in number of moles from time t-1 to t 

return