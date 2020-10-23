
/*******************************************************************************

Data setup for lasso variable selection in R. 
Creates full set of covariates and interactions to be used in lasso models 

*******************************************************************************/

* load full dataset
use "/Users/scottmiller/Dropbox (UFL)/LSIL 2/Work Spaces/Scott/Side-Selling/Data/sales_final.dta", clear
				

* keep relevant variables				 
keep co_sale price LS8 LS9 net_goat_income_w idx district HHR4 HHR14 ID10 pre_goats_owned bHHR16 mem_length ///
		bMEM4 MEM7 n_services index_emp nfloors dirt_floor geo_dist_mi GPS_altitude 
				 

* full set of interactions	
* ---------------------------------------------
local controls HHR4 HHR14 ID10 pre_goats_owned bHHR16 mem_length bMEM4 MEM7 ///
		n_services index_emp nfloors dirt_floor geo_dist_mi GPS_altitude
		
/* The local macro covs now contains a list of variables */
local q: list sizeof controls
local qq = `q' - 1 // This is used later.
tokenize `controls' 

global interact
			 
forvalues i = 1/`qq' { // Loop from the first element of covs to the last
	local k = `i' + 1
	forvalues j = `k'/`q' {
		g ``i''X``j'' = ``i''*``j''
		gl interact $interact ``i''X``j'' 
	}
}
* ---------------------------------------------

* full set of squared terms
global sqrd

foreach v of varlist HHR4 HHR14 ID10 pre_goats_owned mem_length MEM7 ///
		n_services index_emp nfloors geo_dist_mi GPS_altitude {
	
	gen `v'_sq = `v'*`v'	
	gl sqrd $sqrd `v'_sq
}

export excel using "/Users/scottmiller/Desktop/lasso_psm_vars.xlsx", firstrow(variables) replace

save "/Users/scottmiller/Dropbox (UFL)/LSIL 2/Work Spaces/Scott/Side-Selling/Data/sales_final_full.dta", replace 	
