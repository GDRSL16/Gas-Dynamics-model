% ============================================================
% Documentation review: 2026-10-18 | Batch 04
% File: beakedwhale_tissue_kinetics1.m
% MATLAB function: y=beakedwhale_tissue_kinetics1(s,op,new_i, dsum)%s=data file with all dive data, op=body mass of animal, new_i=the repeated record when running this repeatedly to find a record, dsum=data file containing all the summarized dive and surface interval data with metabolic rates for COL
% Review scope: documentation only; numerical model unchanged.
% Original source preserved verbatim below this header.
% ============================================================
%This is the driver for the tissue gas kinetics program
function y=beakedwhale_tissue_kinetics1(s,op,new_i, dsum)%s=data file with all dive data, op=body mass of animal, new_i=the repeated record when running this repeatedly to find a record, dsum=data file containing all the summarized dive and surface interval data with metabolic rates for COL
format long e
global SURFACE_VALUE
global N N2_ARRAY O2_ARRAY CO2_ARRAY P_AMB  P_H2O  ART_VEN_PN2 SHUNT_FLAG DECO_FLAG %global variables initialized here
global  SUMMARY_ARRAY ART_VEN_nN2 ATA DEBUG LUNG_VOL ART_VEN_PO2 ART_VEN_PCO2 OP%temporary array to hold the arterial and venous values.
global SONAR_FLAG QTOTARRAY STORES O2_DEPLETED_FLAG BREATH_FLAG
%%%%%%%%%%%%%%%Creating headers for files
persistent prefixes headers
if isempty(prefixes)
    prefixes = {
     '1-Zica-20191012-144029'
     '2-Zica-20191012-145101'
     '3-Zica-20191111-94810'
     '4-Zica-20191117-195993'
     '5-Zica-20211112-94819'
     '6-Zica-20211113-195993'
     '7-Zica-20220112-195994'
     '8-Zica-20230518-233391'
     '9-Zica-20230519-232950'
     '10-Zica-20230723-233394'
     '11-Zica-20240227-233396'
     '12-Zica-20240227-240128'
};
 headers.summary = {'N2					O2					CO2					PN2-blood	    PO2-blood	PCO2-blood	Pamb	Alv	Trac	Shunt	ODBA	COL'
'Heart	Muscle	Brain	Fat	Lung	Heart	Muscle	Brain	Fat	Lung	Heart	Muscle	Brain	Fat	Lung	Art	Ven	Art	Ven	Art	Ven	Pamb	Alv	Trac	Shunt	ODBA	COL'};

headers.dADL = {'Tissue_O2_pre	Lung_O2_pre	Blood_O2_pre	Total_O2_pre	SI_duration	Pamb_pre	Tissue_O2_post	Lung_O2_post	Blood_O2_post	Total_O2_post	Heart_MR	Muscle_MR	Brain_MR	Fat_MR	Total_MR	Dive_duration	Max_depth	Pamb_post	Muscle_O2_pre	Muscle_O2_post'};

headers.O2_CO2_N2_PP = {'Pre_N2_Heart	Pre_N2_Muscle	Pre_N2_Brain	Pre_N2_Fat	Pre_O2_Heart	Pre_O2_Muscle	Pre_O2_Brain	Pre_O2_Fat	Pre_CO2_Heart	Pre_CO2_Muscle	Pre_CO2_Brain	Pre_CO2_Fat	Post_N2_Heart	Post_N2_Muscle	Post_N2_Brain	Post_N2_Fat	Post_O2_Heart	Post_O2_Muscle	Post_O2_Brain	Post_O2_Fat	Post_CO2_Heart	Post_CO2_Muscle	Post_CO2_Brain	Post_CO2_Fat	Dive_duration	Max_depth	N2_Arterial-pre	N2_Venous-pre  N2_Arterial-post	 N2_Venous-post   CO2_Arterial-post	 CO2_Venous-post'};

headers.QTOTARRAY = {'Dive_Total	Dive_Heart	Dive_Muscle	Dive_Brain	Dive_Fat	Surface_Total	Surface_Heart	Surface_Muscle	Surface_Brain	Surface_Fat'};

headers.STORES = {'O2_Muscle	O2_Tissue	O2_Arterial	O2_Venous	O2_Lung	CO2_Muscle	CO2_Tissue	CO2_Arterial	CO2_Venous	CO2_Lung'};
end
%%%%%%%%%%%%%%%End creating headers and file names

%%%%%%%%%%%%%%%%%%%%%%%%%INIT GLOBAL VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%
P_H2O=(10^(0.024932*37+0.7514))/760; %Vapour pressure at saturation, in atm, of water at STPD @37C
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%START PROGRAM%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%s=data file loaded in driver_to_dolphin_tissue_kin, op=animal specific
%body mass, new_1=specifies which animal so we can load correct data file
%and get variables when they are different for Bermuda and Sarasota
timearraystart = clock;
OP=op;
DEBUG=0;
SHUNT_FLAG=0;%this holds the number for the row when the lung N2 has run out

