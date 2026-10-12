function y=blood_tiss_Po2(pco2,nO2tot, Vtiss,Vblood,stiss)%units returned is l gas STPD /l blood
%this uses Al's function to compute CO2 concentration from PCO2
%pco2=pco2 of blood at t-1, nO2tot=total mol O2 in blood and tissue after metabolism, Vtiss=tissue volume in l, Vblood=blood volume, %stiss=solubility of O2 in tissue
global GAS_CONSTANT O2_CAPACITY_HB SO2_BLOOD T_TIS STPD_TO_BT DEBUG
%ggf=DEBUG;
%if ggf> 571035
%    pp="in blood_tiss_Po2"
%    pco2
%    nO2tot
%    Vtiss
%    Vblood
%    stiss
%    ggf
%end

y=fzero(@(x)(((blood_O2_sat(x,pco2)*O2_CAPACITY_HB*STPD_TO_BT+SO2_BLOOD*x)*Vblood)/GAS_CONSTANT)+((stiss*x*Vtiss)/GAS_CONSTANT)-nO2tot,[0.00000000001,50]);

return
