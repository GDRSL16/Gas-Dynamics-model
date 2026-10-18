# Second-round code review — Batch 05

Review date: 2026-10-18

Scope: Add targeted internal documentation and review prompts. No executable MATLAB statements changed. No legacy code removed. No calculations, signatures, control flow, or variable names altered.

| File | Original SHA-256 | Review focus |
|---|---|---|
| `extract_ascent_rates.m` | `4eebe583ffcd8d234bee067410798d42bc3a8ef1ebecaaae2c74f06b588082c3` | Post-processing extraction. Verify array indexing, output units and assumptions about dive boundaries. |
| `extract_boutstartend_N2_tension.m` | `46a3622fcdcdc50db48e28099e57cf4630735fa3be1478cd85cf93594040d509` | Post-processing extraction. Verify array indexing, output units and assumptions about dive boundaries. |
| `extract_max_N2_tensions.m` | `07ec1ba61377a4a1f962a91bb22df4b663e9720ba27e67ae25d111f3d9397181` | Post-processing extraction. Verify array indexing, output units and assumptions about dive boundaries. |
| `extract_ven_tens_at_depths.m` | `93fd111acdbfac6bddd1b0e5c88e14f8101169bfb400dc7d526bbd467f97e227` | Post-processing extraction. Verify array indexing, output units and assumptions about dive boundaries. |
| `init_array.m` | `8a2f42602bfcc8efb7561d884fd636d9eec73474da71cd0a5eea2d72d26e5318` | Review input/output dimensions, global state, units and call-site assumptions before further refactoring. |
| `iteration_CO2_lung_search.m` | `60b705846e76afe73bf62244b4771da5ea41060bfdf42814661ce839d69b7be5` | Iterative lung gas solution. Convergence conditions and iteration order are part of the numerical method; do not modify them during documentation review. |
| `iteration_N2_lung_search.m` | `0e7fe9450db2329d4399ddbcd4a022896ab28bd53b0fee8cd175e52627c2be6e` | Iterative lung gas solution. Convergence conditions and iteration order are part of the numerical method; do not modify them during documentation review. |
| `iteration_O2_lung_search.m` | `1992e74bd269022010f563544260c5edb3b26671369f84928c696f2e6431cdc1` | Iterative lung gas solution. Convergence conditions and iteration order are part of the numerical method; do not modify them during documentation review. |
| `muscle_Co2.m` | `21ff5a22d28595afeb372a547e9f1e8dd5f8089ab42a117061d3bb191bc3b754` | Gas content, saturation, tension, or acid-base helper. Confirm whether the input is pressure, content, saturation or moles and record units from the actual implementation. |
| `plot_dive_summary.m` | `3901e00950b306ffafbc843e7fec537ebbe080ba1a708ece19787e5eddb95562` | Diagnostic visualization only. Verify column mapping against the two header rows of SUMMARY_ARRAY before interpreting tissue or blood traces. |

## Verification
- Original file bytes are preserved after the new comment header.
- Run whale 12 with identical parameters and breath schedule.
- Compare the new SUMMARY_ARRAY to the frozen original baseline before committing.

## Deferred detailed review
- Inspect legacy comments and dead-code candidates manually; none removed here.
- Extract precise parameter definitions and equations in a separate source-audited pass.
