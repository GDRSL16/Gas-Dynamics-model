function [n_CO2_ven_t,P_CO2_ven_t]=update_tissue_CO2(Pamb,i,pect,rt);
%This funtion updates the tissue tensions. It separates the "arterial blood" flow based on percentages of total blood flow to each of the tissues
%The O2 is then updated 
%tissues are T1=heart+liver+kidney=61% of total blood flow, T2=fat+skin+bone+remainder=11% of total blood flow, T3=muscle 16% of total blood flow, T4=brain 12% of total blood flow

%This funtion updates the tissue tensions. It separates the "arterial blood" flow based on percentages of total blood flow to each of the tissues
%The O2 is then updated, does not contain AV-shunt at the moment and AV
%shunt will not have an effect as it is number of moles removed from the
%blood and not partial pressure gradients that determine mixed venous
%output
global Q_TOT Q_HEART Q_FAT Q_MUSCLE Q_BRAIN  TEMP_ARRAY CO2_ARRAY BLOOD_PARTITIONS_ART BLOOD_PARTITIONS_VEN
global deltaT  SCO2_BLOOD SCO2_FAT SCO2_BRAIN V_HEART V_MUSCLE V_BRAIN V_FAT R GAS_CONSTANT
global nCO2DOT_HEART nCO2DOT_MUSCLE nCO2DOT_BRAIN nCO2DOT_FAT TEMP_ARRAY STPD_TO_BT 
global ART_VEN_PCO2 ART_VEN_PO2 O2_DEPLETED_FLAG

temp_changes=[1, 1, 1, 1];%the relative temperature as comapred to muscle, i.e. fat temperature changes much more than deep body core. These are "relative" changes as comapred to pectoral, brain is assumed to be unchanged
art_O2=BLOOD_PARTITIONS_ART;%this is the last arterial blood package which exchanges with the tissue
ven_O2=BLOOD_PARTITIONS_VEN;
tissue_Q=[Q_HEART Q_MUSCLE Q_BRAIN Q_FAT];%tissue perfusion rate in liter/s 
blood_vol_tissue=deltaT*tissue_Q; %the total volume of blood to each tissue in Liters per deltaT 
s_CO2=[SCO2_BLOOD SCO2_BLOOD SCO2_BRAIN SCO2_FAT];%tissue solubilities for dissolved CO2
tissue_vol=[V_HEART V_MUSCLE V_BRAIN V_FAT];%
mol_prod_rate=[nCO2DOT_HEART nCO2DOT_MUSCLE nCO2DOT_BRAIN nCO2DOT_FAT]./60; %mol/min converted to mol/sec
mol_added=mol_prod_rate.*deltaT;%mol/sec*sec=mol

%%%%%%%%%%%%%%%%%%%if tissue has run out of O2,VCO2=0%%%%%%%%%%%%%%%%%%%
for p=1:4
    if O2_DEPLETED_FLAG(i,p)==1
        mol_added(p)=0;%VCO2 is 0
    end
end


%vol_prod_rate=[VCO2_HEART VCO2_MUSCLE VCO2_BRAIN VCO2_FAT VCO2_TOT]./60;%l/sec
%vol_added=vol_prod_rate.*deltaT;%l/sec*sec=l
pco2_tiss_init=CO2_ARRAY(i-1,1:4,1);%this is the tissue tension of CO2 at time t-1
po2_blood_init=TEMP_ARRAY(BLOOD_PARTITIONS_ART,1,2);%this is the blood tension of O2 at time t-1

pco2_blood_init=TEMP_ARRAY(BLOOD_PARTITIONS_ART,1,3);%this is the blood tension of CO2 at time t-1
n_art_tmin1=TEMP_ARRAY(BLOOD_PARTITIONS_ART,2,3);%the moles CO2 in the arterial blood at time t-1
n_tiss_tmin1=CO2_ARRAY(i-1,1:4,2);%total number of molecules of CO2 in tissues at t-1
po2_art_blood_init=ART_VEN_PO2(i-1,1);%this is the arterial blood tension of CO2 at time t-1
po2_ven_blood_init=ART_VEN_PO2(i-1,2);%this is the venous blood tension of CO2 at time t-1
po2mix=(po2_art_blood_init+po2_ven_blood_init)/2;
%removes moles of O2 from blood, then computes Co2 (l O2 STPD/l blood), relationship n(mol)=Co2*Vblood/RT
%finally computes new blood partial pressure
for p=1:4
    %n_art_to_tiss_tmin1(p)=(n_art_tmin1*tissue_Q(p)/Q_TOT+mol_added(p)) %the moles shunted to each tissue and the fraction removed by metabolism
    nCO2_t(p)=(n_art_tmin1*tissue_Q(p)/Q_TOT+n_tiss_tmin1(p)+mol_added(p));
    p_common(p)=blood_tiss_Pco2(po2mix, pco2_blood_init,nCO2_t(p), tissue_vol(p),blood_vol_tissue(p),s_CO2(p));
    %p_common(p)=blood_tiss_Pco2(po2_blood_init, pco2_blood_init,nCO2_t(p), tissue_vol(p),blood_vol_tissue(p),s_CO2(p));
    CO2_ARRAY(i,p,1)=p_common(p);%tissue O2 tension
    CO2_ARRAY(i,p,2)=(p_common(p)*tissue_vol(p)*s_CO2(p))./GAS_CONSTANT;
    ven_n(p)=(blood_vol_tissue(p)*blood_Cco2(po2_blood_init,p_common(p)))./GAS_CONSTANT;%the moles in each package of blood
end
   
  
%if sum(n_art_tiss_tmin1)+mol_removed~=n_art_tmin1
%    disp('number of moles O2 in uptake is not the same as removal')
%end    

    
n_CO2_ven_t=sum(ven_n);
%this should use venous blood PCO2 and PO2 at time t-1 to estimate S
s=blood_O2_sat(ART_VEN_PO2(i-1,2),ART_VEN_PCO2(i-1,2));
P_CO2_ven_t=blood_Pco2(s,(n_CO2_ven_t*GAS_CONSTANT/(sum(blood_vol_tissue) )));%updates blood tension

%P_CO2_ven_t=blood_Pco2(blood_O2_sat(po2_blood_init,pco2_blood_init),(n_CO2_ven_t*GAS_CONSTANT/(sum(blood_vol_tissue)*STPD_TO_BT )));%updates blood tension

return     
      
      