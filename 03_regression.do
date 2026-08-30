*===============================================================================
* 03_regression.do
*   Main empirical analysis for the undergraduate dissertation:
*   "What changes has the development of the digital economy brought to
*    China's employment structure?"
*
*   Author  : Airui Meng
*   Updated : April 2026
*
*   Inputs  : regression_data.xlsx  (sheet: "panel data")
*   Outputs : output/04_benchmark_regression.rtf
*             output/05_robustness_substitution.rtf
*             output/06_heterogeneity.rtf
*             output/07_2sls.rtf
*             (descriptive stats and correlation matrix written to output/)
*===============================================================================

clear all
set more off
capture log close

* ------------------------------------------------------------------------------
* 0. Paths. When run via 00_master.do, the working directory is already the
*    repository root. Otherwise set it manually before running this file.
* ------------------------------------------------------------------------------
local data_file "regression_data.xlsx"
local out_dir   "output"
capture mkdir "`out_dir'"

* ------------------------------------------------------------------------------
* 1. Load data and declare panel structure
* ------------------------------------------------------------------------------
import excel "`data_file'", sheet("panel data") firstrow clear

xtset id year                                      // province-id x year panel

gen digital_e2 = digital_e^2
gen digital_p2 = digital_p^2

* Instrumental variable:
*   (1 / provincial terrain undulation) x provincial internet-user count.
* Spatial variation from geographic ruggedness, time variation from provincial
* internet penetration. Note: in logs the two terms are additively separable
* (log iv = log internet_user - log Terrain_undulation) and the time-invariant
* terrain term is absorbed by the province fixed effects, so the identifying
* variation in ivv comes from log(internet_user). See README.
gen iv  = (1 / Terrain_undulation) * internet_user
gen ivv = log(iv)

* ------------------------------------------------------------------------------
* 2. Hausman tests (fixed- vs random-effects model selection)
* ------------------------------------------------------------------------------
foreach dv in low_skill_pct mid_skill_pct high_skill_pct {
    quietly xtreg `dv' digital_e digital_e2 human_capital rd_intensity ///
        digitalization gov_intervention industry, fe
    estimates store fe_`dv'
    quietly xtreg `dv' digital_e digital_e2 human_capital rd_intensity ///
        digitalization gov_intervention industry, re
    estimates store re_`dv'
    display as text _newline(1) "Hausman test: " "`dv'"
    hausman fe_`dv' re_`dv'
}

* ------------------------------------------------------------------------------
* 3. Descriptive statistics
* ------------------------------------------------------------------------------
summarize low_skill_pct mid_skill_pct high_skill_pct ///
          digital_e digital_e2 digital_p digital_p2 ///
          human_capital rd_intensity digitalization gov_intervention industry

