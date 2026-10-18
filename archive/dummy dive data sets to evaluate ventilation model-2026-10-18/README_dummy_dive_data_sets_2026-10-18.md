# Dummy dive data sets to evaluate ventilation model

**Created:** 18 October 2026  
**Purpose:** Standardized synthetic dive records for testing finite ventilation, lung gas exchange, and tissue gas kinetics in the MATLAB gas dynamics model. These are *model inputs*, not observations or validated physiological predictions.

## 1. Dive profiles

| Profile | Number of dives | Total dive duration | Maximum depth | Descent | Time at depth | Ascent | Data rows |
|---|---:|---:|---:|---:|---:|---:|---:|
| Shallow | 20 | 600 s (10 min) | 20 m | 10 s | 580 s | 10 s | 15,430 |
| Intermediate | 10 | 1,200 s (20 min) | 400 m | 200 s | 800 s | 200 s | 13,630 |
| Deep | 5 | 3,000 s (50 min) | 1,200 m | 600 s | 1,800 s | 600 s | 15,730 |

All profiles use **1-second sampling**, **2 m/s descent and ascent**, and constant depth between descent and ascent. The stated dive duration includes both transits. There are **10 seconds at the surface before the first dive** and **180 seconds at the surface between successive dives**; there is no added surface interval after the final dive.

The supplied dummy data were used to preserve the input-column format and constant conditions: **ODBA = 0.095062223 g**, **locomotion cost = 1 L O2/min**, and **sonar = 1**. These fixed values are testing assumptions, not species-specific estimates. The profiles do not guarantee that oxygen stores remain sufficient.

## 2. Files and data structure

Each profile has a common prefix, for example `shallow_20x600s_20m`:

| File suffix | Contents |
|---|---|
| `_data.csv` | One row per second: `Time (s)`, `depth (m)`, `ODBA (g)`, `Locomotion cost (l O2/min)`, `sonar`. |
| `_summary.csv` | One row per dive, with its preceding surface interval: surface interval number/duration/start/end; mean locomotion cost; dive number/duration/start/end; mean locomotion cost; maximum and mean depth; sonar. |
| `_breaths.csv` | Original generator's 0/1 breath flag for each time step (see scheduling distinction below). |
| `_breath_flags.csv` | **Updated schedule**: `TimeStep`, `BREATH_FLAG`, one row per data row. Use this version for the revised breath timing. |
| `_breath_rows.csv` | **Updated schedule**: explicit breath rows with surface interval and event label. Useful for inspection. |

All row indices in the generated summaries are **1-based MATLAB indices**, with **inclusive, non-overlapping** intervals. The supplied dummy summary template used different/overlapping boundary conventions; verify the model's input parser before relying on the generated summary files.

### Updated breath timing (recommended)

During each surface interval, schedule a breath **1 second after surfacing**, then **every 20 seconds**, plus a **final breath 1 second before the next dive**. The initial 10-second surface interval has breaths at rows **2 and 9**. For the 180-second between-dive intervals this gives ten breaths per interval, counting the final breath. The resulting totals are:

| Profile | Breath events |
|---|---:|
| Shallow | 192 |
| Intermediate | 92 |
| Deep | 42 |

**Important:** The original `_breaths.csv` files created with `generate_synthetic_dive_profiles.m` have an *earlier* schedule (no initial breaths and nine breaths per between-dive interval). They are **not interchangeable** with the later `_breath_flags.csv` schedules. Use the updated flags for the agreed experiment. If regenerating data with the original generator, retain/reapply the updated breath schedule separately.

For example, after selecting the matching dive profile in the driver:

```matlab
T = readtable('shallow_20x600s_20m_breath_flags.csv');
BREATH_FLAG = T.BREATH_FLAG;
assert(numel(BREATH_FLAG) == height(T));
```

Ensure `BREATH_FLAG` is shared with the model as intended, and **remove/disable the old manually assigned breath rows** so they do not overwrite the imported schedule. The breath flag must have one entry per dive-data row.

## 3. MATLAB plotting function

**File:** `plot_dive_summary.m`  
**Input:** MATLAB model output files, not the synthetic input CSVs.

The function reads one of these model-generated text files, expected to contain **two header rows followed by numerical data**:

- `shallow-SUMMARY_ARRAY.txt`
- `intermed-SUMMARY_ARRAY.txt`
- `deep-SUMMARY_ARRAY.txt`

Place the plotting function and these three output files in the same folder, or supply the output folder as the second argument:

```matlab
plot_dive_summary(1)   % Shallow
plot_dive_summary(2)   % Intermediate
plot_dive_summary(3)   % Deep

% Optional explicit folder:
plot_dive_summary(2, 'C:\path\to\results')
```

Each call creates **three MATLAB figures**, one each for N2, O2, and CO2. Each figure contains **three aligned, vertically stacked panels**:

1. **Tissues and lung:** heart/central circulation, muscle, brain, fat, lung.
2. **Blood:** arterial and mixed venous.
3. **Ambient pressure:** dive-pressure profile.

Column mapping in the model's `SUMMARY_ARRAY` output:

| Gas | Tissue/lung columns | Arterial, venous columns | Pressure column |
|---|---|---|---|
| N2 | 1–5 | 16–17 | 22 |
| O2 | 6–10 | 18–19 | 22 |
| CO2 | 11–15 | 20–21 | 22 |

The plotting function preserves the numerical values and units found in the output files; it does **not** convert units. Its three x-axes are linked for synchronized zooming/panning, and legends sit to the right of equally sized panels. Figures can be saved as MATLAB `.fig` files for later inspection.

## 4. Suggested evaluation and archiving

Compare full and partial exhalation/inhalation and no-breath runs using the **same dive profile and metabolic/perfusion settings**. Examine post-breath lung volume, lung O2/CO2/N2, tissue gas stores, arterial/venous responses, and any oxygen-depletion warnings. A successful run is not itself evidence of physiological validity.

Suggested archive location:

`archive/dummy dive data sets to evaluate ventilation model-Oct 18-2026/`

Keep the input data, updated breath schedules, `plot_dive_summary.m`, this README, and (if useful) the original generator together. The three `*-SUMMARY_ARRAY.txt` files are **simulation outputs**, and should be clearly separated from synthetic input files if archived here.
