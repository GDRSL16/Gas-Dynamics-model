% GAS DYNAMICS MODEL - INITIAL PARAMETERS AND GAS STORES
% This function initializes global model parameters and compartment states.
% IMPORTANT: Calculations are intentionally retained in their original order.
% Sections group parameter types without altering numerical equations.
% Units are noted where established; legacy assumptions remain unchanged.
% Ventilation fractions are added ONLY in the separate flexible version.


%need to check if vo2 for each tissue is somewhat similar to blood flow at the surface
%check blood arrays and PO2, PCO2, , Co2 and Cco2
%line 145, muscle o2 from bound mb
%Saturation calculations need to return sat at body temp 37C
%iffy if lung PN2, PO2 and PCO2 should be computed with FN2=0.79, FO2=0.21
%or mixed gas volume maybe an assumption of perfect exchange is warranted

%This is variable file for "penguin_tissue_kinetics"
function GET_VARIABLES_ZIP_NEW(op)
format long e %to increase precision and reduce round off error
global VTIS R SN2_BLOOD SO2_BLOOD SCO2_BLOOD SN2_FAT SO2_FAT SCO2_FAT SCO2_BRAIN M_B V_LUNG V_BLOOD M_HEART M_MUSCLE M_BRAIN M_BLOOD M_FAT 
global V_MUSCLE V_HEART V_FAT V_BRAIN  T_S_O2_BLOOD T_S_CO2_BLOOD T_S_N2_BLOOD T_S_O2_FAT 
global T_S_CO2_FAT T_S_N2_FAT Q_TOT Q_HEART Q_FAT Q_MUSCLE Q_BRAIN VO2_TOT VO2_FAT VO2_MUSCLE VO2_BRAIN VO2_HEART n_N2_LUNG n_O2_LUNG n_CO2_LUNG
global n_N2_HEART n_O2_HEART n_CO2_HEART n_N2_FAT n_O2_FAT n_CO2_FAT n_N2_MUSCLE n_O2_MUSCLE n_CO2_MUSCLE n_N2_BRAIN n_O2_BRAIN n_CO2_BRAIN P50_O2 BETA_0
global BOHR HALDANE STANDARD_BICARBONATE O2_CAPACITY_HB HB_O2 HB  HCT MCHC deltaT  RQ VCO2_FAT VCO2_MUSCLE VCO2_BRAIN VCO2_HEART VCO2_TOT V_BLOOD_ART V_BLOOD_VEN TRANSIT_ART
global TRANSIT_VEN BLOOD_PARTITIONS_ART BLOOD_PARTITIONS_VEN B_VOL_PACKAGE_VEN ART_BLOOD_ARRAY VEN_BLOOD_ARRAY GAS_CONSTANT P_AMB TEMP_ARRAY
global FN2 FO2 FCO2 MB_O2 P50_MB BETA_0_MB B_VOL_PACKAGE_ART ART_VEN_PN2 Q_TOT_INIT Q_HEART_INIT Q_FAT_INIT 
global Q_MUSCLE_INIT Q_BRAIN_INIT BLOOD_PARTITIONS_ART_INIT BLOOD_PARTITIONS_VEN_INIT O2_CAPACITY_MB  STPD_TO_BT PN2_alv_init PO2_alv_init PCO2_alv_init
global nO2DOT_HEART nO2DOT_MUSCLE nO2DOT_BRAIN nO2DOT_FAT nCO2DOT_HEART nCO2DOT_MUSCLE nCO2DOT_BRAIN nCO2DOT_FAT PN2_ven_init PO2_ven_init PCO2_ven_init P_H2O T_TIS
global ALV_SURFACE_VALUE ART_VEN_PO2 ART_VEN_PCO2 ART_VEN_O2_STORE V_LUNG
global  Q_AVSHUNT  Q_AVSHUNT_INIT LUNG_VOL AL_A0 AL_A1 AL_B0 AL_B1 DUMMY ACTUAL_MUSCLE_VOLUME
global EXHALED_FRACTION INHALED_FRACTION
global nCO2DOT_HEART_ORIGINAL nCO2DOT_MUSCLE_ORIGINAL nCO2DOT_BRAIN_ORIGINAL nCO2DOT_FAT_ORIGINAL
global nO2DOT_HEART_ORIGINAL nO2DOT_MUSCLE_ORIGINAL nO2DOT_BRAIN_ORIGINAL nO2DOT_FAT_ORIGINAL QTOTARRAY

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%START Initilization of GLOBAL VARIABLES%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% MODEL TIME STEP, TEMPERATURE AND GAS CONSTANTS
% FINITE VENTILATION: parameters used only when BREATH_FLAG(i)==1.
% EXHALED_FRACTION: fraction of V_old - VTinit removed (0=none; 1=to VTinit).
% INHALED_FRACTION: fraction of available capacity refilled at ambient dry
% pressure (0=none; 1=to VLmax). Values can later vary per breath.
% Defaults reproduce the current full-exhalation/full-inspiration experiment.
EXHALED_FRACTION=1.0;%Can only be between 1 and 0;
INHALED_FRACTION=1.0;

