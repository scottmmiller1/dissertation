
/*******************************************************************************

Estimates ATT models using covariates selected by Lasso as applied in R.
Applied 10-fold cross validation to select tuning parameter (and covariates) 

*******************************************************************************/


*capture log close
clear all
set more off
set matsize 11000
set maxvar 20000
local seed 13489
set seed `seed' 

log using "/Users/scottmiller/Dropbox (UFL)/LSIL 2/Work Spaces/Scott/Lasso_Select/Logs/lasso_psm_est", replace

cd "/Users/scottmiller/Dropbox (UFL)/LSIL 2/Work Spaces/Scott/Lasso_Select/"


* Run R program to run lasso estimation and store output to .csv files
*shell "C:/Program Files/R/R-3.3.1/bin/x64/R.exe" CMD BATCH "$d3/do files for food policy resubmit 1/Plantain_lasso_IHSa.R" "$d3/logs/RlogIHSa.txt"

* number of lasso covariate sets (change this number to reflect # of columns in lasso output .csv files)
local ps_lcount 68 // 54		// pscore lasso
local y_lcount 96 // 64		// outcome lasso


******************************************************************
** Select covariates for pscore model from Lasso selection in R **
******************************************************************


* load lasso selection output
insheet using "lasso output/coef_pscore.csv", clear

drop if v1 == "(Intercept)"
save temp_pscore.dta, replace


* Step 1: Remove covariates with zero parameter values and store covariate sets as locals
* ---------------------------------------------------------------
* Loop over variable sets
forv i = 0/`ps_lcount' {
	use temp_pscore.dta, clear
	* Keep variables with non-zero coefficients
	quietly keep if s`i' != 0
	quietly count
	if `r(N)' == 0 {
		local pscore_vars`i'
		continue
	}
	*List of retained variables
	quietly levelsof v1, local(a)
	local z: list sizeof local(a)
	tokenize `"`a'"'

	forv j = 1/`z' {
		local pscore_vars`i' "`pscore_vars`i'' ``j''"  // cannot remove ` and ' from string, so we have to loop to build variable lists
	}
}  
* ---------------------------------------------------------------


* Step 2: Run pscore model on each variable set, pick final set using CV
* ---------------------------------------------------------------

* load full dataset
use "/Users/scottmiller/Dropbox (UFL)/LSIL 2/Work Spaces/Scott/Side-Selling/Data/sales_final_full.dta", clear
					
local pscore_vars
set seed `seed'

* Step 2.1: create 5 equal groups within treatment and control groups
	* -------------------------------
	* Generate folds for 5 fold cross validation
	g random = uniform()
	sort co_sale random
	by co_sale: g n = _n
	g fold = .
	
	count if co_sale == 1
	count if co_sale == 0

	forv i = 1/5 {		
		local j = `i'*85
		replace fold = `i' if n <= `j' & fold == . & co_sale == 1
		local j = `i'*264
		replace fold = `i' if n <= `j' & fold == . & co_sale == 0
	}
	replace fold = 1 if fold == .
	* -------------------------------

	
* Step 2.2: Run logit 5-fold cross validaion on each variable set
	* -------------------------------
	quietly forv i = 0/`ps_lcount' {
	
		g double deviance_`i' = . // fill in as we loop over folds
		g one_`i' = .
	
		forv k = 1/5 {
			set seed `seed' 
			cap logit co_sale `pscore_vars`i'' if fold != `k', iterate(100) difficult
			if _rc != 0 {
				continue
			}
			else {
				cap drop yhat
				predict double yhat
				replace deviance_`i' = -2*(co_sale*ln(yhat) + (1-co_sale)*ln(1 - yhat)) ///
				if fold == `k'
				replace one_`i' = 1 if deviance_`i' != .
			}
		}
	}
	* -------------------------------


