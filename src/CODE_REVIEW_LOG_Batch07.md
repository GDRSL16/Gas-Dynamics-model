# MATLAB code documentation review - Batch 07

Review date: 2026-10-18
Scope: documentation-only; original source retained byte-for-byte after new header.
Validation: pending whale 12 SUMMARY_ARRAY comparison.

| File | Original SHA256 | Function signature |
|---|---|---|
| `update_tissue_CO2.m` | `2efc544893df9880eccd90a3948c2a0c925ad55c20ca2a46af32dc3c3e25777b` | `[n_CO2_ven_t,P_CO2_ven_t]=update_tissue_CO2(Pamb,i,pect,rt);` |
| `update_tissue_metabolic_rates.m` | `c5524e192b6d1980224edf8200ae100c60bba689cacdcf2283191f574ad47cfc` | `update_tissue_metabolic_rates(row, multiplier_ht, multiplier_mus, multiplier_brain, multiplier_fat, dive_no, dive_response_flag)` |
| `update_tissue_N2.m` | `917cbc05c9e458e019bd37bbfe9c0f9878f9cf398161d429d0c7a927fe7443d6` | `[n_N2_ven_t,P_N2_ven_t]=update_tissue_N2(Pamb,i, pect,rt);` |
| `update_tissue_O2.m` | `c47bd392608e6548a528c545b0adfceb52879fd5596e4cd26afade256018848e` | `[n_O2_ven_t,P_O2_ven_t]=update_tissue_O2(Pamb,i,pect,rt);` |

## Verification
1. Replace only this batch of MATLAB files in src.
2. Run whale 12 using the same settings and breath schedule.
3. Upload the new SUMMARY_ARRAY for comparison against the original baseline.
4. Commit only after a zero-difference comparison.

## Review scope
This is a conservative header/documentation pass. Existing executable statements and legacy comments are unchanged.
Any further legacy comment cleanup should be reviewed and tested separately.
