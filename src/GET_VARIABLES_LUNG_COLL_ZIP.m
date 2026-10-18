% ========================================================================
% Documentation reviewed: 2026-10-18 | Batch 02
% Purpose: Initialize lung-compression parameters and initial lung-volume state.
% Interface: Inputs are initial O2, CO2 and N2 lung moles; results are global variables.
% Review note: Initial values and pressure/volume relationships are not altered.
% Scope: Documentation only; all pre-existing lines remain unchanged.
% ========================================================================

function GET_VARIABLES_LUNG_COLL_ZIP(n_O2_LUNG,n_CO2_LUNG, n_N2_LUNG)

global VLinit VLmax VTinit VTmax Pint_init KP A1 A2 A3 A4  FLAGGA VLprev  VT VLmin VL Pint NN VLinit0 CLUNG VLprev0
global  LUNG_VOL GAS_CONSTANT M_B V_LUNG TAC

%%%%%%%%.05%%%%%%%%%%%%START INITILIZATION FOR LUNG COLLAPSE%%%%%%%%%%%%%%%%%%%%%%
A1=0;
%%%%%%%OLD parameters
%A2=1.1063;%1.05;%new: 1.05, old:a: 1.1063;
%A3=1.2304;%0.9;%new: 0.9, old:b: 1.2304;
%A4=1.3361;%2.5;% new : 2.5 old c: 1.3361;

%KP=-12.78;%-31;%new: -31, old-12.78;
%NN=0.907;%2.4;%new: 2.4, old 0.907;

%%%%%%%new parameters

A2=1.05;%new: 1.05, old:a: 1.1063;
A3=0.9;%new: 0.9, old:b: 1.2304;
A4=2.5;% new : 2.5 old c: 1.3361;

KP=-31;%new: -31, old-12.78;
NN=2.4;%new: 2.4, old 0.907;



Pint_init=95.009576964007664;%ambient pressure in kPa after removing water vapor101.3; %Pint_init=initial pressure inside the respiratory system in mbar, BB=Pinto

%VTmax=0.07*V_LUNG;%Dead space is 7% of TLC .5;%VTmax=maximum volume of trachea; BB=VTo
VLmax=25*M_B/1000;%25 ml/kg from Zimmer et al., 2007, and miller et al., 2016
VTmax=0.0667*VLmax;%maximum dead space volume, from Kooyman REsp Adaptations Amer Zool, 13: 1973 

VLinit=V_LUNG-VTmax; %VLinit=initial dive lung volume at surface and what I need is start alveolar volume ; BB=VLo2, set equal to V_LUNG at the start of the dive
FLAGGA=0;%set to 0 if Pint <= Pamb and no tracheal collapse else it is set to 1 and use tracheal collapse
%VLmax=0.135*M_B^0.92;%ax volume defined as 50.4 ml/kg for elephant seal and is alveolia + trachea and I need max alveolar volume in Kooyman et al. AmJP 1972 assumed to be close to max insp volume,%VLmax=maximum volume of lung; BB=VLo

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