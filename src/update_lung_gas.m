% ========================================================================
% Second-round internal documentation review: 2026-10-18 | Batch 06
% File: update_lung_gas.m
% Review focus: Lung gas inventory and breath-event update. Distinguish ventilation additions/removals from blood-lung exchange; pressure and volume consistency are separate checks.
% Documentation only: original MATLAB source follows unchanged.
% ========================================================================
% ============================================================
% Documentation review: 2026-10-18 | Batch 06
% File: update_lung_gas.m
% Function signature: [n_N2_art_t,P_N2_art_t,n_O2_art_t,P_O2_art_t, n_CO2_art_t,P_CO2_art_t]=update_lung_gas(Pamb,i,pect)
% Scope: documentation only; numerical model unchanged.
% Original source preserved verbatim below this header.
% ============================================================
% GAS DYNAMICS MODEL - LUNG GAS UPDATE
% BREATH_FLAG(i)=1: finite exhalation/inspiration in moles; bypass est_va.
% Otherwise: preserve existing finite pulmonary gas exchange iteration.
% Gas order in vectors: [N2 O2 CO2]; pressure in atm; volumes in L.
% On a breath the surface arterial routines impose instantaneous equilibrium.
% This approximation is not an explicit diffusion/perfusion calculation.
% Validation checks confirm algebraic consistency, not whole-model conservation.

%possibly change all gases here as the "shunt" works fine in this version, so update all gases here 
function [n_N2_art_t,P_N2_art_t,n_O2_art_t,P_O2_art_t, n_CO2_art_t,P_CO2_art_t]=update_lung_gas(Pamb,i,pect)
%This funtion updates the lung/arterial tissue tensions. It iteratively searches for values during compression/decompression but is just updating
%values when the pressure is constant between t-1 and t

global  TEMP_ARRAY N2_ARRAY BLOOD_PARTITIONS_ART BLOOD_PARTITIONS_VEN B_VOL_PACKAGE_VEN SN2_BLOOD SO2_BLOOD SCO2_BLOOD
global O2_ARRAY CO2_ARRAY SURFACE_VALUE  R  ALV_SURFACE_VALUE P_AMB 
global Pint Pint_init  VLinit VLinit0 ART_BLOOD_ARRAY VLprev0 VLprev LUNG_VOL FLAGGA
global BREATH_FLAG VTinit VLmax TAC EXHALED_FRACTION INHALED_FRACTION
%Pamb is the pressure at time t and t-1

rt=R*(273+pect);%assuming that blood temp is equal to pectoral muscle 

ven_N2=BLOOD_PARTITIONS_VEN;%this is the last venuous blood package which exchanges with the tissue
art_N2=BLOOD_PARTITIONS_ART;%this is the last arterial blood package which exchanges with the tissue

%%%%%%%%%%%computation of shunt has to be moved to GET_GAS_FLUX
%%%%%%%%%%%%%%computes shunt from lung collapse model%%%%%%%%%%%%%%%%
 
   % A breath bypasses est_va and lung collapse.
   % At exact surface pressure without a breath, preserve the prior volume
   % instead of allowing est_va to reset it to VLinit0.
   if BREATH_FLAG(i)==1
       shunt=0;
       LUNG_VOL(i,5)=0;
   elseif P_AMB(i)==SURFACE_VALUE
       LUNG_VOL(i,1:2)=LUNG_VOL(i-1,1:2);
       LUNG_VOL(i,3)=P_AMB(i)*101.3;
       LUNG_VOL(i,4)=P_AMB(i)*101.3;
       LUNG_VOL(i,5)=0;
       shunt=0;
   else
       shunt=est_va(i,rt);
   end
   getlungvol=LUNG_VOL(i,1)+LUNG_VOL(i,2);

P_N2_ven_tmin1=TEMP_ARRAY((art_N2+ven_N2),1,1);%partial pressure of N2 
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

