# The Impact of Food Insecurity on Subjective Welfare: Evidence from Households in Tanzania

Research paper by Hawa Kebe (March 2025, revised November 2026). Revised and extended version of a group project report written with Maty Gueye and Youmna Mohamed for the course Applied Econometrics II (Master 1 International Economics Studies, Université Paris-Est Créteil).

## Summary

The paper studies the relationship between food insecurity and self-reported life satisfaction in Tanzania with the 2019-2020 National Panel Survey (World Bank LSMS). It estimates ordered logit models with standard errors clustered by household, since food insecurity is reported once per household. Individuals in food-insecure households are about 11 percentage points more likely to be dissatisfied with their life. The result is robust to demographic controls, to a 12-month measure of food shortage and to linear estimation.

## Contents

| File | Description |
|---|---|
| `KEBE_Food_Insecurity_Subjective_Welfare_Tanzania.pdf` | Paper |
| `food_insecurity_tanzania.do` | Stata do-file: variable construction, descriptive statistics, figures, ordered logit models, marginal effects, robustness |
| `food_insecurity_tanzania.log` | Stata log of the full run: every command with its output, so the results in the paper can be checked without access to the data |

## Data

The microdata are not redistributed here. The Tanzania National Panel Survey 2019-2020, Extended Panel with Sex Disaggregated Data, is available on request from the World Bank Microdata Library: https://microdata.worldbank.org/index.php/catalog/3885

## How to run

Software: Stata 14 or later, with the user-written command `outreg2` (installed by the do-file if missing).

1. Save the survey file as `database_TZA.dta` in the same folder as the do-file.
2. Edit the `cd` line at the top of the do-file so that it points to that folder.
3. Run the do-file. The log, figures and tables are written to an `output` sub-folder.
