# Gas dynamics model — physiological basis and assumptions

**Working draft v0.1 — 15 October 2026**  
**Source:** Uploaded current MATLAB source and PDF record of the earlier development conversation.  
**Purpose:** A physiologically oriented companion to `MODEL_TECHNICAL_DOCUMENTATION.md`. Statements marked **to verify** should not be treated as established published-model assumptions.

## 1. Scientific purpose

The model estimates respiratory gas kinetics during repeated breath-hold dives by linking changing ambient pressure, finite pulmonary gas stores, circulation, blood–gas exchange, tissue gas uptake/release, and metabolic oxygen consumption/carbon dioxide production. The current development objective is to replace the legacy assumption of imposed alveolar gas composition at every surface step with finite, discrete breathing events while retaining pressure-dependent lung mechanics and tissue kinetics.

## 2. Compartments and state variables

The MATLAB code tracks N2, O2 and CO2 in a lung compartment and exchanges these gases with blood and tissues. The principal lung gas state variables are partial pressure and gas amount (moles) in the fifth compartment of `N2_ARRAY`, `O2_ARRAY`, and `CO2_ARRAY`. The model separately tracks alveolar and tracheal volumes in `LUNG_VOL`, with total respiratory volume defined by their sum.

**Interpretation requiring review:** the gas stores are handled as a common lung gas pool in the current breath code, despite the mechanical model distinguishing alveolar and tracheal spaces. The validity of well-mixed gas during a breath and between breaths is a physiological assumption, not established by the array structure alone.

**AF comment (2026-10-15):**
For marine mammals, we will initially assume that the tracheal and alveolar gas spaces are well mixed, although the mechanical lung-collapse model distinguishes these compartments.
Modelling separate dead-space gas compartments would increase complexity, and it is unclear whether this would substantially improve model predictions.

**AF decision (2026-10-15):** Use a single well-mixed lung gas reservoir for the initial ventilation model.

## 3. Initial gas stores

`GET_VARIABLES_ZIP_NEW.m` initializes alveolar gas tensions (`PN2_alv_init`, `PO2_alv_init`, `PCO2_alv_init`) and gas amounts using `n_gas=P_gas*V_LUNG/GAS_CONSTANT`. `ALV_SURFACE_VALUE` contains initial gas pressures and corresponding moles. Earlier code used fixed alveolar values at the surface; the revised approach aims to use these values only for initialization or as explicitly defined reference conditions.

**Important distinction:** initial *alveolar* gas composition is not the same as the composition of freshly inspired air. The development discussion assumes approximately 79% N2, 21% O2 and negligible CO2 in inspired dry air. Whether humidification and the chosen surface pressure have already been accounted for must be verified from units and pressure definitions.

**AF comment (2026-10-15):**
The code has a PH2O value that reduces the partial pressures of the other gases, so let's say PH2O is 2.5 kPa at the surface, the 100kPa ammbient pressure and the partial pressures are: Pamb = 2.5 + (Pamb-2.5) x FN2 + (Pamb-2.5) x FO2 + (Pamb-2.5) x FCO2, then at depth, the vapour pressure does not change so should remain 2.5kPa and the equation holds.

**AF decisionc(2026-10-15):** The above should be checked in the model

## 4. Pressure, lung compression and alveolar collapse

The lung mechanics model in `N2_lung_coll.m` calculates alveolar volume `VL`, tracheal volume `VT` and internal pressure `Pint` as ambient pressure changes. Its root search (`fzero`) depends on the current reference volume `VLinit`, the previous alveolar-volume estimate `VLprev`, the tracheal reference volume `VTinit`, and structural parameters (`A1`–`A4`, `KP`, `NN`). A `FLAGGA` state distinguishes mechanics branches associated with tracheal collapse.

This means a breath is not simply a gas composition change: any post-breath change in total gas amount or reference lung volume can influence subsequent pressure–volume calculations. **To verify:** exactly which post-breath reference values preserve the intended pressure-volume mechanics.

**AF comment (2026-10-15):** At the surface, or very close to the surface, the N2_lung_coll is not really relevant and will have a minor effect, apart from the increased partial pressure of gas within the lung. Therefore, I think we can "use" the lung collapse model, making sure that it works ok at close to the surface pressures, e.g. 0.5 meter, or even at the surface without breaths and have conditions in the call for the fzero to be calculated at below maybe 0.5 meter (to save computation), or we have it always run except for during the 1 second of a breath, when we can assume that the lung volume ir equal to the tidal volume (volume inhaled) + tracheal volume.

**AF decision (2026-10-15):** I propose that we treat all depths the same and the only change to the lung mechnics model is during a breath. This will simplify coding, can mostly be physiologcially reasoned and is a simplification that I doubt will have implications to the results.

## 5. Pulmonary exchange and shunting

`est_va.m` calculates a shunt estimate using alveolar volume as a fraction of `TAC`:

`lungratio = va/TAC; shunt = max(0, 1 - a*lungratio^b)`

with the current constants `a=1.495`, `b=0.320`, labeled in code as harbour-seal values. The `iteration_N2_lung_search.m`, `iteration_O2_lung_search.m`, and `iteration_CO2_lung_search.m` functions implement the gas-specific blood–lung updates, including shunt-dependent behavior.

**To verify:** whether the empirical shunt-volume relationship and its coefficients are intended for beaked whales, or are an inherited approximation from another species. The current breath branch substitutes temporary arterial equilibrium calculations rather than the normal iterative exchange: this must be justified or revised before scientific use.

**AF comment (2026-10-15):** Splendid comment and for now, we have no other experimental evidence that they are different. The lung compression model itself, which then results in the shunt, varies between species. It sets up differences in the structrual properties and these are based on real values. So the differences in species are set up at the level of compression, which then is assumed to be equal at the level of shunt.

**AF decision (2026-10-15):**Without experimental evidence of the contrary, for now I think we use the seal data, which are based on empirical data.

## 6. Circulation and dive response

`GET_GAS_FLUX_1.m` changes perfusion and metabolism around dives using `adjust_Q_bradycardia.m`, `adjust_Q_tachycardia.m`, and `update_tissue_metabolic_rates.m`. Its logic uses dive-summary information and sonar state. The breath-event indicator `BREATH_FLAG` should be distinguished from the physiological dive response; a shallow no-breath interval is not automatically equivalent to a deep-dive bradycardic state.

**To verify:** how the surface interval, activity, dive-response flag and cardiac output interact at each time step; this matters because gas exchange continues between breaths.

**AF comment (2026-10-15):** This is a place where we need to be cautious. Previously we invoked a "dive response" if an animal was diving (dive response flag) and sometimes varied this with sonar (sonar flag). We can remove the sonar flag as we are not working on that now and could add later, but we need here to make sure that a "dive" or maybe even an inter-breath interval (so time between breaths) results in a change in heart rate (which results in perfusion changes). I think the simplest is to set this up in the code to create changes for "dives" > a certain duration, then consider redefining a dive as a submersion to a depth of at least 2 meter for 60 seconds (for example) and then leave the rest as at the surface. We can change how the "summary file" defines this and then use the same structure and then anything that is above a dive, has a certain heart rate/perfusion and then the dives are organized by dive duration. This also goes with the argument that surface internvals have to have high perfusion to be able to restore blood and tissue gas stores.

**AF preliminary decision (2026-10-15):** It may be best to use the same structure and perform minimal changes. That way we use the same functions, but redefine what is a dive (which can be done when we create the dive summary excel sheet that is called (dsum=GET_DIVE_SUMMARY_DATA_METABOLIC_RATES(i)) that is called in driver_to_beakedwhale_tissue_kin) that way, we can use the same structure as before, but we alter a bit the assumptions. We then assign a new depth and duration as a dive, and everything else is above this depth but still "treated" as a dive but without perfusion changes. Then a breath can be a brief excursion to the surface where the only thing we do is alter the lung volume (alveolar volume as the tracheal volume at this depth should be the same at Pint_init) and the internal gas content. And then we reset those values in the O2_..., N2_..., and CO2_...arrays so new gas volumes and partial pressures/concntrations exist. We may have to consider if we alter lung vol and composition first and then calculate the exchange or do the exchange first and then alter the lung composition.

## 7. Metabolism and tissue kinetics

The model updates oxygen, carbon dioxide and nitrogen in tissue and blood compartments, with tissue-specific perfusion, stores, and metabolic demand set by animal parameters and dive state. The functions `update_tissue_O2.m`, `update_tissue_CO2.m`, `update_tissue_N2.m`, and `update_tissue_metabolic_rates.m` provide the main pathways. These processes must remain active when the whale is at the surface but not breathing, if finite pulmonary gas exchange is the intended model.

**To verify:** compartment-specific units (e.g., mol versus concentration, time units for metabolic rates), dissolved versus bound gas representations, and numerical conservation across compartments.

**AF comment (2026-10-15):** There are variations in pressure units in the model, I think, but I do think that other units are preserved. As we are concerned with conservation of mass, we need moles as rounding errors can results in changes if using pressure, I think.

**AF preliminary decision (2026-10-15):** The "breath" is such as short duration (normally on the order of a 1-2 seonds) so we do not need to do anything special during the breath, I think, just update the volumes and gas concentrations and then do the calculation

## 8. Finite ventilation: proposed physiological specification

The scientific question is how to represent a breath as a **discrete event** in a continuously evolving finite pulmonary reservoir. The current experimental implementation assumes exhalation leaves a residual volume equal to `VTinit`, followed by inspiration of `V_BREATH`. It retains a proportional fraction of previous lung moles and adds inspired gas moles:

`V_residual = VTinit`