deltaT=1;%the time step of the data and to be used in calculations in sec
%%%%%%%%%%%%%%%%%%%Fractional concentrations of air%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%Physcial variables %%%%%%%%%%%%%%
T_TIS=37+273; %body temperature in K
STPD_TO_BT=(T_TIS/273);%CONVERSION FROM STPD to body temperature, used in Cco2 and Co2 functions to get volume at body temperature as Al's functions give them at STPD
R= 0.08206;%atm x l/(mol x K) 

%% GAS SOLUBILITIES AND TEMPERATURE COEFFICIENTS
SN2_BLOOD=0.0144; %tissue/gas partition coefficient, ml gas @37C/ml liquid,In Weahtersby et al. Undersea Biomed Res 1980, plasma, water and blood are the same 
SO2_BLOOD=0.0261;%In Weahtersby et al. Undersea Biomed Res 1980, plasma, water and blood are the same
SCO2_BLOOD=0.63;%For water, In Weahtersby et al. Undersea Biomed Res 1980
SN2_FAT=0.072; %the range is between 0.052-0.076 and I choose a value 5 times higher than blood 
SO2_FAT=0.133;% In Weahtersby et al. Undersea Biomed Res 1980, RBC ghost and olive oil, i.e. fat has a much higher O2 solubility 
SCO2_FAT=1.36;% In Weahtersby et al. Undersea Biomed Res 1980 for oil, average of 1.28 and 1.40
SCO2_BRAIN=0.56;% In Weahtersby et al. Undersea Biomed Res 1980
T_S_O2_BLOOD=-1.3/100;%percent change SO2_BLOOD with each degree centigrade, percent cast into fraction
T_S_CO2_BLOOD=-1.97/100;
T_S_N2_BLOOD=-0.8/100;
T_S_O2_FAT=-0.2/100;
T_S_CO2_FAT=-1.1/100; 
T_S_N2_FAT=-0.4/100;

%% INSPIRED AIR AND INITIAL ALVEOLAR / VENOUS GAS TENSIONS
FN2=0.79;%assuming fractional concentration of air with 21% O2, 0.05% CO2 and 79% N2, 
FCO2=0.005;
FO2=0.21-FCO2;
GAS_CONSTANT=R*T_TIS;
%%%%%%%%%%%%Initial alveolar,arterial and venous fractional concentrations and partial
%%%%%%%%%%%%pressures and tensions
Fa_N2=P_AMB(1)*FN2;%P_AMB(1) is water vapour corrected value for surface pressure
Fa_CO2=41.6/760;%value in Stephenson table 2 as a steady state value
Fa_O2=1-Fa_N2-Fa_CO2-P_H2O;%108.9 mmHg from Stephesnon JEB 2005 table 2 slightly different to make water vapour and N2 equal 1

PN2_alv_init=Fa_N2;%as surface pressure is 1 ATA, partial pressure and fraction is interchangeable.
PO2_alv_init=Fa_O2;%as surface pressure is 1 ATA, partial pressure and fraction is interchangeable.
PCO2_alv_init=Fa_CO2;%PCO2in arterial blood of gentoo and chinstrap penguin, from Powell and Hempleman AmJP 248:748-752, 1985


%%%%%%%%%%%%%%%%%mixed venous values given by Stephenson JEB
%%%%%%%%%%%%%%%%%2005%%%%%%%%%%%% but these do not add up to 1 with PN2 and
%%%%%%%%%%%%%%%%%PH2O being constant
PN2_ven_init=PN2_alv_init;%assuming that tissues are at equilibrium
PO2_ven_init=55.9/760;%from stephenson 2005 jeb, table 2
PCO2_ven_init=48.9/760;% from stephenson jeb 2005, table 2 

%%%%%%%%%%%%%%body and organ masses and volumes%%%%%%%%%%%%%

%% BODY MASS, TISSUE MASSES AND COMPARTMENT VOLUMES
M_B=op%send the animal specific body mass to function 200;%animals body mass, from andrews-jeb-200-2083-2095-1997, Seal: GJ325, Mb=177kg, Mb=104kg Kooyman et al, 1972 AmJP paper
V_LUNG=25*M_B/1000%25 ml/kg from Zimmer et al., 2007, Miller et al., 2016
%V_LUNG= 0.135*M_B^0.92;%Max volume defined as 50.4 ml/kg for elephant seal in Kooyman et al. AmJP 1972 assumed to be close to max insp volume, 20.4 ml/kg was seen during chamber dives 
%ALV_SURFACE_VALUE(row,column) where row 1=N2, 2=O2, 3=CO2 and column %1=Pressure, 2=moles, a new varaible that has the alveolar gas tensions for
%lung while at the surface
ALV_SURFACE_VALUE(1:3,1:2)=-9;%initialzing array
ALV_SURFACE_VALUE(1,1)=PN2_alv_init;%this should always be the same and not change with hyperventilation
ALV_SURFACE_VALUE(2,1)=PO2_alv_init;%increase above PO2_alv_init during hypervent
ALV_SURFACE_VALUE(3,1)=PCO2_alv_init;%decrease below PCO2_alv_init during hypervent
ALV_SURFACE_VALUE(1,2)=(ALV_SURFACE_VALUE(1,1)*V_LUNG)/GAS_CONSTANT;%this should always be the same and not change with hyperventilation
ALV_SURFACE_VALUE(2,2)=(ALV_SURFACE_VALUE(2,1)*V_LUNG)/GAS_CONSTANT;%increase above PO2_alv_init during hypervent
ALV_SURFACE_VALUE(3,2)=(ALV_SURFACE_VALUE(3,1)*V_LUNG)/GAS_CONSTANT;%decrease below PCO2_alv_init during hypervent

