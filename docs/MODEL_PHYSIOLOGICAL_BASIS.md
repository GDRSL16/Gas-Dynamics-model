# Gas dynamics model — physiological basis and assumptions

**Working draft v0.1 — 15 October 2026**  
**Source:** Uploaded current MATLAB source and PDF record of the earlier development conversation.  
**Purpose:** A physiologically oriented companion to `MODEL_TECHNICAL_DOCUMENTATION.md`. Statements marked **to verify** should not be treated as established published-model assumptions.

## 1. Scientific purpose

The model estimates respiratory gas kinetics during repeated breath-hold dives by linking changing ambient pressure, finite pulmonary gas stores, circulation, blood–gas exchange, tissue gas uptake/release, and metabolic oxygen consumption/carbon dioxide production. The current development objective is to replace the legacy assumption of imposed alveolar gas composition at every surface step with finite, discrete breathing events while retaining pressure-dependent lung mechanics and tissue kinetics.

## 2. Compartments and state variables

The MATLAB code tracks N2, O2 and CO2 in a lung compartment and exchanges these gases with blood and tissues. The principal lung gas state variables are partial pressure and gas amount (moles) in the fifth compartment of `N2_ARRAY`, `O2_ARRAY`, and `CO2_ARRAY`. The model separately tracks alveolar and tracheal volumes in `LUNG_VOL`, with total respiratory volume defined by their sum.

**Interpretation requiring review:** the gas stores are handled as a common lung gas pool in the current breath code, despite the mechanical model distinguishing alveolar and tracheal spaces. The validity of well-mixed gas during a breath and between breaths is a physiological assumption, not established by the array structure alone.

## 3. Initial gas stores

`GET_VARIABLES_ZIP_NEW.m` initializes alveolar gas tensions (`PN2_alv_init`, `PO2_alv_init`, `PCO2_alv_init`) and gas amounts using `n_gas=P_gas*V_LUNG/GAS_CONSTANT`. `ALV_SURFACE_VALUE` contains initial gas pressures and corresponding moles. Earlier code used fixed alveolar values at the surface; the revised approach aims to use these values only for initialization or as explicitly defined reference conditions.

**Important distinction:** initial *alveolar* gas composition is not the same as the composition of freshly inspired air. The development discussion assumes approximately 79% N2, 21% O2 and negligible CO2 in inspired dry air. Whether humidification and the chosen surface pressure have already been accounted for must be verified from units and pressure definitions.

## 4. Pressure, lung compression and alveolar collapse

The lung mechanics model in `N2_lung_coll.m` calculates alveolar volume `VL`, tracheal volume `VT` and internal pressure `Pint` as ambient pressure changes. Its root search (`fzero`) depends on the current reference volume `VLinit`, the previous alveolar-volume estimate `VLprev`, the tracheal reference volume `VTinit`, and structural parameters (`A1`–`A4`, `KP`, `NN`). A `FLAGGA` state distinguishes mechanics branches associated with tracheal collapse.

This means a breath is not simply a gas composition change: any post-breath change in total gas amount or reference lung volume can influence subsequent pressure–volume calculations. **To verify:** exactly which post-breath reference values preserve the intended pressure-volume mechanics.

## 5. Pulmonary exchange and shunting

`est_va.m` calculates a shunt estimate using alveolar volume as a fraction of `TAC`:

`lungratio = va/TAC; shunt = max(0, 1 - a*lungratio^b)`

with the current constants `a=1.495`, `b=0.320`, labeled in code as harbour-seal values. The `iteration_N2_lung_search.m`, `iteration_O2_lung_search.m`, and `iteration_CO2_lung_search.m` functions implement the gas-specific blood–lung updates, including shunt-dependent behavior.

**To verify:** whether the empirical shunt-volume relationship and its coefficients are intended for beaked whales, or are an inherited approximation from another species. The current breath branch substitutes temporary arterial equilibrium calculations rather than the normal iterative exchange: this must be justified or revised before scientific use.

## 6. Circulation and dive response

