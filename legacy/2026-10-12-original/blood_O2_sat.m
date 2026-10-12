function y=blood_O2_sat(po2,pco2)%units returned is l gas STPD /l blood
%this uses Al's function to compute CO2 concentration from PCO2
global BETA_0 
%global pH P50_O2 BOHR

p50_adj=0.02326+0.1465*pco2;%adjust P50 using a data from Clausen and Ersland, Resp Physiol 1969, 7, 1-6 
%%%%%%%%%%%%%%%%%%using the general definition of BOHR effect
%dlogP50=(7.4-pH)*BOHR;%BOHR expressed as delta log(P50)/delta(pH), pH must come from last iteration as it depends on saturation and that is esitmate dhere
%p50_adj=10^(log10(P50_O2)+dlogP50);%P50_O2 must be defined for a starting pH, here assumed as the pH at 7.4 and at body temp=37C

y=(po2.^BETA_0)./(po2.^BETA_0+p50_adj.^BETA_0); %O2 saturation of blood

return