V_BLOOD= 0.20*M_B;%specified as approx. 15% of Mb for 1.05*15%  Pabst et al., 2016 and Velten et al. 2013, but Wedell seal and sperm whale about 20% so will assume this instead
V_BLOOD_ART=V_BLOOD*1/3;%arterial blood volume is assumed to be 1/3 of total
V_BLOOD_VEN=V_BLOOD*2/3;%venous blood voluem is the rest
M_MUSCLE=M_B*0.57;%, muscle-40, skin-4.6, spleen-0.07, testis-1.33, lung-4, alimentary-2connective tissue and alimentary canal (lung table 2 in Davis) and all other tissues. Consequently this is not exactly muscle and for estimating O2 stores see below for adjustment of tissue volume
M_HEART=M_B*0.05;% %Pabast et al 2016 5% viscera or tissues with high MR also able to lower MR during diving by reduced cardiac work, 50%, and reduction in liver and kidney function
M_BRAIN=0.002*M_B;%Pabast et al 2016 0.2%
M_BLOOD=1.05*V_BLOOD;%for blood 7.11.05*V_BLOOD;%M_B;%450 kg wedell seal, table 1 Davis and kanatous JEB 1999specific gravity for a bunch of mammals is approx. 1.05 refs:Berne, Robert M. Levy Matthew N. Cardiovascular Physiology. Seventh Edition. Mosby-Year Book, Inc. 1997. St. Louis, Missouri.;Bone, Jesse F. Animal Anatomy and Physiology. Second edition. Reston Publishing Company, Inc. 1982. Reston, Virginia.;Schalm, Oscar William, Jain, N.C., Carroll, E.J. et al. Veterinary Hematology. 3’rd edition.Lea & Febiger inc. 1975. Philadelphia, PA. 
M_FAT=M_B-M_HEART-M_MUSCLE-M_BRAIN-M_BLOOD;%changed Feb 24 2007 to match to 100% of total mass, fat mass 55.31 kg originally 36% of total 
ACTUAL_MUSCLE_MASS= 0.49*M_B;%used to estimate O2 stores as muscle compartment is more than just muscle, also used in update_tissue_O2
ACTUAL_MUSCLE_VOLUME=ACTUAL_MUSCLE_MASS/1.06;%only used once to get total O2 store as muscle compartment is 57% but only 49% is muscle

V_HEART=M_HEART/1.06;%volume of tissue, specific gravity of muscle 1.06 kg/L Kayar and Parker J. Therm Biol 1997
V_MUSCLE= M_MUSCLE/1.06;%specific gravity of muscle 1.06 kg/L Kayar and Parker J. Therm Biol 1997
V_BRAIN=M_BRAIN/0.91;%assuming to be have a specific gravity of fat 0.918 kg/L
V_FAT=M_FAT/(0.5*0.91+0.5*1.06);%specific gravity of fat 0.918 kg/L, FAT tissue is assumed to have a density consistent with 50% fat or 50% muscle and tissue with more water
VTIS= V_MUSCLE+V_HEART+V_FAT+V_BRAIN;%Total tissue volume
%%%%%%%%%%%%%%VO2s, ml/min but converted to liter per min for each organ computed from Table 1 in Davis, assuming this is in STPD%%%%%%%%%%%%%%%%
%scaling=(M_B^-0.25/450^-0.25);
%VO2_HEART=(59.2*scaling*(1.9/20.4)*M_HEART+27.7*scaling*(8.8/20.4)*M_HEART+38.4*scaling*(1.6/20.4)*M_HEART+10.1*scaling*(8.1/20.4)*M_HEART)/1000%in ml/min but converted to liter per min;%in ml/mi%an avergae of the proportions of heart, liver and kidney and alimentary canal organ sVO2s
%VO2_MUSCLE=(1.4*scaling*(157.5/211.05)*M_MUSCLE+1.6*scaling*(25.7/211.05)*M_MUSCLE+1.4*scaling*(2.3/211.05)*M_MUSCLE+4.7*scaling*(5.9/211.05)*M_MUSCLE+2.4*scaling*(0.1/211.05)*M_MUSCLE+4.5*scaling*(5.1/211.05)*M_MUSCLE)/1000%an avergae of the proportions of muscle, skin, other, spleen, testis, lung organ sVO2s
%VO2_BRAIN=(22.1*scaling*M_BRAIN)/1000
%VO2_FAT= (0.5*scaling*M_FAT)/1000%fat+bone, mass specific VO2 estimated from assuming an allometric relationship that each organ scales by Mb^0.75 with human and weddell seal VO2penguin-organ=VO2seal-organ*(Mbpenguin^-0.25/Mbseal^-0.25), Davis and Kanatous JEB 1999 
%VO2_TOT=VO2_FAT+VO2_MUSCLE+VO2_BRAIN+VO2_HEART% l O2 min-1

