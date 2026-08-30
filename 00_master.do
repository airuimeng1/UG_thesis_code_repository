*===============================================================================
* 00_master.do
*   Master do-file for the full replication pipeline of
*   "What changes has the development of the digital economy brought to
*    China's employment structure?"
*
*   Execution order:
*     1. 01_ewm_index.do       Build the EWM-based digital-economy index
*     2. 02_pca_index.do       Build the PCA-based index (robustness)
*     3. 03_regression.do      Main regressions, robustness, heterogeneity, 2SLS
*
*   Author  : Airui Meng
*   Updated : April 2026
*
*   To run: open this file in Stata with the working directory set to your
*   local clone of the repository (or uncomment and edit the `cd` line
*   below), then execute the whole file.
*===============================================================================

clear all
set more off
capture log close

* ----- Optional: uncomment and edit to point at your local clone -----
* cd "/path/to/UG_thesis_code_repository"

* Create the output folder if it does not exist
capture mkdir "output"

* ------------------------------------------------------------------------------
* Install all required user-written packages (runs once; skips if present).
* Remove `capture` so that any install failure is immediately visible.
* ------------------------------------------------------------------------------
foreach pkg in estout asdoc ranktest ivreg2 xtivreg2 factortest {
    capture which `pkg'
    if _rc != 0 {
        display as text "Installing missing package: `pkg'"
        ssc install `pkg'
    }
}

display as text _newline(2) "=== [1/3] Running 01_ewm_index.do ==="
do "01_ewm_index.do"

display as text _newline(2) "=== [2/3] Running 02_pca_index.do ==="
do "02_pca_index.do"

display as text _newline(2) "=== [3/3] Running 03_regression.do ==="
do "03_regression.do"

display as text _newline(2) "=== Pipeline complete. Outputs written to ./output/ ==="
