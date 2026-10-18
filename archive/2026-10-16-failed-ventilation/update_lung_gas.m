%possibly change all gases here as the "shunt" works fine in this version, so update all gases here 
function [n_N2_art_t,P_N2_art_t,n_O2_art_t,P_O2_art_t, n_CO2_art_t,P_CO2_art_t]=update_lung_gas(Pamb,i,pect)
%This funtion updates the lung/arterial tissue tensions. It iteratively searches for values during compression/decompression but is just updating
%values when the pressure is constant between t-1 and t

global  TEMP_ARRAY N2_ARRAY BLOOD_PARTITIONS_ART BLOOD_PARTITIONS_VEN B_VOL_PACKAGE_VEN SN2_BLOOD SO2_BLOOD SCO2_BLOOD
global O2_ARRAY CO2_ARRAY SURFACE_VALUE  R  ALV_SURFACE_VALUE P_AMB 
global Pint Pint_init  VLinit VLinit0 ART_BLOOD_ARRAY VLprev0 VLprev LUNG_VOL FLAGGA
global V_LUNG V_BREATH BREATH_FRACTION
global BREATH_FLAG VTinit VLmax F_INSPIRED_N2 F_INSPIRED_CO2 F_INSPIRED_O2%Added October 13 2026 to keep track of breaths
%Pamb is the pressure at time t and t-1

rt=R*(273+pect);%assuming that blood temp is equal to pectoral muscle 

ven_N2=BLOOD_PARTITIONS_VEN;%this is the last venuous blood package which exchanges with the tissue
art_N2=BLOOD_PARTITIONS_ART;%this is the last arterial blood package which exchanges with the tissue

%%%%%%%%%%%computation of shunt has to be moved to GET_GAS_FLUX
%%%%%%%%%%%%%%computes shunt from lung collapse model%%%%%%%%%%%%%%%%
 
   shunt=est_va(i,rt);%a fraction of the total driving pressure
   

   getlungvol=LUNG_VOL(i,1)+LUNG_VOL(i,2); %need this to calculate lung pressures when diving
    %%%%%%%%%%%%%%computes shunt from lung collapse model%%%%%%%%%%%%%%%%
    %%%%%%%%%%%lung collapse at certain depth%%%%%%%%%%%
    %if P_AMB(i)>6.57;%3.75= 30mpressures(4ATA), 6.57 = 60m (8ATA), 15.9=160m (17ATA) are in ATA so surface is 1 ATA, thus depth is depth=(P_AMB-1)*10-PH2O so 8.44 is 80m, as PH2O at 37C is 0.0621
    %   shunt=1;%fractional shunt
    %else 
    %  shunt=0;
    %end   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

P_N2_ven_tmin1=TEMP_ARRAY((art_N2+ven_N2),1,1);%venous partial pressure of N2 
n_N2_ven_tmin1=TEMP_ARRAY((art_N2+ven_N2),2,1); %the number of moles in the venuous blood at the start of the routine
P_N2_lung_tmin1=N2_ARRAY(i-1,5,1);%the partial pressure based of N2 in the lung at t-1.
n_N2_lung_tmin1=N2_ARRAY(i-1,5,2);%the number of moles N2 in the lung at time t-1

P_O2_ven_tmin1=TEMP_ARRAY((art_N2+ven_N2),1,2);%partial pressure of O2 
n_O2_ven_tmin1=TEMP_ARRAY((art_N2+ven_N2),2,2); %the number of moles in the venuous blood at the start of the routine
P_O2_lung_tmin1=O2_ARRAY(i-1,5,1);%the partial pressure based of O2 in the lung at t-1.
n_O2_lung_tmin1=O2_ARRAY(i-1,5,2);%the number of moles O2 in the lung at time t-1

P_CO2_ven_tmin1=TEMP_ARRAY((art_N2+ven_N2),1,3);%partial pressure of N2 
n_CO2_ven_tmin1=TEMP_ARRAY((art_N2+ven_N2),2,3); %the number of moles in the venuous blood at the start of the routine
P_CO2_lung_tmin1=CO2_ARRAY(i-1,5,1);%the partial pressure based of N2 in the lung at t-1.
n_CO2_lung_tmin1=CO2_ARRAY(i-1,5,2);%the number of moles N2 in the lung at time t-1