if BREATH_FLAG(i)==1 %%Old case A and C joined and we assume that a breath is a sudddent excursion to the surface where gas is exchanged. This event by-passes the function est_va and ignnores any lung comrpession.
    % Finite breath at current dry ambient pressure. Gas order [N2 O2 CO2].
    % During this event ventilation is modeled explicitly in moles;
    % arterial blood is updated by the legacy instantaneous-equilibrium rule.
    V_old=LUNG_VOL(i-1,1)+LUNG_VOL(i-1,2);
    % Exhalation fraction is defined relative to gas volume above VTinit.
    % Mole fractions are removed uniformly (well-mixed lung assumption).
    if ~isfinite(EXHALED_FRACTION) || EXHALED_FRACTION < 0 || EXHALED_FRACTION > 1 || ...
       ~isfinite(INHALED_FRACTION) || INHALED_FRACTION < 0 || INHALED_FRACTION > 1
        error('Ventilation fractions must be finite and between 0 and 1.');
    end
    if V_old < VTinit || V_old <= 0
        error('Breath at step %d: previous lung volume below residual volume',i);
    end
    V_exhaled=EXHALED_FRACTION*(V_old-VTinit);
    V_end_exp=V_old-V_exhaled;
    n_old=[n_N2_lung_tmin1,n_O2_lung_tmin1,n_CO2_lung_tmin1];
    n_remaining=n_old*(V_end_exp/V_old);
    F_inspired=[0.79,0.21,0];

    % Convert retained moles to an equivalent volume at ambient dry pressure.
    % The retained gas may not initially be at the same pressure as ambient.
    V_remaining=sum(n_remaining)*rt/P_AMB(i);
    if V_remaining > VLmax+1e-8
        error('Breath at step %d: retained gas alone exceeds TLC',i);
    end

    % INHALED_FRACTION=1 fills available capacity to TLC; 0 adds no gas.
    V_inspired=INHALED_FRACTION*max(0,VLmax-V_remaining);
    n_inspired=F_inspired*P_AMB(i)*V_inspired/rt;

    % Updated lung gas
    n_new=n_remaining+n_inspired;
    V_new=sum(n_new)*rt/P_AMB(i);    
 
    if V_new < VTinit || V_new > VLmax+1e-8
        error('Breath at step %d: derived lung volume %.6f L outside bounds',i,V_new);
    end
    % ===== VALIDATION OF BREATH CALCULATION =====
    % Gas order: N2, O2, CO2

    % 1. Conservation of gas moles
    mole_error = n_new - (n_remaining + n_inspired);

    % 2. Pressure-volume consistency
    pressure_error = sum(n_new)*rt/V_new - P_AMB(i);

    % 3. Lung volume constraints
    volume_ok = V_new >= VTinit && V_new <= VLmax+1e-8;

    % 4. Check physical gas amounts
    moles_ok = ~any(~isfinite(n_new)) && ~any(n_new < 0);

    %fprintf('Breath %d: V=%.4f L, mole error=%.2e, pressure error=%.2e\n', ...
    %    i,V_new,max(abs(mole_error)),abs(pressure_error));

    assert(max(abs(mole_error)) < 1e-10, ...
        'Gas mole conservation failed');

    assert(abs(pressure_error) < 1e-10, ...
        'Pressure-volume consistency failed');

    assert(volume_ok, 'Lung volume outside limits');
    assert(moles_ok, 'Invalid gas amounts');
    % ===== END VALIDATION =====
    
    
    P_new=n_new*rt/V_new;
    LUNG_VOL(i,1)=V_new-VTinit;
    LUNG_VOL(i,2)=VTinit;
    Pint=P_AMB(i)*101.3;
    LUNG_VOL(i,3)=Pint;
    LUNG_VOL(i,4)=P_AMB(i)*101.3;
    LUNG_VOL(i,5)=0;
    VLinit=LUNG_VOL(i,1);
    VLprev=VLinit;
    FLAGGA=0;
    % Reuse the original surface arterial equilibrium functions, but pass
    % the computed gas state rather than fixed ALV_SURFACE_VALUE.
    breath_gas=[P_new(:),n_new(:)];
    [P_N2_lung_t,n_N2_lung_t,P_N2_art_t,n_N2_art_t]=update_N2_case_A_or_C(B_VOL_PACKAGE_VEN,SN2_BLOOD,rt,breath_gas);
    [P_O2_lung_t,n_O2_lung_t,P_O2_art_t,n_O2_art_t]=update_O2_case_A_or_C(B_VOL_PACKAGE_VEN,SO2_BLOOD,rt,breath_gas);
    [P_CO2_lung_t,n_CO2_lung_t,P_CO2_art_t,n_CO2_art_t]=update_CO2_case_A_or_C(B_VOL_PACKAGE_VEN,SCO2_BLOOD,rt,breath_gas);
