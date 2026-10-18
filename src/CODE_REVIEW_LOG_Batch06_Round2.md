# Second-round code review — Batch 06

Review date: 2026-10-18

Scope: Add targeted internal documentation and review prompts. No executable MATLAB statements changed. No legacy code removed. No calculations, signatures, control flow, or variable names altered.

| File | Original SHA-256 | Review focus |
|---|---|---|
| `saveTabWithHeader.m` | `04487327d74efa439882bba5dea21e3ee5abc0224a1efd3650a9680c6864c4d6` | Output utility. Preserve exact data formatting and file naming used by downstream scripts. |
| `surface_breath_exchange.m` | `4a932b427572ffd8e6d7bfd35dfeb1673ff7af0cd09abcec124b1453c568867e` | Finite surface breath operation. Track retained gas, exhaled gas, inspired gas and final gas composition; no changes to the current mixing assumptions. |
| `test_lung_blood_gas_transition.m` | `e6576e6540595e48d142e470510bc1fd465973f3bb6e09620d05542e25e6d7e2` | Diagnostic test script. This test does not replace a whole-model conservation check or a baseline regression comparison. |
| `test_lung_gas_transition.m` | `f9d7289c685a2a52e0920455a18b621513fdb1a6855f2487701a4a21ff25c715` | Diagnostic test script. This test does not replace a whole-model conservation check or a baseline regression comparison. |
| `update_CO2_case_A_or_C.m` | `850854cf0d91aecadd778ad16b88292273215cbcafbc771c5db76087df3c542a` | Gas-specific lung/blood exchange branch. Case selection and gas flux sign conventions should be documented against the corresponding physiological equations. |
| `update_N2_case_A_or_C.m` | `6205cad583a34d8595ab48446a7f7d72f5e7be9a44ff9c454144205c81fb19c4` | Gas-specific lung/blood exchange branch. Case selection and gas flux sign conventions should be documented against the corresponding physiological equations. |
| `update_O2_case_A_or_C.m` | `37fcdffcf6fe825ec477856f37dc8f281a3ee74a52b57f2ec5a1ebefba89fda2` | Gas-specific lung/blood exchange branch. Case selection and gas flux sign conventions should be documented against the corresponding physiological equations. |
| `update_lung_gas.m` | `dab2cd60bd717f1000359543d9eeaddb575f930bc47da01b92f566a8129166da` | Lung gas inventory and breath-event update. Distinguish ventilation additions/removals from blood-lung exchange; pressure and volume consistency are separate checks. |
| `update_tissue_CO2.m` | `35edbabbc7e072598f34a0b514b50839dfee02222029465edac85cadf70253dd` | Carbon dioxide tissue exchange. Distinguish gas transfer from metabolic CO2 production and buffering assumptions. |
| `update_tissue_N2.m` | `eb1dfa5152e8b5f7573363055a836d3ef27e68b6e49585e8140c66445a7a0477` | Nitrogen tissue exchange. Distinguish tissue partial pressure from stored gas moles and retain existing perfusion/diffusion assumptions. |

## Verification
- Original file bytes are preserved after the new comment header.
- Run whale 12 with identical parameters and breath schedule.
- Compare the new SUMMARY_ARRAY to the frozen original baseline before committing.

## Deferred detailed review
- Inspect legacy comments and dead-code candidates manually; none removed here.
- Extract precise parameter definitions and equations in a separate source-audited pass.
