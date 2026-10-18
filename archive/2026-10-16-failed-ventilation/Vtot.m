%this is the equation for the lung volume changes
function y=Vtot(n_N2, n_O2, n_CO2, T_tis, Pamb)
global R 
%Pamb, n_N2, n_CO2, n_O2 Vtot=n(sum)*R*T/Pamb where n(sum)=n_N2+n_CO2+n_O2
y=((n_N2+n_O2+n_CO2)*R*T_TIS)/Pamb;
return