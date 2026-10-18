% ============================================================
% Code documentation review: 2026-10-18 (Batch 03)
% Purpose: Legacy oxygen saturation calculation.
% Interface: No declared input arguments; returns y.
% Notes: WARNING: source contains incomplete expression PO2=; and references undeclared PCO2. Preserved without repair.
% Review scope: Documentation only; model logic unchanged.
% ============================================================
%this is the equation for the O2 tissue tension
function y= O2_saturation()
global HB P50_O2 BETA_0 BOHR HALDANE STANDARD_BICARBONATE HB T_TIS

blood_temp=T_TIS;
P_CO2=PCO2*760;%converting PCO2 from atm to mmHg
pHa=6.1+log(STANDARD_BICARBONATE/(0.03*P_CO2));%pK'+log([HCO3]/(CO2_solubility*PCO2), where pK'=6.1, CO2_solubility=0.03mM/[L*mmHg] and PCO2 is in mmHg
PO2=;
p50=P50_O2-(10^(BOHR)*10^(7.4-pHa));%change in P50 with a change in pH away from 7.4
Sat=(PO2^BETA_0)/(PO2^BETA_0+p50^BETA_0); %O2 saturation given by Hill function as a fraction, take pH and body temp changes into consideration
y=Sat;
return