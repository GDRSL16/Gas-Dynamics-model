# Gas dynamics model — technical documentation

**Working draft v0.1 — 15 October 2026**  
**Source:** `Gas-dynamics-model-2026-10-15-debug.zip..zip` (uncommitted, unsuccessful development snapshot).  
**Status:** Code-reading documentation; NOT a validated or executable release. Do not use this draft to infer that the revised breath model works.

## 1. Scope and reading guide

This document describes the uploaded beaked-whale MATLAB implementation as written. It distinguishes **observed code**, **interpretation**, and **items to verify**. Original published/legacy behavior is described only where identifiable in the current code or in the supplied conversation PDF; the untouched legacy repository was not independently diffed against this snapshot.

## 2. Entry point and model sequence

- `driver_to_beakedwhale_tissue_kin.m`: driver for input records and model runs.
- `GET_DIVE_DATA_LOAD_TISSUE_KIN.m` and `GET_DIVE_SUMMARY_DATA_METABOLIC_RATES.m`: import time-series and summary inputs.
- `beakedwhale_tissue_kinetics1.m`: initializes arrays, ambient pressure and simulation context, calls the gas kinetics pathway.
- `GET_VARIABLES_ZIP_NEW.m`: animal-specific gas stores, tissue volumes, circulation, blood parameters and initial lung gases; invokes `GET_VARIABLES_LUNG_COLL_ZIP.m`.
- `GET_GAS_FLUX_1.m`: principal time-step loop, including dive-response adjustments and gas transport.
- `est_va.m` → `N2_lung_coll.m`: alveolar volume, tracheal volume, internal pressure, and shunt.
- `update_lung_gas.m` → `iteration_N2_lung_search.m`, `iteration_O2_lung_search.m`, `iteration_CO2_lung_search.m`: pulmonary gas composition and blood-gas updates on no-breath steps.
- `update_tissue_N2.m`, `update_tissue_O2.m`, `update_tissue_CO2.m`: tissue exchange routines; `SAVEDATA.m` and other helpers produce outputs.

**Note:** The call chain is a navigation aid, not a verified complete ordering of every operation. Use the line-by-line time-step sequence when changing the model.
**AF comment (2026-10-15):** One important point, this alters perfusion during diving vs surface. It only alters the perfusion at the end and beginning of a dive and the level of change is set by the dive duration in the summary file. Here, we can "alter" what is considered a dive in the summary file and then the program will alter the dive response. This will not have any effect, I think, on gas exchange at the surface. We could, for example, during a breath. Send the animal to the surface, take the breath, and then go down again like it is "diving" but with renewed gas and still call that surface. 

## 3. Arrays and indexing

The three gas state arrays are `N2_ARRAY`, `O2_ARRAY`, `CO2_ARRAY`. In `update_lung_gas.m`, `GAS_ARRAY(i-1,5,1)` supplies the previous lung gas partial pressure and `GAS_ARRAY(i-1,5,2)` supplies previous lung gas amount (moles). The same slots at row `i` receive updated values. Other compartments and array dimensions require a dedicated indexing audit.

`LUNG_VOL(i,1)` is alveolar volume; `(i,2)` tracheal volume; `(i,3)` internal pressure; `(i,4)` ambient pressure; `(i,5)` shunt. The current `beakedwhale_tissue_kinetics1.m` documents this convention. **Unit caution:** `(i,3)` is assigned `Pint` in kPa-like units, and `(i,4)` is assigned `P_AMB(i)*101.3` in `est_va.m`, whereas `N2_lung_coll.m` assigns `(i,4)=PAMB` where `PAMB` is its kPa input. Check consistency across paths.

**AF comment (2026-10-15):** here units varies among equations so care need to be taken to not use these as GLOBAL. For example, the calculation of lung compression was written using kPa so care need to be taken as depth is in ata.

## 4. Lung-volume variable dictionary (verified assignments)