`n_residual = n_old * V_residual / V_old_total`

`n_inspired = F_inspired * P_surface * V_BREATH / RT`

`n_after = n_residual + n_inspired`

`V_after = V_residual + V_BREATH`

`P_gas_after = n_after * RT / V_after`

This is **what the unsuccessful uploaded code currently implements**, not an endorsed physiological model. It differs from the earlier stand-alone `surface_breath_exchange.m` helper, which assumes partial replacement at fixed gas-space volume. These two alternatives should be compared rather than combined without justification.

### Questions for physiological review

1. What is the appropriate *end-expiratory* lung volume in a diving cetacean, and should it be fixed or vary with the prior state?
2. Is the gas expelled during exhalation a representative, well-mixed fraction of the lung, or is sequential emptying relevant?
3. What volume does `V_BREATH` represent: inhaled volume, exchanged volume, or a fraction of total/alveolar capacity?
4. Should the post-inspiratory lung volume equal `VLmax`, be less than `VLmax`, or depend on an animal-specific breath amplitude?
5. How should the updated gas amount modify `VLinit`, `VLprev` and `Pint` without double-counting gas loss from the preceding dive?
6. Does pulmonary exchange continue throughout a one-second breath time step, or is the event treated as instantaneous at a chosen point within that step?
7. How should the tracheal dead-space volume contribute to mixing and effective alveolar ventilation?
8. What is the correct handling of gas humidity and dry inspired gas fractions when converting partial pressure to moles?
9. How should repeated breaths produce hyperventilation or hypoventilation without imposing fixed alveolar PO2/PCO2?

**AF comment (2026-10-15):** The old model assumed that there was dead space ventilation at the surface and that the entire lung volume was exchanged bbut only to that partial pressure, which was always constant. What we wanted to do with the previous version was to include specific ventilation, which then by default will allow the animal to hyper and hypoventilate. Maybe the best way forward is to write a script that uses the same abbreviations as proposed above and that respond in this way. However, it would be difficult as it would require a sink for co2 and connsukption of o2 and n2 exchange. But what we need is a "brief" breath which now alters gas concentrations.
First, I think the concept above is not correct and the animal can not exhale the volume contained in the residual space/volume. Consequently, what is "left" in the lung when an animal is at the surface is correct, so: 
'n_residual = n_old * V_residual / V_old_total' 
would be the "fraction" of gas that will be left after exhalation. This would not work if for some reason the volume when taking a breath is less that V_residual, as it would become a value larger than 1, but this should never happen, I hope, even if all oxygen is removed, but may be one possibility during extremely long dives. 
This should also be true in almost any case: 
`n_inspired = F_inspired * P_surface * V_BREATH / RT` 
and this should be specific for each gas assuming that V_BREATH is the inhaled volume and that is a fraction of total lung capacity - residual volumme, so if the fraction is 1, V_BREATH=TAC and V_BREATH+residual volume=total lung capacity of VLmax. Here, P_surface is what we have as P_AMB so the ambient pressure minus water vapour pressure (PH2O). We may have to "assume" a temperature for that and make that clear and that volume then would change if we did it in the tropics or in the artic.
This function should be ok: 
`n_after = n_residual + n_inspired` 
as well as this one:
`V_after = V_residual + V_BREATH`
and this one:
`P_gas_after = n_after * RT / V_after`


**AF preliminary decision (2026-10-15):** Let's keep these for now, and create a case where we set things in a loop and see what happens, i.e. we set diving lung volume before (during breath=V_BREATH) and after a long dive and then the estimated O2, CO2 and N2 concntratins following the dive and then run this for 500 dives and see what heppens to the values. Followinf that, we can insert these equations.

## 9. References visible in the source (not bibliographically verified)

The source comments cite, among others: Zimmer et al. (2007); Miller et al. (2016); Kooyman et al. (1972; 1973); Stephenson (JEB 2005); and a “Brian paper” for the shunt relation. These are **code-comment attributions only**. Exact bibliographic details, applicability to beaked whales, and which equations each publication supports remain to be checked against the original papers. Do not convert these mentions into formal citations without verification.

**AF comment (2026-10-15):** I agree, these are "legacy" citations and really needs improvement for each study

**AF preliminary decision (2026-10-15):** Leave as is for now. If we do any implementation that is based on someones work, we should include a citations, but otherwise we can leave these for now.


## 10. Next review and acceptance criteria

First confirm the intended breathing physiology and units. Then document a testable specification that conserves gas moles during exhalation/inhalation, uses internally consistent gas volumes and pressure units, and preserves gas exchange during no-breath surface intervals. Only after these choices are explicit should the development branch be revised and compared with the archived model.

**Change log:** v0.1 initial source-grounded documentation, 2026-10-15. Not reviewed against publications or validated by running MATLAB.

**AF comment (2026-10-15):** I like this way forward

**AF decision (2026-10-15):** Agreed with the above