%if Pamb(1)==SURFACE_VALUE && Pamb(2)==SURFACE_VALUE %case A in note book p. 25 at surface, SURFACE_VALUE=Pamb at surface, defined in beakedwhale_tissue_kinetics1
if BREATH_FLAG(i)==1 
   % ===== FINITE BREATH: MOLE-BASED UPDATE =====

% Previous lung volume and gas amounts
V_old_total = LUNG_VOL(i-1,1) + LUNG_VOL(i-1,2);

n_old = [N2_ARRAY(i-1,5,2), ...
         O2_ARRAY(i-1,5,2), ...
         CO2_ARRAY(i-1,5,2)];

% Exhalation to the selected end-expiratory volume
V_residual = VTinit;

if V_old_total < V_residual
    error('Previous lung volume is below residual volume.');
end

fraction_remaining = V_residual / V_old_total;
n_residual = n_old * fraction_remaining;

% Inspiration
V_inspired = V_BREATH;

F_inspired = [F_INSPIRED_N2, ...
              F_INSPIRED_O2, ...
              F_INSPIRED_CO2];

P_dry = P_AMB(i);

n_inspired = F_inspired * P_dry * V_inspired / rt;

% Conservation of moles during the breath
n_new = n_residual + n_inspired;

% Calculate new volume from total moles
n_total = sum(n_new);
V_final = n_total * rt / P_dry;

if V_final > VLmax + 1e-9
    error('Post-breath volume exceeds TLC.');
end

if V_final < VTinit
    error('Post-breath volume is below tracheal volume.');
end

% Update mechanical lung volume
LUNG_VOL(i,1) = V_final - VTinit;
LUNG_VOL(i,2) = VTinit;

% Update reference state for next calculation
VLinit = LUNG_VOL(i,1);
VLprev = VLinit;
Pint = P_dry * 101.3;
FLAGGA = 0;

LUNG_VOL(i,3) = Pint;
LUNG_VOL(i,4) = P_dry * 101.3;

% Calculate gas partial pressures
P_lung = n_new * rt / V_final;
   P_N2_lung_t = P_lung(1);
    n_N2_lung_t = n_new(1);

    P_O2_lung_t = P_lung(2);
    n_O2_lung_t = n_new(2);

    P_CO2_lung_t = P_lung(3);
    n_CO2_lung_t = n_new(3);

    % Temporary perfect-equilibrium arterial calculation
    P_N2_art_t = P_N2_lung_t;
    n_N2_art_t = ...
        B_VOL_PACKAGE_VEN * SN2_BLOOD * P_N2_art_t / rt;

    P_O2_art_t = P_O2_lung_t;
    n_O2_art_t = ...
        B_VOL_PACKAGE_VEN * ...
        blood_Co2(P_CO2_lung_t,P_O2_lung_t) / rt;

    P_CO2_art_t = P_CO2_lung_t;
    n_CO2_art_t = ...
        B_VOL_PACKAGE_VEN * ...
        blood_Cco2(P_O2_lung_t,P_CO2_lung_t) / rt; 
% ===== END FINITE BREATH UPDATE =====

  
else %case B, D-F in note book p. 25 only when diving
   
   [n_N2_lung_t, P_N2_art_t, n_N2_art_t]=iteration_N2_lung_search(rt,i,P_N2_lung_tmin1, n_N2_lung_tmin1, P_N2_ven_tmin1, n_N2_ven_tmin1,Pamb,shunt);
   [n_O2_lung_t, P_O2_art_t, n_O2_art_t]=iteration_O2_lung_search(rt,i,P_O2_lung_tmin1, n_O2_lung_tmin1, P_O2_ven_tmin1, n_O2_ven_tmin1,Pamb,shunt);
   [n_CO2_lung_t, P_CO2_art_t, n_CO2_art_t]=iteration_CO2_lung_search(rt,i,P_CO2_lung_tmin1, n_CO2_lung_tmin1, P_CO2_ven_tmin1, n_CO2_ven_tmin1,Pamb,shunt);
   all=n_N2_lung_t+n_O2_lung_t+n_CO2_lung_t;
 
   P_N2_lung_t=n_N2_lung_t/all*Pamb(2);%fraction of N2 left in lung times ambient pressure, good old Dalton's law
   P_O2_lung_t=n_O2_lung_t/all*Pamb(2);
   P_CO2_lung_t=n_CO2_lung_t/all*Pamb(2);
   %%%%This section updates VLinit so it accounts for the changes in lung volume that occurs when N2, O2 and CO2 are removed or added from the lung 
   if P_AMB(i)>P_AMB(1)%just in case
      initialvalue=(N2_ARRAY(1,5,2)+O2_ARRAY(1,5,2)+CO2_ARRAY(1,5,2))*rt;%initial value is the value at row 1
      currentvalue=(n_N2_lung_t+n_O2_lung_t+n_CO2_lung_t)*rt;
      VLinit=VLinit0*currentvalue/initialvalue;%The initial dive lung volume is adjusted for next iteration of lung collapse to inc or dec the volume according to the number of moles N2 that is added or removed.
   %elseif P_AMB(i)==P_AMB(1)%at the surface
    %   VLinit=VLinit0;
    % %  VLprev=VLprev0;
    %  Pint=Pint_init;
     % FLAGGA=0;
   end
