% ========================================================================
% Documentation reviewed: 2026-10-18 | Batch 01
% Purpose: Coordinate stepwise gas exchange, circulation and dive-response calculations.
% Interface: dsum supplies dive summary/boundary information; state is communicated largely through globals.
% Review note: Physiological branches, call sequence and blood-package calculations are preserved.
% Scope: Documentation only; all pre-existing lines remain unchanged.
% ========================================================================

% ============================================================
% Documentation review: 2026-10-18 | Batch 01
% Scope: Review tracking header only; original code preserved.
% Numerical calculations, logic, and existing comments unchanged.
% ============================================================
%%%%%%%Possibly do, change dive intervals to 1050 for long and change HIF
%%%%%%%added to short dives
%SONAR FLAG is used to create a different type of heart rate response
%during sonar. It looks at the columns sonar which is 1 for no sonar and 0
%for sonar, it then uses a different dive response and it then matches the
%upcoming surface interval so if heart rate is reduced by 10, the surface
%value has to be increased by 10
%This is the function that leads the tension estimations
%splitting dive response into different dive durations, Aug 13, 2022
function GET_GAS_FLUX_1(dsum)
global N   CO2_ARRAY P_AMB  BLOOD_PARTITIONS_ART BLOOD_PARTITIONS_VEN ART_VEN_PN2%global variables initialized here
global TEMP_ARRAY  ART_VEN_nN2 GAS_CONSTANT  B_VOL_PACKAGE_VEN SN2_BLOOD P_AMB ADJ_BLOOD_VOL_LUNG_N2
global ART_VEN_nO2 ART_VEN_PO2 ART_VEN_PO2 ART_VEN_PCO2 DEBUG SONAR_FLAG  ART_VEN_nCO2 
global n_O2_LUNG n_CO2_LUNG n_N2_LUNG V_LUNG VLinit ART_VEN_O2_STORE
global VTinit VLinit0 VO2_TOT VO2_MUSCLE Q_TOT STORES ART_VEN_CO2_STORE 
%temporary array to hold the arterial and venous values.  
rt=GAS_CONSTANT;
ADJ_BLOOD_VOL_LUNG_N2=B_VOL_PACKAGE_VEN*SN2_BLOOD;
%n_MET_GAS_LUNG=O2_ARRAY(1,5,2)+CO2_ARRAY(1,5,2);%assumes that the number of moles in the lung is constant
o=-1;
DIVE_RESPONSE_FLAG=0; %checks that the dive response is only updated once 0=for previous surface, 1=already in dive response

