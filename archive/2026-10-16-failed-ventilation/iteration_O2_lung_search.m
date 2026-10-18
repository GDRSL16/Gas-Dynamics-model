function [n_O2_lung_t, P_O2_art_t, n_O2_art_t]=iteration_O2_lung_search(rt,i,P_O2_lung_tmin1, n_O2_lung_tmin1, P_O2_ven_tmin1, n_O2_ven_tmin1,Pamb,shunt);
format long e
global B_VOL_PACKAGE_VEN SO2_BLOOD O2_ARRAY VLinit0 VLinit BLOOD_PARTITIONS_VEN BLOOD_PARTITIONS_ART TEMP_ARRAY
global LUNG_VOL ART_VEN_PCO2 STPD_TO_BT DEBUG
if shunt==1%no gas exchange and arterial at t is venous at t-1
    P_O2_art_t=P_O2_ven_tmin1;
    n_O2_art_t=n_O2_ven_tmin1;
    P_O2_lung_t=P_O2_lung_tmin1;
    n_O2_lung_t=n_O2_lung_tmin1;

else
   
   pco2_blood=TEMP_ARRAY((BLOOD_PARTITIONS_ART+BLOOD_PARTITIONS_VEN),1,3);%venous PCO2 at time t-1
   %Pamb is ambient pressure at i-1 and i
   vl=LUNG_VOL(i,1)+LUNG_VOL(i,2);%the lung volume at time i
   vol_blood_via_lung=B_VOL_PACKAGE_VEN*(1-shunt);%blood volume that is not shunted
   nO2_in_blood_via_lung=n_O2_ven_tmin1*(1-shunt);%assuming a homogensouly mixed blood volume that is split in 1-shunt and shunt fractions, 1-shunt is in the volume of blood available to exchange with lung
   nO2_shunted_past_lung=n_O2_ven_tmin1-nO2_in_blood_via_lung;
   mol_O2_lung_exchange=(nO2_in_blood_via_lung+n_O2_lung_tmin1);%total moles participating in exchange
   %I assume that PCO2 (for calculating S in blood_lung_Po2 is the average
   %between venous and last arterial

   %P_O2_lung_t=blood_lung_Po2((pco2_blood),mol_O2_lung_exchange,vl,vol_blood_via_lung)%setting lung and blood CO2 pressures equal, uses only venous PCO2 to estimate S uses the average of current venous and last arterial PCO2 to estimate saturation
%%%%%%%%%%%%%%%%%%DEBUG SECTION   
%ggf=DEBUG;
%if ggf> 571035
%    pp="iteration_O2_lung_search"
%    pco2_blood%part of Pco2
%    ART_VEN_PCO2(i-1,1)%part of pco2
%    mol_O2_lung_exchange%nO2tot
%    vl% Vlung
%    vol_blood_via_lung%Vblood
%    ggf
%end


   P_O2_lung_t=blood_lung_Po2((pco2_blood+ART_VEN_PCO2(i-1,1))/2,mol_O2_lung_exchange,vl,vol_blood_via_lung);%setting lung and blood CO2 pressures equal
   n_O2_lung_t=(P_O2_lung_t*vl)/rt; %moles CO2 in lung at time t, after exchange

   nO2_in_blood_via_lung=nO2_in_blood_via_lung+(n_O2_lung_tmin1-n_O2_lung_t);%new and working
   %P_O2_art_t=blood_Po2((pco2_blood+ART_VEN_PCO2(i-1,1))/2,nO2_in_blood_via_lung*rt/vol_blood_via_lung)
   n_O2_art_t=nO2_in_blood_via_lung+nO2_shunted_past_lung;%the moles CO2 left in blood after lung exchange and when joined with shunted blood, i.e. moles CO2 in arterial blood at time t


   %%%NEEDS checking AS WHEN PCO2 IS CALCULATED IT SHOULD HAVE THE ARTERIAL PCO2, USE arterial PCO2 at time t-1 from temporary array ART_VEN_PCO2(i,1)

   P_O2_art_t=blood_Po2(ART_VEN_PCO2(i-1,1),n_O2_art_t*rt/(B_VOL_PACKAGE_VEN));%this is a bit tricky as I assume that S=is at t-1
   %P_O2_art_t=blood_Po2(pco2_blood,n_O2_art_t*rt/B_VOL_PACKAGE_VEN);%uses%only venous PCO2 
   %debugging check, this must be true and these must be equal but of opposite
   %sign
end
    %shunt
    %lung=n_O2_lung_tmin1-n_O2_lung_t%delta moles in lung
    %lung=P_O2_lung_tmin1-P_O2_lung_t%delta moles in lung
    %blood=n_O2_ven_tmin1-n_O2_art_t%delta moles in blood
    %blood=P_O2_ven_tmin1-P_O2_art_t%delta moles in blood
return   