%% METABOLIC RATE PARAMETERS AND TISSUE O2 CONSUMPTION
muscle_fiber_scaling=0.5; %change in muscle metabolism as glycolytic fibers are larger with less mitochondria, estimtes from Velten et al. 2013
neuronal_density_scaling=0.5;%Ridgway et al., 2019 lower neuronal density in beaked whales so assume brain 50% lower metabolic rate, also brain only 0.1% of Mb but will keep 0.2% as spinal cord then also included
scaling=(M_B^-0.25/450^-0.25);
VO2_HEART=(59.2*scaling*0.5/3*M_HEART+27.7*scaling*2/3.*M_HEART+38.4*scaling*0.5/3.*M_HEART)/1000;%in ml/min but converted to liter per min;%in ml/min for a 450kg weddells seal anmd then converted to Mb%an avergae of the proportions of heart-59.2=>converted to 2000kg 40.7, liver-27.7=>19.1 when converted to 2000kg and kidney-38.4=>26.4 when converted to 2000kg  sVO2s
VO2_MUSCLE=(1.4*scaling*(50/57)*M_MUSCLE*muscle_fiber_scaling+1.4*scaling*(2.45/57)*M_MUSCLE+4.7*scaling*(0.05/57)*M_MUSCLE+2.4*scaling*(1/57)*M_MUSCLE+4.5*scaling*(2/57)*M_MUSCLE+10.1*scaling*1.5/57*M_MUSCLE)/1000;%an avergae of the proportions of muscle-1.4l O2 min-1 kg-1 THJIS IS FROM HUMAN of this due to musckle fiber, other/skin-1.4, spleen-4.7, testis-2.4, lung organ-4.5 sVO2, and alimentary canal-10.1 organ-10.1-alimentary moved for dllphin 2017 paper
VO2_BRAIN=(22.1*scaling*neuronal_density_scaling*M_BRAIN)/1000;
VO2_FAT= (0.5*scaling*M_FAT)/1000;%bone, added here and has about the same mass specific vo2mass specific VO2 estimated from assuming an allometric relationship that each organ scales by Mb^0.75 with human and weddell seal VO2penguin-organ=VO2seal-organ*(Mbpenguin^-0.25/Mbseal^-0.25), Davis and Kanatous JEB 1999 
VO2_TOT=VO2_FAT+VO2_MUSCLE+VO2_BRAIN+VO2_HEART;% l O2 min-1

%%VO2_MUSCLE/VO2_TOT; %to see the proportion of muscle metabilism to total
%VO2_TOT/op*1000%checks mass specific and DQ animals are 1.9-4.1ml/kg from
%Austin
%%%%%%%%%%%%%%VCO2s%%%%%%%%%%%%%%%%

%% CO2 PRODUCTION AND RESPIRATORY QUOTIENT
RQ=1;%0.7; %The respiratory quotient, assumed a constant
VCO2_HEART=VO2_HEART*RQ;
VCO2_MUSCLE=VO2_MUSCLE*RQ;
VCO2_BRAIN=VO2_BRAIN*RQ;
VCO2_FAT=VO2_FAT*RQ;
VCO2_TOT=VCO2_FAT+VCO2_MUSCLE+VCO2_BRAIN+VCO2_HEART;% ml CO2 min-1
%%%%%%%%%%%converting metabolic rate to moles O2 consumed per min

%% O2 CONSUMPTION IN MOLES AND BASELINE COPIES
nO2DOT_HEART=(1*(VO2_HEART))./(R*273);%metabolic rate in moles per min per tissue, ambient pressure is 1 ATA, and temperature 273 K
nO2DOT_MUSCLE=(1*(VO2_MUSCLE))./(R*273);
nO2DOT_BRAIN=(1*VO2_BRAIN)./(R*273);
nO2DOT_FAT=(1*VO2_FAT)./(R*273);
%%%%%SEPT 13 20201%%%% TO BE ABLE TO UPDATE METABOLIC RATE BASED ON
%%%%%ACTIVITY
nO2DOT_HEART_ORIGINAL=nO2DOT_HEART;
nO2DOT_MUSCLE_ORIGINAL=nO2DOT_MUSCLE;
nO2DOT_BRAIN_ORIGINAL=nO2DOT_BRAIN;
nO2DOT_FAT_ORIGINAL=nO2DOT_FAT;
%%%%%%%%%%%converting CO2 prodcution rate to moles CO2 produced per min
nCO2DOT_HEART=nO2DOT_HEART*RQ;
nCO2DOT_MUSCLE=nO2DOT_MUSCLE*RQ;
nCO2DOT_BRAIN=nO2DOT_BRAIN*RQ;
nCO2DOT_FAT=nO2DOT_FAT*RQ;
%%%%%SEPT 13 20201%%%% TO BE ABLE TO UPDATE VCO2 BASED ON
%%%%%ACTIVITY
nCO2DOT_HEART_ORIGINAL=nCO2DOT_HEART;
nCO2DOT_MUSCLE_ORIGINAL=nCO2DOT_MUSCLE;
nCO2DOT_BRAIN_ORIGINAL=nCO2DOT_BRAIN;
nCO2DOT_FAT_ORIGINAL=nCO2DOT_FAT;
%%%%%%%%%%blood flows in l/sec%%%%%%%%%%%%
%Q_TOT_MULTIPLIER=10;%A MULTIPLIER TO BE USED AT SURFACE
%Q_TOT=0.52*(M_B^-0.25/175^-0.25)*M_B/1000*Q_TOT_MULTIPLIER %FROM MIEDLER ET AL units in liter per second
% An increase of 7 above resting %resting blood flow in l s-1 for animals at rest from Miedler et al, 0.52 ml kg-1 sec-1 (from a 175 kg animal) 
%also try from Fahlman et al., 2020 paper Dolphin: 0.78 ml kg-1 sec-1 (Mb=169); beluga 1.94 ml kg-1 sec-1(Mb=160) ; false killer whale 0.64 ml kg-1 sec-1(Mb=520) 
%%%%%%%Dolphin Fahlman et al., JEB 2020, Mb=169kg CO=0.78 ml kg-1 sec-1, 
%Q_TOT_MULTIPLIER=??;
%Q_TOT=0.78*(M_B^-0.25/169^-0.25)*M_B/1000*Q_TOT_MULTIPLIER;
%%%%%%%false killer whale Fahlman et al., JEB 2020,  Mb=520kg CO0.64 ml kg-1 sec-1
%Q_TOT_MULTIPLIER=??;
%Q_TOT=0.64*(M_B^-0.25/520^-0.25)*M_B/1000*Q_TOT_MULTIPLIER;
%%%%%%%beluga Fahlman et al., JEB 2020, Mb=160kg CO 1.94 ml kg-1 sec-1

