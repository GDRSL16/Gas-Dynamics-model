# Second-round code review — Batch 03

Review date: 2026-10-18

Scope: Add targeted internal documentation and review prompts. No executable MATLAB statements changed. No legacy code removed. No calculations, signatures, control flow, or variable names altered.

| File | Original SHA-256 | Review focus |
|---|---|---|
| `SAVEDATA.m` | `4724d73199e60effe4164c0cf4dc2d6173d1c5e4ec90bf55e8074fcbb38ba60c` | Output writer. Preserve the existing header/column order and file formatting because SUMMARY_ARRAY files are regression-test references. |
| `adjust_Q.m` | `889c081fc30b16101c1edcb3975cef54783bc40a46913af9b6da553fb8705b0b` | Circulatory adjustment. Document how cardiac output/perfusion changes with dive response while retaining original conditionals. |
| `adjust_Q_bradycardia.m` | `47a4629ddca191d50c2a982be82d81d7e5e8032780041b119348d455d9170a34` | Circulatory adjustment. Document how cardiac output/perfusion changes with dive response while retaining original conditionals. |
| `adjust_Q_tachycardia.m` | `0dfe073c0741eb19492222d0141773ae9c680860e7cc42208988fe205c71bc2f` | Circulatory adjustment. Document how cardiac output/perfusion changes with dive response while retaining original conditionals. |
| `batchSaveWithHeaders_example.m` | `4fcc2c4350eb24eb0a215a8a458fa061e8d59550ad9a28ed2ea547d1edb62124` | Output utility. Preserve exact data formatting and file naming used by downstream scripts. |
| `beakedwhale_tissue_kinetics1.m` | `ce482d910df14432535fc156ae0d3bdae0ae57966e3054bfe1aa63d1978acc5d` | Main simulation time-step controller. Breath scheduling, pressure updates, and tissue/blood exchange ordering are scientifically important; preserve their execution order. |
| `blood_Cco2.m` | `e62e2798bc7716e58af5318037069af5d1cba951727ba5c31a37c2e7b336e492` | Gas content, saturation, tension, or acid-base helper. Confirm whether the input is pressure, content, saturation or moles and record units from the actual implementation. |
| `blood_Co2.m` | `b5b1a203b170ac854d94269b7c8bc4dda670bf7e7385e1ce2d87881782a038f6` | Gas content, saturation, tension, or acid-base helper. Confirm whether the input is pressure, content, saturation or moles and record units from the actual implementation. |
| `blood_O2_sat.m` | `f23c1275e2f55ad4b3aaac989f5a0728a5bcb61b45b45dcfff7f3045d17dff67` | Gas content, saturation, tension, or acid-base helper. Confirm whether the input is pressure, content, saturation or moles and record units from the actual implementation. |
| `blood_Pco2.m` | `99be87528c5c379d7a5c4826d3e5595b01d4405054f82fa52616fb30c3edb264` | Gas content, saturation, tension, or acid-base helper. Confirm whether the input is pressure, content, saturation or moles and record units from the actual implementation. |

## Verification
- Original file bytes are preserved after the new comment header.
- Run whale 12 with identical parameters and breath schedule.
- Compare the new SUMMARY_ARRAY to the frozen original baseline before committing.

## Deferred detailed review
- Inspect legacy comments and dead-code candidates manually; none removed here.
- Extract precise parameter definitions and equations in a separate source-audited pass.