| Variable | Meaning in current code | Units (inferred; verify) | Where set or changed |
|---|---|---|---|
| `M_B` | Body mass | kg | `GET_VARIABLES_ZIP_NEW.m` |
| `V_LUNG` | Animal initial lung gas volume | L | `GET_VARIABLES_ZIP_NEW.m`: `25*M_B/1000` |
| `VLmax` | Maximum total respiratory volume | L | `GET_VARIABLES_LUNG_COLL_ZIP.m`: `25*M_B/1000` |
| `VTmax` | Maximum tracheal/dead-space volume | L | same: `0.0667*VLmax` |
| `TAC` | Total alveolar capacity | L | same: `VLmax-VTmax` |
| `VTinit` | Reference tracheal volume | L | same: `VTmax` |
| `VLinit0` | Reference initial alveolar volume | L | same: `V_LUNG-VTmax` |
| `VLinit` | Variable reference alveolar volume used by collapse calculation | L | initialized in lung setup; overwritten by breath handling in `est_va.m` and by gas-ratio calculation in `update_lung_gas.m` |
| `VLprev` | Previous/initial guess alveolar volume for root search | L | initialized in lung setup; updated in `N2_lung_coll.m`; reset during breath in `est_va.m` |
| `Pint` | Internal lung pressure | likely kPa | initialized in lung setup; updated in collapse function; reset during breath in `est_va.m` |
| `V_BREATH` | Inspired volume on breath event | L | `GET_VARIABLES_ZIP_NEW.m`: `BREATH_FRACTION*TAC` |
| `BREATH_FRACTION` | Fraction applied to `TAC` | dimensionless | `GET_VARIABLES_ZIP_NEW.m`: `1.0` |
| `BREATH_FLAG` | Time-step breath event indicator | 0/1 | simulation initialization/inputs; read by `est_va.m` and `update_lung_gas.m` |
| `ALV_SURFACE_VALUE` | Initial imposed alveolar gas partial pressures and moles | mixed: pressures and mol | `GET_VARIABLES_ZIP_NEW.m` |

**Critical:** In this snapshot `V_BREATH = BREATH_FRACTION*TAC`, **not** `BREATH_FRACTION*V_LUNG`. With `BREATH_FRACTION=1`, `V_BREATH` is 46.665 L for `M_B=2000 kg`, while `VLmax` is 50 L and `VTmax` is 3.335 L. The naming and choice of reference volume must be settled physiologically.

**AF comment (2026-10-15):**The units for Pint_init and Pint are kPa, BREATH_FLAG not yet used. I agree, we need ti "fix" these volumes once and for all and then reorganize them and make sure they are not "altered" somewhere.

**AF decision (2026-10-15):**Go through code and fix this at the end. Alternatively, fix first before we introduce new code.

## 5. Pressure and gas units: audit required

`P_AMB` is described in comments as ambient pressure in ATA with water-vapor correction. `N2_lung_coll.m` receives `P_AMB(i)*101.3`, indicating conversion to kPa. The parameter `Pint_init=95.009576964007664` is commented as kPa after subtracting water vapor. The gas conversion `n = P*V/GAS_CONSTANT` and breath update `n = P*V/rt` require consistent pressure, volume and temperature units. Do not assume all `P_*` variables are in the same unit: code comments also mention mmHg for initial alveolar gas tensions.

**Audit checklist:** record the value, unit, and conversion of `GAS_CONSTANT`, `rt`, `P_AMB`, `SURFACE_VALUE`, `PN2_alv_init`, `PO2_alv_init`, `PCO2_alv_init`, `Pint_init`, and every blood-gas pressure passed between functions.

**AF comment (2026-10-15):** Yes, we need to make sure that functions that need units in kPa, or mmHg are only inside those functions and those pressures are not passed out. This should have worked in the initial program 

## 6. Existing finite-breath branch — code as uploaded

`est_va.m` on `BREATH_FLAG(i)==1`:

1. Reads previous total gas-space volume from `LUNG_VOL(i-1,1:2)`.
2. Defines retained residual gas-space volume `V_residual=VTinit`.
3. Sets `V_inspired=V_BREATH` and rejects `V_residual+V_inspired>VLmax`.
4. Sets post-breath total volume `V_final=V_residual+V_inspired`, alveolar volume `V_final-VTinit`, tracheal volume `VTinit`.
5. Sets `VLinit` and `VLprev` to the new alveolar volume, `Pint=Pint_init`, `FLAGGA=0`; calculates shunt from `va/TAC`.