`GET_GAS_FLUX_1.m` changes perfusion and metabolism around dives using `adjust_Q_bradycardia.m`, `adjust_Q_tachycardia.m`, and `update_tissue_metabolic_rates.m`. Its logic uses dive-summary information and sonar state. The breath-event indicator `BREATH_FLAG` should be distinguished from the physiological dive response; a shallow no-breath interval is not automatically equivalent to a deep-dive bradycardic state.

**To verify:** how the surface interval, activity, dive-response flag and cardiac output interact at each time step; this matters because gas exchange continues between breaths.

## 7. Metabolism and tissue kinetics

The model updates oxygen, carbon dioxide and nitrogen in tissue and blood compartments, with tissue-specific perfusion, stores, and metabolic demand set by animal parameters and dive state. The functions `update_tissue_O2.m`, `update_tissue_CO2.m`, `update_tissue_N2.m`, and `update_tissue_metabolic_rates.m` provide the main pathways. These processes must remain active when the whale is at the surface but not breathing, if finite pulmonary gas exchange is the intended model.

**To verify:** compartment-specific units (e.g., mol versus concentration, time units for metabolic rates), dissolved versus bound gas representations, and numerical conservation across compartments.

## 8. Finite ventilation: proposed physiological specification

The scientific question is how to represent a breath as a **discrete event** in a continuously evolving finite pulmonary reservoir. The current experimental implementation assumes exhalation leaves a residual volume equal to `VTinit`, followed by inspiration of `V_BREATH`. It retains a proportional fraction of previous lung moles and adds inspired gas moles:

`V_residual = VTinit`

`n_residual = n_old * V_residual / V_old_total`

`n_inspired = F_inspired * P_surface * V_BREATH / RT`

`n_after = n_residual + n_inspired`

`V_after = V_residual + V_BREATH`

`P_gas_after = n_after * RT / V_after`

This is **what the unsuccessful uploaded code currently implements**, not an endorsed physiological model. It differs from the earlier stand-alone `surface_breath_exchange.m` helper, which assumes partial replacement at fixed gas-space volume. These two alternatives should be compared rather than combined without justification.

### Questions for physiological review

1. What is the appropriate *end-expiratory* lung volume in a diving cetacean, and should it be fixed or vary with the prior state?
2. Is the gas expelled during exhalation a representative, well-mixed fraction of the lung, or is sequential emptying relevant?
3. What volume does `V_BREATH` represent: inhaled volume, exchanged volume, or a fraction of total/alveolar capacity?
4. Should the post-inspiratory lung volume equal `VLmax`, be less than `VLmax`, or depend on an animal-specific breath amplitude?
5. How should the updated gas amount modify `VLinit`, `VLprev` and `Pint` without double-counting gas loss from the preceding dive?
6. Does pulmonary exchange continue throughout a one-second breath time step, or is the event treated as instantaneous at a chosen point within that step?
7. How should the tracheal dead-space volume contribute to mixing and effective alveolar ventilation?
8. What is the correct handling of gas humidity and dry inspired gas fractions when converting partial pressure to moles?
9. How should repeated breaths produce hyperventilation or hypoventilation without imposing fixed alveolar PO2/PCO2?

## 9. References visible in the source (not bibliographically verified)

The source comments cite, among others: Zimmer et al. (2007); Miller et al. (2016); Kooyman et al. (1972; 1973); Stephenson (JEB 2005); and a “Brian paper” for the shunt relation. These are **code-comment attributions only**. Exact bibliographic details, applicability to beaked whales, and which equations each publication supports remain to be checked against the original papers. Do not convert these mentions into formal citations without verification.

## 10. Next review and acceptance criteria

First confirm the intended breathing physiology and units. Then document a testable specification that conserves gas moles during exhalation/inhalation, uses internally consistent gas volumes and pressure units, and preserves gas exchange during no-breath surface intervals. Only after these choices are explicit should the development branch be revised and compared with the archived model.

**Change log:** v0.1 initial source-grounded documentation, 2026-10-15. Not reviewed against publications or validated by running MATLAB.
