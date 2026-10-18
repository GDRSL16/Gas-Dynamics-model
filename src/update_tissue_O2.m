% ========================================================================
% Second-round internal documentation review: 2026-10-18 | Batch 07
% File: update_tissue_O2.m
% Review focus: Oxygen tissue exchange. Distinguish gas transfer from metabolic oxygen consumption; maintain existing compartment conventions.
% Documentation only: original MATLAB source follows unchanged.
% ========================================================================
% ============================================================
% Documentation review: 2026-10-18 | Batch 07
% File: update_tissue_O2.m
% Function signature: [n_O2_ven_t,P_O2_ven_t]=update_tissue_O2(Pamb,i,pect,rt);
% Scope: documentation only; numerical model unchanged.
% Original source preserved verbatim below this header.
% ============================================================
function [n_O2_ven_t,P_O2_ven_t]=update_tissue_O2(Pamb,i,pect,rt);
%This funtion updates the tissue tensions. It separates the "arterial blood" flow based on percentages of total blood flow to each of the tissues
%The O2 is then updated 
%tissues are T1=heart+liver+kidney=61% of total blood flow, T2=fat+skin+bone+remainder=11% of total blood flow, T3=muscle 16% of total blood flow, T4=brain 12% of total blood flow

%This funtion updates the tissue tensions. It separates the "arterial blood" flow based on percentages of total blood flow to each of the tissues
%The O2 is then updated, does not contain AV-shunt at the moment and AV
%shunt will not have an effect as it is number of moles removed from the
%blood and not partial pressure gradients that determine mixed venous
%output
global Q_TOT Q_HEART Q_FAT Q_MUSCLE Q_BRAIN  TEMP_ARRAY O2_ARRAY BLOOD_PARTITIONS_ART BLOOD_PARTITIONS_VEN
global deltaT  SO2_BLOOD SO2_FAT V_HEART V_MUSCLE V_BRAIN V_FAT R GAS_CONSTANT
global nO2DOT_HEART nO2DOT_MUSCLE nO2DOT_BRAIN nO2DOT_FAT  STPD_TO_BT ACTUAL_MUSCLE_VOLUME
global VO2_HEART VO2_MUSCLE VO2_BRAIN VO2_FAT VO2_TOT 
global ART_VEN_PCO2 ART_VEN_PO2 O2_DEPLETED_FLAG
%O2_DEPLETED_FLAG=[0 0 0 0 0]; %an array that tracks if O2 has run out,
%which means anaerobic metabolism and stop for CO2 accumulation, this is
%updated in "update_tissue_O2" and then used in "update_tissue_CO2", has 5
%cells, heart, muscle, brain, fat, blood, initialized in
%beakedwhale_tissue_kinetics
O2_DEPLETED_FLAG(i,:)=0;%start off assuming that they are all 0
temp_changes=[1, 1, 1, 1];%the relative temperature as comapred to muscle, i.e. fat temperature changes much more than deep body core. These are "relative" changes as comapred to pectoral, brain is assumed to be unchanged
art_O2=BLOOD_PARTITIONS_ART;%this is the last arterial blood package which exchanges with the tissue
ven_O2=BLOOD_PARTITIONS_VEN;
tissue_Q=[Q_HEART Q_MUSCLE Q_BRAIN Q_FAT];%tissue perfusion rate in liter/s 
blood_vol_tissue=deltaT*tissue_Q; %the total volume of blood to each tissue in Liters per deltaT 
s_O2=[SO2_BLOOD SO2_BLOOD SO2_FAT SO2_FAT];%tissue solubilities for dissolved O2
tissue_vol=[V_HEART ACTUAL_MUSCLE_VOLUME V_BRAIN V_FAT];%
mol_removal_rate=[nO2DOT_HEART nO2DOT_MUSCLE nO2DOT_BRAIN nO2DOT_FAT]./60; %mol/min converted to mol/sec
mol_removed=mol_removal_rate.*deltaT;%mol/sec*sec=mol
%vol_removal_rate=[VO2_HEART VO2_MUSCLE VO2_BRAIN VO2_FAT %VO2_TOT]./60;%l/sec, not used so % out
%vol_removed=vol_removal_rate.*deltaT;%l/sec*sec=l
po2_tiss_init=O2_ARRAY(i-1,1:4,1);%this is the tissue tension of O2 at time t-1
po2_blood_init=TEMP_ARRAY(BLOOD_PARTITIONS_ART,1,2);%this is the blood tension of O2 at time t-1
pco2_art_blood_init=ART_VEN_PCO2(i-1,1);%this is the arterial blood tension of CO2 at time t-1
pco2_ven_blood_init=ART_VEN_PCO2(i-1,2);%this is the venous blood tension of CO2 at time t-1
pco2mix=(pco2_art_blood_init+pco2_ven_blood_init)/2;
n_art_tmin1=TEMP_ARRAY(BLOOD_PARTITIONS_ART,2,2);%the moles O2 in the arterial blood at time t-1

