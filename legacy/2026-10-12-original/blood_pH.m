function y=blood_pH(po2,pco2)%units returned is l gas STPD /l blood
%this uses Al's function to compute pH as estimated from seal blood,
%Ersland and calusen 1969 in resp physiol

s=po2;%blood_O2_sat(po2,pco2);
%Hb-O2, s=1 pH=8.137-0.4892*log10(pco2)
%Hb, s=0, pH=8.04-0.4959*log10(pco2)
y=(1-s)*(6.702-0.4982*log10(pco2))+s*(6.611-0.4959*log10(pco2));
return

