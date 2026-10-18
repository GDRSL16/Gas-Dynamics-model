% ========================================================================
% Documentation reviewed: 2026-10-18 | Batch 01
% Purpose: Collect oxygen and carbon dioxide stores from tissue and blood states.
% Interface: i is the current model row; output is a vector of store summaries.
% Review note: The original column mapping is retained; check legacy comments for naming inconsistencies.
% Scope: Documentation only; all pre-existing lines remain unchanged.
% ========================================================================

% ============================================================
% Documentation review: 2026-10-18 | Batch 01
% Scope: Review tracking header only; original code preserved.
% Numerical calculations, logic, and existing comments unchanged.
% ============================================================
%This function looks for the blood, tissue and lung O2 and CO2 stores throughout the entire data set
%It pulls out the O2 from the blood array and each compartment. 
%it then also pulls out the metabolic rate of the upcoming dive
%returns an array that has 1=o2store-muscle, 2-O2store-total 3-O2store arterial blood,
%4-O2store-venous blood, 5-O2 store lung, 6-Co2store-muscle, 7-CO2store-total 8-CO2store-arterial blood,
%9-CO2store-venous blood, 10-O2 store lung

function y=GET_O2_CO2_STORES(i)
% Output interpretation: collects compartment and circulating O2/CO2 store estimates.
% Units and component ordering follow the existing arrays and should be verified
% against the variable dictionary before publication.
global R CO2_ARRAY O2_ARRAY ART_VEN_O2_STORE STORES ART_VEN_CO2_STORE

%%%%O2 section
%%%SEPARATE THESE BY ART AND VEN
art_nO2_store=ART_VEN_O2_STORE(i,1);%number of moles O2 in arterial blood, from GET_GAS_FLUX
ven_nO2_store=ART_VEN_O2_STORE(i,2);%number of moles O2 in arterial blood, from GET_GAS_FLUX
blood_nO2_store=ART_VEN_O2_STORE(i,3);%number of moles O2 in blood, from GET_GAS_FLUX
art_volO2_store=art_nO2_store*R*273;%liter O2 in arterial blood
ven_volO2_store=ven_nO2_store*R*273;%liter O2 in venous blood
blood_volO2_store=blood_nO2_store*R*273;%liter O2 in blood
%%%TOTAL O2 STORE
tissue_nO2_store=(O2_ARRAY(i,1,2)+O2_ARRAY(i,2,2)+O2_ARRAY(i,3,2)+O2_ARRAY(i,4,2));%moles of O2 in tissues
tissue_volO2_store=tissue_nO2_store*R*273;%tissue O2 store in liters STPD
%muscle_nO2_store=O2_ARRAY(i,2,2);%moles of O2 in muscle
%%%%%LUNG O2 store
lung_nO2_store=(O2_ARRAY(i,5,2));%moles of O2 in lung
lung_volO2_store=lung_nO2_store*R*273;%lung O2 store in liters STPD
%%%%save in "stores"
STORES(i,1)=O2_ARRAY(i,2,2)*R*273;%muscle O2 store in liters STPD
STORES(i,2)=tissue_volO2_store;%tissue O2 store in liters STPD
STORES(i,3)=art_volO2_store;%arterial blood O2 store
STORES(i,4)=ven_volO2_store;%venous blood O2 store
STORES(i,5)=lung_volO2_store;%lung O2 store at end of dive

%%%%%%%%%%%%%CO2 stores
%%%SEPARATE THESE BY ART AND VEN
art_nCO2_store=ART_VEN_CO2_STORE(i,1);%number of moles O2 in arterial blood, from GET_GAS_FLUX
ven_nCO2_store=ART_VEN_CO2_STORE(i,2);%number of moles O2 in arterial blood, from GET_GAS_FLUX
blood_nCO2_store=ART_VEN_CO2_STORE(i,3);%number of moles O2 in blood, from GET_GAS_FLUX
art_volCO2_store=art_nCO2_store*R*273;%liter O2 in arterial blood
ven_volCO2_store=ven_nCO2_store*R*273;%liter O2 in venous blood
blood_volCO2_store=blood_nCO2_store*R*273;%liter O2 in blood
%%%TOTAL O2 STORE
tissue_nCO2_store=(CO2_ARRAY(i,1,2)+CO2_ARRAY(i,2,2)+CO2_ARRAY(i,3,2)+CO2_ARRAY(i,4,2));%moles of O2 in tissues
tissue_volCO2_store=tissue_nCO2_store*R*273;%tissue O2 store in liters STPD
%%%%%LUNG O2 store
lung_nCO2_store=(CO2_ARRAY(i,5,2));%moles of O2 in lung
lung_volCO2_store=lung_nCO2_store*R*273;%lung O2 store in liters STPD
%%%%save in "stores"
STORES(i,6)=CO2_ARRAY(i,2,2)*R*273;%muscle O2 store in liters STPD
STORES(i,7)=tissue_volCO2_store;%tissue O2 store in liters STPD
STORES(i,8)=art_volCO2_store;%arterial blood O2 store
STORES(i,9)=ven_volCO2_store;%venous blood O2 store
STORES(i,10)=lung_volCO2_store;%lung O2 store at end of dive


 y=STORES;     
   
return



                       