# MATLAB code documentation review - Batch 04

Review date: 2026-10-18
Scope: documentation-only; original source retained byte-for-byte after new header.
Validation: pending whale 12 SUMMARY_ARRAY comparison.

| File | Original SHA256 | Description |
|---|---|---|
| `batchSaveWithHeaders_example.m` | `0aeac72208ffc3bd418cd5bfb9ff89730274e6e64e55e109b913468ff4587bd5` | `MATLAB script; review original code for purpose and dependencies.` |
| `beakedwhale_tissue_kinetics1.m` | `662073fe7bacb46ddb536b1f923f0a6cd5ebc3cc9506c05e428b94aae521e5ce` | `MATLAB function: y=beakedwhale_tissue_kinetics1(s,op,new_i, dsum)%s=data file with all dive data, op=body mass of animal, new_i=the repeated record when running this repeatedly to find a record, dsum=data file containing all the summarized dive and surface interval data with metabolic rates for COL` |
| `blood_Cco2.m` | `4484839ddd0dc7805dedb35e3e1efa0985b912c428f125bf14738e625b31dd1a` | `MATLAB function: y=blood_Cco2(po2,pco2)` |
| `blood_Co2.m` | `cfea4fa464a01064cf96c00ed5f2cdef49db428beb7a7cfd5ead7eaa30b3028e` | `MATLAB function: y=blood_Co2(pco2,po2)%units returned is l gas is Body temperature standard pressure dry per l blood` |
| `blood_lung_Pco2.m` | `d977dd20ab8aebbaef2b77ea52d4681097604f00fb024d6486a9470e5974bf52` | `MATLAB function: y=blood_lung_Pco2(po2,nCO2tot,Vlung,Vblood)%units returned is l gas STPD /l blood` |
| `blood_lung_Po2.m` | `d715b203004ae545bbf8a6e27a6cc052041b8af2b9c42a643c0499e2eaaf74a7` | `MATLAB function: y=blood_lung_Po2(pco2,nO2tot,Vlung,Vblood)%units returned is l gas STPD /l blood` |
| `blood_O2_sat.m` | `c93574c8824e87bd6022ad3e64bf9cccf39e388d790b40147c5f39e2db60b847` | `MATLAB function: y=blood_O2_sat(po2,pco2)%units returned is l gas STPD /l blood` |
| `blood_Pco2.m` | `de334232658ae22c974a9c8ddeb25adab91dd0d8532cc548794ffcaf976e612b` | `MATLAB function: y=blood_Pco2(S,Cco2)` |
| `blood_pH.m` | `986afa6b03fef782a64087bde71bb4f14706c1e33d34839d1ca965053ad1a36e` | `MATLAB function: y=blood_pH(po2,pco2)%units returned is l gas STPD /l blood` |
| `blood_Po2.m` | `4c09a9f0c596c9f9628ac23d9e247823e47394e51c532e15c495185be8b7b06d` | `MATLAB function: y=blood_Po2(pco2,Co2)%units returned is l gas STPD /l blood` |

## Validation procedure
1. Replace only these 10 files in `src`.
2. Run whale 12 with identical input data, breath schedule, and model parameters.
3. Save the output as `12-Zica-SUMMARY_ARRAY-batch4.txt`.
4. Compare all rows and columns with the original baseline before committing.

## Editing notes
All source statements, legacy comments, whitespace, and line endings are preserved after the new header.
Potential code issues are intentionally not repaired in this pass.
