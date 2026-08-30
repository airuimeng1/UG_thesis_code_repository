*===============================================================================
* 01_ewm_index.do
*   Construct the composite digital-economy index using the Entropy Weight
*   Method (EWM). The EWM assigns data-driven weights to each of the 22
*   third-level indicators based on their information entropy.
*
*   Author : Airui Meng
*   Input  : independent_variables.xlsx  (sheet: "panel data")
*   Output : ewm_processed_data.xlsx
*===============================================================================

clear all
set more off

local data_file "independent_variables.xlsx"

* ------------------------------------------------------------------------------
* 1. Load the raw panel (province x year, 22 third-level indicators x1..x22)
* ------------------------------------------------------------------------------
import excel "`data_file'", sheet("panel data") firstrow clear

tsset id year

* ------------------------------------------------------------------------------
* 2. Indicator list
* ------------------------------------------------------------------------------
global xlist1 "x1 x2 x3 x4 x5 x6 x7 x8 x9 x10 x11 x12 x13 x14 x15 x16 x17 x18 x19 x20 x21 x22"

* ------------------------------------------------------------------------------
* Step 1. Range-standardization
*         All indicators are positive, so we use the min-max transform.
* ------------------------------------------------------------------------------
foreach x of global xlist1 {
    egen min`x'      = min(`x')
    egen max`x'      = max(`x')
    gen  standard`x' = (`x' - min`x') / (max`x' - min`x')
}

* ------------------------------------------------------------------------------
* Step 2. Per-province per-year share of the standardized indicator
* ------------------------------------------------------------------------------
foreach x of global xlist1 {
    egen sum`x' = total(standard`x')
    gen  w1`x'  = standard`x' / sum`x'
}

* ------------------------------------------------------------------------------
* Step 3. Information entropy and redundancy
*         A small positive offset avoids log(0).
* ------------------------------------------------------------------------------
by id, sort: egen m1 = count(year)

foreach x of global xlist1 {
    gen  w`x'  = w1`x' + 0.0000000001
    egen e1`x' = total(w`x' * log(w`x'))
    gen  d`x'  = 1 + (1 / log(m1)) * e1`x'
}

* ------------------------------------------------------------------------------
* Step 4. Final indicator weights (w2*)
* ------------------------------------------------------------------------------
gen sumd1 = dx1 + dx2 + dx3 + dx4 + dx5 + dx6 + dx7 + dx8 + dx9 + dx10 + ///
            dx11 + dx12 + dx13 + dx14 + dx15 + dx16 + dx17 + dx18 + dx19 + ///
            dx20 + dx21 + dx22

foreach x of global xlist1 {
    gen w2`x' = d`x' / sumd1
}

* ------------------------------------------------------------------------------
* Step 5. Composite score per province-year
* ------------------------------------------------------------------------------
foreach x of global xlist1 {
    gen score_`x' = standard`x' * w2`x'
}

gen score = score_x1 + score_x2 + score_x3 + score_x4 + score_x5 + score_x6 + ///
            score_x7 + score_x8 + score_x9 + score_x10 + score_x11 + score_x12 + ///
            score_x13 + score_x14 + score_x15 + score_x16 + score_x17 + ///
            score_x18 + score_x19 + score_x20 + score_x21 + score_x22

label variable score "Digital-economy composite index (EWM)"

* ------------------------------------------------------------------------------
* 6. Persist the processed dataset for downstream use
* ------------------------------------------------------------------------------
export excel using "ewm_processed_data.xlsx", replace firstrow(variables)

display as text "EWM index construction complete. Output: ewm_processed_data.xlsx"
