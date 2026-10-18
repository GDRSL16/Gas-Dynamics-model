% ========================================================================
% Second-round internal documentation review: 2026-10-18 | Batch 05
% File: iteration_N2_lung_search.m
% Review focus: Iterative lung gas solution. Convergence conditions and iteration order are part of the numerical method; do not modify them during documentation review.
% Documentation only: original MATLAB source follows unchanged.
% ========================================================================
% ========================================================================
% Documentation reviewed: 2026-10-18 | Batch 02
% Purpose: Calculate pulmonary N2 redistribution between lung and venous blood.
% Interface: Inputs include prior lung/venous N2, ambient conditions, time index and shunt.
% Review note: Uses a gas-equivalent blood volume; do not change conservation algebra.
% Scope: Documentation only; all pre-existing lines remain unchanged.
% ========================================================================

function  [n_N2_lung_t, P_N2_art_t, n_N2_art_t]=iteration_N2_lung_search(rt,i,P_N2_lung_tmin1, n_N2_lung_tmin1, P_N2_ven_tmin1, n_N2_ven_tmin1, Pamb,shunt);
%old with estimation of lung PN2 [n_N2_lung_t,P_N2_lung_t, P_N2_art_t, n_N2_art_t]=iteration_N2_lung_search(rt,i,P_N2_lung_tmin1, n_N2_lung_tmin1, P_N2_ven_tmin1, n_N2_ven_tmin1, Pamb,shunt);
format long e
global B_VOL_PACKAGE_VEN SN2_BLOOD P_AMB N2_ARRAY VLinit0 VLinit n_MET_GAS_LUNG 
global LUNG_VOL ADJ_BLOOD_VOL_LUNG_N2

%Pamb is ambient pressure at i-1 and i
vl=LUNG_VOL(i,1)+LUNG_VOL(i,2);%the lung volume at time i
adj_blood_vol=ADJ_BLOOD_VOL_LUNG_N2;%gets computed in GET_GAS_FLUX once instead of each interation, This is an adjusted blood volume corresponding to the equivlanet volume of "gas", this way I can treat them both as gas phases

mol_N2=(n_N2_ven_tmin1+n_N2_lung_tmin1);%total number of moles N2 available for exchange
Vtot=adj_blood_vol+vl;%the total volume adjusted to gas phase that the moles N2 are kept in

mol_lung=(vl/Vtot)*mol_N2;%moles N2 in lung after N2 exchange
molmove_shuntadjust=(n_N2_lung_tmin1-mol_lung)*(1-shunt);%these are the moles to move after shunt has been taken into consideration, if shunt=0 all are moved and if shunt=1 no molecules are moved; molmove_shuntadjust>0 if molecules are removed from lung and <0 if they come into lung
                                                     
n_N2_lung=n_N2_lung_tmin1-molmove_shuntadjust;                                                     
n_N2_ven=n_N2_ven_tmin1+molmove_shuntadjust;

P_N2_ven=n_N2_ven*rt/adj_blood_vol;

n_N2_art_t=n_N2_ven;%the last venuous value becomes the new arterial value and this is returned
P_N2_art_t=P_N2_ven;%
n_N2_lung_t=n_N2_lung;
%P_N2_lung_t=P_N2_lung;

return   