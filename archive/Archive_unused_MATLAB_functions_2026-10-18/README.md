# Archived MATLAB functions — 2026-10-18

These files were archived after checking all 64 MATLAB files in the source ZIP for direct code references.

- O2_saturation.m: no direct calls found outside its own definition.
- Vtot.m: no direct function calls found. `Vtot` is also a local variable in update_tissue_N2.m and iteration_N2_lung_search.m; these are not calls to Vtot.m.
- SAVEDATA.m: retained in src because it is called by beakedwhale_tissue_kinetics1.m and driver_to_beakedwhale_tissue_kin.m.

The archived functions are unchanged copies from the original source ZIP. Check external scripts, dynamic calls and MATLAB path resolution before considering permanent deletion. Re-run the whale 12 baseline after moving the files.
