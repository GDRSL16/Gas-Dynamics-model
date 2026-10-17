# Change log and validation plan

## Cleaned-only version
- Added function-level explanations of assumptions, units, and array conventions.
- Added MATLAB `%%` section headings to `GET_VARIABLES_ZIP_NEW.m` to group parameters, metabolic rates, initial gas stores, lung gas, and circulation.
- Kept all original executable statements and their order. Did not remove legacy globals, numerical warnings, or existing debug/validation checks.
- Did not modify `N2_lung_coll.m` or the exact-surface branch of `est_va.m`.

## Flexible version (functional change)
- Added globals `EXHALED_FRACTION` and `INHALED_FRACTION` to initialization and lung update.
- Set both to 1.0 by default in `GET_VARIABLES_ZIP_NEW.m`.
- Exhalation: `V_exhaled = EXHALED_FRACTION*(V_old-VTinit)`; retained moles scale by `(V_old-V_exhaled)/V_old`.
- Inspiration: convert retained moles to surface-equivalent volume `V_remaining = sum(n_remaining)*rt/P_AMB(i)`; then `V_inspired = INHALED_FRACTION*max(0,VLmax-V_remaining)`.
- Retained gas plus inspired moles define final volume and partial pressures; preserve all existing validation checks.
- Input checks reject fractions outside [0,1] and retained-gas states that already exceed TLC.
- **Potential limitation:** a zero or small inhalation can expose pre-existing pressure/volume inconsistencies; if retained gas corresponds to less than VTinit at ambient pressure, the existing lower-volume bound can stop the simulation. Do not silently clamp or change moles.

## Scientific assumptions to document
1. Alveolar and tracheal gas are well mixed for the breath calculation, while mechanically distinct volumes remain.
2. Instantaneous arterial gas equilibration is inherited from legacy surface routines; perfusion/diffusion limitations are not resolved.
3. No explicit lung-to-arterial mass-transfer debit occurs during the breath reset; the ventilation mole check is not a whole-model mass-balance validation.
4. No-breath lung gas exchange continues at the surface; the current exact-surface branch in `update_lung_gas.m` preserves prior volume and sets shunt to zero.
5. `VLinit` in the no-breath pathway still scales against the row-1 lung gas content. This was retained unchanged and warrants a separate sensitivity check.

## Test order
1. Compare cleaned-only model to the committed baseline using identical breath rows and inputs: all numerical arrays should match.
2. Test flexible version at `EXHALED_FRACTION=1`, `INHALED_FRACTION=1`; compare breath moles, pressures, and volumes against the baseline (allow numerical tolerance).
3. Test 0.75, 0.5 and 0.25 independently for each fraction; inspect final volume, O2/CO2/N2, and no-breath continuation.
4. Check that zero exhalation and zero inhalation behave as expected or stop with a clear constraint error.
5. Preserve both tested code and figures in GitHub before further model changes.
