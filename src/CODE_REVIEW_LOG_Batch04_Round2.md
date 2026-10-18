# Second-round code review — Batch 04

Review date: 2026-10-18

Scope: Add targeted internal documentation and review prompts. No executable MATLAB statements changed. No legacy code removed. No calculations, signatures, control flow, or variable names altered.

| File | Original SHA-256 | Review focus |
|---|---|---|
| `blood_Po2.m` | `a494cae95cf7cda1f157b50c44cc3f67dc08697c071a6530e2da13372dcf5315` | Gas content, saturation, tension, or acid-base helper. Confirm whether the input is pressure, content, saturation or moles and record units from the actual implementation. |
| `blood_lung_Pco2.m` | `8fa7b890c972b37fd37e038421005c5a5d2f61cbcdbc307d930bc43672fe1d9c` | Gas content, saturation, tension, or acid-base helper. Confirm whether the input is pressure, content, saturation or moles and record units from the actual implementation. |
| `blood_lung_Po2.m` | `fb1082833092191f682c2adf3c39f4e669bfd4711221c795d954837e0dda9d66` | Gas content, saturation, tension, or acid-base helper. Confirm whether the input is pressure, content, saturation or moles and record units from the actual implementation. |
| `blood_pH.m` | `409c3453fb6b0e9a39b3a1659389b0c008e7b8de178fa4b84a0bbb950e0d7b6a` | Gas content, saturation, tension, or acid-base helper. Confirm whether the input is pressure, content, saturation or moles and record units from the actual implementation. |
| `blood_tiss_Pco2.m` | `64afcc694ef9d99a1877a44c9dfcdef7645f266f5ec8a3338a2aac759c0160fa` | Gas content, saturation, tension, or acid-base helper. Confirm whether the input is pressure, content, saturation or moles and record units from the actual implementation. |
| `blood_tiss_Po2.m` | `f50d2fffcb42f6534378bc09e897c20b42201c1180ce7cbb3c8c3a7e66b0ce83` | Gas content, saturation, tension, or acid-base helper. Confirm whether the input is pressure, content, saturation or moles and record units from the actual implementation. |
| `blood_tiss_mus_Po2.m` | `3c8c847606fd339adc85460dbfbb368eb8af622d7f3ef85d099a524bd6427df8` | Gas content, saturation, tension, or acid-base helper. Confirm whether the input is pressure, content, saturation or moles and record units from the actual implementation. |
| `driver_to_beakedwhale_tissue_kin.m` | `f759f37c4ef9254fb165042d934a6eb4287d799afabbfa6563cd7d186dd184b1` | Review input/output dimensions, global state, units and call-site assumptions before further refactoring. |
| `est_va.m` | `0ef4a21bcb26a2e77a654edcf85729386aa600ef08eb1237b3af3213dd5f7ac5` | Alveolar volume estimation. Distinguish tracheal and alveolar gas volumes and check consistency with pressure-dependent collapse. |
| `extract_N2_tensions.m` | `3c6422c64301befadde46a0bb8ed110a9c7f13f22ba2d34d3ba3a658ec1aa28a` | Post-processing extraction. Verify array indexing, output units and assumptions about dive boundaries. |

## Verification
- Original file bytes are preserved after the new comment header.
- Run whale 12 with identical parameters and breath schedule.
- Compare the new SUMMARY_ARRAY to the frozen original baseline before committing.

## Deferred detailed review
- Inspect legacy comments and dead-code candidates manually; none removed here.
- Extract precise parameter definitions and equations in a separate source-audited pass.
