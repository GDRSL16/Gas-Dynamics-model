# Second-round code review — Batch 02

Review date: 2026-10-18

Scope: Add targeted internal documentation and review prompts. No executable MATLAB statements changed. No legacy code removed. No calculations, signatures, control flow, or variable names altered.

| File | Original SHA-256 | Review focus |
|---|---|---|
| `GET_VARIABLES_LUNG_COLL_ZIP.m` | `b515a921b6ed0c00fa6e0266ce4af3a528512810068c8c20d265e872505b8e3e` | Lung-collapse parameter initialization. Distinguish geometric volumes, pressures, and shunt-related quantities when documenting equations. |
| `GET_VARIABLES_ZIP_NEW.m` | `44554a58e5f41449edd1a3935c7bb392aa0e0132ca3b5c3d493bd7f1b3e83a17` | Model parameter and state initialization. Check units and global-variable ownership against the variable dictionary; do not assume every assigned quantity is constant over a dive. |
| `GET_odba_summary_N2.m` | `b0d5013975a951c7907b0c735dcec4e7f86c341b193b63c87a60821b601f4e21` | Review input/output dimensions, global state, units and call-site assumptions before further refactoring. |
| `LOAD_DEPTH_DATA.m` | `6a3388c172310bc57fe24c6188a313a8f99742903c65af48dfd69ef027ae0e02` | Input loader. File format, indexing, time alignment and missing-data behavior should be documented from the calling workflow. |
| `LOAD_DEPTH_DATA_ASCENT.m` | `ec6c7b02f11c6bd3cb4100499443ddb5d2ec1d3476f161186cd7cbcf85fca600` | Input loader. File format, indexing, time alignment and missing-data behavior should be documented from the calling workflow. |
| `LOAD_SIMULATION_DATA.m` | `d42a0741354635ce2317d46dcce3e52f20273bcca8cb4a1fd93fddba584dc9ee` | Input loader. File format, indexing, time alignment and missing-data behavior should be documented from the calling workflow. |
| `LOAD_SUMMARY_DATA.m` | `9a630a3c58bf47488a0104fe96dd12a4c68551a43e8b14f1f779b700af5f4eda` | Input loader. File format, indexing, time alignment and missing-data behavior should be documented from the calling workflow. |
| `Muscle_MbO2_sat.m` | `f0ab2dca50e3f5d27c87277ab696402968223234716d7a9f7cc49b5529a01786` | Gas content, saturation, tension, or acid-base helper. Confirm whether the input is pressure, content, saturation or moles and record units from the actual implementation. |
| `N2_extract_before_EOD.m` | `c2686864abbc2552ac39b8937383707d6484cda2b0eb581a278c312de30ba67d` | Post-processing extraction. Verify array indexing, output units and assumptions about dive boundaries. |
| `N2_lung_coll.m` | `fc694ef052e4a9d5a1e619846f8f282c8f2292344b7c5d7027cf27af322556aa` | Review input/output dimensions, global state, units and call-site assumptions before further refactoring. |

## Verification
- Original file bytes are preserved after the new comment header.
- Run whale 12 with identical parameters and breath schedule.
- Compare the new SUMMARY_ARRAY to the frozen original baseline before committing.

## Deferred detailed review
- Inspect legacy comments and dead-code candidates manually; none removed here.
- Extract precise parameter definitions and equations in a separate source-audited pass.