%% CARDIAC OUTPUT AND PERFUSION PARAMETERS
Q_TOT_MULTIPLIER=5;%original 2026 model
%Q_TOT_MULTIPLIER=2.5;%Models used in 2026 study 10x and 2.5 x
Q_TOT=1.94*(M_B^-0.25/160^-0.25)*M_B/1000*Q_TOT_MULTIPLIER%gives 
QTOTARRAY(1,1)=Q_TOT; %an array that gets updated in GET_GAS_FLUX yo save cardiac output for each change, not necessary for program to run and just used to provide the data and check values
%QTOTARRAY as size the same number of rows as dives and 5 columns 1=total,%2=heart, 3=muscle, 4=brain, 5=fat

%From Lenfant et al AmJP 216 6:1598-1600 1969, Adelie and emperor penguin

%% HEMOGLOBIN / MYOGLOBIN GAS BINDING
P50_O2=31/760;%reported as 31 by Meir et al. can be done by dividing P50(mmHg)/760, function is saturation=(PO2^BETA_0)/(PO2^BETA_0+P50^BETA_0)
BETA_0=2.39; %reported in mmHg as 3.0 and 2.9 so 2.95 used here, for Adelie, this is the Hill coefficient and remains the same for mmHg or ATA 
P50_MB=2.5/760;%2.5 mmHg; valaue between norhtern bottlenose and sperm whale in Helbo and Faro 2015
BETA_0_MB=1.01;%1.01 Tamburini et al Comp Biochm and Physiol 122 235-240, 1999 values for P50 and Hill(n) for emeperor penguin muslce, , this is the Hill coefficient and remains the same for mmHg or ATA 
%BOHR=-0.5;%1.95;%deltalog P50/delta pH this is still for mmHg, will use Al's function instead
HALDANE=2.05*10^-3; %haldane effect in plasme mM the additional bicarbonate in plasma when the blood is reduced
STANDARD_BICARBONATE=29.2*10^-3;% 29.2 mM for Adelie

%%%%%%%%%%STILL RUNS OUT OF O2 FOR BERMUDA DOLPHINS
%%%%%HB=0.26; %Stephenson JEB 2005 kg Hb/L blood
%MB=0.054;% in kg Mb/kg muscle tissue, in Ponganis et al, 1993 PBZ 66:732-749
%HCT=47;%Lenfant for Emperor in percent

%%%%WITH THESE O2 is running out%%%% AND PROGRAM CEASHES FOR BERMUDA
%%%%ANIMALS
HB=0.229; %Velten et al., 2013
MB=0.073;% in kg Mb/kg muscle tissue, Velten et al., 2013
HCT=57;%Hct-44-sarastoa, 57%-Bermuda, Ridgway 1966 dolphin

MCHC=35.9;%Lenfant for Emperor in percent
HB_O2=1.34; %ml O2 per gram Hb Assuming that gas volume is STPD Kooyman Diverse divers, 1989 and Environmental physiol of animals, Willmer, Stone and Johnsotn 2000
MB_O2= 1.34;%ml O2 per gram Mb Assuming that gas volume is STPD Kooyman Divrse divers, 1989
O2_CAPACITY_HB=HB_O2*HB; %the Co2 approx 0.23 ml O2 STPD/ml blood, correspond approximately to value in Butler NIPS 2000
O2_CAPACITY_MB=MB_O2*MB*1.05;%the Co2 conc in muscle approx L O2 STPD/kg muslce tissue *converting from mass to volume
%%%%%%%%%%%%%%%%%%%%%%%paramters for blood PO2 and PCO2%%%%%%%%%%from Al from Seal blood Ersland and Clausen Resp Physiol 1969

%% BLOOD O2 / CO2 CONTENT PARAMETERS
AL_A0=1.7585;%converted to ATA and 0.0559 for mmHg
AL_B0=0.5199;%converted to ATA and 0.0301 for mmHg
AL_A1=1.8714;%converted to ATA and 0.5199 for mmHg
AL_B1=0.6226;%converted to ATA and 0.6226 for mmHg
BOHR=0.304;%the same for ATA and mmHg
%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%Molar values in each compartment%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%Central circulation-ONLY DISSOLVED%%%%%%%%%%%%%%%%%%%%%

