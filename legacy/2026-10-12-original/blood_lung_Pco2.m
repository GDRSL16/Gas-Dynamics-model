function y=blood_lung_Pco2(po2,nCO2tot,Vlung,Vblood)%units returned is l gas STPD /l blood
%this uses Al's functions to compute CO2 concentration from PCO2
%po2=blood PO2 at t-1, pco2=pco2 of blood at t-1, nO2tot=total mol O2 in blood and tissue after metabolism, Vtiss=tissue volume in l, Vblood=blood volume, %stiss=solubility of CO2 in tissue
%this is in fact a function with 2 unknowns as S depends on PCO2 and we do
%not know PCO2. I therefore assume that delta-time is small enough and use
%po2 at time t-1 to define these
global GAS_CONSTANT  STPD_TO_BT AL_A0 AL_A1 AL_B0 AL_B1 DEBUG
%ggf=DEBUG;
%if ggf> 571035
%    e="in lung-poc2"
%    po2
%    nCO2tot
%    Vlung
%    Vblood
%    ggf
%end
y=fzero(@(x)(1/GAS_CONSTANT*((blood_Cco2(po2,x)*Vblood)+(x*Vlung)))-nCO2tot,[0.00000000001,51]);

return