Dive_no=1; %dive number counter, just to check that we have the same dive when checked against dsum
SI_no=1; %SI number counter, just to check that we have the same dive when checked against dsum
RMR=VO2_TOT;%RMR is MR for the entire animal and this cannot be used to get the multiplier as it will cause it to ne really small
RMMR=VO2_MUSCLE;%RMMR is Restimg Muscle Metabolic Rate and this should be used to create the multiplier VO2_MUSCLE is from Get_variables
adjust_muscle=1;
pect=37;
max_iterations=13200;%Max for now-October 17, 2026 13200;
for i=2:max_iterations
%for i=2:N %for each data point
    Pamb=P_AMB(i-1:i); %ambient pressure at time t-1 and t
 
    
   
    %DIVE_RESPONSE_FLAG allows switching on dive response during deeper
    %dives that a set depth, not surface to allow higher cardiac output at
    %the surface

   if dsum(Dive_no,8)==i %%%start of dive using the dive summary array to get start and end of dive,      
     %SONAR_FLAG(i,2)=0;
           
     if (dsum(Dive_no,7)) > 2000
        if SONAR_FLAG(i,1)==1 %---OLD part remove if it works && SONAR_FLAG(i,2)==1----%sonar is off and no previous dive response has been forced
           adjust_Q_bradycardia(1/20,0.8219,0.11,0.06805,0.00005,0.0, Dive_no);%Original from Beaked whale 2025 paper
           
        else %sonar is on and use different dive response
            adjust_Q_bradycardia(1/10,0.8219,0.11,0.06805,0.00005,0.0, Dive_no);%MOD to check effect of heart rate, heart, muscle, brain, fat
            %sonarbradlong=i
        end
        disp('1')
        DIVE_RESPONSE_FLAG=1;
        ADJ_BLOOD_VOL_LUNG_N2=B_VOL_PACKAGE_VEN*SN2_BLOOD;%used in lung interation search to make and "equivalent" gas volume, used to make a function that immediately estimates PN2 equilibriumr between lung and blood
        COL_multiplier_dive=dsum(Dive_no,10)/RMMR; %the COL for a dive in dsum, column 10 in l/O2 min, RMR from VO2_TOT in Get_variables
        update_tissue_metabolic_rates(i,-0.8,COL_multiplier_dive*adjust_muscle,-0.0,-0.9, Dive_no, DIVE_RESPONSE_FLAG);% M6d Model 5b and M5e
     elseif (dsum(Dive_no,7)) > 1050% in paper
        if SONAR_FLAG(i,1)==1 %%---OLD part remove if it works && SONAR_FLAG(i,2)==1---%sonar is off and no previous dive response has been forced
           adjust_Q_bradycardia(1/14,0.86,0.09,0.0495,0.0005,0.0, Dive_no);%%Original from Beaked whale 2025 paper, heart, muscle, brain, fat
           
        else %sonar is on and use different dive response
            adjust_Q_bradycardia(1/8,0.86,0.09,0.0495,0.0005,0.0, Dive_no);%%MOD to check effect of heart rate, heart, muscle, brain, fat
            %sonarbradint=i
        end
       
        disp('2')
        DIVE_RESPONSE_FLAG=1;
        ADJ_BLOOD_VOL_LUNG_N2=B_VOL_PACKAGE_VEN*SN2_BLOOD;%used in lung interation search to make and "equivalent" gas volume, used to make a function that immediately estimates PN2 equilibriumr between lung and blood
     
        COL_multiplier_dive=dsum(Dive_no,10)/RMMR; %the COL for a dive in dsum, column 10 in l/O2 min, RMR from VO2_TOT in Get_variables
          update_tissue_metabolic_rates(i,-0.7,COL_multiplier_dive*adjust_muscle,-0.0,-0.8,Dive_no, DIVE_RESPONSE_FLAG);% Model M6d
     elseif (dsum(Dive_no,7)) > 60                                                                   
        
        adjust_Q_bradycardia(1/6,0.6,0.35,0.025,0.025,0.0, Dive_no);%Model M5b, M5e 1/4
        disp('3')
        Dive_no
        DIVE_RESPONSE_FLAG=1;
        ADJ_BLOOD_VOL_LUNG_N2=B_VOL_PACKAGE_VEN*SN2_BLOOD;%used in lung interation search to make and "equivalent" gas volume, used to make a function that immediately estimates PN2 equilibriumr between lung and blood
     
        COL_multiplier_dive=dsum(Dive_no,10)/RMMR; %the COL for a dive in dsum, column 10 in l/O2 min, RMR from VO2_TOT in Get_variables
        update_tissue_metabolic_rates(i,-0.3,COL_multiplier_dive*adjust_muscle,-0.0,-0.5, Dive_no, DIVE_RESPONSE_FLAG);%this function a M5b, M5e
     else
          adjust_Q_bradycardia(1,0.3,0.685,0.01,0.005,0.0, Dive_no);%Modbels M5b, M5e
         disp('4')
         DIVE_RESPONSE_FLAG=1;
         ADJ_BLOOD_VOL_LUNG_N2=B_VOL_PACKAGE_VEN*SN2_BLOOD;%used in lung interation search to make and "equivalent" gas volume, used to make a function that immediately estimates PN2 equilibriumr between lung and blood
         COL_multiplier_dive=dsum(Dive_no,10)/RMMR; %the COL for a dive in dsum, column 10 in l/O2 min, RMR from VO2_TOT in Get_variables
         update_tissue_metabolic_rates(i,0,COL_multiplier_dive*adjust_muscle,-0.0,-0.0, Dive_no, DIVE_RESPONSE_FLAG);  %Models M5b, e fnew muscle metabolism for lower based on allometry and fiber type

     end
       Dive_no=Dive_no+1;
   elseif dsum(SI_no,9)==i %%%end of dive, add 2 seconds as sometimes 
   %%%%%%This is the old code but does not agree with the dive summary file,
   %%%%%%so am using that instead
      if (dsum(Dive_no-1,7)) > 2000  
         if SONAR_FLAG(i-1,1)==1 %means last dive was no sonar so adjust perfusion with the same value%sonar is off and no previous dive response has been forced
            adjust_Q_tachycardia(20,0.35,0.635,0.01,0.005,0.0, SI_no);%%Model heart, muscle, brain, fat,%Original from Beaked whale 2025 paper
            
         else
            adjust_Q_tachycardia(10,0.35,0.635,0.01,0.005,0.0, SI_no);%%Model heart, muscle, brain, fat,model sensitivvyt 
            %sonartachlong=i
         end
         disp('1a')
         DIVE_RESPONSE_FLAG=0;
         ADJ_BLOOD_VOL_LUNG_N2=B_VOL_PACKAGE_VEN*SN2_BLOOD;         
         COL_multiplier_surface=dsum(SI_no,10)/RMMR; %the COL for a dive in dsum, column 10 in l/O2 min, RMR from VO2_TOT in Get_variables
           update_tissue_metabolic_rates(i,0.4,COL_multiplier_surface*adjust_muscle,0,0, Dive_no, DIVE_RESPONSE_FLAG);  %n
      elseif (dsum(Dive_no-1,7)) > 1050  
         if SONAR_FLAG(i-1,1)==1 %means last dive was no sonar so adjust perfusion with the same value
            adjust_Q_tachycardia(14,0.35,0.635,0.01,0.005,0.0, SI_no);%;%%Model  heart, muscle, brain, fat, %Original from Beaked whale 2025 paper
            
         else
            adjust_Q_tachycardia(8,0.35,0.635,0.01,0.005,0.0, SI_no);%;%%Model  heart, muscle, brain, fat, %model sensitivty checking
            %sonartachint=i
         end

         disp('2a')
         DIVE_RESPONSE_FLAG=0;
         ADJ_BLOOD_VOL_LUNG_N2=B_VOL_PACKAGE_VEN*SN2_BLOOD;
         COL_multiplier_surface=dsum(SI_no,10)/RMMR; %the COL for a dive in dsum, column 10 in l/O2 min, RMR from VO2_TOT in Get_variables
        update_tissue_metabolic_rates(i,0.4,COL_multiplier_surface*adjust_muscle,0,0, Dive_no, DIVE_RESPONSE_FLAG); 
      elseif (dsum(Dive_no-1,7)) > 60 
           adjust_Q_tachycardia(6,0.35,0.635,0.01,0.005,0.0, SI_no);%%Model B%%Model heart, muscle, brain, fatM5e
            disp('3a')
          
           DIVE_RESPONSE_FLAG=0;
           ADJ_BLOOD_VOL_LUNG_N2=B_VOL_PACKAGE_VEN*SN2_BLOOD;
         
           COL_multiplier_surface=dsum(SI_no,10)/RMMR; %the COL for a dive in dsum, column 10 in l/O2 min, RMR from VO2_TOT in Get_variables
           update_tissue_metabolic_rates(i,0.4,COL_multiplier_surface*adjust_muscle,0,0, Dive_no, DIVE_RESPONSE_FLAG); 
      else
           adjust_Q_tachycardia(1,0.35,0.635,0.01,0.005,0.0, SI_no);%%Model  heart, muscle, brain, fat 
           disp('4a')
          
           DIVE_RESPONSE_FLAG=0;
           ADJ_BLOOD_VOL_LUNG_N2=B_VOL_PACKAGE_VEN*SN2_BLOOD;
         
           COL_multiplier_surface=dsum(SI_no,10)/RMMR; %the COL for a dive in dsum, column 10 in l/O2 min, RMR from VO2_TOT in Get_variables
           %update_tissue_metabolic_rates(i,1,COL_multiplier_surface,1,1); 
           %update_tissue_metabolic_rates(i,0,COL_multiplier_surface*1,0,0, Dive_no, DIVE_RESPONSE_FLAG);  %new muscle metabolism for lower based on allometry and fiber type
           update_tissue_metabolic_rates(i,0.4,COL_multiplier_surface*adjust_muscle,0,0, Dive_no, DIVE_RESPONSE_FLAG); 
      end
           SI_no=SI_no+1;%dive ended/SI started so add SI number to counter

         
      
   end
   if P_AMB(i)>P_AMB(1)&& SONAR_FLAG(i-1,2)==0%indicate that dive response has occured
       SONAR_FLAG(i,2)=0;
   end
   [n_N2_ven_t,P_N2_ven_t]=update_tissue_N2(Pamb,i,pect,rt);%performs the gas exchange at each tissue by mass exchange of molecules to/from blood to tissue
   															%then it sums the new number of molecules for the total blood volume and computes the new blood tension
                                                              %which is then returns. The tissue tensions and moles are updated before the function returns
   [n_O2_ven_t,P_O2_ven_t]=update_tissue_O2(Pamb,i,pect,rt);
   [n_CO2_ven_t,P_CO2_ven_t]=update_tissue_CO2(Pamb,i,pect,rt);
                                                            
   %This should update all gases
   [n_N2_art_t,P_N2_art_t,n_O2_art_t,P_O2_art_t, n_CO2_art_t,P_CO2_art_t]=update_lung_gas(Pamb,i,pect);%lung partial pressure and number of moles is updated before this function ends%this needs to update all gases when I later on consider O2 and CO2
   
   for w=1:(BLOOD_PARTITIONS_VEN+BLOOD_PARTITIONS_ART-1)
      temp_arr(w+1,:,:)=TEMP_ARRAY(w,:,:);
   end
   temp_arr(1,1,1)=P_N2_art_t;
   temp_arr(1,2,1)= n_N2_art_t;
   temp_arr(1,3,1)= temp_arr(2,3,1);
   
   temp_arr(1,1,2)=P_O2_art_t;
   temp_arr(1,2,2)= n_O2_art_t;
   temp_arr(1,3,2)= temp_arr(2,3,2);
  
   temp_arr(1,1,3)=P_CO2_art_t;
   temp_arr(1,2,3)= n_CO2_art_t;
   temp_arr(1,3,3)= temp_arr(2,3,3);
   
   temp_arr(BLOOD_PARTITIONS_ART+1,1,1)=P_N2_ven_t;
   temp_arr(BLOOD_PARTITIONS_ART+1,2,1)= n_N2_ven_t;
   temp_arr(BLOOD_PARTITIONS_ART+1,3,1)= temp_arr(BLOOD_PARTITIONS_VEN+1,3,1);  
   
   temp_arr(BLOOD_PARTITIONS_ART+1,1,2)=P_O2_ven_t;
   temp_arr(BLOOD_PARTITIONS_ART+1,2,2)= n_O2_ven_t;
   temp_arr(BLOOD_PARTITIONS_ART+1,3,2)= temp_arr(BLOOD_PARTITIONS_VEN+1,3,2);  
   
   temp_arr(BLOOD_PARTITIONS_ART+1,1,3)=P_CO2_ven_t;
   temp_arr(BLOOD_PARTITIONS_ART+1,2,3)= n_CO2_ven_t;
   temp_arr(BLOOD_PARTITIONS_ART+1,3,3)= temp_arr(BLOOD_PARTITIONS_VEN+1,3,3);  
   
   TEMP_ARRAY=temp_arr;
   %SUMMED BLOOD O2 FOR VENOUS AND ARTERIAL FOR ROW I 
   ART_VEN_O2_STORE(i,1)=sum(TEMP_ARRAY(1:BLOOD_PARTITIONS_ART,2,2));%total number of moles in arterial blood, moles
   ART_VEN_O2_STORE(i,2)=sum(TEMP_ARRAY(BLOOD_PARTITIONS_ART+1:BLOOD_PARTITIONS_ART+BLOOD_PARTITIONS_VEN,2,2));%total number of moles in venous blood, moles
   %%%changed above Aug 3, 2023 ART_VEN_O2_STORE(i,1)=sum(TEMP_ARRAY(BLOOD_PARTITIONS_ART+1:BLOOD_PARTITIONS_ART+BLOOD_PARTITIONS_VEN,2,2));%total number of moles in venous blood, moles
   ART_VEN_O2_STORE(i,3)=ART_VEN_O2_STORE(i,1)+ART_VEN_O2_STORE(i,2);%total number of moles in arterial blood, moles
   
   ART_VEN_CO2_STORE(i,1)=sum(TEMP_ARRAY(1:BLOOD_PARTITIONS_ART,2,3));%total number of moles in arterial blood, moles
   ART_VEN_CO2_STORE(i,2)=sum(TEMP_ARRAY(BLOOD_PARTITIONS_ART+1:BLOOD_PARTITIONS_ART+BLOOD_PARTITIONS_VEN,2,3));%total number of moles in venous blood, moles
   %%%changed above Aug 3, 2023 ART_VEN_O2_STORE(i,1)=sum(TEMP_ARRAY(BLOOD_PARTITIONS_ART+1:BLOOD_PARTITIONS_ART+BLOOD_PARTITIONS_VEN,2,2));%total number of moles in venous blood, moles
   ART_VEN_CO2_STORE(i,3)=ART_VEN_CO2_STORE(i,1)+ART_VEN_CO2_STORE(i,2);%total number of moles in arterial and venous blood, moles
   

   ART_VEN_nN2(i,1)=n_N2_art_t;%arterial number of moles
   ART_VEN_nN2(i,2)=n_N2_ven_t;%venous number of moles
   ART_VEN_PN2(i,1)=P_N2_art_t; %arterial N2 tension
   ART_VEN_PN2(i,2)=P_N2_ven_t;%venuous N2 tension
  
   ART_VEN_nO2(i,1)=n_O2_art_t;%arterial number of moles
   ART_VEN_nO2(i,2)=n_O2_ven_t;%venous number of moles
   ART_VEN_PO2(i,1)=P_O2_art_t; %arterial CO2 tension
   ART_VEN_PO2(i,2)=P_O2_ven_t;%venuous CO2 tension
   
   ART_VEN_nCO2(i,1)=n_CO2_art_t;%arterial number of moles
   ART_VEN_nCO2(i,2)=n_CO2_ven_t;%venous number of moles
   ART_VEN_PCO2(i,1)=P_CO2_art_t; %arterial CO2 tension
   ART_VEN_PCO2(i,2)=P_CO2_ven_t;%venuous CO2 tension
   
   STORES=GET_O2_CO2_STORES(i);%updates the stores of O2 and CO2 used in beaked_whale_tissue_kinetics and saves this to a file

end   
save SONAR_FLAG SONAR_FLAG -ascii -tabs
return