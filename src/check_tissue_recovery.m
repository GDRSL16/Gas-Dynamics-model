
function T = check_tissue_recovery(STORES, P_AMB, SURFACE_VALUE, outputFile)
% CHECK_TISSUE_RECOVERY
% Updated 2026-11-05
%
% Quantifies O2 and CO2 tissue-store recovery after each dive.
% Stores are in L STPD.
% STORES(:,2) = total tissue O2 (includes muscle)
% STORES(:,7) = total tissue CO2 (includes muscle)
%
% Does not modify model variables.
%
% Example:
% T = check_tissue_recovery(STORES,P_AMB,SURFACE_VALUE,'recovery_Model1F_recovery.xlsx');

if nargin < 4
    outputFile = 'tissue_recovery.xlsx';
end

P_AMB = P_AMB(:);
N = numel(P_AMB);

assert(size(STORES,1)==N, ...
    'STORES and P_AMB must have the same number of rows');

% Identify underwater periods
underwater = P_AMB > SURFACE_VALUE + 1e-7;

diveStart = find(diff([false; underwater])==1);
diveEnd   = find(diff([underwater; false])==-1);

% Only dives followed by a complete surface interval
nDive = numel(diveStart);

results = [];

for j = 1:nDive

    % Previous pre-dive state
    pre = diveStart(j)-1;

    % First surface row after the dive
    surf = diveEnd(j)+1;

    % End of recovery: row before next dive
    if j < nDive
        finish = diveStart(j+1)-1;
    else
        % No complete subsequent interval available
        continue
    end

    if pre < 1 || surf > N || finish < surf
        continue
    end

    O2pre  = STORES(pre,2);
    O2surf = STORES(surf,2);
    O2end  = STORES(finish,2);

    CO2pre  = STORES(pre,7);
    CO2surf = STORES(surf,7);
    CO2end  = STORES(finish,7);

    % Dive-associated changes
    O2deficit = O2pre-O2surf;
    CO2excess = CO2surf-CO2pre;

    % Recovery fractions
    RO2 = NaN;
    RCO2 = NaN;

    if O2deficit > 0
        RO2 = 100*(O2end-O2surf)/O2deficit;
    end

    if CO2excess > 0
        RCO2 = 100*(CO2surf-CO2end)/CO2excess;
    end

    % Target stores for 50%, 90%, 95% recovery
    O2targets = O2surf + [0.50 0.90 0.95]*O2deficit;
    CO2targets = CO2surf - [0.50 0.90 0.95]*CO2excess;

    results = [results; ...
        j, pre, surf, finish, finish-surf+1, ...
        O2pre,O2surf,O2end,O2deficit,RO2, ...
        O2targets, ...
        CO2pre,CO2surf,CO2end,CO2excess,RCO2, ...
        CO2targets];
end

names = { ...
    'DiveNumber','PreDiveRow','SurfacingRow', ...
    'RecoveryEndRow','RecoveryRows', ...
    'O2_PreDive_L','O2_Surfacing_L','O2_End_L', ...
    'O2_Deficit_L','O2_Recovery_pct', ...
    'O2_Target50_L','O2_Target90_L','O2_Target95_L', ...
    'CO2_PreDive_L','CO2_Surfacing_L','CO2_End_L', ...
    'CO2_Excess_L','CO2_Recovery_pct', ...
    'CO2_Target50_L','CO2_Target90_L','CO2_Target95_L'};

T = array2table(results,'VariableNames',names);

disp(T)

writetable(T,outputFile,'Sheet','RecoverySummary');

fprintf('\nSaved %d completed recovery intervals to %s\n', ...
    height(T),outputFile);

end
