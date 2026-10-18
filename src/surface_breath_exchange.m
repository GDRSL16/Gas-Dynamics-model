% ============================================================
% Documentation review: 2026-10-18 | Batch 06
% File: surface_breath_exchange.m
% Function signature: n_new = surface_breath_exchange( ...
% Scope: documentation only; numerical model unchanged.
% Original source preserved verbatim below this header.
% ============================================================
function n_new = surface_breath_exchange( ...
    n_old, V_gas, V_breath, P_inspired, RT, inspired_fraction)
%SURFACE_BREATH_EXCHANGE Mix inspired gas into the existing lung gas.
%
% n_old            1x3 vector: [N2 O2 CO2] moles before the breath
% V_gas            gas-space volume
% V_breath         volume exchanged during the breath
% P_inspired       inspired gas pressure
% RT               gas constant multiplied by absolute temperature
% inspired_fraction 1x3 vector: [fraction N2, fraction O2, fraction CO2]
%
% n_new             1x3 vector: [N2 O2 CO2] moles after the breath

    if V_gas <= 0
        error('V_gas must be greater than zero.');
    end

    if V_breath < 0
        error('V_breath cannot be negative.');
    end

    if V_breath > V_gas
        error('V_breath cannot be greater than V_gas.');
    end

    if abs(sum(inspired_fraction) - 1) > 1e-10
        error('Inspired gas fractions must sum to one.');
    end

    exchanged_fraction = V_breath / V_gas;

    n_inspired = inspired_fraction .* P_inspired .* V_gas ./ RT;

    n_new = (1 - exchanged_fraction) .* n_old ...
          + exchanged_fraction .* n_inspired;
end