asdoc summarize low_skill_pct mid_skill_pct high_skill_pct ///
                digital_e digital_e2 digital_p digital_p2 ///
                human_capital rd_intensity digitalization gov_intervention industry, ///
                replace save(`out_dir'/02_descriptive_stats.doc)

* ------------------------------------------------------------------------------
* 4. Multicollinearity diagnostics (VIF)
* ------------------------------------------------------------------------------
quietly reg low_skill_pct digital_e human_capital rd_intensity ///
            digitalization gov_intervention industry
estat vif

* ------------------------------------------------------------------------------
* 5. Correlation matrix with significance stars
* ------------------------------------------------------------------------------
asdoc pwcorr low_skill_pct mid_skill_pct high_skill_pct ///
             digital_e digital_e2 digital_p digital_p2 ///
             human_capital rd_intensity digitalization gov_intervention industry, ///
             star(all) replace save(`out_dir'/03_correlation.doc)

* ------------------------------------------------------------------------------
* 6. Benchmark regressions (two-way fixed effects: province + year)
* ------------------------------------------------------------------------------
xtreg low_skill_pct digital_e human_capital rd_intensity digitalization ///
      gov_intervention industry i.year, fe robust
estimates store a1

xtreg low_skill_pct digital_e digital_e2 human_capital rd_intensity ///
      digitalization gov_intervention industry i.year, fe robust
estimates store a2

xtreg mid_skill_pct digital_e human_capital rd_intensity digitalization ///
      gov_intervention industry i.year, fe robust
estimates store a3

xtreg mid_skill_pct digital_e digital_e2 human_capital rd_intensity ///
      digitalization gov_intervention industry i.year, fe robust
estimates store a4

xtreg high_skill_pct digital_e human_capital rd_intensity digitalization ///
      gov_intervention industry i.year, fe robust
estimates store a5

xtreg high_skill_pct digital_e digital_e2 human_capital rd_intensity ///
      digitalization gov_intervention industry i.year, fe robust
estimates store a6

esttab a1 a2 a3 a4 a5 a6 using "`out_dir'/04_benchmark_regression.rtf", replace ///
    b(%6.3f) se(%6.3f) se ar2(3) ///
    star(* 0.1 ** 0.05 *** 0.01) compress nogap ///
    mtitles("low" "low" "mid" "mid" "high" "high") ///
    title("Benchmark two-way FE regressions (EWM index)")

* ------------------------------------------------------------------------------
* 7. Robustness: substitution-variable method (PCA-based index)
* ------------------------------------------------------------------------------
xtreg low_skill_pct digital_p human_capital rd_intensity digitalization ///
      gov_intervention industry i.year, fe robust
estimates store s1

xtreg low_skill_pct digital_p digital_p2 human_capital rd_intensity ///
      digitalization gov_intervention industry i.year, fe robust
estimates store s2

xtreg mid_skill_pct digital_p human_capital rd_intensity digitalization ///
      gov_intervention industry i.year, fe robust
estimates store s3

xtreg mid_skill_pct digital_p digital_p2 human_capital rd_intensity ///
      digitalization gov_intervention industry i.year, fe robust
estimates store s4

xtreg high_skill_pct digital_p human_capital rd_intensity digitalization ///
      gov_intervention industry i.year, fe robust
estimates store s5

xtreg high_skill_pct digital_p digital_p2 human_capital rd_intensity ///
      digitalization gov_intervention industry i.year, fe robust
estimates store s6

esttab s1 s2 s3 s4 s5 s6 using "`out_dir'/05_robustness_substitution.rtf", replace ///
    b(%6.3f) se(%6.3f) se ar2(3) ///
    star(* 0.1 ** 0.05 *** 0.01) compress nogap ///
    mtitles("low" "low" "mid" "mid" "high" "high") ///
    title("Robustness: PCA-based digital-economy index")

* ------------------------------------------------------------------------------
* 8. Heterogeneity: inland vs. coastal provinces
*    (inland_city and coastal_province are indicator variables in the panel)
* ------------------------------------------------------------------------------
xtreg low_skill_pct  digital_e human_capital rd_intensity digitalization ///
      gov_intervention industry i.year if inland_city == 1, fe robust
estimates store c1

xtreg mid_skill_pct  digital_e human_capital rd_intensity digitalization ///
      gov_intervention industry i.year if inland_city == 1, fe robust
estimates store c2

xtreg high_skill_pct digital_e human_capital rd_intensity digitalization ///
      gov_intervention industry i.year if inland_city == 1, fe robust
estimates store c3

xtreg low_skill_pct  digital_e human_capital rd_intensity digitalization ///
      gov_intervention industry i.year if coastal_province == 1, fe robust
estimates store c4

xtreg mid_skill_pct  digital_e human_capital rd_intensity digitalization ///
      gov_intervention industry i.year if coastal_province == 1, fe robust
estimates store c5

xtreg high_skill_pct digital_e human_capital rd_intensity digitalization ///
      gov_intervention industry i.year if coastal_province == 1, fe robust
estimates store c6

esttab c1 c2 c3 c4 c5 c6 using "`out_dir'/06_heterogeneity.rtf", replace ///
    b(%6.3f) se(%6.3f) se ar2(3) ///
    star(* 0.1 ** 0.05 *** 0.01) compress nogap ///
    mtitles("inland low" "inland mid" "inland high" ///
            "coastal low" "coastal mid" "coastal high") ///
    title("Heterogeneity: inland vs. coastal provinces")

* ------------------------------------------------------------------------------
* 9. Two-stage least squares with the terrain-undulation x internet-user IV
* ------------------------------------------------------------------------------
* First-stage diagnostic (no year FEs — the IV's temporal variation comes from
* internet_user, which would be absorbed by year dummies)
xtreg digital_e ivv human_capital rd_intensity digitalization ///
      gov_intervention industry, fe
estimates store v1

xtivreg2 low_skill_pct  digital_e2 human_capital rd_intensity digitalization ///
         gov_intervention (digital_e = ivv), fe robust
estimates store v2

xtivreg2 mid_skill_pct  digital_e2 human_capital rd_intensity digitalization ///
         gov_intervention industry (digital_e = ivv), fe robust
estimates store v3

xtivreg2 high_skill_pct digital_e2 human_capital rd_intensity digitalization ///
         gov_intervention industry (digital_e = ivv), fe robust
estimates store v4

esttab v1 v2 v3 v4 using "`out_dir'/07_2sls.rtf", replace ///
    b(%6.3f) se(%6.3f) se ar2(3) ///
    star(* 0.1 ** 0.05 *** 0.01) compress nogap ///
    mtitles("first stage" "low_skill_pct" "mid_skill_pct" "high_skill_pct") ///
    title("2SLS: (1 / Terrain_undulation) x internet_user as IV")

* ------------------------------------------------------------------------------
* End of file
* ------------------------------------------------------------------------------