* Step 2.3: get deviance measures for each variable combination and select covariate
* 			list with minimum deviance
	* -------------------------------
	collapse (sum) deviance_* one_*
	/*
	forv q = 0/`lcount' {
		replace deviance_`q' = . if one_`q' < 146
	}
	*/
	
	* minimum deviance
	egen double dev_min = rowmin(deviance_*)
	scalar min_dev = dev_min[1]

	* Pick variable set that minimizes the deviance
	forv i = 0/`ps_lcount' {
		cap scalar dev_`i' = deviance_`i'[1]
	
		if dev_`i' <= min_dev {
			di "Chosen variable set is set `i'"
			local pscore_vars "`pscore_vars`i''"
			di "`pscore_vars`i''"
			continue, break
		}
		else {
		}
	}
	* -------------------------------
* ---------------------------------------------------------------



*******************************************************************
** Select covariates for outcome model from Lasso selection in R **
*******************************************************************


* Step 3: Remove covariates with zero parameter values and store covariate sets as locals
* ---------------------------------------------------------------

* loads outcome-specific lasso selection output and loops through potentual covariate options
* 	as in Step 1

gl outcomes price LS8 net_goat_income_w

*local x 1

foreach v in $outcomes {
	insheet using "lasso output/coef_`v'.csv", clear
	drop if v1 == "(Intercept)"

	quietly forv i = 0/`y_lcount' {
		preserve
		keep if s`i' != 0
		
		if _N == 0 {
			restore // if no variables with non-zero coeffs, restore and skip remaining steps
			continue
		}
		else {
			qui levelsof v1, local(a)
			local z: list sizeof local(a)
			tokenize `"`a'"'
			
			local `v'_vars`i'
			
			forv j = 1/`z' {
				local `v'_vars`i' "``v'_vars`i'' ``j''"
			}

		}
		restore
	}
	
	*local ++x
}

*local x 1

* ---------------------------------------------------------------


* Step 4: Run regression model on each variable set, pick final set using CV
* ---------------------------------------------------------------

* load full dataset
use "/Users/scottmiller/Dropbox (UFL)/LSIL 2/Work Spaces/Scott/Side-Selling/Data/sales_final_full.dta", clear

set seed `seed' 


* Step 4.1: create 5 equal groups within treatment and control groups
	* -------------------------------
	* Pick folds for CV
	* Generate folds for 5 fold cross validation
		* Only uses control group
	gen random = uniform() if co_sale == 0
	sort random
	gen n = _n if co_sale == 0
	g fold = 1 if n <= 511 & co_sale == 0

	forv i = 2/5 {		
		local j = `i'*511
		replace fold = `i' if n <= `j' & fold == . & co_sale == 0
	}
	replace fold = 1 if fold == .
	* -------------------------------



* Loop over variable sets, pick set that minimizes mean sq CV error.

* Step 4.2: Run regression 5-fold cross validaion on each variable set
	* -------------------------------
	
	 foreach v in $outcomes {

		local `v'_vars
		cap drop deviance* one*

	* OLS 5-fold cross validation
		quietly forv i = 0/`y_lcount' {
		
			g double deviance_`i' = . if co_sale == 0  // fill in as we loop over folds
			g one_`i' = .
		
			forv k = 1/5 {
				set seed `seed'
				if "`v'" != "shock" & "`v'" != "drought" {			
					cap reg `v' ``v'_vars`i'' if fold != `k' & co_sale == 0
				}
				else {												// for binary outcome vars
					cap logit `v' ``v'_vars`i'' if fold != `k' & co_sale == 0, iterate(100) difficult
				}
				if _rc != 0 | e(converged) == 0 {
					continue
				}
				else {
					cap drop yhat
					predict double yhat if co_sale == 0
					if "`v'" != "shock" & "`v'" != "drought" {	
						replace deviance_`i' = (`v' - yhat)^2 if fold == `k' & co_sale == 0
					}
					else {											// for binary outcome vars
						replace deviance_`i' = -2*(co_sale*ln(yhat) + (1-co_sale)*ln(1 - yhat)) ///
						if fold == `k' & co_sale == 0
					}
					replace one_`i' = 1 if deviance_`i' != .
				}
			}
		}
	* -------------------------------	
		
