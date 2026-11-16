* =============================================================================
*  The Impact of Food Insecurity on Subjective Welfare:
*  Evidence from Households in Tanzania
*
*  Replication do-file - Hawa KEBE
*  March 2025, revised November 2026.
*  Revised and extended version of a group project report written with
*  Maty GUEYE and Youmna MOHAMED (Applied Econometrics II, M1 International
*  Economics Studies, UPEC).
*
*  Data:    database_TZA.dta
*           Tanzania National Panel Survey 2019-2020, Extended Panel with Sex
*           Disaggregated Data (World Bank LSMS, catalog no. 3885)
*  Outputs: output/  (log file, figures .png, regression tables .doc)
*
*  Structure:
*    0. Setup
*    1. Variable construction
*    2. Coding of the dependent variable (tests for merging categories)
*    3. Descriptive statistics and figures      (Table 1, Figures 1-3)
*    4. Correlation matrix                      (Table 2)
*    5. Ordered logit models                    (Table 3)
*    6. Average marginal effects                (Table 4)
*    7. Robustness                              (Table 5)
*
* =============================================================================

* -----------------------------------------------------------------------------
* 0. Setup
* -----------------------------------------------------------------------------
version 14
clear all
set more off
capture log close

cd "/Users/hawakebe/Downloads/Projects/Tanzania" 

capture mkdir "output"
log using "output/food_insecurity_tanzania.log", replace text

* outreg2 exports the regression tables; install it once if needed
capture which outreg2
if _rc ssc install outreg2

use "database_TZA.dta", clear

* -----------------------------------------------------------------------------
* 1. Variable construction
* -----------------------------------------------------------------------------

* Household size: number of individuals listed in the household roster
bysort HHID: generate HouseholdSize = _N
label variable HouseholdSize "Household size (roster members)"

* The survey codes yes/no questions as 1 = yes, 2 = no. Recode to 1/0.
label define yesno 0 "NO" 1 "YES"

generate byte FoodInsecurity = (hh_h01 == 1) if !missing(hh_h01)
label variable FoodInsecurity "Worried about not having enough food, past 7 days"

generate byte FoodShortage12m = (hh_h08 == 1) if !missing(hh_h08)
label variable FoodShortage12m "Did not have enough food at some point, past 12 months"

generate byte Labor = (hh_e03 == 1) if !missing(hh_e03)
label variable Labor "Worked as an employee for a wage, past 7 days"

generate byte Healthcare = (hh_d02 == 1) if !missing(hh_d02)
label variable Healthcare "Visited a health care provider, past 4 weeks"

label values FoodInsecurity FoodShortage12m Labor Healthcare yesno

* Estimated rental value of the dwelling, in TSH and in units of 100,000 TSH
generate double HousingCost = hh_i04
generate double HousingCost100k = hh_i04 / 100000
label variable HousingCost     "Estimated rental value of the dwelling (TSH)"
label variable HousingCost100k "Estimated rental value of the dwelling (100,000 TSH)"

* Demographic controls used in the robustness analysis
generate byte Female = (hh_b02 == 2) if !missing(hh_b02)
label variable Female "Female"

generate Age = hh_b04
generate AgeSq100 = Age^2 / 100
label variable Age      "Age (years)"
label variable AgeSq100 "Age squared / 100"

generate byte School = (hh_c03 == 1) if !missing(hh_c03)
label variable School "Ever attended school"

* Marital status: 1 monogamous married, 2 polygamous married, 3 living together
generate byte Married = inlist(hh_b19, 1, 2, 3) if !missing(hh_b19)
label variable Married "Married or living together"

generate byte Urban = (sdd_rural == 2) if !missing(sdd_rural)
label variable Urban "Urban"

* -----------------------------------------------------------------------------
* 2. Coding of the dependent variable
* -----------------------------------------------------------------------------

* hh_g03_9: "How satisfied or dissatisfied would you say you are with your
* life as a whole?"  1 = very satisfied ... 7 = very dissatisfied,
* 8 = not applicable (3 respondents, dropped).
tabulate hh_g03_9, missing
drop if hh_g03_9 == 8

* Reverse the scale so that higher values mean higher satisfaction
generate byte Satisfaction7 = 8 - hh_g03_9
label define sat7 1 "VERY DISSATISFIED" 2 "DISSATISFIED" 3 "SOMEWHAT DISSATISFIED" ///
                  4 "NEITHER SATISFIED NOR DISSATISFIED" 5 "SOMEWHAT SATISFIED"    ///
                  6 "SATISFIED" 7 "VERY SATISFIED"
label values Satisfaction7 sat7

* Pearson chi-squared tests on each pair of adjacent categories: do they
* differ in their relationship with food insecurity?
forvalues k = 1/6 {
    local j = `k' + 1
    tabulate Satisfaction7 FoodInsecurity if inlist(Satisfaction7, `k', `j'), chi2
}

* "Dissatisfied" and "somewhat dissatisfied" cannot be distinguished
* (p = 0.221) and are merged. The middle category is kept as a separator.
recode Satisfaction7 (1 = 1) (2 3 = 2) (4 = 3) (5 = 4) (6 = 5) (7 = 6), ///
    generate(SubjectiveWelfare)
label define sat6 1 "VERY DISSATISFIED" 2 "DISSATISFIED" 3 "INDIFFERENT" ///
                  4 "SOMEWHAT SATISFIED" 5 "SATISFIED" 6 "VERY SATISFIED"
