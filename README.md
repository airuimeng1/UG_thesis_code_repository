# Undergraduate Thesis – Data & Stata Code (EWM / PCA / Regressions)

This repository contains the materials for my undergraduate thesis, including:
- the full thesis PDF,
- the processed datasets used in the analysis, and
- Stata `.do` files for index construction and regression analysis.

> **Thesis title:** *(What changes has the development of the digital economy brought to China's employment structure?)*  
> **Author:** Airui Meng  
> **Keywords:** Entropy Weight Method (EWM), Principal Component Analysis (PCA), Stata, empirical regression

---

## Repository contents

| File | What it is |
|---|---|
| `essay.pdf` | The complete thesis write-up |
| `EWM code.do` | Stata code for constructing an index using **Entropy Weight Method (EWM)** |
| `PCA code.do` | Stata code for constructing an index using **Principal Component Analysis (PCA)** |
| `regression code.do` | Stata regression code for the main empirical results |
| `Processed Data EWM.xls` | Processed dataset used for the EWM construction |
| `Processed data PCA.xls` | Processed dataset used for the PCA construction |
| `independent V.xlsx` | Independent variables (processed) |
| `dependent V.xlsx` | Dependent variables (processed) |
| `control V.xlsx` | Control variables (processed) |

---

## How to reproduce the results

### Requirements
- **Stata** (recommended: Stata 16+)
- Ability to read Excel files (`.xls` / `.xlsx`) in Stata

### Quick start
1. Download or clone this repository.
2. Open Stata and set your working directory to the repo folder, e.g.
   ```stata
   cd "/path/to/UG_thesis_code_repository"
