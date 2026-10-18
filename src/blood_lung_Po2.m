% ========================================================================
% Second-round internal documentation review: 2026-10-18 | Batch 04
% File: blood_lung_Po2.m
% Review focus: Gas content, saturation, tension, or acid-base helper. Confirm whether the input is pressure, content, saturation or moles and record units from the actual implementation.
% Documentation only: original MATLAB source follows unchanged.
% ========================================================================
% ============================================================
% Documentation review: 2026-10-18 | Batch 04
% File: blood_lung_Po2.m
% MATLAB function: y=blood_lung_Po2(pco2,nO2tot,Vlung,Vblood)%units returned is l gas STPD /l blood
% Review scope: documentation only; numerical model unchanged.
% Original source preserved verbatim below this header.
% ============================================================
function y=blood_lung_Po2(pco2,nO2tot,Vlung,Vblood)%units returned is l gas STPD /l blood
%this uses Al's functions to compute O2 concentration from PO2
%pco2=blood PCO2 at t-1, nO2tot=total mol O2 in blood and tissue after metabolism, Vtiss=tissue volume in l, Vblood=blood volume, 
%this is in fact a function with 2 unknowns as S depends on PCO2 and we do
%not know PCO2. I therefore assume that delta-time is small enough and use
%po2 at time t-1 to define these
global GAS_CONSTANT  STPD_TO_BT AL_A0 AL_A1 AL_B0 AL_B1 DEBUG
%ggf=DEBUG;
%if ggf> 571035
%    pp="in blood lung po2"
%    pco2
%    nO2tot
%    Vlung
%    Vblood
%    ggf
%end

y=fzero(@(x)(1/GAS_CONSTANT*((blood_Co2(pco2,x)*Vblood)+(x*Vlung)))-nO2tot,[0.00000000001,51]);

return
