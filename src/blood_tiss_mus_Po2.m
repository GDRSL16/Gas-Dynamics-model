% ========================================================================
% Second-round internal documentation review: 2026-10-18 | Batch 04
% File: blood_tiss_mus_Po2.m
% Review focus: Gas content, saturation, tension, or acid-base helper. Confirm whether the input is pressure, content, saturation or moles and record units from the actual implementation.
% Documentation only: original MATLAB source follows unchanged.
% ========================================================================
% ============================================================
% Documentation review: 2026-10-18 | Batch 05
% File: blood_tiss_mus_Po2.m
% MATLAB function: y=blood_tiss_mus_Po2(pco2,nO2tot, Vtiss,Vblood)%units returned is l gas STPD /l blood
% Review scope: documentation only; numerical model unchanged.
% Original source preserved verbatim below this header.
% ============================================================
function y=blood_tiss_mus_Po2(pco2,nO2tot, Vtiss,Vblood)%units returned is l gas STPD /l blood
%this uses Al's function to compute CO2 concentration from PCO2
%pco2=pco2 of blood at t-1, nO2tot=total mol O2 in blood and tissue after metabolism, Vtiss=tissue volume in l, Vblood=blood volume, %stiss=solubility of O2 in tissue
global GAS_CONSTANT O2_CAPACITY_HB O2_CAPACITY_MB SO2_BLOOD T_TIS STPD_TO_BT DEBUG
%ggf=DEBUG;
%if ggf> 571035
%    pp="in blood_tiss_mus_Po2"
%    pco2
%    nO2tot
%    Vtiss
%    Vblood
%    ggf
%end

y=fzero(@(x)(((muscle_Co2(x)*Vtiss)+(blood_Co2(pco2,x)*Vblood))/GAS_CONSTANT)-nO2tot,[0.00000000001,50]);

return
