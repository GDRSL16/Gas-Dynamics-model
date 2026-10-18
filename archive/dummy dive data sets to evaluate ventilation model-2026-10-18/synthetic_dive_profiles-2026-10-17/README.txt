SYNTHETIC DIVES - TEST INPUTS (NOT MODEL OUTPUT)

The supplied dummy input CSVs define five data columns and 13 summary columns.
The generated data/summary files preserve those exact headers and use 1-based
MATLAB row numbers. Separate *_breaths.csv files specify BREATH_FLAG.

PROFILE                      DIVES   TOTAL ROWS   BREATH EVENTS
shallow 20 m, 600 s          20      15430        171
intermediate 400 m, 1200 s  10      13630         81
deep 1200 m, 3000 s          5      15730         36

Depth is sampled every second, with 2 m/s descent and ascent. Dive durations
INCLUDE transit. At maximum depth, remaining dive time is held constant:
shallow 580 s, intermediate 800 s, deep 1800 s.

Initial surface: 10 rows. BETWEEN dives: 180 rows at depth zero.
Breaths are scheduled every 20 s during each 180-s interval (nine per interval),
with no breaths in the initial 10-s interval. No surface interval after final dive.

ODBA=0.095062223 g; locomotion cost=1 L O2/min; sonar=1, all held constant
as in the supplied dummy input. This does not guarantee tissue O2 sufficiency.
These are input profiles, not validated physiological simulations.

IMPORTANT: The provided dummy summary file uses overlapping/inconsistent
boundary row conventions; generated summaries use inclusive, non-overlapping
row indices. Confirm the main model's summary-file parser uses the same
convention before running. The main model may also use specific naming or
file locations. Do not overwrite whale-12 inputs.

MATLAB: Use the accompanying generate_synthetic_dive_profiles.m to regenerate.
When importing *_breaths.csv, use the second column as BREATH_FLAG, ensuring
its length equals the data-file row count. Verify that the model reads the
CSV data/summary pairs and does not auto-generate breath events.