* Step 4.3: get deviance measures for each variable combination and select covariate
* 			list with minimum deviance
	* -------------------------------
	preserve
	* get deviance measures for each variable combination
	collapse (sum) deviance_* one_*
	
	/*
	forv q = 0/`lcount' {
		replace deviance_`q' = . if one_`q' < 51
	}
	*/ 
	* minimum deviance
	egen double dev_min = rowmin(deviance_*) 
	scalar min_dev = dev_min[1]

	* Pick variable set that minimizes the deviance
	forv i = 0/`y_lcount' {
		scalar dev_`i' = deviance_`i'[1]
		
			if dev_`i' <= min_dev {
				di "Chosen variable set for `v' is set `i'"
				local `v'_vars "``v'_vars`i''"
				di "``v'_vars`i''"
				continue, break
			}
			else {
			}
		}
		restore
	}
	* -------------------------------
* ---------------------------------------------------------------



***********************************************************************************
** Estimate pscore and outcome models with full sample using selected covariates **
***********************************************************************************

* load full dataset
use "/Users/scottmiller/Dropbox (UFL)/LSIL 2/Work Spaces/Scott/Side-Selling/Data/sales_final_full.dta", clear

set seed `seed'

* pscore estimation with selected covariates
logit co_sale `pscore_vars'

*outreg2 using "Results/pscore1", excel br se sdec(3) label ctitle("Pscore logit") ///
*replace addstat(Pseudo R2, e(r2_p)) 


* generate propensity score
predict double pscore if e(sample) == 1

*sort formulario year
*replace pscore = F.pscore if year == 2009

* graphs of p-score distribution
lab var pscore "Propensity score"
g lpscore = ln(pscore/(1-pscore))
lab var lpscore "Linearized propensity score"
g weight = co_sale + (1-co_sale)*pscore/(1-pscore)


twoway (kdensity lpscore if co_sale == 1, lcolor(black) lwidth(medthick)) ///
(kdensity lpscore if co_sale == 0, lcolor(black) lpattern(dash) lwidth(medthick)) ///
(kdensity lpscore if co_sale == 0 [aw = weight], lcolor(black) lpattern(dash_dot) lwidth(medthick) ///
xlabel(,labsize(vsmall)) xtitle("") ylabel(, nogrid labsize(vsmall)) ytitle("Density", size(vsmall)) ///
graphregion(color(white) icolor(white)) ///
plotregion(color(white) icolor(white)) ///
legend(order(1 2 3) lab(1 "Treatment group") lab(2 "Control group") ///
lab(3 "Control group" "with inverse" "probability weights") ///
size(medsmall) ring(0) col(1) bplacement(nwest)))
graph save "Results/pscore_dens.gph", replace


* generate common support variable for robustness checks
su pscore if co_sale == 1
scalar treatmax = r(max)
scalar treatmin = r(min)

su pscore if co_sale == 0
scalar max = min(r(max), treatmax)
scalar min = max(r(min), treatmin)

g common = (pscore <= max & pscore >= min)

*graphs on common support
twoway (kdensity lpscore if co_sale == 1 & common == 1, lcolor(black) lwidth(medthick)) ///
(kdensity lpscore if co_sale == 0 & common == 1, lcolor(black) lpattern(dash) lwidth(medthick)) ///
(kdensity lpscore if co_sale == 0 & common == 1 [aw = weight], lcolor(black) lpattern(dash_dot) lwidth(medthick) ///
xlabel(,labsize(vsmall)) xtitle("") ylabel(, nogrid labsize(vsmall)) ytitle("Density", size(vsmall)) ///
graphregion(color(white) icolor(white)) ///
plotregion(color(white) icolor(white)) ///
legend(order(1 2 3) lab(1 "Treatment group") lab(2 "Control group") ///
lab(3 "Control group" "with inverse" "probability weights") ///
size(medsmall) ring(0) col(1) bplacement(nwest)))
graph save "Results/pscore_dens_comm.gph", replace



* table showing balance for variables in propensity score
* ---------------------------------------------------------------

