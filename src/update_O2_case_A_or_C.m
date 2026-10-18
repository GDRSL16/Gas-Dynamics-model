% ========================================================================
% Second-round internal documentation review: 2026-10-18 | Batch 06
% File: update_O2_case_A_or_C.m
% Review focus: Gas-specific lung/blood exchange branch. Case selection and gas flux sign conventions should be documented against the corresponding physiological equations.
% Documentation only: original MATLAB source follows unchanged.
% ========================================================================
% ============================================================
% Documentation review: 2026-10-18 | Batch 06
% File: update_O2_case_A_or_C.m
% Function signature: [P_O2_lung_t,n_O2_lung_t,P_O2_art_t,n_O2_art_t]=update_O2_case_A_or_C(Vblood, sO2_blood,rt,breath_gas);
% Scope: documentation only; numerical model unchanged.
% Original source preserved verbatim below this header.
% ============================================================
% FINITE BREATH / LEGACY SURFACE - O2
% Optional breath_gas is 3x2: rows N2,O2,CO2; columns pressure(atm), moles.
% O2 blood content depends on both lung PO2 and PCO2.
% Instantaneous arterial equilibration is an explicit model assumption.

function [P_O2_lung_t,n_O2_lung_t,P_O2_art_t,n_O2_art_t]=update_O2_case_A_or_C(Vblood, sO2_blood,rt,breath_gas);
global O2_ARRAY ALV_SURFACE_VALUE
if nargin < 4
    surface_gas=ALV_SURFACE_VALUE; % legacy behavior if called elsewhere
else
    surface_gas=breath_gas;
end 
%SURFACE_VALUE is a new global variable that will take the place of N2_ARRAY and will also contain O2 and CO2
%SURFACE_VALUE(row,column) where row 1=N2, 2=O2, 3=CO2 and column
%1=Pressure, 2=moles
%this needs some work as blood is a bit more complex
P_O2_lung_t=surface_gas(2,1);%O2_ARRAY(1,5,1); %partial pressure of N2 assuming that lung when at surface is constant  
n_O2_lung_t=surface_gas(2,2);%O2_ARRAY(1,5,2);%mol N2 in lung
P_O2_art_t=P_O2_lung_t; %immediate and no shunt allowed 
n_O2_art_t=(Vblood*blood_Co2(surface_gas(3,1), P_O2_lung_t))/(rt);

return