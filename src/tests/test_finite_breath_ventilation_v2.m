%% Standalone finite-breath ventilation test - independent exhalation and inspiration
% No blood exchange, metabolism, pressure compression or water-vapour correction.
% Volumes in litres; equivalent gas volumes proportional to moles at fixed P,T.
% Gas order: [O2 CO2 N2]. Does not modify the main gas dynamics model.
clear; clc;
TLC = 50;                     % Total lung capacity (L)
residual_fraction_min = 0.067; % Anatomical minimum residual volume / TLC
exhaled_fraction = 1;      % Fraction of exhalable gas expelled (0 to 1)
breath_fraction = 1.00;       % Fraction of available inspiratory space filled (0 to 1)
N = 5;                        % Number of breath cycles
F_post_dive = [0.05 0.16 0.79];
F_inspired = [0.21 0 0.79];

assert(TLC > 0);
assert(residual_fraction_min >= 0 && residual_fraction_min < 1);
assert(exhaled_fraction >= 0 && exhaled_fraction <= 1);
assert(breath_fraction >= 0 && breath_fraction <= 1);
assert(N >= 1 && N == floor(N));
assert(all(F_post_dive >= 0) && all(F_inspired >= 0));
assert(abs(sum(F_post_dive)-1)<1e-12 && abs(sum(F_inspired)-1)<1e-12);

V_residual_min = TLC * residual_fraction_min;

% Case A: independent breaths, each starting at TLC with identical post-dive gas.
F_fixed = zeros(N,3);
V_fixed = zeros(N,1);
for k = 1:N
    [F_fixed(k,:), V_fixed(k), V_end_exp, V_inspired] = ...
        mix_one_breath(F_post_dive, TLC, TLC, V_residual_min, ...
                       exhaled_fraction, breath_fraction, F_inspired);
end

% Case B: consecutive breaths, retaining both gas composition AND actual
% post-inspiratory volume from the preceding breath. No intervening exchange.
F_sequential = zeros(N,3);
V_sequential = zeros(N,1);
F_before = F_post_dive;
V_before = TLC;
for k = 1:N
    [F_before, V_before] = mix_one_breath(F_before, V_before, TLC, ...
        V_residual_min, exhaled_fraction, breath_fraction, F_inspired);
    F_sequential(k,:) = F_before;
    V_sequential(k) = V_before;
end

fprintf('TLC %.3f L, minimum residual %.3f L\n', TLC, V_residual_min);
fprintf('Exhaled fraction %.2f, inhaled fraction %.2f\n', exhaled_fraction, breath_fraction);
fprintf('Case A: end-expiratory %.3f L, inspired %.3f L, final %.3f L\n', ...
    V_end_exp, V_inspired, V_fixed(1));
fprintf('Case A first and last post-breath [O2 CO2 N2]: [%0.6f %0.6f %0.6f]\n', F_fixed(1,:));
fprintf('Case B first post-breath [O2 CO2 N2]: [%0.6f %0.6f %0.6f]\n', F_sequential(1,:));
fprintf('Case B last post-breath [O2 CO2 N2]: [%0.6f %0.6f %0.6f]\n', F_sequential(end,:));

figure('Name','A: identical independent breaths');
plot(1:N, 100*F_fixed, 'LineWidth',1.5); grid on;
xlabel('Breath number'); ylabel('Post-breath gas fraction (%)');
legend('O2','CO2','N2','Location','best');
title('A) Identical post-dive composition, starting at TLC');

figure('Name','B: sequential breaths');
plot(1:N, 100*F_sequential, 'LineWidth',1.5); grid on;
xlabel('Breath number'); ylabel('Post-breath gas fraction (%)');
legend('O2','CO2','N2','Location','best');
title('B) Sequential breaths, no intervening gas exchange');

figure('Name','Sequential lung volume');
plot(1:N, V_sequential, 'LineWidth',1.5); grid on;
xlabel('Breath number'); ylabel('Post-inspiratory lung volume (L)');
title('B) Lung volume carried forward between breaths');

function [F_after, V_after, V_end_exp, V_inspired] = mix_one_breath( ...
    F_before, V_before, TLC, V_residual_min, exhaled_fraction, breath_fraction, F_inspired)
    % Exhale a fraction of gas available above the minimum residual volume.
    % Then inspire a fraction of the remaining capacity up to TLC.
    if V_before < V_residual_min - 1e-10 || V_before > TLC + 1e-10
        error('Pre-breath volume must be between minimum residual and TLC.');
    end
    V_exhaled = exhaled_fraction * (V_before - V_residual_min);
    V_end_exp = V_before - V_exhaled;
    V_inspired = breath_fraction * (TLC - V_end_exp);
    V_after = V_end_exp + V_inspired;
    if V_after <= 0 || V_after > TLC + 1e-10
        error('Invalid post-breath volume.');
    end
    n_remaining = F_before * V_end_exp;
    n_inspired = F_inspired * V_inspired;
    F_after = (n_remaining + n_inspired) / V_after;
    assert(abs(sum(F_after)-1)<1e-10);
end
