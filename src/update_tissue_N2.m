% ============================================================
% Documentation review: 2026-10-18 | Batch 07
% File: update_tissue_N2.m
% Function signature: [n_N2_ven_t,P_N2_ven_t]=update_tissue_N2(Pamb,i, pect,rt);
% Scope: documentation only; numerical model unchanged.
% Original source preserved verbatim below this header.
% ============================================================
  function [n_N2_ven_t,P_N2_ven_t]=update_tissue_N2(Pamb,i, pect,rt);
%This funtion updates the tissue tensions. It separates the "arterial blood" flow based on percentages of total blood flow to each of the tissues
%The N2 is then updated 
global Q_TOT Q_HEART Q_FAT Q_MUSCLE Q_BRAIN  TEMP_ARRAY N2_ARRAY BLOOD_PARTITIONS_ART BLOOD_PARTITIONS_VEN
global deltaT  SN2_BLOOD SN2_BLOOD SN2_FAT SN2_FAT V_HEART V_MUSCLE V_BRAIN V_FAT BLOOD_PARTITIONS_VEN R Q_AVSHUNT ADJ_BLOOD_VOL_LUNG_N2

temp_changes=[1, 1, 1, 1];%the relative temperature as comapred to muscle, i.e. fat temperature changes much more than deep body core. These are "relative" changes as comapred to pectoral, brain is assumed to be unchanged
art_N2=BLOOD_PARTITIONS_ART;%this is the last arterial blood package which exchanges with the tissue
ven_N2=BLOOD_PARTITIONS_VEN;
tissue_Q=[Q_HEART Q_MUSCLE Q_BRAIN Q_FAT Q_AVSHUNT];%tissue perfusion rate in liter/s   NEED TO ADD AVSHUNT HERE
blood_vol_tissue=deltaT*tissue_Q; %the total volume of blood to each tissue in Liters per deltaT ONCE ADDED ABOVE AVSHUNT AUTOMATICALLY IS ADDED HERE
s_N2=[SN2_BLOOD SN2_BLOOD SN2_FAT SN2_FAT];%tissue solubilities, muscle and heart is assumed to be equal to blood, brain and fat are 5 times higher than muscle NO NEED FOR AVSHUNT HERE
tissue_vol=[V_HEART V_MUSCLE V_BRAIN V_FAT];%NO NEED FOR AVSHUNT HERE

n_AV_shunt=0;
adj_tissue_vol(1:4)=tissue_vol(1:4).*s_N2(1:4);%this is a "virtual" tissue volume in l
adj_blood_vol=blood_vol_tissue*SN2_BLOOD;%a virtual blood volume
n_art_tmin1=TEMP_ARRAY(BLOOD_PARTITIONS_ART,2,1);%the moles N2 in the arterial blood at time t-1

n_tiss_tmin1_tot=sum(N2_ARRAY(i-1,1:4,2));%total number of molecules of N2 in tissues at t-1
for p=1:4
    
    Vtot(p)=adj_blood_vol(p)+adj_tissue_vol(p);%the total volume of each tissue and the blood directed to that tissue and corrected for differences in solubility, tissue volume is "corrected" virtual volume
    n_art_tiss_tmin1(p)=n_art_tmin1*tissue_Q(p)/Q_TOT; %the moles shunted to each tissue and whatever is oleft is AV-shunted
end
%%%%%%section to split the available number of N2 molecules into each
%%%%%%bloodpackage without changing the total number of molecules
%%%%%% package without changing the total number of molecules

if Q_AVSHUNT==0 %if no blood shunted past the tissue, make sure that the number of molecules split into each tissue is the same as the total number in n_art_tmin1, i.e. conservation of mass
    delta=sum(n_art_tiss_tmin1)-n_art_tmin1;%the difference in number of moles in blood to each tissue, if + subtract this number from muscle and if positive add this to muscle
    if delta>0
        n_art_tiss_tmin1(2)=n_art_tiss_tmin1(2)-delta;
    else
        n_art_tiss_tmin1(2)=n_art_tiss_tmin1(2)+delta;
    end
elseif Q_AVSHUNT>0
   delta=n_art_tmin1-sum(n_art_tiss_tmin1);%the difference in number of moles in blood to each tissue, if + subtract this number from muscle and if positive add this to muscle
   if delta<0
       disp('something is not working correct as the number of moles has increased')
   else
       n_AV_shunt=delta;%
   end
end

    
for u=1:4 %for each tissue 1=central circulation ,2=muscle, 3=brain, 4=fat
   %%%%%%%%%%the way to compute tau, not needed but useful to be able to
   %%%%%%%%%%compute it
   %if i==4 || i==200
   %tau=(tissue_Q(u)*SN2_BLOOD)*60/(tissue_vol(u)*s_N2(u)); %the time constant for this tissue, approx for each tissue: heart=0.5min, muscle=13min, brain=1.1min, fat=169min
  % tau=1/(log(2)*tau)%conversion to stick with the functional form used during biochecmial decomp
   %end
   n_tiss_tmin1(u)=N2_ARRAY(i-1,u,2);%moles in tissue u at time t-1 
   mol_tiss(u)=(adj_tissue_vol(u)/Vtot(u))*(n_tiss_tmin1(u)+n_art_tiss_tmin1(u));%moles N2 in tissue u after N2 exchange
   deltamol(u)=mol_tiss(u)-n_tiss_tmin1(u);%this is the number of moles that has been added or subtracted from tissue, if + molecules have been added and if - molecules have been removed
   mol_blood(u)=n_art_tiss_tmin1(u)-deltamol(u);%remove or add the same number of moles as have been changed in tissue
   N2_ARRAY(i,u,2)=mol_tiss(u);%updates moles N2 in tissue
   N2_ARRAY(i,u,1)=(mol_tiss(u)*rt)/(tissue_vol(u)*s_N2(u));%updates tissue tension
   %N2_ARRAY(i,u,1)=(mol_tiss(u)*rt)/(adj_tissue_vol(u));%updates tissue tension
end

%%%%some error trapping
 
at_t=sum(mol_tiss)+sum(mol_blood)+n_AV_shunt;%the total number of moles N2 at time t
at_tmin1=n_art_tmin1+n_tiss_tmin1_tot;%the total number of moles N2 at time t
if abs(at_t-at_tmin1)>0.0000000001
    
    disp('number moles have changed')
end
%%%%%%%%end error trapping%%%%%%%%%%


n_N2_ven_t=sum(mol_blood)+n_AV_shunt;
%P_N2_ven_t=(n_N2_ven_t*rt)/(sum(adj_blood_vol));%updates tissue tension;return this one
P_N2_ven_t=(n_N2_ven_t*rt)/ADJ_BLOOD_VOL_LUNG_N2;%updates tissue tension;return this one


return     
      
      
 