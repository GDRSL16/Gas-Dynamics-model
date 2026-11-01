
%% CHECK_SURFACE_LUNG_VOLUME
% Verification of lung volume and gas consistency during surface intervals.
% Run after completing a simulation (dataset 13, 14 or 15).
% Does not modify model variables.

global BREATH_FLAG LUNG_VOL P_AMB
global N2_ARRAY O2_ARRAY CO2_ARRAY
global R SURFACE_VALUE

%% 1. Extract model data

N = numel(P_AMB);
rows = (1:N)';

V_lung = LUNG_VOL(:,1) + LUNG_VOL(:,2);

n_N2  = N2_ARRAY(:,5,2);
n_O2  = O2_ARRAY(:,5,2);
n_CO2 = CO2_ARRAY(:,5,2);

P_N2  = N2_ARRAY(:,5,1);
P_O2  = O2_ARRAY(:,5,1);
P_CO2 = CO2_ARRAY(:,5,1);

n_total = n_N2 + n_O2 + n_CO2;
P_total = P_N2 + P_O2 + P_CO2;

% Same temperature convention as update_lung_gas
rt = R*(273+37);

V_gas = n_total.*rt./P_AMB;

%% 2. Identify surface intervals and breath events

surface = abs(P_AMB-SURFACE_VALUE) < 1e-8;
breaths = BREATH_FLAG(:)==1;

assert(numel(breaths)==N, ...
    'BREATH_FLAG length does not match P_AMB');

% Identify contiguous surface periods
surface_start = find(diff([false;surface])==1);
surface_end   = find(diff([surface;false])==-1);

% Exclude initial surface period; retain post-dive intervals
surface_start = surface_start(2:end);
surface_end   = surface_end(2:end);

%% 3. Surface interval summary

nSI = numel(surface_start);

SI_number = (1:nSI)';
Start_row = surface_start;
End_row = surface_end;
Duration_s = End_row-Start_row+1;

Number_breaths = zeros(nSI,1);
Min_volume = zeros(nSI,1);
Max_volume = zeros(nSI,1);
Mean_volume = zeros(nSI,1);
Max_volume_error = zeros(nSI,1);
Max_pressure_error = zeros(nSI,1);

for k = 1:nSI

    idx = Start_row(k):End_row(k);

    Number_breaths(k) = sum(breaths(idx));

    Min_volume(k) = min(V_lung(idx));
    Max_volume(k) = max(V_lung(idx));
    Mean_volume(k) = mean(V_lung(idx));

    Max_volume_error(k) = ...
        max(abs(V_lung(idx)-V_gas(idx)));

    Max_pressure_error(k) = ...
        max(abs(P_total(idx)-P_AMB(idx)));

end

SI_summary = table( ...
    SI_number,Start_row,End_row,Duration_s, ...
    Number_breaths,Min_volume,Max_volume, ...
    Mean_volume,Max_volume_error,Max_pressure_error);

disp(' ')
disp('SURFACE INTERVAL SUMMARY')
disp(SI_summary)

%% 4. Breath-by-breath volume changes

breath_rows = find(breaths);
breath_rows = breath_rows(breath_rows>1);

V_before = V_lung(breath_rows-1);
V_after = V_lung(breath_rows);
Delta_V = V_after-V_before;

Breath_summary = table( ...
    breath_rows,V_before,V_after,Delta_V, ...
    'VariableNames', ...
    {'TimeStep','Volume_before','Volume_after','Change_L'});

disp(' ')
disp('BREATH SUMMARY')
disp(Breath_summary(1:min(30,height(Breath_summary)),:))

%% 5. Plots

figure('Name','Surface lung volume verification')

subplot(3,1,1)
plot(SI_number,Min_volume,'bo-')
hold on
plot(SI_number,Max_volume,'ro-')
plot(SI_number,Mean_volume,'k.-')
ylabel('Lung volume (L)')
legend('Minimum','Maximum','Mean','Location','best')
title('Lung volume across surface intervals')
grid on

subplot(3,1,2)
plot(SI_number,Max_volume_error,'ko-')
ylabel('Maximum volume error (L)')
title('Stored versus gas-derived volume')
grid on

subplot(3,1,3)
plot(SI_number,Max_pressure_error,'mo-')
xlabel('Surface interval number')
ylabel('Pressure error (atm)')
title('Sum of lung gas partial pressures versus ambient')
grid on

%% 6. Overall numerical checks

fprintf('\nOVERALL SURFACE CHECKS\n');
fprintf('Number of surface intervals: %d\n',nSI);
fprintf('Total breaths: %d\n',sum(breaths));
fprintf('Maximum surface lung volume: %.6f L\n', ...
    max(V_lung(surface)));
fprintf('Minimum surface lung volume: %.6f L\n', ...
    min(V_lung(surface)));
fprintf('Maximum gas-volume discrepancy: %.6e L\n', ...
    max(abs(V_lung(surface)-V_gas(surface))));
fprintf('Maximum pressure discrepancy: %.6e atm\n', ...
    max(abs(P_total(surface)-P_AMB(surface))));
