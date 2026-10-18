# MATLAB code documentation review - Batch 06

Review date: 2026-10-18
Scope: documentation-only; original source retained byte-for-byte after new header.
Validation: pending whale 12 SUMMARY_ARRAY comparison.

| File | Original SHA256 | Function signature |
|---|---|---|
| `muscle_Co2.m` | `28915cfd7ea2a5cb1d8b2015ac4763d02c8fcc4029eb6d0238cb2ae6170b951d` | `y=muscle_Co2(po2)%units returned is l gas  (Body temperature standard pressure dry) per l muscle` |
| `plot_dive_summary.m` | `f2b927ce4afa562d5c8d34d6a77b2df1ec00a56952eec41a5054f5951672197f` | `plot_dive_summary(whichRun, folder)` |
| `saveTabWithHeader.m` | `342a49650f20cd6070141cc3129347fec8d5b32052e987a7180395cd097b89ae` | `saveTabWithHeader(filename, data, headerRows, varargin)` |
| `surface_breath_exchange.m` | `dc5dba50e3c941494f1305ac3272c22b0203576dc1878e15680997a340c2d312` | `n_new = surface_breath_exchange( ...` |
| `test_lung_blood_gas_transition.m` | `0c6e8a6b3896b6adf8ce92a1a52195252e039998e644ac50e7b4cff16fb87003` | `(MATLAB script; no function declaration)` |
| `test_lung_gas_transition.m` | `992b0afd2457886a4974025aeb575d0d5f0bdb1053f0f43d6fe04c4d44e637a9` | `(MATLAB script; no function declaration)` |
| `update_CO2_case_A_or_C.m` | `c85ec2660e48d262173f0e5754e2981d26b9af41ce210dfe81854b69839cadbb` | `[P_CO2_lung_t,n_CO2_lung_t,P_CO2_art_t,n_CO2_art_t]=update_CO2_case_A_or_C(Vblood, sCO2_blood,rt,breath_gas);` |
| `update_lung_gas.m` | `defbfebf61b599a458ed4d0fd4fe1fe4f55487a4811dc84a7136645dfa3bbfa1` | `[n_N2_art_t,P_N2_art_t,n_O2_art_t,P_O2_art_t, n_CO2_art_t,P_CO2_art_t]=update_lung_gas(Pamb,i,pect)` |
| `update_N2_case_A_or_C.m` | `ec4d4ef4bd5a5eb59275cee7ced7789f84bef32538f0e8f6e5598c97621a559d` | `[P_N2_lung_t,n_N2_lung_t,P_N2_art_t,n_N2_art_t]=update_N2_case_A_or_C(Vblood, sN2_blood,rt,breath_gas);` |
| `update_O2_case_A_or_C.m` | `1d372d062d1553b31c43621a33fd6fb41e76eeeb0f592ce9c968d648cb03893f` | `[P_O2_lung_t,n_O2_lung_t,P_O2_art_t,n_O2_art_t]=update_O2_case_A_or_C(Vblood, sO2_blood,rt,breath_gas);` |

## Verification
1. Replace only this batch of MATLAB files in src.
2. Run whale 12 using the same settings and breath schedule.
3. Upload the new SUMMARY_ARRAY for comparison against the original baseline.
4. Commit only after a zero-difference comparison.

## Review scope
This is a conservative header/documentation pass. Existing executable statements and legacy comments are unchanged.
Any further legacy comment cleanup should be reviewed and tested separately.
