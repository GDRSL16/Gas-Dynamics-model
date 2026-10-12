function y=blood_Co2(pco2,po2)%units returned is l gas is Body temperature standard pressure dry per l blood
%this uses Al's function to compute CO2 concentration from PCO2
global O2_CAPACITY_HB SO2_BLOOD STPD_TO_BT
%O2_CAPACITY=ml O2 STPD/ml blood) and STPD_TO_BT converts to T_TIS=tissue
%temp which is assumed to be 37C

y=STPD_TO_BT.*blood_O2_sat(po2,pco2).*O2_CAPACITY_HB+SO2_BLOOD.*po2; %total concentration is attached to Hb and dissolved, assuming that L 

return