`update_lung_gas.m` on the same breath step:

1. Reads previous gas moles `n_old` for N2/O2/CO2.
2. Assumes exhalation leaves `n_residual=n_old*(VTinit/V_old_total)`.
3. Adds inspired moles `n_inspired=F_INSPIRED*SURFACE_VALUE*V_BREATH/rt`.
4. Sets `n_new=n_residual+n_inspired`, then partial pressures `P_lung=n_new*rt/V_final`.
5. Uses **temporary perfect-equilibrium** arterial calculations, bypassing the usual iterative blood–lung pathway on breath steps.

On non-breath steps it invokes all three `iteration_*_lung_search` functions. It also computes `VLinit=VLinit0*(current total lung moles)/(initial total lung moles)` **only if** `P_AMB(i)>P_AMB(1)`.

`surface_breath_exchange.m` also exists as a standalone mixing helper, but `update_lung_gas.m` contains a separate breath calculation. The two implementations are not identical: the helper uses fractional replacement in a fixed gas space, whereas the active branch models exhalation to `VTinit` followed by inspiration. This is a potential source of conceptual drift.
**AF comment (2026-10-15):** That is where we could start to check. The "volume" here needs to be correct and updated in the lung array and also the moles of the gases.

## 7. Priority technical issues before another simulation

1. **Mass and volume consistency:** assess whether exhaling to `VTinit` is intended, whether the remaining moles/volume are at a consistent pressure, and whether the post-breath volume represents a true physiological end-inspiratory volume.
2. **State-update ordering:** determine whether `est_va` runs before `update_lung_gas` in each step, and how `VLinit`, `VLprev`, `Pint`, `LUNG_VOL` and lung gas arrays are synchronized.
3. **Reference-state mismatch:** `VLinit` on non-breath underwater steps is calculated relative to time-step 1, not the latest breath. Assess the intended reference for repeated breaths.
4. **Surface no-breath behavior:** the finite-iteration pathway should work at surface pressure, but requires numerical and physiological testing.
5. **Blood exchange during a breath:** current branch uses a temporary perfect-equilibrium arterial calculation instead of the normal shunt-sensitive iteration.
6. **Pressure/volume units:** audit pressure units, gas constant, and volume units before interpreting a 45.8 L versus 50 L result.
7. **Debugging code:** `GET_GAS_FLUX_1.m` currently contains `MAX_TEST_STEPS=1000` and a shortened loop; document this as a debug setting, not full-model behavior.
8. **NaN test:** `est_va.m` contains `if va==NaN`, which will not detect NaNs in MATLAB; use `isnan(va)` when revising debug checks.

## 8. Suggested validation tests (not yet run)

- Initialize a 2000 kg whale; print `V_LUNG`, `VLmax`, `VTmax`, `TAC`, `VLinit0`, `V_BREATH` with units.
- Run one no-breath step at fixed surface pressure and verify that lung gas changes only via modeled exchange.
- Run one breath with zero gas exchange and check gas-mole accounting before/after exhalation and inspiration.
- Run multiple breaths separated by no-breath steps and check pressure, volume, `VLinit`, `VLprev` and `Pint` continuity.
- Compare results at 0, 0.1 and 0.3 m equivalent pressures; distinguish pressure effects from ventilation effects.
- Compare current code against the archived baseline on a short identical input, not a full two-hour run.
**AF comment (2026-10-15):** These were run and do not work, the volume is not updated. We need to look at this and see where this fails. Also, we need to consider if we need V_BREATH or if that can be an experiment. 

## 9. Provenance and review notes

This is documentation of the uploaded **failed experimental snapshot**, not a verified model specification. Equations quoted above are literal code expressions; physiological interpretations are provisional. Add a `Last reviewed` date and reviewer notes as definitions are confirmed. Preserve the original code and the unsuccessful ZIP for traceability.
**AF comment (2026-10-15):**I can upload this code again if that helps?