else %%%%%%%OLD CASE B, D, E, F and G
    % All no-breath time steps use the original finite gas iteration.
    [n_N2_lung_t,P_N2_art_t,n_N2_art_t]=iteration_N2_lung_search(rt,i,P_N2_lung_tmin1,n_N2_lung_tmin1,P_N2_ven_tmin1,n_N2_ven_tmin1,Pamb,shunt);
    [n_O2_lung_t,P_O2_art_t,n_O2_art_t]=iteration_O2_lung_search(rt,i,P_O2_lung_tmin1,n_O2_lung_tmin1,P_O2_ven_tmin1,n_O2_ven_tmin1,Pamb,shunt);
    [n_CO2_lung_t,P_CO2_art_t,n_CO2_art_t]=iteration_CO2_lung_search(rt,i,P_CO2_lung_tmin1,n_CO2_lung_tmin1,P_CO2_ven_tmin1,n_CO2_ven_tmin1,Pamb,shunt);
    all=n_N2_lung_t+n_O2_lung_t+n_CO2_lung_t;
    P_N2_lung_t=n_N2_lung_t/all*Pamb(2);
    P_O2_lung_t=n_O2_lung_t/all*Pamb(2);
    P_CO2_lung_t=n_CO2_lung_t/all*Pamb(2);
    % Apply the original mole-dependent volume reference adjustment at all
    % no-breath pressures, including the surface. No surface reset.
    initialvalue=(N2_ARRAY(1,5,2)+O2_ARRAY(1,5,2)+CO2_ARRAY(1,5,2))*rt;
    currentvalue=(n_N2_lung_t+n_O2_lung_t+n_CO2_lung_t)*rt;
    VLinit=VLinit0*currentvalue/initialvalue;
    
    % =================Nov 1 2026=====================
    % SURFACE LUNG VOLUME UPDATE
    % At the surface, allow lung volume to change according to
    % net pulmonary exchange of N2, O2 and CO2.
    % This does not impose VLmax between breaths.
    % ============================================================

    if P_AMB(i)==SURFACE_VALUE

        n_total_lung = n_N2_lung_t + n_O2_lung_t + n_CO2_lung_t;

        V_surface = n_total_lung*rt/P_AMB(i);

        if V_surface < VTinit
            error('Surface lung volume below tracheal volume at row %d',i);
        end

        LUNG_VOL(i,1) = V_surface-VTinit;
        LUNG_VOL(i,2) = VTinit;

    end
%%%%%%%%%%%%%%%%%%%END volume update Nov 1 2026%%%%%%%%%%

end

N2_ARRAY(i,5,1)=P_N2_lung_t;%updates lung N2 partial pressure
N2_ARRAY(i,5,2)=n_N2_lung_t;%updates moles N2 in lung,
O2_ARRAY(i,5,1)=P_O2_lung_t;%updates lung N2 partial pressure
O2_ARRAY(i,5,2)=n_O2_lung_t;%updates moles N2 in lung,
CO2_ARRAY(i,5,1)=P_CO2_lung_t;%updates lung N2 partial pressure
CO2_ARRAY(i,5,2)=n_CO2_lung_t;%updates moles N2 in lung,

return 
   
   
   
   
   
   
   
