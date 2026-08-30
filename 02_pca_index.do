*===============================================================================
* 02_pca_index.do
*   Construct the composite digital-economy index using Principal Component
*   Analysis (PCA). Used as a robustness check on the EWM-based weights.
*
*   Author : Airui Meng
*   Input  : independent_variables.xlsx  (sheet: "panel data")
*   Output : pca_processed_data.xlsx
*===============================================================================

clear all
set more off

local data_file "independent_variables.xlsx"

* ------------------------------------------------------------------------------
* 1. Load the raw panel data
* ------------------------------------------------------------------------------
import excel "`data_file'", sheet("panel data") firstrow clear

* ------------------------------------------------------------------------------
* 2. Variables used for PCA (22 third-level indicators)
* ------------------------------------------------------------------------------
global pca_var "x1 x2 x3 x4 x5 x6 x7 x8 x9 x10 x11 x12 x13 x14 x15 x16 x17 x18 x19 x20 x21 x22"

* ------------------------------------------------------------------------------
* 3. KMO and Bartlett sphericity test
*    Significant Bartlett / KMO > 0.6 indicates suitability for factor analysis.
* ------------------------------------------------------------------------------
factortest $pca_var

* ------------------------------------------------------------------------------
* 4. Principal component analysis
*    Retain components with cumulative contribution > 80% and eigenvalue > 1.
*    The four-component solution explains roughly 82.7% of total variance in
*    this panel.
* ------------------------------------------------------------------------------
pca $pca_var

* ------------------------------------------------------------------------------
* 5. Predict component scores and build the composite index.
*    Coefficients below are the variance-contribution rates reported by Stata
*    for the four retained components.
* ------------------------------------------------------------------------------
predict c1 c2 c3 c4

gen digital_pca = (0.5340*c1 + 0.1744*c2 + 0.0742*c3 + 0.0447*c4) / 0.8274

* ------------------------------------------------------------------------------
* 6. Rescale to the [0.6, 1.0] range so that cross-year comparisons stay
*    interpretable (Han et al., 2014).
* ------------------------------------------------------------------------------
summarize digital_pca
replace digital_pca = (digital_pca / (r(max) - r(min))) * 0.4 + 0.6

summarize digital_pca
gen digital_pca_norm = (digital_pca / (r(max) - r(min))) * 0.4 + 0.6

label variable digital_pca      "Digital-economy composite index (PCA)"
label variable digital_pca_norm "Digital-economy composite index (PCA, rescaled)"

* ------------------------------------------------------------------------------
* 7. Persist the processed dataset
* ------------------------------------------------------------------------------
export excel using "pca_processed_data.xlsx", replace firstrow(variables)

display as text "PCA index construction complete. Output: pca_processed_data.xlsx"
