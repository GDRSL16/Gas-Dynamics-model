# MATLAB code documentation review

Review date: 2026-10-18
Batch: 03 (10 files)
Scope: header documentation only; all original file bytes follow each new header unchanged.
Validation: pending whale 12 SUMMARY_ARRAY comparison.

| File | Original SHA256 | Note |
|---|---|---|
| `LOAD_SUMMARY_DATA.m` | `b95f88e4d707556ccdf437a4e09f66c1c4418a5592df0b9224743541d520ce5d` | Uses a graphical file selector; the original comments describe the summary columns. |
| `Muscle_MbO2_sat.m` | `ad60b08ec3eced48921ddf91607f5dc30fc4c2b76d02c7768a45b462055d9699` | Uses global P50_MB and BETA_0_MB; no Bohr adjustment is applied. |
| `N2_extract_before_EOD.m` | `6d1f5860e9acb9081577611579a920316bc6284e13187038acb52fa556b948f8` | Original code assumes a two-second sampling interval; verify source-data alignment. |
| `N2_lung_coll.m` | `2b89d097c57f8b2d52787accf80414e55c22d17a99ff72b6a0276eae5cf18220` | Ambient pressure is documented as absolute kPa; relies on model-wide global lung variables. |
| `O2_saturation.m` | `65e5154f7d0de5af31279776f8277005595b550c15c93cf22ef686035b7f128a` | WARNING: source contains incomplete expression PO2=; and references undeclared PCO2. Preserved without repair. |
| `SAVEDATA.m` | `b37f84ebd6d4a45230b4c10551e72cb53a62a4cca43944f584c1ddd638fdb421` | Function declaration uses savedata while filename is SAVEDATA.m; preserve original behavior and check usage before refactoring. |
| `Vtot.m` | `6ff3b362bef32a271ca64bfdec0fc79ac7549e0565815fd1d78d867e1a14c51d` | WARNING: body uses T_TIS rather than input T_tis; preserved for later investigation. |
| `adjust_Q.m` | `31d42e67592062e603a09245a22fbcf3f061657555f87f96393e03be10397f21` | Uses global blood package sizes and flow variables; package counts can change with perfusion. |
| `adjust_Q_bradycardia.m` | `55e781ef10ffb4c21ffbd98df271da58d21200b883017f36b348fbb8c4f8a80e` | Uses globals to update circulation state; no numerical statements modified. |
| `adjust_Q_tachycardia.m` | `bb3f958661c6cb0b7dee6085fe631092b469532176dd794afee70f1610d4915b` | Uses globals to update circulation state; no numerical statements modified. |

## Validation procedure
1. Replace only these 10 files in src.
2. Run the same whale 12 case with the unchanged breath schedule and parameters.
3. Save the output as `12-Zica-SUMMARY_ARRAY-batch3.txt`.
4. Compare all rows and columns with the original baseline before committing.

## Follow-up findings
- `O2_saturation.m` contains an incomplete assignment (`PO2=;`) in the original source.
- `Vtot.m` references `T_TIS` instead of its declared input `T_tis`.
- `SAVEDATA.m` declares `savedata` as its function name; case behavior may vary by platform.
These issues are **not fixed** in this documentation-only batch.