size(s)
N=length(s); %number data points

%%%%%%%%%%%%%DUMM CALL TO GET BREATHS
% ===== BREATH EVENTS =====
global BREATH_FLAG

BREATH_FLAG = zeros(size(N,1));

breath_rows = [ ...
    90, ...
    1688, 1700, 1768, ...
    3295, 3330, 3390, 3440, 3480, ...
    8750, 8780, 8810, 8825, 8842, ...
    10378, 10400, 10430, 10450, 10480, ...
    11740, 11760, 11790, 11810, 11835, 13190, 13210];

BREATH_FLAG(breath_rows) = 0;
%%%%%%%%%%%%%%%END DUMMY CALL FOR BREATHS


LUNG_VOL=[];
LUNG_VOL(N,5)=-9;%t LUNG_VOL(:,1)=alveolar volume, LUNG_VOL(:,2)=tracehal volume, LUNG_VOL(:,3)=Pinternal,, LUNG_VOL(:,4)=Pambinet, LUNG_VOL(:,5)=Shunt
DECO_FLAG=0;
SONAR_FLAG=[];
SONAR_FLAG(:,1)=s(:,5);%a 2nd column that indicates time when sonar is on, 1=sonar off, 0=sonar on
SONAR_FLAG(:,1)=1;%FORCE all to be no sonar
%SONAR_FLAG(:,1)=s(:,6);%a 2nd column that indicates time when orca sound is on, 1=sonar off, 0=sonar on only for file 7-Zica-20220112-195994
SONAR_FLAG(:,2)=1;%keeps track of the dive response in GET_GAS_FLUX, 1=surface value, 0=dive response
depth=s(:,2); %create depth variable
depth(depth < 0) = 0;%make sure no value is negative
%DECO_FLAG=s(:,2);%used in "GET_GAS_FLUX" to find the depth where diving bradycardia is reversed at depth
s(:,2)=depth;
ATA=(s(:,2)/10)+1;%-0.1; %Pressure in m, the 0.1 is to "subtract" 1 m from depth to make sure that surface intervals are found 
O2_DEPLETED_FLAG=[0 0 0 0 0]; %an array that tracks if O2 has run out, which means anaerobic metabolism and stop for CO2 accumulation, this is updated in "update_tissue_O2" and then used in "update_tissue_CO2", has 5 cells, heart, muscle, brain, fat, blood, modifications in update_tissue_O2 and CO2
%%%%%%%%%%%%%Fix september 17, 2021
for r=1:length(ATA)
    if ATA(r)<1
        ATA(r)=1;
    else
        ATA(r)=ATA(r);
    end
end
%plot(ATA)
%ATA=s(:,1); %Pressure already in atmospheres absolute
%P_AMB=ATA;
P_AMB=ATA.*(1-P_H2O);%corrects all pressures to absolute gauge pressures and removes vapour pressure
%P_AMB=(s(:,1)+1)*(1-P_H2O);%corrects all pressures to absolute gauge pressures and removes vapour pressure

%PECT=s(:,2);%pectoral temperature
SURFACE_VALUE=P_AMB(1);%ambient pressure at surface corrected for water vapour
ART_VEN_PN2=zeros(N,2);%array of arterial and venuous values throughout the dive
ART_VEN_nN2=zeros(N,2);%array of arterial and venuous number of moels values throughout the dive
ART_VEN_PO2=zeros(N,2);%array of arterial and venuous values throughout the dive
ART_VEN_nO2=zeros(N,2);%array of arterial and venuous number of moels values throughout the dive
ART_VEN_PCO2=zeros(N,2);%array of arterial and venuous values throughout the dive
ART_VEN_nCO2=zeros(N,2);%array of arterial and venuous number of moels values throughout the dive
STORES=zeros(N,10); %array that contains and tracks the O2 and CO2 stores throughout the entire dive series

%GET_VARIABLES_ZIP(op);%get variables for ziphius, original before 2022
GET_VARIABLES_ZIP_NEW(op);%get variables for ziphius with reduced muscle MR


%%%%%%%%%%%%%%%%%%%%%%%%%Initializing lung and tissue arrays%%%%%%%%%%%%%%%%%
C=5;%number of tissue compartments including lung C1:heart C2:muscle C3:Brain C4:fat C5:Lung
V=3;%number of columns for each tissue, to keep V1:Ptis=tissue tension, V2:n=mol, V3:volume=only changing for lung 
N2_ARRAY=zeros(N,C,V);
O2_ARRAY=zeros(N,C,V);
CO2_ARRAY=zeros(N,C,V);
init_array;
%init_array_temp;%Initalizes the arrays %%%%%%%%%%%%%%%%%%%%%%%%%%%%OCT27 2006 DEBUG REMOVE %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%end%%%%%%%%%%%%%%%%%%%%%%%%
%GET_GAS_FLUX(dsum);%the onl one with splitting dive duration into 3 different sections, <60, <600 and > 600

