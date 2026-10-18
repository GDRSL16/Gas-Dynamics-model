# MATLAB code documentation review - Batch 05

Review date: 2026-10-18
Scope: documentation-only; original source retained byte-for-byte after new header.
Validation: pending whale 12 SUMMARY_ARRAY comparison.

| File | Original SHA256 | Description |
|---|---|---|
| `blood_tiss_mus_Po2.m` | `dace2b1bebcfaf979ff7f70c7755158f3813a1e2cb35a49a113c8b323284d90e` | `MATLAB function: y=blood_tiss_mus_Po2(pco2,nO2tot, Vtiss,Vblood)%units returned is l gas STPD /l blood` |
| `blood_tiss_Pco2.m` | `447dcc71238b64d56f636749d643f7625656f700aef39618ad9ed16d6ac10845` | `MATLAB function: y=blood_tiss_Pco2(po2,pco2, nCO2tot,Vtiss,Vblood,stiss)%units returned is l gas STPD /l blood` |
| `blood_tiss_Po2.m` | `aa67bc4f0cd75558727548191fe529c2fbbe0d394ace916cd86fdb536a67d2d4` | `MATLAB function: y=blood_tiss_Po2(pco2,nO2tot, Vtiss,Vblood,stiss)%units returned is l gas STPD /l blood` |
| `driver_to_beakedwhale_tissue_kin.m` | `d686a08f9b6b867136a17b79ebb240c1684903b9b85cac3132445ab112e09c8c` | `MATLAB function: y=driver_to_beakedwhale_tissue_kin (u);` |
| `est_va.m` | `831e4d8cbc72b9ebb16cde3478651e0ba7814b853fefab04e7a49e73e5960e6b` | `MATLAB function: y=est_va(i,rt) %THE SHUNT EQUATION` |
| `extract_ascent_rates.m` | `dc3cf9535c127eb53d01d70ff73f79b57b24818e4b95d84865300c50bc58eb85` | `MATLAB function: y=extract_ascent_rates` |
| `extract_boutstartend_N2_tension.m` | `d9ecb18b24d1fad7e54b20fc58bcd40df6a459d691872d733cfe418340760dcb` | `MATLAB function: y=extract_boutstartend_N2_tension` |
| `extract_max_N2_tensions.m` | `50739cf9f27730ee4aace68f0a232ae7752c1a39daa795fb6b1ec7010243df1e` | `MATLAB function: y=extract_max_N2_tensions(z, u, depth) %this program takes the rows for where a dive is occuring and looks for max PN2 for each tissue and also the PN2 for each tissue at max depth` |
| `extract_N2_tensions.m` | `482a5e6ad214eebd742cbb114ffe5694d595ad0f25c0b2f98782ece58cad460b` | `MATLAB function: y=extract_N2_tensions(zx,u,depth)` |
| `extract_ven_tens_at_depths.m` | `32df7ede12fa7b71543bfc9182dd2815fa0b13bb0c577772209d60de450bbaac` | `MATLAB function: y=extract_ven_tens_at_depths` |

## Validation procedure
1. Replace only these 10 files in `src`.
2. Run whale 12 with identical input data, breath schedule, and model parameters.
3. Save the output as `12-Zica-SUMMARY_ARRAY-batch5.txt`.
4. Compare all rows and columns with the original baseline before committing.

## Editing notes
All source statements, legacy comments, whitespace, and line endings are preserved after the new header.
Potential code issues are intentionally not repaired in this pass.
