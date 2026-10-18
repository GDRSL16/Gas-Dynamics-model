% ========================================================================
% Second-round internal documentation review: 2026-10-18 | Batch 03
% File: blood_Cco2.m
% Review focus: Gas content, saturation, tension, or acid-base helper. Confirm whether the input is pressure, content, saturation or moles and record units from the actual implementation.
% Documentation only: original MATLAB source follows unchanged.
% ========================================================================
% ============================================================
% Documentation review: 2026-10-18 | Batch 04
% File: blood_Cco2.m
% MATLAB function: y=blood_Cco2(po2,pco2)
% Review scope: documentation only; numerical model unchanged.
% Original source preserved verbatim below this header.
% ============================================================
function y=blood_Cco2(po2,pco2)
%this uses Al's function to compute CO2 concentration from PCO2
global AL_A0 AL_A1 AL_B0 AL_B1 STPD_TO_BT
s=blood_O2_sat(po2,pco2);

y=STPD_TO_BT.*(((1-s).*AL_A0.*pco2.^AL_B0)+(s.*AL_A1.*pco2.^AL_B1));
return