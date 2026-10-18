% ============================================================
% Documentation review: 2026-10-18 | Batch 05
% File: blood_tiss_Pco2.m
% MATLAB function: y=blood_tiss_Pco2(po2,pco2, nCO2tot,Vtiss,Vblood,stiss)%units returned is l gas STPD /l blood
% Review scope: documentation only; numerical model unchanged.
% Original source preserved verbatim below this header.
% ============================================================
function y=blood_tiss_Pco2(po2,pco2, nCO2tot,Vtiss,Vblood,stiss)%units returned is l gas STPD /l blood
%this uses Al's functions to compute CO2 concentration from PCO2
%po2=blood PO2 at t-1, pco2=pco2 of blood at t-1, nO2tot=total mol O2 in blood and tissue after metabolism, Vtiss=tissue volume in l, Vblood=blood volume, %stiss=solubility of CO2 in tissue
%this is in fact a function with 2 unknowns as S depends on PCO2 and we do
%not know PCO2. I therefore assume that delta-time is small enough and use
%po2 at time t-1 to define these
global GAS_CONSTANT  STPD_TO_BT AL_A0 AL_A1 AL_B0 AL_B1 DEBUG;
%ggf=DEBUG;
%if ggf> 571035
%    pp="in blood_tiss_Pco2"
%    po2
%    pco2
%    nCO2tot
%    Vtiss
%    Vblood
%    stiss
%    ggf
%end
y=fzero(@(x)(1/GAS_CONSTANT*(((((1-blood_O2_sat(po2,x))*AL_A0*x^AL_B0)+(blood_O2_sat(po2,x)*AL_A1*x^AL_B1))*Vblood*STPD_TO_BT)+(x*stiss*Vtiss)))-nCO2tot,[0.00000000001,51]);

return
