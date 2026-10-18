% ========================================================================
% Documentation reviewed: 2026-10-18 | Batch 01
% Purpose: Summarize oxygen stores and metabolic variables at dive boundaries.
% Interface: dsum provides dive start/end rows; results combine tissue, lung and blood O2 stores.
% Review note: Dive boundary indexing and output-column meanings are documented in legacy comments.
% Scope: Documentation only; all pre-existing lines remain unchanged.
% ========================================================================

% ============================================================
% Documentation review: 2026-10-18 | Batch 01
% Scope: Review tracking header only; original code preserved.
% Numerical calculations, logic, and existing comments unchanged.
% ============================================================
%This function looks for the blood, tissue and lung O2 store the last
%second before a dive starts and again the last second before a dive ends.
%It uses dsum=the data file that has the row number for start and end of
%dive, and pulls out the O2 from the blood array and each compartment. 
%it then also pulls out the metabolic rate of the upcoming dive
%returns an array that has 1=o2store tissue before dive, 2=O2 store lung before dive, 3=O2 store
%blood before dive, 4=total O2 store before dive, 5=o2store tissue end of dive, 6=O2 store lung end of, 7=O2 store
%blood end of, 8=total O2 store at end of dive 9= adjusted MR for heart for dive, 10=adjusted MR for
%muscle for dive, 11=adjusted MR for brain for dive, 12=adjusted MR for fat
%for dive, 13=adjusted total MR for dive, 14=SI duration, 15=dive duration,
%16=maximal dive depth
function dADL=GET_DIVE_DYNAMIC_ADL(dsum)
global R P_AMB O2_ARRAY ART_VEN_O2_STORE METABOLIC_RATES
%METABOLIC_RATES are computed in update_tissue_metabolic_rates
num_dives= size(dsum,1)-1;%number of dives in record