end

N2_ARRAY(i,5,1)=P_N2_lung_t;%updates lung N2 partial pressure
N2_ARRAY(i,5,2)=n_N2_lung_t;%updates moles N2 in lung,
O2_ARRAY(i,5,1)=P_O2_lung_t;%updates lung N2 partial pressure
O2_ARRAY(i,5,2)=n_O2_lung_t;%updates moles N2 in lung,
CO2_ARRAY(i,5,1)=P_CO2_lung_t;%updates lung N2 partial pressure
CO2_ARRAY(i,5,2)=n_CO2_lung_t;%updates moles N2 in lung,
% ===== TEMPORARY BREATH DEBUGGING =====
if BREATH_FLAG(i)==1 || ...
   (i>1 && BREATH_FLAG(i-1)==1)

    fprintf('\nTime step: %d\n',i);
    fprintf('Breath flag: %d\n',BREATH_FLAG(i));
    fprintf('Ambient pressure: %.6f\n',P_AMB(i));

    fprintf('VLinit0: %.6f L\n',VLinit0);
    fprintf('VLinit:  %.6f L\n',VLinit);
    fprintf('VLprev:  %.6f L\n',VLprev);
    fprintf('Pint:    %.6f kPa\n',Pint);

    fprintf('Alveolar volume: %.6f L\n',LUNG_VOL(i,1));
    fprintf('Tracheal volume: %.6f L\n',LUNG_VOL(i,2));

    fprintf('Total lung volume: %.6f L\n', ...
        LUNG_VOL(i,1)+LUNG_VOL(i,2));

    fprintf('V_BREATH: %.6f L\n',V_BREATH);

    fprintf('N2 moles: %.10f\n',N2_ARRAY(i,5,2));
    fprintf('O2 moles: %.10f\n',O2_ARRAY(i,5,2));
    fprintf('CO2 moles: %.10f\n',CO2_ARRAY(i,5,2));

    fprintf('Total lung moles: %.10f\n', ...
        N2_ARRAY(i,5,2)+ ...
        O2_ARRAY(i,5,2)+ ...
        CO2_ARRAY(i,5,2));

    fprintf('Gas-derived volume nRT/P: %.6f L\n', ...
        (N2_ARRAY(i,5,2)+O2_ARRAY(i,5,2)+ ...
         CO2_ARRAY(i,5,2))*rt/Pamb(2));
end
% ===== PRESSURE AND VOLUME CONSISTENCY CHECK =====

if BREATH_FLAG(i)==1 || ...
   (i>1 && BREATH_FLAG(i-1)==1)

    n_total = N2_ARRAY(i,5,2) + ...
              O2_ARRAY(i,5,2) + ...
              CO2_ARRAY(i,5,2);

    V_mechanical = LUNG_VOL(i,1) + LUNG_VOL(i,2);

    % Total pressure from gas amounts and mechanical volume
    P_from_gas = n_total * rt / V_mechanical;

    % Convert mechanical pressure from kPa to atm
    Pint_atm = Pint / 101.3;

    fprintf('\nPRESSURE CONSISTENCY, step %d\n',i);
    fprintf('Ambient dry pressure: %.6f atm\n',P_AMB(i));
    fprintf('Internal pressure:    %.6f atm\n',Pint_atm);
    fprintf('Pressure from gas:    %.6f atm\n',P_from_gas);
    fprintf('Difference gas-Pint:  %.6f atm\n', ...
        P_from_gas-Pint_atm);

end
% ===== END TEMPORARY DEBUGGING =====
return 
   
   
   
   
   
   
   
