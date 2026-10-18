%% Finite-breath ventilation: two independent sensitivity experiments
% Standalone script. Does not change the main gas dynamics model.
% Single breath per grid point, with no metabolism or blood gas exchange.
% Gas order: [O2 CO2 N2]. Volumes in litres; gas amounts proportional
% to moles at fixed pressure and temperature.
clear; clc;
TLC = 50;
residual_fraction_min = 0.067;
V_residual_min = TLC * residual_fraction_min;
F_post_dive = [0.05 0.16 0.79];
F_inspired = [0.21 0 0.79];
assert(abs(sum(F_post_dive)-1)<1e-10 && abs(sum(F_inspired)-1)<1e-10);

%% Experiment 1: exhaled vs inhaled fractions, one breath starting at TLC
fraction_grid = linspace(0,1,51);
[EX,IN] = meshgrid(fraction_grid,fraction_grid);
F_end_1 = zeros([size(EX),3]);
V_end_1 = zeros(size(EX));
for row = 1:size(EX,1)
    for col = 1:size(EX,2)
        [F_end_1(row,col,:), V_end_1(row,col)] = ...
            one_breath(F_post_dive,TLC,TLC,V_residual_min, ...
                       EX(row,col),IN(row,col),F_inspired);
    end
end
figure('Name','Experiment 1: ventilation fractions','Color','w');
for gas = 1:3
    subplot(1,3,gas);
    imagesc(fraction_grid,fraction_grid,100*F_end_1(:,:,gas));
    set(gca,'YDir','normal'); axis square; colorbar;
    xlabel('Exhaled fraction'); ylabel('Inhaled fraction');
    gas_names = {'O2','CO2','N2'};
    title(['Post-breath ',gas_names{gas},' (%)']);
end
sgtitle('Experiment 1: varying exhalation and inhalation');

%% Experiment 2: initial O2 and CO2, fixed exhaled/inhaled fractions
fixed_exhaled_fraction = 0.50;
fixed_inhaled_fraction = 1.00;
O2_grid = linspace(0,0.30,61);
CO2_grid = linspace(0,0.30,61);
[O2_before,CO2_before] = meshgrid(O2_grid,CO2_grid);
F_end_2 = NaN([size(O2_before),3]);
for row = 1:size(O2_before,1)
    for col = 1:size(O2_before,2)
        F0 = [O2_before(row,col), CO2_before(row,col), ...
              1-O2_before(row,col)-CO2_before(row,col)];
        if all(F0 >= 0)
            [F_end_2(row,col,:), ~] = ...
                one_breath(F0,TLC,TLC,V_residual_min, ...
                           fixed_exhaled_fraction,fixed_inhaled_fraction,F_inspired);
        end
    end
end
figure('Name','Experiment 2: post-dive composition','Color','w');
for gas = 1:3
    subplot(1,3,gas);
    imagesc(100*O2_grid,100*CO2_grid,100*F_end_2(:,:,gas));
    set(gca,'YDir','normal'); axis square; colorbar;
    xlabel('Pre-breath O2 (%)'); ylabel('Pre-breath CO2 (%)');
    title(['Post-breath ',gas_names{gas},' (%)']);
end
sgtitle(sprintf('Experiment 2: exhaled = %.2f, inhaled = %.2f', ...
                fixed_exhaled_fraction,fixed_inhaled_fraction));

%% Reference case
[F_ref,V_ref] = one_breath(F_post_dive,TLC,TLC,V_residual_min, ...
    fixed_exhaled_fraction,fixed_inhaled_fraction,F_inspired);
fprintf('Reference: exhaled=%.2f, inhaled=%.2f; final volume=%.3f L\n', ...
    fixed_exhaled_fraction,fixed_inhaled_fraction,V_ref);
fprintf('Post-breath: O2=%.3f%%, CO2=%.3f%%, N2=%.3f%%\n',100*F_ref);

function [F_after,V_after] = one_breath(F_before,V_before,TLC,V_min,ex_frac,in_frac,F_in)
    assert(V_before>=V_min && V_before<=TLC);
    assert(ex_frac>=0 && ex_frac<=1 && in_frac>=0 && in_frac<=1);
    V_exhaled = ex_frac * (V_before-V_min);
    V_end_exp = V_before-V_exhaled;
    V_inspired = in_frac * (TLC-V_end_exp);
    V_after = V_end_exp+V_inspired;
    F_after = (F_before*V_end_exp+F_in*V_inspired)/V_after;
    assert(abs(sum(F_after)-1)<1e-10);
end