%no_dive=1;%dive counter which is used to get row of dADL
for x=1:size(dsum,1)%9464%76702%change
    no_dive=x;
    if dsum(x,3)==1%get start values for PRE-DIVE
       i=x;
       blood_nO2_store=ART_VEN_O2_STORE(i,3);%number of moles O2 in blood, from GET_GAS_FLUX
       blood_volO2_store=blood_nO2_store*R*273;%liter O2 in blood
       tissue_nO2_store=(O2_ARRAY(i,1,2)+O2_ARRAY(i,2,2)+O2_ARRAY(i,3,2)+O2_ARRAY(i,4,2));%moles of O2 in tissues
       tissue_volO2_store=tissue_nO2_store*R*273;%tissue O2 store in liters STPD
       lung_nO2_store=(O2_ARRAY(i,5,2));%moles of O2 in lung
       lung_volO2_store=lung_nO2_store*R*273;%lung O2 store in liters STPD
       dADL(no_dive,1)=tissue_volO2_store;%tissue O2 store at end of dive
       dADL(no_dive,2)=lung_volO2_store;%lung O2 store at end of dive
       dADL(no_dive,3)=blood_volO2_store;%blood O2 store at end of dive
       dADL(no_dive,4)=blood_volO2_store+lung_volO2_store+tissue_volO2_store;%total O2 store before dive at end of dive
       dADL(no_dive,5)=dsum(no_dive,2);%SI duration
       dADL(no_dive,6)=P_AMB(i);%depth when data is taken for O2 store before dive
       dADL(no_dive,19)=O2_ARRAY(i,2,2)*R*273;% pre-dive muscle O2 store
       %%%%%update cell reference
       i=dsum(x,4)-2; %now collect values right before the end of surface period which should be the same, so full stores etc
       blood_nO2_store=ART_VEN_O2_STORE(i,3);%number of moles O2 in blood, from GET_GAS_FLUX
       blood_volO2_store=blood_nO2_store*R*273;%liter O2 in blood
       tissue_nO2_store=(O2_ARRAY(i,1,2)+O2_ARRAY(i,2,2)+O2_ARRAY(i,3,2)+O2_ARRAY(i,4,2));%moles of O2 in tissues
       tissue_volO2_store=tissue_nO2_store*R*273;%tissue O2 store in liters STPD
       lung_nO2_store=(O2_ARRAY(i,5,2));%moles of O2 in lung
       lung_volO2_store=lung_nO2_store*R*273;%lung O2 store in liters STPD
       
       dADL(no_dive,7)=tissue_volO2_store;%tissue O2 store at end of dive
       dADL(no_dive,8)=lung_volO2_store;%lung O2 store at end of dive
       dADL(no_dive,9)=blood_volO2_store;%blood O2 store at end of dive
       dADL(no_dive,10)=blood_volO2_store+lung_volO2_store+tissue_volO2_store;%total O2 store before dive at end of dive
       dADL(no_dive,11)=METABOLIC_RATES(no_dive,7)*R*273;%adjusted heart MR, R*273 is to convert moles to l
       dADL(no_dive,12)=METABOLIC_RATES(no_dive,8)*R*273;%adjusted muscle MR
       dADL(no_dive,13)=METABOLIC_RATES(no_dive,9)*R*273;%fill with dummy for now adjusted brain MR
       dADL(no_dive,14)=METABOLIC_RATES(no_dive,10)*R*273;%adjusted fat MR
       dADL(no_dive,15)=METABOLIC_RATES(no_dive,11)*R*273;%adjusted total MR
       
       dADL(no_dive,16)=dsum(no_dive,7);%dive duration for the upcoming dive
       dADL(no_dive,17)=dsum(no_dive,11);%max depthfor the upcoming dive
       dADL(no_dive,18)=P_AMB(i);%depth when data is taken imediately before end of dive, i.e last depth before surface
       
       dADL(no_dive,20)=O2_ARRAY(i,2,2)*R*273;% post-dive muscle O2 store
      

       
    elseif x<=num_dives && x>1
       %%%%%%%%%%%%%%%PRE-DIVE SECTION%%%%%%%%%%%%%%%
       i=dsum(x,4)-2;%end of SI, then back 2 seconds to get pre-dive value
       blood_nO2_store=ART_VEN_O2_STORE(i,3);%number of moles O2 in blood, from GET_GAS_FLUX
       blood_volO2_store=blood_nO2_store*R*273;%liter O2 in blood
       tissue_nO2_store=(O2_ARRAY(i,1,2)+O2_ARRAY(i,2,2)+O2_ARRAY(i,3,2)+O2_ARRAY(i,4,2));%moles of O2 in tissues
       tissue_volO2_store=tissue_nO2_store*R*273;%tissue O2 store in liters STPD
       lung_nO2_store=(O2_ARRAY(i,5,2));%moles of O2 in lung
       lung_volO2_store=lung_nO2_store*R*273;%lung O2 store in liters STPD
       dADL(no_dive,1)=tissue_volO2_store;%tissue O2 store
       dADL(no_dive,2)=lung_volO2_store;%lung O2 store
       dADL(no_dive,3)=blood_volO2_store;%blood O2 store
       dADL(no_dive,4)=blood_volO2_store+lung_volO2_store+tissue_volO2_store;%total O2 store before dive
       dADL(no_dive,5)=dsum(no_dive,2);%SI duration
       dADL(no_dive,6)=P_AMB(i);%depth when data is taken for O2 store before dive
       dADL(no_dive,19)=O2_ARRAY(i,2,2)*R*273;% pre-dive muscle O2 store
       %%%%%%%%%%%%%%%POST-DIVE SECTION%%%%%%%%%%%%%%%
       i=dsum(x,9)-1;%end of dive, then back 1 seconds to get post-dive value
       blood_nO2_store=ART_VEN_O2_STORE(i,3);%number of moles O2 in blood
       blood_volO2_store=blood_nO2_store*R*273;%liter O2 in blood
       tissue_nO2_store=(O2_ARRAY(i,1,2)+O2_ARRAY(i,2,2)+O2_ARRAY(i,3,2)+O2_ARRAY(i,4,2));%moles of O2 in tissues; O2_ARRAY(row, tissue[N2,O2,CO2),content(pressure, mol, pH)]
       tissue_volO2_store=tissue_nO2_store*R*273;%tissue O2 store in liters STPD
       lung_nO2_store=(O2_ARRAY(i,5,2));%moles of O2 in lung
       lung_volO2_store=lung_nO2_store*R*273;%lung O2 store in liters STPD  
       dADL(no_dive,7)=tissue_volO2_store;%tissue O2 store at end of dive
       dADL(no_dive,8)=lung_volO2_store;%lung O2 store at end of dive
       dADL(no_dive,9)=blood_volO2_store;%blood O2 store at end of dive
       dADL(no_dive,10)=blood_volO2_store+lung_volO2_store+tissue_volO2_store;%total O2 store before dive at end of dive
       dADL(no_dive,11)=METABOLIC_RATES(no_dive,2)*R*273;%adjusted heart MR, R*273 is to convert moles to l
       dADL(no_dive,12)=METABOLIC_RATES(no_dive,3)*R*273;%adjusted muscle MR
       dADL(no_dive,13)=METABOLIC_RATES(no_dive,4)*R*273;%fill with dummy for now adjusted brain MR
       dADL(no_dive,14)=METABOLIC_RATES(no_dive,5)*R*273;%adjusted brain MR
       dADL(no_dive,15)=METABOLIC_RATES(no_dive,6)*R*273;%adjusted fat MR
       dADL(no_dive,16)=dsum(no_dive,7);%dive duration
       dADL(no_dive,17)=dsum(no_dive,11);%max depth
       dADL(no_dive,18)=P_AMB(i);%depth when data is taken imediately before end of dive, i.e last depth before surface
       dADL(no_dive,20)=O2_ARRAY(i,2,2)*R*273;% post-dive muscle O2 store
       %dADL(no_dive,19)=(dADL(no_dive,10))/(dADL(no_dive,11)+dADL(no_dive,12)+dADL(no_dive,14)+dADL(no_dive,15));%the
       %calculated dADL at end of dive
       %dADL(no_dive,20)=(dADL(no_dive,10))/(dADL(no_dive,11)+dADL(no_dive,12)+dADL(no_dive,14)+dADL(no_dive,15));%the
       %calculated %dADL(no_dive,19)=(dADL(no_dive,10))/(dADL(no_dive,11)+dADL(no_dive,12)+dADL(no_dive,14)+dADL(no_dive,15));%the
       %calculated dADL at surface before dive
    end
end
 
return



                       