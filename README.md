# Digital-Economy Development and the Skill Composition of Chinese Employment (2013–2022)

Undergraduate dissertation, School of Economics,
University of Nottingham Ningbo China.

- **Author:** Airui Meng — [am6817@tc.columbia.edu](mailto:am6817@tc.columbia.edu)
- **Supervisor:** Prof. Zhenjiang Lin
- **Submitted:** July 2025

---

## Summary

This project estimates how the development of the digital economy reshapes
the skill composition of labor demand in China, using a balanced province
× year panel of all 31 provincial-level administrative units from 2013 to 2022.
The outcome is the share of employment classified by human-capital tier
(low- / mid- / high-skill, defined by educational attainment). The core
treatment is a composite digital-economy index built from 22 third-level
indicators spanning digital infrastructure, digital industry development,
and digital ecosystem dimensions.

**Key findings**

- **Inverted-U** effect on low-skill employment: early-stage job creation
  via digital-enabled service expansion, later-stage job substitution via
  automation.
- **Positive U-shape** on high-skill employment.
- Mid-skill employment response is not statistically significant.
- Significant **east / inland regional heterogeneity**: eastern coastal
  provinces have already entered the skill-upgrading phase, while inland
  provinces remain dominated by low-skill growth.
- The pattern is consistent with the **skill-biased technological change**
  literature.

## Methodology

- **Composite treatment index.** 22 third-level indicators are aggregated
  into a single digital-economy score with data-driven weights. The
  Entropy Weight Method (EWM, following He et al. 2023) provides the main
  weights; Principal Component Analysis (PCA) is used as a robustness
  check.
- **Model selection.** Hausman tests across all three skill-share outcomes
  reject random effects at the 1% level, supporting the fixed-effects
  specification.
- **Main estimator.** Two-way fixed-effects panel regression with province
  and year effects.
- **Diagnostics.** Variance Inflation Factor (mean VIF ≈ 1.89) confirms
  the absence of serious multicollinearity.
- **Robustness.** Substitution-variable robustness check using the
  PCA-based digital-economy index in place of the EWM index.
- **Heterogeneity.** Separate fixed-effects regressions for inland and
  coastal provinces.

## Identification strategy

The main threat to identification is that provinces with stronger
fundamentals may both digitize faster and undergo more skill-upgrading in
their labor force, biasing the OLS estimate of the digital-economy effect.
I address this with an instrumental variable constructed as

```
iv = (1 / Terrain_undulation) × internet_user
```

This follows the shift-share logic used in the digital-infrastructure
literature: provincial terrain ruggedness is geographically predetermined
and exogenous to current labor-market outcomes, but strongly predicts the
cost of laying digital infrastructure; provincial internet-user growth
provides the time-varying component. The specification is exactly
identified (one instrument for one endogenous regressor); the first-stage
and weak-instrument diagnostics are reported in the main thesis.

**What the instrument identifies.** Because the instrument enters in logs,
log(iv) = log(internet_user) − log(Terrain_undulation). The terrain term is
time-invariant within a province, so it is absorbed by the province fixed
effects: terrain explains why provinces differ in the *level* of digital
infrastructure, but contributes no identifying variation once province effects
are included, and the identifying variation comes from provincial
internet-user growth. For the same reason the 2SLS specifications are estimated
with province fixed effects only, without the year dummies used in the
benchmark regressions — so they do not absorb common national shocks, and the
exclusion restriction has to carry more weight than the shift-share framing
alone suggests. The 2SLS results should be read as exploratory alongside the
fixed-effects benchmark rather than as the paper's identified estimate.

**Data sources for the IV:**

- `Terrain_undulation`: National Geomatics Center of China
- `internet_user`: National Bureau of Statistics of China, China Statistical
  Yearbook, 2013–2022

## Software

- **Stata** (recommended 17 or later)
- User-written packages, installed automatically on first run by
  `00_master.do`: `estout`, `asdoc`, `factortest`, `ranktest`, `ivreg2`, `xtivreg2`
  (`ranktest` is a hard dependency of `ivreg2`/`xtivreg2` that `ssc install` does not pull in
  automatically)

## Replication

