% ============================================================
% Code documentation review: 2026-10-18 (Batch 03)
% Purpose: Computes myoglobin oxygen saturation using a Hill-type relationship.
% Interface: Input: po2. Output: fractional myoglobin O2 saturation.
% Notes: Uses global P50_MB and BETA_0_MB; no Bohr adjustment is applied.
% Review scope: Documentation only; model logic unchanged.
% ============================================================
function y=Muscle_MbO2_sat(po2)%units returned is l gas STPD /l blood
%Not sure that Mb is affected by CO2 in a similar fashion as Hb so I set
%Bohr to 0, according to Al Olszowka, Mb is a monomer and it is unlikely
%that it will experience the same type of geometric change with changes in
%PCO2
global P50_MB BETA_0_MB %BOHR

p50_adj=P50_MB;
%p50_adj=P50_MB.*(pco2./40).^BOHR;

y=(po2.^BETA_0_MB)./(po2.^BETA_0_MB+p50_adj.^BETA_0_MB); %O2 saturation of blood

return