# Ventilation code cleanup - 17 October 2026

## Contents
- `01_cleaned_no_equation_changes/`: six uploaded functions with documentation and section headers only. No executable statement was intentionally changed.
- `02_flexible_ventilation/`: same files plus independent `EXHALED_FRACTION` and `INHALED_FRACTION` controls.
- `CHANGELOG.md`: change notes and test plan.

## Important
`GET_VARIABLES_LUNG_COLL_ZIP.m` was NOT present in the supplied ZIP. The new fractions are therefore initialized in `GET_VARIABLES_ZIP_NEW.m`, which *was* supplied. The original `est_va.m` surface branch and `N2_lung_coll.m` have not been changed.

**Use only one version at a time.** First run the cleaned-only version and compare to the committed baseline. Then test the flexible version with both fractions = 1.0, and only afterward vary the fractions.

The MATLAB code has not been executed here. Static checks establish source equivalence for the documentation-only version, not runtime equivalence.