1. Clone the repository:
   ```bash
   git clone https://github.com/airuimeng1/UG_thesis_code_repository.git
   cd UG_thesis_code_repository
   ```
2. Open Stata and set the working directory to the repository root:
   ```stata
   cd "/path/to/UG_thesis_code_repository"
   ```
3. Run `00_master.do`. It creates `output/`, installs any missing
   user-written packages, and then runs the pipeline in three stages:
   - `01_ewm_index.do` — builds the EWM composite index from
     `independent_variables.xlsx`
   - `02_pca_index.do` — builds the PCA-based index for robustness
   - `03_regression.do` — loads `regression_data.xlsx`, runs Hausman tests,
     descriptive statistics, VIF diagnostics, the correlation matrix, the
     benchmark two-way FE regressions, the substitution-variable
     robustness checks, the inland/coastal heterogeneity analysis, and
     the 2SLS specification
4. Results are written to `./output/`: the four regression tables as RTF
   (`04_benchmark_regression.rtf`, `05_robustness_substitution.rtf`,
   `06_heterogeneity.rtf`, `07_2sls.rtf`), and the descriptive statistics
   and correlation matrix as `asdoc` Word files (`02_descriptive_stats.doc`,
   `03_correlation.doc`).

Every path in the do-files is relative to the working directory, so no
path editing is needed as long as Stata's working directory is the
repository root. You can also run the three do-files individually in
order if you prefer to inspect intermediate results.

## Repository contents

| File | What it is |
|---|---|
| `00_master.do` | Top-level runner: executes the whole pipeline |
| `01_ewm_index.do` | Stata code constructing the EWM composite index |
| `02_pca_index.do` | Stata code constructing the PCA composite index |
| `03_regression.do` | Stata code for all regressions, robustness, and 2SLS |
| `regression_data.xlsx` | Canonical merged province × year panel, 2013–2022 (52 variables) |
| `independent_variables.xlsx` | 22 third-level digital-economy indicators, plus EWM/PCA intermediate sheets |
| `dependent_variables.xlsx` | Dependent-variable blocks (skill shares, industry shares, stability) |
| `control_variables.xlsx` | Control-variable blocks |
| `ewm_processed_data.xls` | Saved snapshot of the EWM workflow output; re-running `01_ewm_index.do` writes `ewm_processed_data.xlsx` |
| `pca_processed_data.xls` | Saved snapshot of the PCA workflow output; re-running `02_pca_index.do` writes `pca_processed_data.xlsx` |

## Variable quick reference

The main regression panel (`regression_data.xlsx`, sheet `panel data`)
contains 52 variables. The ones used in `03_regression.do` are:

| Variable | Role | Definition |
|---|---|---|
| `id`, `year`, `province` | Panel keys | Province administrative code, year, name |
| `low_skill_pct`, `mid_skill_pct`, `high_skill_pct` | Outcomes | Employment share by educational tier |
| `digital_e` | Main treatment | EWM composite digital-economy index |
| `digital_p` | Robustness treatment | PCA composite digital-economy index |
| `human_capital` | Control | Tertiary-enrollment share / population |
| `rd_intensity` | Control | R&D expenditure / GDP |
| `digitalization` | Control | Postal and telecommunications service / GDP |
| `gov_intervention` | Control | Fiscal expenditure / GDP |
| `industry` | Control | Industrial value added / GDP |
| `inland_city`, `coastal_province` | Heterogeneity indicators | Province classification |
| `Terrain_undulation`, `internet_user` | IV inputs | Used to build `iv = (1/Terrain_undulation) × internet_user` |

## Data sources

All variables come from public Chinese macroeconomic sources:

- National Bureau of Statistics of China (provincial panel indicators,
  2013–2022)
- China Statistical Yearbook (provincial volumes)
- China Labor Statistical Yearbook (dependent variables)
- Peking University Digital Finance Research Center (Digital Financial
  Inclusion Index)
- National Geomatics Center of China (terrain undulation)

All included `.xlsx` files contain only public or processed aggregate
indicators; no confidential microdata are redistributed.

## License

MIT License — see [`LICENSE`](LICENSE) for details.
