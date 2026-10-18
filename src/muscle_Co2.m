% ========================================================================
% Second-round internal documentation review: 2026-10-18 | Batch 05
% File: muscle_Co2.m
% Review focus: Gas content, saturation, tension, or acid-base helper. Confirm whether the input is pressure, content, saturation or moles and record units from the actual implementation.
% Documentation only: original MATLAB source follows unchanged.
% ========================================================================
% ============================================================
% Documentation review: 2026-10-18 | Batch 06
% File: muscle_Co2.m
% Function signature: y=muscle_Co2(po2)%units returned is l gas  (Body temperature standard pressure dry) per l muscle
% Scope: documentation only; numerical model unchanged.
% Original source preserved verbatim below this header.
% ============================================================
function y=muscle_Co2(po2)%units returned is l gas  (Body temperature standard pressure dry) per l muscle
%this uses Al's function to compute CO2 concentration from PCO2
global O2_CAPACITY_MB STPD_TO_BT SO2_BLOOD
%O2_CAPACITY=ml O2 STPD/ml blood)

y=STPD_TO_BT*Muscle_MbO2_sat(po2).*O2_CAPACITY_MB+SO2_BLOOD.*po2; %total volume in BTPS attached to Mb per kg muscle

return