%% INITIAL CENTRAL-CIRCULATION GAS STORES
n_N2_HEART=(PN2_ven_init*V_HEART*SN2_BLOOD)./(GAS_CONSTANT);%n= (Pamb x FN2 x V_HEART x SN2_BLOOD)/(R x T)
n_O2_HEART =(PO2_ven_init*V_HEART*SO2_BLOOD)./GAS_CONSTANT;%Of the total mass of the central circulation compartment heart is very small. There, the assumption is that any O2 tied to myoglobin is negligible
n_CO2_HEART =(PCO2_ven_init*V_HEART*SCO2_BLOOD)./GAS_CONSTANT;%Tissue tensions needs to be taken from animal studies

%%%%%%%%%%%%%%%%%%%%%Muscle-MYOGLOBIN BOUND O2---STORES%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% INITIAL MUSCLE GAS STORES
n_N2_MUSCLE=(PN2_ven_init*V_MUSCLE*SN2_BLOOD)./(GAS_CONSTANT);%n= (Pamb x FN2 x V_MUSCLE x SN2_BLOOD)/(R x T), dissolved + Mb bound
%muscle_S=Muscle_MbO2_sat(PO2_ven_init);%assumes that this returns saturation at 37C

n_O2_MUSCLE=muscle_Co2(PO2_ven_init)*ACTUAL_MUSCLE_VOLUME./(GAS_CONSTANT);%dissolved and Mb bound assuming dissolved muscle O2 is equal to venous, i.e. dynamic equilibrium, and muscle Mb sSat on of venous blood  

n_CO2_MUSCLE=(PCO2_ven_init*V_MUSCLE*SCO2_BLOOD)./(GAS_CONSTANT);%difficult to know what this value is 

%%%%%%%%%%%%%%%%%%%%%%%%%%Brain%%%%%%%%%%%%%%%%%%%%%%%%

%% INITIAL BRAIN GAS STORES
n_N2_BRAIN=(PN2_ven_init*V_BRAIN*SN2_FAT)/(GAS_CONSTANT);%n= (Pamb x FN2 x V_BRAIN x SN2_FAT)/(R x T) 
n_O2_BRAIN= (PO2_ven_init*V_BRAIN*SO2_FAT)/(GAS_CONSTANT); 
n_CO2_BRAIN=(PCO2_ven_init*V_BRAIN*SCO2_BRAIN)/(GAS_CONSTANT);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%FAT%%%%%%%%%%%%%%%%%%%%%%%%%
disp('line 217 in GET_VARIABLES_ZIP_NEW has x 2 initial fat N2 saturation to reduce time to equilibrium')

%% INITIAL FAT GAS STORES
n_N2_FAT=(PN2_ven_init*V_FAT*SN2_FAT)/(GAS_CONSTANT)*2;%Feb 16-2026 initialize to 2 times %n= (Pamb x FN2 x V_FAT x (1/2*SN2_FAT+1/2*SN2_BLOOD))/(R x T), the fat tissue is assumed to have a solubility equal to 4/5 fat and the rest as blood
n_O2_FAT=(PO2_ven_init*V_FAT*SO2_FAT)/(GAS_CONSTANT); 
n_CO2_FAT=(PCO2_ven_init*V_FAT*SCO2_FAT)/(GAS_CONSTANT);
%%%%%%%%%%%%%%%%%%%%%%%%%Lung-Gas phase%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

%% INITIAL LUNG GAS STORES
n_N2_LUNG=(PN2_alv_init*V_LUNG)/GAS_CONSTANT;%Determined from end-tidal PO2 (max 120 mmHg), PCO2's (min 30 mmHg) reported in Stephenson JEB 2005, 
n_O2_LUNG=(PO2_alv_init*V_LUNG)/GAS_CONSTANT;%The assumption is that ambient surface pressure (1 ATA)
n_CO2_LUNG=(PCO2_alv_init*V_LUNG)/GAS_CONSTANT;

%%%%%%%%%%%%%%%%%%%%%%Lung-tissue pase%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%Time variables%%%%%%%%%%%%%

%% BLOOD TRANSIT TIMES AND PACKAGE SIZES
TRANSIT_ART=(V_BLOOD_ART/Q_TOT);%transit time (s) of arterial blood equal to arterial blood volume/Q_tot 
TRANSIT_VEN=(V_BLOOD_VEN/Q_TOT);%transit time (s) of venous blood equal to venous blood volume/Q_tot
%The "round" below makes sure that the packages below always become whole numbers
BLOOD_PARTITIONS_ART=round(TRANSIT_ART/deltaT);%the number of "small" packages of blood from lung to tissue
BLOOD_PARTITIONS_ART_INIT=round(TRANSIT_ART/deltaT);%the number of "small" packages of blood from lung to tissue
BLOOD_PARTITIONS_VEN_INIT=BLOOD_PARTITIONS_ART*2;%cheating so that things will be easierround(TRANSIT_VEN/deltaT);%the number of "small" packages of blood from tissue to lung
BLOOD_PARTITIONS_VEN=BLOOD_PARTITIONS_ART*2;%cheating so that things will be easierround(TRANSIT_VEN/deltaT);%the number of "small" packages of blood from tissue to lung
B_VOL_PACKAGE_ART=V_BLOOD_ART/BLOOD_PARTITIONS_ART;%The volume of blood (L) in each little package, arterial blood volume/number of packages
B_VOL_PACKAGE_VEN=B_VOL_PACKAGE_ART;%forcing blood volumes in each package to be the same

