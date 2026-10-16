# Gas dynamics model: source-derived function map

Generated from the uploaded 2026-10-15 debugging ZIP. **This is a static inventory, not proof of runtime execution or physiological correctness.** Explicit function calls using `name(...)` are detected; script-style calls and dynamic calls may be missing.

Files inspected: **60 MATLAB files**. Variables indexed: **936**.

## Main lung-update chain (to verify against runtime)

### `driver_to_beakedwhale_tissue_kin.m`
Explicit detected calls: `GET_DIVE_DATA_LOAD_TISSUE_KIN`, `GET_DIVE_SUMMARY_DATA_METABOLIC_RATES`, `SAVEDATA`, `beakedwhale_tissue_kinetics1`

### `beakedwhale_tissue_kinetics1.m`
Explicit detected calls: `GET_DIVE_DYNAMIC_ADL`, `GET_DIVE_ODBA`, `GET_GAS_FLUX_1`, `GET_O2_CO2_N2_PP`, `GET_VARIABLES_ZIP_NEW`, `saveTabWithHeader`

### `GET_VARIABLES_ZIP_NEW.m`
Explicit detected calls: `GET_VARIABLES_LUNG_COLL_ZIP`, `blood_Cco2`, `blood_Co2`, `muscle_Co2`

### `GET_VARIABLES_LUNG_COLL_ZIP.m`
Explicit detected calls: none detected

### `update_lung_gas.m`
Explicit detected calls: `blood_Cco2`, `blood_Co2`, `est_va`, `iteration_CO2_lung_search`, `iteration_N2_lung_search`, `iteration_O2_lung_search`

### `est_va.m`
Explicit detected calls: `N2_lung_coll`

### `N2_lung_coll.m`
Explicit detected calls: none detected

### `surface_breath_exchange.m`
Explicit detected calls: none detected

### `iteration_N2_lung_search.m`
Explicit detected calls: none detected

### `iteration_O2_lung_search.m`
Explicit detected calls: `blood_Po2`, `blood_lung_Po2`

### `iteration_CO2_lung_search.m`
Explicit detected calls: `blood_O2_sat`, `blood_Pco2`, `blood_lung_Pco2`

## Known questions for review

- Distinguish **total lung volume** from **alveolar** and **tracheal** volumes at each time step.
- Verify whether pressure is in atm, kPa, Pa, or mmHg at each function boundary.
- Confirm gas amounts versus gas partial pressures and any conversion through `RT`/`rt`.
- Identify every surface-condition reset in `update_lung_gas.m` and `est_va.m`.
- Trace `VLinit`, `VLinit0`, `VLprev`, and `Pint` through the breath event and subsequent iteration.
- Compare the current uncommitted source against the last working Git commit before changing code.
**AF comment (2026-10-15):**The units, if different from atm, should only be equation specific. The other confirmations seem reasonable.