putexcel set "Results/balance_lasso", sheet("pscore balance", replace) replace


putexcel B1 = ("Treatment group") B2 = ("Mean") C2 = ("Standard deviation") ///
D2 = ("Skewness") ///
E1 = ("Control group") E2 = ("Mean") F2 = ("Standard deviation") G2 = ("Skewness") ///
H1 = ("Inverse probability weighted control group") ///
H2 = ("Mean") I2 = ("Standard deviation") J2 = ("Skewness") ///
K1 = ("Unweighted sample") ///
K2 = ("Normalized difference") ///
L2 = ("p-value") M2 = ("Ratio of standard deviations") N2 = ("Ratio of skewness coefficients") ///
O1 = ("Inverse probability weighted sample") ///
O2 = ("Normalized difference") ///
P2 = ("p-value") Q2 = ("Ratio of standard deviations") R2 = ("Ratio of skewness coefficients")

putexcel set "Results/balance_lasso", sheet("pscore balance") modify

tokenize lpscore `pscore_vars'

local j: list sizeof local(pscore_vars)

local ++j

forv i = 1/`j' {
	local k = `i' + 2
	* Variable label
	local l ``i''
	* Summary stats, treated
	qui su ``i'' if co_sale == 1, d
	local tobs = r(N)
	local treatmean: display %05.2fc `r(mean)'
	scalar treatmean = r(mean)
	local treatsd: display %05.2fc `r(sd)'
	scalar treatsd = r(sd)
	local treatskew: display %05.2fc `r(skewness)'
	scalar treatskew = r(skewness)
	
	* Summary stats, control
	qui su ``i'' if co_sale == 0, d
	local cobs = r(N)
	local controlmean: display %05.2fc `r(mean)'
	scalar controlmean = r(mean)
	local controlsd: display %05.2fc `r(sd)'
	scalar controlsd = r(sd)
	local controlskew: display %05.2fc `r(skewness)'
	scalar controlskew = r(skewness)
	
	* difference in means: standardized difference
	local sdiff: display %05.2fc (abs(scalar(treatmean) - scalar(controlmean)))/((.5*scalar(controlsd)*scalar(controlsd) + .5*scalar(treatsd)*scalar(treatsd))^.5)
	* ratio of st. devs. and skewness
	local sd_ratio: di %05.2fc (treatsd/controlsd)
	local skew_ratio: di %05.2fc (treatskew/controlskew)
	
	* difference in means: t-test
	qui reg ``i'' co_sale
	local pvalue: display %05.3fc ttail(`e(df_r)' - 1, abs(_b[co_sale]/_se[co_sale]))*2
	
	* Summary stats, control IPW
	qui su ``i'' [aw = weight] if co_sale == 0, d
	local controlmean_ipw: di %05.2fc `r(mean)'
	scalar controlmean_ipw = r(mean)
	local controlsd_ipw: display %05.2fc `r(sd)'
	scalar controlsd_ipw = r(sd)
	local controlskew_ipw: display %05.2fc `r(skewness)'
	scalar controlskew_ipw = `r(skewness)'
	
	* difference in means with IPW: standardized difference
	local sdiff_ipw: display %05.2fc (abs(scalar(treatmean) - scalar(controlmean_ipw)))/((.5*scalar(controlsd_ipw)*scalar(controlsd_ipw) + .5*scalar(treatsd)*scalar(treatsd))^.5)
	* ratio of st. devs. and skewness, IPW
	local sd_ratio_ipw: di %05.2fc (treatsd/controlsd_ipw)
	local skew_ratio_ipw: di %05.2fc (treatskew/controlskew_ipw)
	
	* difference in means with IPW: t-test
	qui reg ``i'' co_sale [pw = weight]
	local pvalue_ipw: display %05.3fc ttail(`e(df_r)' - 1, abs(_b[co_sale]/_se[co_sale]))*2
	
	* Fill in the table
	putexcel A`k' = ("`l'") B`k' = ("`treatmean'") C`k' = ("`treatsd'") ///
	D`k' = ("`treatskew'") E`k' = ("`controlmean'") F`k' = ("`controlsd'") ///
	G`k' = ("`controlskew'") ///
	h`k' = ("`controlmean_ipw'") i`k' = ("`controlsd_ipw'") j`k' = ("`controlskew_ipw'") ///
	K`k' = ("`sdiff'") ///
	L`k' = ("`pvalue'") m`k' = ("`sd_ratio'") n`k' = ("`skew_ratio'") ///
	O`k' = ("`sdiff_ipw'") P`k' = ("`pvalue_ipw'") ///
	Q`k' = ("`sd_ratio_ipw'") R`k' = ("`skew_ratio_ipw'")
}

