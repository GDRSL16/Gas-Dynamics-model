function GET_VARIABLES_LUNG_COLL(n_O2_LUNG,n_CO2_LUNG, n_N2_LUNG)

global VLinit VLmax VTinit VTmax Pint_init KP A1 A2 A3 A4  FLAGGA VLprev  VT VLmin VL Pint NN VLinit0 CLUNG VLprev0
global  LUNG_VOL GAS_CONSTANT M_B V_LUNG TAC

%VLmax = total lung capacity at the relevant reference condition
%VTmax = tracheal/dead-space volume
%V_LUNG = functional lung volume available for the breath
%VLinit = alveolar volume at the beginning of a dive
%V_BREATH = volume exchanged during the breath
%TAC    = total alveolar capacity = VLmax - VTmax

%%%%%%%%%%%%%%%%%%%%START INITILIZATION FOR LUNG COLLAPSE%%%%%%%%%%%%%%%%%%%%%%
A1=0;
A2=1.1063;
A3=1.2304;
A4=1.3361;

KP=-12.78;%possibly use -12
NN=0.907;
Pint_init=95.009576964007664;%ambient pressure in kPa after removing water vapor101.3; %Pint_init=initial pressure inside the respiratory system in mbar, BB=Pinto

VTmax=0.5%0.5;%VTmax=maximum volume of trachea; BB=VTo
VLinit=V_LUNG-VTmax; %VLinit=initial dive lung volume at surface and what I need is start alveolar volume ; BB=VLo2, set equal to V_LUNG at the start of the dive
FLAGGA=0;%set to 0 if Pint <= Pamb and no tracheal collapse else it is set to 1 and use tracheal collapse
VLmax=0.025*M_B;%25 ml/kg from Zimmer et al., 2007, Miller et al., 2016

%VLmax=0.0504*M_B;%ax volume defined as 50.4 ml/kg for elephant seal and is alveolia + trachea and I need max alveolar volume in Kooyman et al. AmJP 1972 assumed to be close to max insp volume,%VLmax=maximum volume of lung; BB=VLo
TAC=VLmax-VTmax;%To keep with BBs abbreviations, TAC is total alveolar volumei
VTinit=VTmax;%VTinit=initial tracheal volume; BB=VTo2
VT=VTinit;
VL=VLinit;
Pint=Pint_init;
VLprev=VLinit-0.5; % this should be kept and passed to the function and is the previous alveolar volume
VLmin(1)=VLmax*.001;%This will be the minimum alveolar volume that is considered before lung collapse
VLmin(2)=900000; %VLmin will contain two numbers, 1=the minimal alveolar volume for a given max volume and 2) the depth where this is reached for a given VLinit
%%%%%%%%%%%%%%%%%%%%END INITILIZATION FOR LUNG COLLAPSE%%%%%%%%%%%%%%%%%%%%%%

%NEEDS INITIALIZATION WITH START VALUES, 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%END Initilization of GLOBAL VARIABLES%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
VLinit0=V_LUNG-VTmax;%this is the initial lung volume as the animal begins a dive, VLinit has to change as N2 is removed from the lung in iteration lungnsearch and when the animal agains reaches the surface VLinit is reset to VLinit0 
%CLUNG=(n_O2_LUNG+n_CO2_LUNG+n_N2_LUNG)*GAS_CONSTANT; %The number of moles O2, N2 and CO2 at the start of the dive, this is a constant as the animal dives as I assume an RQ=1 and the number of moles O2 and CO2 are therefore constant
VLprev0=VLprev;%used to re-set VLprev after each repeated dive
LUNG_VOL(1,1)=VLinit0;
LUNG_VOL(1,2)=VTinit;

return