%%%%%%%%%%%%%%%%%%MAKE SURE IT IS MODIFIED AS THIS IS REST
disp('MAKE SURE THAT CO IS ADJUSTED AS 95 ML/SEC IS REST, DISPLAY IN GET_VARIABLE_DOLPHIN ROW 209')
Q_TOT=(B_VOL_PACKAGE_VEN)/deltaT;%total blood flow gets modified to fit the assumption of a certain number of packages, l/s,


%% TISSUE BLOOD FLOW ALLOCATION
Q_HEART=0.25*Q_TOT; %31%fraction of blood flow to heart+kidney+liver, relative to VO2 to each organ, flow from heart kidney and splanchnic
Q_FAT=0.03*Q_TOT;% < 1% to adipose tissueQ_TOT;
Q_MUSCLE=0.65*Q_TOT;%Q_TOT 67% 18% to muscle and the rest fat skin and bone, alimentary etc
Q_BRAIN=0.07*Q_TOT;%%brain 1.3%
Q_AVSHUNT=0.0*Q_TOT;%AV shunt blood flow, let's start with 0
%Q_HEART=0.31*Q_TOT; %31%fraction of blood flow to heart+kidney+splanchnic (liver and alimentary), relative to VO2 to each organ, flow from heart kidney and splanchnic
%Q_FAT=0.015*Q_TOT;% < 1% to adipose tissueQ_TOT;
%Q_MUSCLE=0.67*Q_TOT;%Q_TOT 67% 18% to muscle and the rest fat skin and bone etc
%Q_BRAIN=0.015*Q_TOT;%%brain 1.3%
%Q_AVSHUNT=0.0*Q_TOT;%AV shunt blood flow, let's start with 0

Q_TOT_INIT=Q_TOT;%The initial values that can be found again after dive bradycardia adjustment
Q_HEART_INIT=Q_HEART;
Q_FAT_INIT=Q_FAT;%
Q_MUSCLE_INIT=Q_MUSCLE;% 
Q_BRAIN_INIT=Q_BRAIN;%
Q_AVSHUNT_INIT=Q_AVSHUNT;
QTOTARRAY(1,2)=Q_HEART_INIT;%see QTOTARRAY above where Q_tot is defined and initiliazed 
QTOTARRAY(1,3)=Q_MUSCLE_INIT;
QTOTARRAY(1,4)=Q_BRAIN_INIT;
QTOTARRAY(1,5)=Q_FAT_INIT;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Circulation arrays%%%%%%%%%%%%%%%%%%%%%
%%ART_N2_BLOOD_ARRAY and ART_O2_BLOOD_ARRAY and ART_CO2_BLOOD_ARRAY is a single (r x v x c) array called ART_BLOOD_ARRAY where 
%%r is the number of rows=BLOOD_PARTITIONS_ART, c=is 3 columns for the 3 gases N2, O2, CO2, and v=are 3 changing variables, Partial pressure, mol of gas c, pH

%% ARTERIAL / VENOUS BLOOD PACKAGE INITIALIZATION
ART_BLOOD_ARRAY=zeros(BLOOD_PARTITIONS_ART,3,3);
%%VEN_N2_BLOOD_ARRAY and VEN_O2_BLOOD_ARRAY VEN_CO2_BLOOD_ARRAY is a single (r x v x c) array called VEN_BLOOD_ARRAY where 
%%r is the number of rows=BLOOD_PARITIONS_VEN, c=is 3 columns for the 3 gases, and v=are 3 changing variables, Partial pressure and mol of gas c, pH
VEN_BLOOD_ARRAY=zeros(BLOOD_PARTITIONS_VEN,3,3);
%initialization of blood arrays assuming that everything is at steady state
%ART_BLOOD_ARRAY(_,_,1)=N2, (_,_,2)=O2,(_,_,1)=CO2
ART_BLOOD_ARRAY(:,1,1)=PN2_alv_init;%PN2 assumed saturated at 1 atm 
ART_BLOOD_ARRAY(:,1,2)=PO2_alv_init;
ART_BLOOD_ARRAY(:,1,3)=PCO2_alv_init;

pHa=6.1+log(STANDARD_BICARBONATE/(0.03*(ART_BLOOD_ARRAY(1,1,3)*760)));%pK'+log([HCO3]/(CO2_solubility*PCO2), where pK'=6.1, CO2_solubility=0.03mM/[L*mmHg] and PCO2 is in mmHg
ART_BLOOD_ARRAY(:,2,1)=(ART_BLOOD_ARRAY(1,1,1).*B_VOL_PACKAGE_ART*SN2_BLOOD)/(GAS_CONSTANT);%mol N2 in each arterial blood package

%s=blood_O2_sat(ART_BLOOD_ARRAY(1,1,2),ART_BLOOD_ARRAY(1,1,3));%arterial O2 saturation
ART_BLOOD_ARRAY(:,2,2)=(B_VOL_PACKAGE_ART*blood_Co2(ART_BLOOD_ARRAY(:,1,3),ART_BLOOD_ARRAY(1,1,2)))/(GAS_CONSTANT);%dissolved + bound to Hb
ART_BLOOD_ARRAY(:,2,3)=(blood_Cco2(ART_BLOOD_ARRAY(1,1,2),ART_BLOOD_ARRAY(1,1,3))*B_VOL_PACKAGE_ART)/GAS_CONSTANT; %moles CO2 in arterial blood
ART_BLOOD_ARRAY(:,3,1)=pHa;%the pH is constant for all gases
ART_BLOOD_ARRAY(:,3,2)=pHa;
ART_BLOOD_ARRAY(:,3,3)=pHa;

