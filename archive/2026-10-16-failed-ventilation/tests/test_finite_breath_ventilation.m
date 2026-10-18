%% Standalone finite-breath ventilation test
% No blood exchange, metabolism, pressure compression or water-vapour correction.
% All volumes are litres, pressure is arbitrary fixed 1 atm, and gas amounts
% are represented in equivalent litres at that pressure (proportional to moles).
% Gas order: [O2 CO2 N2]. No modifications to the main gas dynamics model.
clear; clc;
TLC = 50;                     % L, total lung capacity
residual_fraction = 0.067;    % fraction of TLC
V_residual = TLC * residual_fraction;
V_inspired_max = TLC - V_residual;
breath_fraction = 1;        % fraction of available inspiratory capacity
V_inspired = breath_fraction * V_inspired_max;
V_after = V_residual + V_inspired;
N = 5;
F_post_dive = [0.05 0.16 0.79];
F_inspired = [0.21 0 0.79];
assert(abs(sum(F_post_dive)-1)<1e-12 && abs(sum(F_inspired)-1)<1e-12);
assert(V_inspired >= 0 && V_after <= TLC + 1e-12);

% Case A: identical post-dive composition before every breath.
% Every breath gives the same post-breath composition, by construction.
F_fixed = zeros(N,3);
for k = 1:N
    F_fixed(k,:) = mix_one_breath(F_post_dive, V_residual, ...
                                 V_inspired, F_inspired);
end

% Case B: sequential breaths with no gas exchange between breaths.
% At the next cycle the prior post-breath gas is exhaled to residual volume.
F_sequential = zeros(N,3);
F_before = F_post_dive;
for k = 1:N
    F_after = mix_one_breath(F_before, V_residual, ...
                             V_inspired, F_inspired);
    F_sequential(k,:) = F_after;
    F_before = F_after;
end

fprintf('TLC = %.3f L; residual = %.3f L; inspired = %.3f L; post-breath = %.3f L\n', ...
    TLC,V_residual,V_inspired,V_after);
fprintf('Gas order: O2, CO2, N2\n');
fprintf('Fixed post-dive input, first and 5th breath: [%0.6f %0.6f %0.6f]\n', F_fixed(1,:));
fprintf('Sequential, first breath: [%0.6f %0.6f %0.6f]\n', F_sequential(1,:));
fprintf('Sequential, 500th breath: [%0.6f %0.6f %0.6f]\n', F_sequential(end,:));

figure('Name','Finite-breath ventilation: fixed post-dive input');
plot(1:N,100*F_fixed,'LineWidth',1.5); grid on;
xlabel('Breath number'); ylabel('Post-breath dry gas fraction (%)');
legend('O2','CO2','N2','Location','best');
title('A) Same post-dive composition before every breath');

figure('Name','Finite-breath ventilation: sequential breaths');
plot(1:N,100*F_sequential,'LineWidth',1.5); grid on;
xlabel('Breath number'); ylabel('Post-breath dry gas fraction (%)');
legend('O2','CO2','N2','Location','best');
title('B) No exchange between breaths; composition carried forward');

% Future sensitivity runs: vary TLC, residual_fraction, breath_fraction,
% and F_post_dive. If post-dive composition varies randomly, normalize
% each row to sum to 1 and set rng(seed) for reproducibility.

function F_after = mix_one_breath(F_before, V_residual, V_inspired, F_inspired)
    % Assumes a well-mixed pre-breath gas pool, exhalation to V_residual,
    % and fresh inspiration at the same reference pressure/temperature.
    % Equivalent gas volumes are proportional to gas moles.
    V_after = V_residual + V_inspired;
    if V_after <= 0
        error('Post-breath gas volume must be positive.');
    end
    n_residual_equiv = F_before * V_residual;
    n_inspired_equiv = F_inspired * V_inspired;
    F_after = (n_residual_equiv + n_inspired_equiv) / V_after;
    assert(abs(sum(F_after)-1) < 1e-10, 'Gas fractions do not sum to 1.');
end