local jj = `j' + 3
local jjj = `j' + 4

putexcel A`jj' = ("Observations") B`jj' = ("`tobs'") e`jj' = ("`cobs'") ///
A`jjj' = ("Notes: Propensity score estimated via a logit regression, with covariates selected using the logit LASSO. The LASSO tuning parameter was selected by five-fold cross validation as applied to the post-LASSO (i.e. unpenalized) model. The normalized differences show the difference in means divided by the pooled sample standard deviation.")

* now on the common support

putexcel set "Results/balance_lasso", sheet("pscore balance CS", replace) modify

putexcel B1 = ("Treatment group") B2 = ("Mean") C2 = ("Standard deviation") ///
D2 = ("Skewness") ///
E1 = ("Control group") E2 = ("Mean") F2 = ("Standard deviation") G2 = ("Skewness") ///
H1 = ("Inverse probability weighted control group") ///
H2 = ("Mean") I2 = ("Standard deviation") J2 = ("Skewness") ///
K1 = ("Unweighted sample") ///
K2 = ("Normalized difference") ///
L2 = ("p-value") M2 = ("Ratio of standard deviations") N2 = ("Ratio of skewness coefficients") ///
O1 = ("Inverse probability weighted sample") ///
O2 = ("Normalized difference") ///
P2 = ("p-value") Q2 = ("Ratio of standard deviations") R2 = ("Ratio of skewness coefficients")

putexcel set "Results/balance_lasso", sheet("pscore balance CS") modify

preserve
drop if common == 0

forv i = 1/`j' {
	local k = `i' + 2
	* Variable label
	local l ``i''
	* Summary stats, treated
	qui su ``i'' if co_sale == 1, d
	local tobs = r(N)
	local treatmean: display %05.2fc `r(mean)'
	scalar treatmean = r(mean)
	local treatsd: display %05.2fc `r(sd)'
	scalar treatsd = r(sd)
	local treatskew: display %05.2fc `r(skewness)'
	scalar treatskew = r(skewness)
	
	* Summary stats, control
	qui su ``i'' if co_sale == 0, d
	local cobs = r(N)
	local controlmean: display %05.2fc `r(mean)'
	scalar controlmean = r(mean)
	local controlsd: display %05.2fc `r(sd)'
	scalar controlsd = r(sd)
	local controlskew: display %05.2fc `r(skewness)'
	scalar controlskew = r(skewness)
	
	* difference in means: standardized difference
	local sdiff: display %05.2fc (abs(scalar(treatmean) - scalar(controlmean)))/((.5*scalar(controlsd)*scalar(controlsd) + .5*scalar(treatsd)*scalar(treatsd))^.5)
	* ratio of st. devs. and skewness
	local sd_ratio: di %05.2fc (treatsd/controlsd)
	local skew_ratio: di %5.2fc (treatskew/controlskew)
	
	* difference in means: t-test
	qui reg ``i'' co_sale
	local pvalue: display %05.3fc ttail(`e(df_r)' - 1, abs(_b[co_sale]/_se[co_sale]))*2
	
	* Summary stats, control IPW
	qui su ``i'' [aw = weight] if co_sale == 0, d
	local controlmean_ipw: di %05.2fc `r(mean)'
	scalar controlmean_ipw = r(mean)
	local controlsd_ipw: display %05.2fc `r(sd)'
	scalar controlsd_ipw = r(sd)
	local controlskew_ipw: display %05.2fc `r(skewness)'
	scalar controlskew_ipw = `r(skewness)'

	* difference in means with IPW: standardized difference
	local sdiff_ipw: display %05.2fc (abs(scalar(treatmean) - scalar(controlmean_ipw)))/((.5*scalar(controlsd_ipw)*scalar(controlsd_ipw) + .5*scalar(treatsd)*scalar(treatsd))^.5)
	* ratio of st. devs. and skewness, IPW
	local sd_ratio_ipw: di %05.2fc (treatsd/controlsd_ipw)
	local skew_ratio_ipw: di %05.2fc (treatskew/controlskew_ipw)
	
	* difference in means with IPW: t-test
	qui reg ``i'' co_sale [pw = weight]
	local pvalue_ipw: display %05.3fc ttail(`e(df_r)' - 1, abs(_b[co_sale]/_se[co_sale]))*2
	
	* Fill in the table
	putexcel A`k' = ("`l'") B`k' = ("`treatmean'") C`k' = ("`treatsd'") ///
	D`k' = ("`treatskew'") E`k' = ("`controlmean'") F`k' = ("`controlsd'") ///
	G`k' = ("`controlskew'") ///
	h`k' = ("`controlmean_ipw'") i`k' = ("`controlsd_ipw'") j`k' = ("`controlskew_ipw'") ///
	K`k' = ("`sdiff'") ///
	L`k' = ("`pvalue'") m`k' = ("`sd_ratio'") n`k' = ("`skew_ratio'") ///
	O`k' = ("`sdiff_ipw'") P`k' = ("`pvalue_ipw'") ///
	Q`k' = ("`sd_ratio_ipw'") R`k' = ("`skew_ratio_ipw'")
}

