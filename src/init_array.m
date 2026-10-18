% ========================================================================
% Second-round internal documentation review: 2026-10-18 | Batch 05
% File: init_array.m
% Review focus: Review input/output dimensions, global state, units and call-site assumptions before further refactoring.
% Documentation only: original MATLAB source follows unchanged.
% ========================================================================
% ========================================================================
% Documentation reviewed: 2026-10-18 | Batch 02
% Purpose: Initialize gas-state arrays and starting tissue/lung values.
% Interface: No arguments; uses globally configured array dimensions and initial gas stores.
% Review note: The -9 sentinel values are intentional diagnostics for uninitialized entries.
% Scope: Documentation only; all pre-existing lines remain unchanged.
% ========================================================================

%This gives starting values for the arrays
function init_array()
global V_MUSCLE V_HEART V_FAT V_BRAIN 
global  n_N2_LUNG n_O2_LUNG n_CO2_LUNG
global n_N2_HEART  n_N2_FAT  n_N2_MUSCLE  n_N2_BRAIN
global n_O2_HEART  n_O2_FAT  n_O2_MUSCLE  n_O2_BRAIN
global n_CO2_HEART  n_CO2_FAT  n_CO2_MUSCLE  n_CO2_BRAIN
global GAS_CONSTANT N2_ARRAY O2_ARRAY CO2_ARRAY %global variables initialized here
global PN2_ven_init PO2_ven_init PCO2_ven_init PN2_alv_init PO2_alv_init PCO2_alv_init 
N2_ARRAY(:,:,:)=-9;%initializes all arrays to -9 so I can find which values are not used or changing, such as the tissue tension of O2
O2_ARRAY(:,:,:)=-9;
CO2_ARRAY(:,:,:)=-9;
initial_N2_increase=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Initilizing N2%%%%%%%%%%%%%%%%%%%%%%%%%%%555
N2_ARRAY(1,1:4,1)=PN2_ven_init.*initial_N2_increase; %partial pressure of N2, assuming that the animal is initially fully saturated 
N2_ARRAY(1,5,1)=PN2_alv_init; %partial pressure of N2 in lung 
N2_ARRAY(1,1,2)=n_N2_HEART.*initial_N2_increase;%mol N2 in heart
N2_ARRAY(1,2,2)=n_N2_MUSCLE.*initial_N2_increase;%mol N2 in muscle
N2_ARRAY(1,3,2)=n_N2_BRAIN.*initial_N2_increase;%mol N2 in Brain
N2_ARRAY(1,4,2)=n_N2_FAT.*initial_N2_increase;%mol N2 in fat
N2_ARRAY(1,5,2)=n_N2_LUNG;%*initial_N2_increase;%mol N2 in lung
N2_ARRAY(:,1,3)=V_HEART;%volume of heart tissue
N2_ARRAY(:,2,3)=V_MUSCLE;%volume of muscle tissue
N2_ARRAY(:,3,3)=V_BRAIN;%volume of brain tissue
N2_ARRAY(:,4,3)=V_FAT;%volume of FAT tissue
N2_ARRAY(1,5,3)=n_N2_LUNG*GAS_CONSTANT;% volume N2 in lung 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Initilizing O2%%%%%%%%%%%%%%%%%%%%%%%%%%%555
O2_ARRAY(1,1:4,1)=PO2_ven_init; %partial pressure of O2, assuming that the animal is initially fully saturated 
O2_ARRAY(1,5,1)=PO2_alv_init; %partial pressure of O2 in lung 
O2_ARRAY(1,1,2)=n_O2_HEART;%mol O2 in heart
O2_ARRAY(1,2,2)=n_O2_MUSCLE;%mol O2 in muscle tied to myoglobin
O2_ARRAY(1,3,2)=n_O2_BRAIN;%mol O2 in Brain
O2_ARRAY(1,4,2)=n_O2_FAT;%mol O2 in fat
O2_ARRAY(1,5,2)=n_O2_LUNG;%mol O2 in lung
O2_ARRAY(:,1,3)=V_HEART;%volume of heart tissue
O2_ARRAY(:,2,3)=V_MUSCLE;%volume of muscle tissue
O2_ARRAY(:,3,3)=V_BRAIN;%volume of brain tissue
O2_ARRAY(:,4,3)=V_FAT;%volume of FAT tissue
O2_ARRAY(1,5,3)=n_O2_LUNG*GAS_CONSTANT;% volume O2 in lung 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Initilizing CO2%%%%%%%%%%%%%%%%%%%%%%%%%%%555
CO2_ARRAY(1,1:4,1)=PCO2_ven_init; %partial pressure of O2, assuming that the animal is initially fully saturated 
CO2_ARRAY(1,5,1)=PCO2_alv_init; %partial pressure of O2 in lung 
CO2_ARRAY(1,1,2)=n_CO2_HEART;%mol CO2 in heart%we assume no
CO2_ARRAY(1,2,2)=n_CO2_MUSCLE;%mol CO2 in muscle
CO2_ARRAY(1,3,2)=n_CO2_BRAIN;%mol CO2 in Brain
CO2_ARRAY(1,4,2)=n_CO2_FAT;%mol CO2 in fat
CO2_ARRAY(1,5,2)=n_CO2_LUNG;%mol CO2 in lung
CO2_ARRAY(:,1,3)=V_HEART;%volume of heart tissue
CO2_ARRAY(:,2,3)=V_MUSCLE;%volume of muscle tissue
CO2_ARRAY(:,3,3)=V_BRAIN;%volume of brain tissue
CO2_ARRAY(:,4,3)=V_FAT;%volume of FAT tissue
CO2_ARRAY(1,5,3)=n_CO2_LUNG*GAS_CONSTANT;% volume O2 in lung 


%%%%%%%%%%%%%%%%%CHECK THESE%%%%%%%%%%%%%%%%%%%%%041027-not done
%CO2_ARRAY(1,5,2) 
%O2_ARRAY(1,5,2)
%N2_ARRAY(1,5,2)
N2_ARRAY(1,:,:);
O2_ARRAY(1,:,:);
CO2_ARRAY(1,:,:);
%%%%%%%%%%%%%%%%%CHECK THESE%%%%%%%%%%%%%%%%%%%%%

return