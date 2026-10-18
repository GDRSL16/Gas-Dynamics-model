Breaths are at row start SI + 1, then every 20 rows while inside the surface interval, plus row end SI - 1. The first 10-second interval has breaths at rows 2 and 9. For 180-second intervals, this gives 10 breaths (9 regularly spaced and one final). TimeStep is a 1-based MATLAB row index. The breath_flags CSV has a header and two columns; breath_rows CSV lists events only. These replace the prior breath flag schedules, not the dive data or summary files.

MATLAB example:
T = readtable("shallow_20x600s_20m_breath_flags.csv");
global BREATH_FLAG
BREATH_FLAG = T.BREATH_FLAG;