n_tiss_tmin1=O2_ARRAY(i-1,1:4,2);%total number of molecules of O2 in tissues at t-1
%removes moles of O2 from blood, then computes Co2 (l O2 STPD/l blood), relationship n(mol)=Co2*Vblood/RT
%finally computes new blood partial pressure


for p=1:4%for 4 tissues 
    %tissue=p
    %n_art_to_tiss_tmin1(p)=(n_art_tmin1*tissue_Q(p)/Q_TOT-mol_removed(p)); %the moles shunted to each tissue and the fraction removed by metabolism
    %co2blood_t(p)=n_art_to_tiss_tmin1(p)*GAS_CONSTANT./blood_vol_tissue(p);
    %p_t(p)=blood_Po2(pco2_blood_init,co2blood_t(p));%update blood tension and see if it is higher than tissue
    
   
    nO2_t(p)=n_art_tmin1*tissue_Q(p)/Q_TOT+n_tiss_tmin1(p)-mol_removed(p);%the blood and tissue O2 content
   if nO2_t(p)<0%new error trappping when rtunning out of O2
      % disp('ran out of O2 at row and tissue ');%new error trappping when rtunning out of O2
     %  i
     %  p
       O2_DEPLETED_FLAG(i,p)=1;%this tissue gets 1 and then this will be used in "update_tissue_CO2"
       %new error trappping when rtunning out of O2
       %new error trappping when rtunning out of O2
       O2_ARRAY(i,p,1)=0;%new error trappping when rtunning out of O2
       O2_ARRAY(i,p,2)=0;%%new error trappping when rtunning out of O2
       ven_n(p)=0;%new error trappping when rtunning out of O2
   else%new error trappping when rtunning out of O2
   %p
   %nO2_t(p)
       if p==2
          p_common(p)=blood_tiss_mus_Po2(pco2mix,nO2_t(p), tissue_vol(p),blood_vol_tissue(p));%for muscle, need a different one as it contains Mb
          O2_ARRAY(i,p,1)=p_common(p);
          O2_ARRAY(i,p,2)=muscle_Co2(p_common(p))*tissue_vol(p)/GAS_CONSTANT;%
       elseif p>0 & p<5 
          p_common(p)=blood_tiss_Po2(pco2mix,nO2_t(p), tissue_vol(p),blood_vol_tissue(p),s_O2(p));
          O2_ARRAY(i,p,1)=p_common(p);%tissue O2 tension
          O2_ARRAY(i,p,2)=(p_common(p)*tissue_vol(p)*s_O2(p))./GAS_CONSTANT;%tissue mol 
       
       end
        O2_DEPLETED_FLAG(i,p)=0;%tissue still has O2
       ven_n(p)=(blood_vol_tissue(p)*blood_Co2(pco2mix,p_common(p)))./(GAS_CONSTANT);%the moles in each package of blood
   end%new error trappping when rtunning out of O2
end
   
  
%if sum(n_art_tiss_tmin1)+mol_removed~=n_art_tmin1
%    disp('number of moles O2 in uptake is not the same as removal')
%end  


n_O2_ven_t=sum(ven_n);
if n_O2_ven_t<=0%new error trappping when rtunning out of O2 %Changed dec 4 2024 to n_O2_ven_t<=0 and before it was n_O2_ven_t<0 so never there
    n_O2_ven_t=0;%new error trappping when rtunning out of O2
    P_O2_ven_t=0;%new error trappping when rtunning out of O2
    disp('venous blood out of O2 at row')%new error trappping when rtunning out of O2
    %new error trappping when rtunning out of O2
     O2_DEPLETED_FLAG(i,5)=1;%this indicates where mixed venous blood is out of O2
else%new error trappping when rtunning out of O2
   %s=blood_O2_sat(ART_VEN_PO2(i-1,2),ART_VEN_PCO2(i-1,2));%uses venous PCO2 at time t-1 to get S in blood PO2
   %i
   if i==1633005 || i==1633050
       n_O2_ven_t=sum(ven_n);
   %   aaa=n_O2_ven_t*GAS_CONSTANT/(sum(blood_vol_tissue))
   %    bbb=pco2_ven_blood_init
       
  end
   P_O2_ven_t=blood_Po2(pco2_ven_blood_init,n_O2_ven_t*GAS_CONSTANT/(sum(blood_vol_tissue)));%updates blood tension
end%new error trappping when rtunning out of O2
%P_O2_ven_t=blood_Po2(pco2_blood_init,n_O2_ven_t*GAS_CONSTANT/(sum(blood_vol_tissue)*STPD_TO_BT));%updates blood tension

return     
      
      