% ========================================================================
% Second-round internal documentation review: 2026-10-18 | Batch 04
% File: blood_Po2.m
% Review focus: Gas content, saturation, tension, or acid-base helper. Confirm whether the input is pressure, content, saturation or moles and record units from the actual implementation.
% Documentation only: original MATLAB source follows unchanged.
% ========================================================================
% ============================================================
% Documentation review: 2026-10-18 | Batch 04
% File: blood_Po2.m
% MATLAB function: y=blood_Po2(pco2,Co2)%units returned is l gas STPD /l blood
% Review scope: documentation only; numerical model unchanged.
% Original source preserved verbatim below this header.
% ============================================================
function y=blood_Po2(pco2,Co2)%units returned is l gas STPD /l blood
%this uses Al's function to compute CO2 concentration from PCO2
global P50_O2 BETA_0 BOHR O2_CAPACITY_HB SO2_BLOOD STPD_TO_BT DEBUG
%ggf=DEBUG;
%if ggf> 571035
%    pp="in blood_PO2"
%    Co2
%    pco2
%    ggf
%end
%pco2=pco2
%Co2=Co2
if Co2<2.623680307909393e-10
    y=0.0000000001;
    disp('adjust blood') %error trapping for fzero not working
else
    y=fzero(@(x) blood_O2_sat(x,pco2)*O2_CAPACITY_HB*STPD_TO_BT+SO2_BLOOD*x-Co2,[0.00000001,50]);
end

return