local jj = `j' + 3
local jjj = `j' + 4

putexcel A`jj' = ("Observations") B`jj' = ("`tobs'") e`jj' = ("`cobs'") ///
A`jjj' = ("Notes: Propensity score estimated via a logit regression, with covariates selected using the logit LASSO. The LASSO tuning parameter was selected by five-fold cross validation as applied to the post-LASSO (i.e. unpenalized) model. The normalized differences show the difference in means divided by the pooled sample standard deviation.")

drop weight

restore
* ---------------------------------------------------------------



* ATT estimates
* ---------------------------------------------------------------
local obs = _N

local s: list sizeof global(outcomes)
local s = `s' + 4
local ss = `s' + 1

putexcel set "Results/ATT_psm_lasso", sheet("ATTs", replace) modify

putexcel b1 = ("") b2 = ("Full sample") ///
a3 = ("Outcome") b3 = ("ATT") c3 = ("Percent impact") ///
d3 = ("Standard error") ///
e3 = ("p-value") f3 = ("q-value") ///
g3 = ("95% Confidence Interval") ///
h2 = ("Median split") h3 = ("Mean ATT") i3 = ("Standard deviation") ///
a`s' = ("Observations") b`s' = (`obs') ///
a`ss' = (`"Notes: "')
 
putexcel set "Results/ATT_psm_lasso", sheet("ATTs") modify


/* ATTs and variances */
su co_sale
scalar P = r(mean) // used in ATT and variance formula


* We will store info for q-values below
g outcome = ""
tokenize $outcomes
local out: list sizeof global(outcomes)

forv i = 1/`out' {
	replace outcome = "``i''" if _n == `i'
}

g double pvalue = .

scalar N = _N
local ii = 4