%VEN_BLOOD_ARRAY(_,_,1)=N2, (_,_,2)=O2,(_,_,1)=CO2
VEN_BLOOD_ARRAY(:,1,1)=ART_BLOOD_ARRAY(1,1,1);%N2=arterial equal to venous at sat
VEN_BLOOD_ARRAY(:,1,2)=PO2_ven_init;
VEN_BLOOD_ARRAY(:,1,3)=PCO2_ven_init;
pHv=6.1+log((STANDARD_BICARBONATE+HALDANE)/(0.03*(VEN_BLOOD_ARRAY(1,1,3)*760)));%pK'+log([HCO3]/(CO2_solubility*PCO2), where pK'=6.1, CO2_solubility=0.03mM/[L*mmHg] and PCO2 is in mmHg
%s=blood_O2_sat(VEN_BLOOD_ARRAY(1,1,2),VEN_BLOOD_ARRAY(1,1,3));%arterial O2 saturation
VEN_BLOOD_ARRAY(:,2,1)=(VEN_BLOOD_ARRAY(1,1,1)*B_VOL_PACKAGE_VEN*SN2_BLOOD)/(GAS_CONSTANT);%mol N2, only dissolved
VEN_BLOOD_ARRAY(:,2,2)=(B_VOL_PACKAGE_ART*blood_Co2(VEN_BLOOD_ARRAY(1,1,3),VEN_BLOOD_ARRAY(1,1,2)))/(GAS_CONSTANT);%mole O2 in arterial blood
VEN_BLOOD_ARRAY(:,2,3)=(blood_Cco2(VEN_BLOOD_ARRAY(1,1,2),VEN_BLOOD_ARRAY(1,1,3))*B_VOL_PACKAGE_VEN)/GAS_CONSTANT; %moles CO2 in arterial blood
VEN_BLOOD_ARRAY(:,3,1)=pHv;%the venous pH
VEN_BLOOD_ARRAY(:,3,2)=pHv;
VEN_BLOOD_ARRAY(:,3,3)=pHv;


%% ARTERIAL AND MIXED VENOUS SUMMARY ARRAYS
ART_VEN_PN2(1,1)=ART_BLOOD_ARRAY(1,1,1);%These keep the "last" venous and arterial value, the one that gas just exchanged with tissue or lung 
ART_VEN_PN2(1,2)=VEN_BLOOD_ARRAY(1,1,1);
ART_VEN_PO2(1,1)=ART_BLOOD_ARRAY(1,1,2);%These keep the "last" venous and arterial value, the one that gas just exchanged with tissue or lung 
ART_VEN_PO2(1,2)=VEN_BLOOD_ARRAY(1,1,2);
ART_VEN_PCO2(1,1)=ART_BLOOD_ARRAY(1,1,3);%These keep the "last" venous and arterial value, the one that gas just exchanged with tissue or lung 
ART_VEN_PCO2(1,2)=VEN_BLOOD_ARRAY(1,1,3);
TEMP_ARRAY=[ART_BLOOD_ARRAY;VEN_BLOOD_ARRAY];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Circulation arrays%%%%%%%%%%%%%%%%%%%%%


%% LUNG MECHANICS INITIALIZATION
GET_VARIABLES_LUNG_COLL_ZIP(n_O2_LUNG,n_CO2_LUNG, n_N2_LUNG);
tissue_O2_store=(n_O2_HEART+n_O2_MUSCLE+n_O2_BRAIN+n_O2_FAT)*R*273;%L O2 STPD
lung_O2_store=n_O2_LUNG*R*273; %L O2 STPD;
%blood_O2_store=(sum(VEN_BLOOD_ARRAY(:,2,2))+sum(ART_BLOOD_ARRAY(:,2,2)))*R*273; 
ART_VEN_O2_STORE(1,1)=(sum(ART_BLOOD_ARRAY(:,2,2))); %sum all moles of arterial blood to get O2 store at each data point, in number of moles
ART_VEN_O2_STORE(1,2)=(sum(VEN_BLOOD_ARRAY(:,2,2))); %sum all moles of venous blood to get O2 store at each data point
ART_VEN_O2_STORE(1,3)=ART_VEN_O2_STORE(1,1)+ART_VEN_O2_STORE(1,2);%SUMMED O2 STORE in moles
blood_O2_store=(ART_VEN_O2_STORE(1,3))*R*273;% Blood O2 store in liter STPD
oxygen_stores=tissue_O2_store+lung_O2_store+blood_O2_store;
return
%Vtot=total tissue volume, R universal gas constant, 
%SN2_BLOOD SO2_BLOOD SCO2_BLOOD SN2_FAT SO2_FAT SCO2_FAT= solubilities for O2, CO2 and N2 in blood and fat, T_S_O2 T_S_CO2 T_S_N2=percent change in solubility per degree centigrade, REF Weathersby and Homer Undersea Biomed Res 1980, 7, 277-296
%