GET_GAS_FLUX_1(dsum);%the function that separates gas fluxes, updated Aug 13, 2022 to allow variation in dive response and metabolic rates, dependong on dive duration

y=N2_ARRAY;%plots N2 tnesion in heart
%plot(N2_ARRAY(:,1,1))%heart tension

%plot(N2_ARRAY(:,2,1))%muslce tension
%plot(N2_ARRAY(:,3,1))%brain tension
%plot(N2_ARRAY(:,4,1))%fat tension

%plot(N2_ARRAY(:,5,1))%lung partial pressure
%plot(ART_VEN_PN2(:,2))%venous tension
%plot(ART_VEN_PN2(:,1))%arterial tension
%plot(P_AMB(8:12))%ambient pressure
%plot(N2_ARRAY(:,2,1))
%SHUNT_FLAG
%y=ART_VEN_PN2;

%dd=[DUMMY_ARTERIAL' ART_VEN_PN2(:,1)];
%dummy_arterial is the arterial value right before gas exchange at the tissue, see lines 25-27 in "update_tissue_N2"

%SUMMARY_ARRAY=[N2_ARRAY(:,:,1) N2_ARRAY(:,:,2) ART_VEN_PN2 P_AMB (ART_VEN_PN2(:,2)-P_AMB*0.79)];%heart, muscle, brain, fat
SUMMARY_ARRAY=[N2_ARRAY(:,:,1) O2_ARRAY(:,:,1) CO2_ARRAY(:,:,1) ART_VEN_PN2 ART_VEN_PO2 ART_VEN_PCO2 P_AMB LUNG_VOL(:,1) LUNG_VOL(:,2) LUNG_VOL(:,5)];%heart, muscle, brain, fat
%1-5:N2-heart, muscle, brain, fat, lung; 6-10:O2-heart, muscle, brain, fat, 11-15:CO2-heart, muscle, brain, fat
%16-17:artvenPN2; 18-19:artvenO2; 20-21:artvenCO2, 22-Pamb, 23-Lung vol-alv,
%24-lungvol-trach, 25-lung sunt, 26=ODBA, 27=COL

%LUNG_VOL(:,1)=alv vol, LUNG_VOL(:,2)=tracheal vol, LUNG_VOL(:,5)=shunt level
%plot(O2_ARRAY(:,2,1))
%dd=[ART_VEN_PN2(:,1) ART_VEN_PN2(:,2) SUMMARY_ARRAY(:,3) ];
%save dd dd -ascii -tabs -double
save SUMMARY_ARRAY SUMMARY_ARRAY -ascii -tabs -double
y=1;



%%%%%%%%%%%%%%%%%%%%%%%%%%%CAN INVOKE LATER WHEN MODEL WORKS COMMENT OUT
%%%%%%%%%%%%%%%%%%%%%%%%%%%NOW TO RUN DUMMY DIVE DATA
odba=GET_DIVE_ODBA(new_i);%extract odba data to save with output data
%dADL=GET_DIVE_DYNAMIC_ADL(dsum);%new function Aug 9, 2022 that pulls out the dyanmic aerobic dive limit, i.e. the cADL for each dive, new_i us used to get start and end of each dive

            %save dsum dsum -ascii -tabs
           %save SUMMARY_ARRAY SUMMARY_ARRAY -ascii -tabs
O2_CO2_N2_PP=GET_O2_CO2_N2_PP(dsum, SUMMARY_ARRAY);%New function Aug 2024, pulls out last 5 values before surface of PO2, PCO2 and PN2
              %save dADL dADL -ascii -tabs
                %save STORES STORES -ascii -tabs
              %odba=odba(:,3);

 length(SUMMARY_ARRAY)
 %SAVEDATA(SUMMARY_ARRAY)
 
 SUMMARY_ARRAY=[SUMMARY_ARRAY(:,:) odba(:,3) s(:,4)]; %add ODBA and COL
SAVEDATA(SUMMARY_ARRAY)

base = prefixes{new_i};

outFolder = fullfile(pwd, 'model_outputs');
if ~exist(outFolder, 'dir'), mkdir(outFolder); end

saveTabWithHeader(fullfile(outFolder, [base '-summary-array.txt']), SUMMARY_ARRAY, headers.summary);
%saveTabWithHeader(fullfile(outFolder, [base '-dADL.txt']),          dADL,          headers.dADL);
saveTabWithHeader(fullfile(outFolder, [base '-O2_CO2_N2_PP.txt']),  O2_CO2_N2_PP,  headers.O2_CO2_N2_PP);

if ~isempty(QTOTARRAY)
    saveTabWithHeader(fullfile(outFolder, [base '-QTOTARRAY.txt']), QTOTARRAY, headers.QTOTARRAY);
end
if ~isempty(STORES)
    saveTabWithHeader(fullfile(outFolder, [base '-STORES.txt']), STORES, headers.STORES);
end