label values SubjectiveWelfare sat6
label variable SubjectiveWelfare "Satisfaction with life as a whole (1 to 6)"

* -----------------------------------------------------------------------------
* 3. Descriptive statistics and figures
* -----------------------------------------------------------------------------

codebook SubjectiveWelfare FoodInsecurity Labor Healthcare HousingCost, compact
tabulate SubjectiveWelfare
tabulate FoodInsecurity
tabulate Labor
tabulate Healthcare
summarize HousingCost, detail

* Share of food-insecure individuals within each satisfaction category
tabulate SubjectiveWelfare FoodInsecurity, row nofreq

* Estimation sample of the main specification
quietly ologit SubjectiveWelfare FoodInsecurity Labor Healthcare HousingCost100k
generate byte Sample = e(sample)

* Table 1: summary statistics, estimation sample
tabstat SubjectiveWelfare FoodInsecurity FoodShortage12m Labor Healthcare     ///
        HousingCost100k Female Age School Married HouseholdSize Urban          ///
        if Sample, statistics(n mean sd min max) columns(statistics) format(%9.3f)

* Figure 1: distribution of life satisfaction
graph pie, over(SubjectiveWelfare) pie(1, explode) pie(2, explode) pie(3, explode) pie(4, explode) pie(5, explode) pie(6, explode) plabel(_all percent, format(%9.2f)) title("Proportion of Individuals by Life Satisfaction Levels", size(medium)) note("Source: World Bank LSMS Tanzania - Plus 2019-2020", size(small)) legend(cols(2) size(small))
graph export "output/fig1_life_satisfaction.png", replace width(2000)

* Figure 2: food insecurity
graph pie, over(FoodInsecurity) pie(1, explode) pie(2, explode) plabel(_all percent, format(%9.2f)) title("Proportion of Individuals Worried About Food Insecurity", size(medium)) note("Source: World Bank LSMS Tanzania - Plus 2019-2020", size(small))
graph export "output/fig2_food_insecurity.png", replace width(2000)

* Figure 3: food insecurity status by life satisfaction level
graph bar (percent), over(SubjectiveWelfare, label(angle(45) labsize(small))) over(FoodInsecurity) title("Food Insecurity Status by Life Satisfaction Levels") ytitle("Percent") note("Source: World Bank LSMS Tanzania - Plus 2019-2020") stack
graph export "output/fig3_fi_by_satisfaction.png", replace width(2000)

* -----------------------------------------------------------------------------
* 4. Correlation matrix (Table 2)
* -----------------------------------------------------------------------------

pwcorr SubjectiveWelfare FoodInsecurity Labor Healthcare HousingCost, sig

* -----------------------------------------------------------------------------
* 5. Ordered logit models (Table 3)
* -----------------------------------------------------------------------------

* Model 1: food insecurity only, heteroskedasticity-robust standard errors
ologit SubjectiveWelfare FoodInsecurity, vce(robust)
outreg2 using "output/Table3_ologit.doc", replace ctitle(Model 1) label

* Model 2: with controls, heteroskedasticity-robust standard errors
ologit SubjectiveWelfare FoodInsecurity Labor Healthcare HousingCost100k, vce(robust)
outreg2 using "output/Table3_ologit.doc", append ctitle(Model 2) label

* Model 3 (preferred): same specification, standard errors clustered by
* household. Food insecurity and housing cost take one value per household,
* so individuals of the same household are not independent observations.
ologit SubjectiveWelfare FoodInsecurity Labor Healthcare HousingCost100k, vce(cluster HHID)
outreg2 using "output/Table3_ologit.doc", append ctitle(Model 3) label

* Odds ratios for Model 3
ologit, or

* -----------------------------------------------------------------------------
* 6. Average marginal effects from Model 3 (Table 4)
* -----------------------------------------------------------------------------

* Effect of each regressor on the probability of each satisfaction category
margins, dydx(*)

* -----------------------------------------------------------------------------
* 7. Robustness (Table 5)
* -----------------------------------------------------------------------------

global controls Female Age AgeSq100 School Married HouseholdSize Urban

* (1) Baseline: Model 3
ologit SubjectiveWelfare FoodInsecurity Labor Healthcare HousingCost100k, vce(cluster HHID)
outreg2 using "output/Table5_robustness.doc", replace ctitle(Baseline) label

* (2) Demographic controls
ologit SubjectiveWelfare FoodInsecurity Labor Healthcare HousingCost100k $controls, ///
    vce(cluster HHID)
outreg2 using "output/Table5_robustness.doc", append ctitle(Controls) label

* (3) Alternative measure: food shortage in the past 12 months
pwcorr FoodInsecurity FoodShortage12m
ologit SubjectiveWelfare FoodShortage12m Labor Healthcare HousingCost100k $controls, ///
    vce(cluster HHID)
outreg2 using "output/Table5_robustness.doc", append ctitle(12-month measure) label

* (4) Linear model (OLS), treating the six-point scale as cardinal
regress SubjectiveWelfare FoodInsecurity Labor Healthcare HousingCost100k $controls, ///
    vce(cluster HHID)
outreg2 using "output/Table5_robustness.doc", append ctitle(OLS) label

* Baseline with standard errors clustered by enumeration area (in the text).
* The identifier is missing for part of the sample, so N is smaller here.
ologit SubjectiveWelfare FoodInsecurity Labor Healthcare HousingCost100k, ///
    vce(cluster sdd_cluster)

* -----------------------------------------------------------------------------
log close
