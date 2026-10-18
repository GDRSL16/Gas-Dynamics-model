% ============================================================
% Code documentation review: 2026-10-18 (Batch 03)
% Purpose: Computes total lung gas volume from gas moles and ideal gas law.
% Interface: Inputs: n_N2, n_O2, n_CO2, T_tis, Pamb.
% Notes: WARNING: body uses T_TIS rather than input T_tis; preserved for later investigation.
% Review scope: Documentation only; model logic unchanged.
% ============================================================
%this is the equation for the lung volume changes
function y=Vtot(n_N2, n_O2, n_CO2, T_tis, Pamb)
global R 
%Pamb, n_N2, n_CO2, n_O2 Vtot=n(sum)*R*T/Pamb where n(sum)=n_N2+n_CO2+n_O2
y=((n_N2+n_O2+n_CO2)*R*T_TIS)/Pamb;
return