foreach i in $outcomes {
	* regression model of untreated avg outcome
	cap drop ehat
	cap drop yhat
	cap drop att
	cap drop v_att
	
	qui reg `i' ``i'_vars' if co_sale == 0

	predict double ehat, resid
	predict double yhat, xb
	
	
	su `i' if co_sale == 1
	g double att = r(mean) - (1/P)*(co_sale*yhat + ((1 - co_sale)*ehat*pscore/(1-pscore)))
	
	su att
	scalar att_`i' = r(mean) // ATT

	g double v_att = (1/P)*(co_sale*(ehat - att_`i')*(ehat - att_`i')/(N*P)) + ///
					(1/P)*((1 - co_sale)*pscore*ehat*ehat/((1-pscore)*N*(1-P)))
	
	sum `i' if co_sale == 0
	scalar control_val = r(mean)
	
	scalar perc_`i' = 100*(att_`i' / control_val) // Percent impact 
	
	local perc_impact: di %5.2fc perc_`i'
	
	local att: di %05.2fc att_`i'
	
	local l: var lab `i'
	
	su v_att
	scalar se_`i' = r(mean)^.5 // Standard error
	scalar t_`i' = att_`i'/se_`i'
	local se: di %05.2fc se_`i'
	
	local df1: list sizeof local(pscore_vars)
	local df2: list sizeof local(`i'_vars)
	local df = _N - (2 + `df1' + `df2')
	
	local pvalue: di %05.3fc 2*ttail(`df',abs(scalar(att_`i')/scalar(se_`i')))
	replace pvalue = 2*ttail(`df',abs(scalar(att_`i')/scalar(se_`i'))) if outcome == "`i'" 
	
	local ci_lb: di %05.2fc att_`i' - se_`i'*invttail(`df', .025)
	local ci_ub: di %05.2fc att_`i' + se_`i'*invttail(`df',.025)
	
	putexcel a`ii' = ("`l'") b`ii' = ("`att'") c`ii' = ("`perc_impact'%") ///
	d`ii' = ("`se'") e`ii' = ("`pvalue'") g`ii' = ("{`ci_lb', `ci_ub'}")
	
}

log close



/*

cap drop ehat
cap drop yhat


* common support

* ATT estimates
local s: list sizeof global(outcomes)
local s = `s' + 4
local ss = `s' + 1

drop if common == 0

local obs = _N

g outcome = ""
tokenize $outcomes
local out: list sizeof global(outcomes)

forv i = 1/`out' {
	replace outcome = "``i''" if _n == `i'
}

g double pvalue09 = .


* number
putexcel set "$d3/results/nicaragua_lasso", sheet("ATTs CS", replace) modify

putexcel b1 = ("2009") b2 = ("Sample on common support of the propensity score") j1 = ("2010") ///
a3 = ("Outcome") b3 = ("ATT") c3 = ("Percent impact") ///
d3 = ("Standard error") ///
e3 = ("p-value") f3 = ("q-value") ///
g3 = ("95% Confidence Interval") ///
h2 = ("Median split") h3 = ("Mean ATT") i3 = ("Standard deviation") ///
j2 = ("Sample on common support of the propensity score") j3 = ("ATT") k3 = ("Percent impact") l3 = ("Standard error") ///
m3 = ("p-value") n3 = ("q-value") ///
o3 = ("95% Confidence Interval") ///
p2 = ("Median split") p3 = ("Mean ATT") q3 = ("Standard deviation") ///
a`s' = ("Observations") b`s' = (`obs') ///
a`ss' = (`"Notes: Sample restricted to the common support of the propensity score. Consumption expenditure, total input expenditure, and fertilizer are in natural log form. Exposure to shocks and drought are binary indicators. The inverse hyperbolic sine transformation was applied to all other dependent variables. ATT and standard errors estimated as in Farrell (2015). Percent impacts were calculated by exponentiating the estimated ATTs and subtracting one. All hypothesis tests conducted using a t-distribution with degrees of freedom given by the sample size minus the total number of parameters in the propensity score and regression models for each ATT. "Median split" results generated by splitting each original covariate at its median, re-estimating the ATT on each subsample, and generate a new estimate of the ATT using a weighted average of the subsample estimates. The median split results are the mean and standard deviation of the resulting ATT estimates. For each ATT, the q-value gives the proportion of rejected null hypotheses that would in fact be true if we rejected all null hypotheses with p-values no greater than what is reported for the given ATT. The q-values were calculated using the method of Benjamini and Hochberg (1995)."')

putexcel set "$d3/results/nicaragua_lasso", sheet("ATTs CS") modify













