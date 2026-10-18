% ========================================================================
% Second-round internal documentation review: 2026-10-18 | Batch 03
% File: blood_Pco2.m
% Review focus: Gas content, saturation, tension, or acid-base helper. Confirm whether the input is pressure, content, saturation or moles and record units from the actual implementation.
% Documentation only: original MATLAB source follows unchanged.
% ========================================================================
% ============================================================
% Documentation review: 2026-10-18 | Batch 04
% File: blood_Pco2.m
% MATLAB function: y=blood_Pco2(S,Cco2)
% Review scope: documentation only; numerical model unchanged.
% Original source preserved verbatim below this header.
% ============================================================
function y=blood_Pco2(S,Cco2)
%this uses Al's function to compute PCO2 concentration from Cco2, and O2
%saturation (S)
global AL_A0 AL_B0 AL_A1 AL_B1 STPD_TO_BT DEBUG
%ggf=DEBUG;
%if ggf> 571035
%    pp="in blood_PCO2"
%    Cco2
%    S
%    ggf
%end
%Cco2=Cco2/STPD_TO_BT;%content is for 37C and needs to be changed and equivalent to concentration. Alternatively, similarly to the equation in blood_Po2, multiplycontent equation by STPD_TO_BT
y=fzero(@(x)((AL_A0*(1-S)*x^AL_B0)+(S*AL_A1*x^AL_B1))*STPD_TO_BT-Cco2,[0.0000000001,50]);
return