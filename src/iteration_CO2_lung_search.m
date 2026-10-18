% ========================================================================
% Documentation reviewed: 2026-10-18 | Batch 02
% Purpose: Calculate pulmonary CO2 transfer and arterial CO2 state for one step.
% Interface: Inputs include prior lung/venous CO2, ambient conditions, time index and shunt.
% Review note: A full shunt bypasses pulmonary exchange; existing blood chemistry is preserved.
% Scope: Documentation only; all pre-existing lines remain unchanged.
% ========================================================================

function [n_CO2_lung_t, P_CO2_art_t, n_CO2_art_t]=iteration_CO2_lung_search(rt,i,P_CO2_lung_tmin1, n_CO2_lung_tmin1, P_CO2_ven_tmin1, n_CO2_ven_tmin1,Pamb,shunt);
format long e
global B_VOL_PACKAGE_VEN SCO2_BLOOD P_AMB CO2_ARRAY VLinit0 VLinit BLOOD_PARTITIONS_VEN BLOOD_PARTITIONS_ART TEMP_ARRAY
global LUNG_VOL ART_VEN_PCO2 ART_VEN_PO2 STPD_TO_BT

if shunt==1%no gas exchange and arterial at t is venous at t-1
    P_CO2_art_t=P_CO2_ven_tmin1;
    n_CO2_art_t=n_CO2_ven_tmin1;
    P_CO2_lung_t=P_CO2_lung_tmin1;
    n_CO2_lung_t=n_CO2_lung_tmin1;

else
   po2_ven_blood=TEMP_ARRAY((BLOOD_PARTITIONS_VEN+BLOOD_PARTITIONS_ART),1,2);%venous PO2 at time t-1
   po2_art_blood=ART_VEN_PO2(i-1,1);%arterial blood PO2 at time t
   %Pamb is ambient pressure at i-1 and i
   vl=LUNG_VOL(i,1)+LUNG_VOL(i,2);%the lung volume at time i
   vol_blood_via_lung=B_VOL_PACKAGE_VEN*(1-shunt);%blood volume that is not shunted
   nCO2_in_blood_via_lung=n_CO2_ven_tmin1*(1-shunt);%assuming a homogensouly mixed blood volume that is split in 1-shunt and shunt fractions, 1-shunt is in the volume of blood available to exchange with lung
   nCO2_shunted_past_lung=n_CO2_ven_tmin1-nCO2_in_blood_via_lung;

   mol_CO2_lung_exchange=(nCO2_in_blood_via_lung+n_CO2_lung_tmin1);%total moles participating in exchange

   %%%%%Need to ad average between arterial and venous here
   %P_CO2_lung_t=blood_lung_Pco2((po2_ven_blood),mol_CO2_lung_exchange,vl,vol_blood_via_lung);%setting lung and blood CO2 pressures equal

   P_CO2_lung_t=blood_lung_Pco2((po2_ven_blood+po2_art_blood)/2,mol_CO2_lung_exchange,vl,vol_blood_via_lung);%setting lung and blood CO2 pressures equal
   n_CO2_lung_t=(P_CO2_lung_t*vl)/rt; %moles CO2 in lung at time t, after exchange

   %%%need to fix this so that it is equal to n_CO2_lung_tmin1-n_CO2_lung_t
   %%%but of oppsite sign and not the one below as it uses a po2_blood that is
   %%%not correct or else use the average
   nCO2_in_blood_via_lung=nCO2_in_blood_via_lung+(n_CO2_lung_tmin1-n_CO2_lung_t);
   n_CO2_art_t=nCO2_in_blood_via_lung+nCO2_shunted_past_lung;%the moles CO2 left in blood after lung exchange and when joined with shunted blood, i.e. moles CO2 in arterial blood at time t

   

   %%%NEEDS checking AS WHEN PCO2 IS CALCULATED IT SHOULD HAVE THE ARTERIAL
   %%%PCO2, USE arterial PCO2 and PO2 at time t-1 from ART_VEN_PO2 and ART_VEN_PCO2 to estimate ART_VEN_PCO2(i-1,1) and ART_VEN_PCO2(i-1,1)
   %blood_O2_sat(po2_art_blood,ART_VEN_PCO2(i-1,1));
   
   P_CO2_art_t=blood_Pco2(blood_O2_sat(po2_art_blood,ART_VEN_PCO2(i-1,1)),n_CO2_art_t*rt/(B_VOL_PACKAGE_VEN));%this is a bit tricky as I assume that S=is at t-1
end
%debugging check, this must be true and these must be equal but of opposite
%sign
%lung=n_CO2_lung_tmin1-n_CO2_lung_t%delta moles in lung
%blood=n_CO2_ven_tmin1-n_CO2_art_t%delta moles in blood

return   