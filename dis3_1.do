
*pathways
gl d0 = "/Users/scottmiller/Dropbox (UFL)/LSIL/Pre-Analysis Plan/PAP Master Replication" // master replication file
*gl d0 = "C:/Users/Conner/Dropbox/LSIL/Pre-Analysis Plan/PAP Master Replication" // master replication file
gl d1 = "$d0/Stata Files" // do files stored here
gl d2 = "$d0/Output" // used to store output
gl d3 = "$d0/Data/Clean Data" // clean data folder
gl d4 = "$d0/Data/Original Data" // original data


/*******************************************************************************
lsilPAP4.d0		
					
- Creates indicator variables & ICW Summary Indices from
	r_CO_Merged_PAP.dta (co-op level dataset)
	and r_HH_Merged_PAP.dta (HH level dataset)
	Saves new datasets respectively as: 
	r_CO_Merged_Ind.dta
	r_HH_Merged_Ind.dta
	
*******************************************************************************/


clear
set more off, perm

*log
cap log close
log using "$d1/lsilPAP4.smcl", replace


cd "$d3" 

** co-op dataset **
clear
use "r_CO_Merged_PAP.dta"

* Drop Banke District & Pilot Co-op
drop if district == "Banke"
drop if r_treat ==.
drop if idx == "" 

encode region, gen(n_region) // create numerical region variable for regression


** Communication **

* factors that limit communication
/* Variables
Mobile Network : COMM8b
Distance : COMM8d
*/

foreach i in a b c d {
	tab COMM1`i'
	tab COMM2`i'
}

forvalues i=1/8 {
	tab COMM6_`i'
	tab COMM7_`i'
}

foreach i in a b c d e f {
	tab COMM8`i'
}



* transparency
/* Variables
Mandate : CO_TRN1
Annual Report : CO_TRN2
Annual Budget : CO_TRN3
Financial Report: CO_TRN4
Meeting minutes : CO_TRN5
Election Results : CO_TRN6
Sale Records : CO_TRN7
*/


** Planning and Goals **

/* Variables 

Time Horizon : PNG2
Expected Goats Sold : PNG3
Expected Rev. : PNG4
*/

replace PNG2 =. if PNG2 == 99

* replace missing values with median
* ----------------------------------
forvalues i=2/4 {
	quietly sum PNG`i', d
	replace PNG`i' = `r(p50)' if PNG`i' ==. 
}
* ----------------------------------

* convert to USD
gen expected_rev = PNG4*(0.0099)


foreach v of varlist PNG3 expected_rev {
	
	** Winsorize with random treatment status
	* -----------------------------------------------
	gen `v'_wr = `v'
	
	* treatment
	sum `v'_wr if r_treat == 1, d
	scalar t_99 = r(p99)

	replace `v'_wr = t_99 if `v'_wr > t_99 & !missing(`v'_wr) & r_treat == 1

	sum `v'_wr if r_treat == 1, d
	scalar t_1= r(p1)

	replace `v'_wr = t_1 if `v'_wr < t_1 & !missing(`v'_wr) & r_treat == 1


	*control
	sum `v'_wr if r_treat == 0, d
	scalar c_99 = r(p99)

	replace `v'_wr = c_99 if `v'_wr > c_99 & !missing(`v'_wr) & r_treat == 0

	sum `v'_wr if r_treat == 0, d
	scalar t_1= r(p1)

	replace `v'_wr = t_1 if `v'_wr < t_1 & !missing(`v'_wr) & r_treat == 0
	* -----------------------------------------------
	
	** Winsorize with true treatment status
	* -----------------------------------------------
	gen `v'_w = `v'
	
	* treatment
	sum `v'_w if treat == 1, d
	scalar t_99 = r(p99)

	replace `v'_w = t_99 if `v'_w > t_99 & !missing(`v'_w) & treat == 1

	sum `v'_w if treat == 1, d
	scalar t_1= r(p1)

	replace `v'_w = t_1 if `v'_w < t_1 & !missing(`v'_w) & treat == 1


	*control
	sum `v'_w if treat == 0, d
	scalar c_99 = r(p99)

	replace `v'_w = c_99 if `v'_w > c_99 & !missing(`v'_w) & treat == 0

	sum `v'_w if treat == 0, d
	scalar t_1= r(p1)

	replace `v'_w = t_1 if `v'_w < t_1 & !missing(`v'_w) & treat == 0
	* -----------------------------------------------
}



** Cooperative Characteristics **

/* Variables 
Members : MAN3
Revenue from all activities : REV4
# of computers owned : EQP1_2
# of phones owned : EQP2_2
# of printers owned : EQP2_2X
# of weighing scales owned : EQP4_2
# of trucks or vans : EQP5_2
# of covered collection centers : EQP6_2
*/

gen goats_sold = REC1

* Convert to USD as of 1/1/18

gen revenue = REV4*(0.0099)
gen costs = REC7*(0.0099)
gen assets = FAL1*(0.0099)
gen liabilities = FAL2*(0.0099)
gen goatrev = REC4_1*(0.0099)

gen net_rev = revenue - costs
gen net_finances = (revenue - costs) + (assets - liabilities)

* per member
gen rev_member = revenue / MAN3
gen cost_member =  costs / MAN3
gen assets_member = assets / MAN3
gen liab_member = liabilities / MAN3
gen net_rev_member = net_rev / MAN3
gen net_finances_member = net_finances / MAN3
gen goatrev_member = goatrev / MAN3

** Replace Missing values with zero 
foreach v of varlist EQP1_2 EQP2_2 EQP2_2X EQP4_2 EQP5_2 EQP6_2 ///
					goats_sold revenue rev_member costs cost_mem {
	replace `v' = 0 if `v' ==.
}	


* ICT and non-ICT assets
gen ICTassets = EQP1_2 + EQP2_2
gen Otherassets = EQP2_2X + EQP4_2 + EQP5_2 + EQP6_2


* Sells goats
replace CO_SER15 = 1 if CO_SER15 > 0



** HH dataset **
clear
use "r_HH_Merged_PAP.dta"


* disagreement
replace CO_SER15 = 1 if CO_SER15 > 0
tab SER15
tab CO_SER15

bysort CO_SER15 : tab SER15

gen coord_agree = 1 if SER15 == 1 & CO_SER15 == 1 
replace coord_agree = 2 if SER15 == 0 & CO_SER15 == 0
replace coord_agree = 3 if SER15 == 0 & CO_SER15 == 1 
replace coord_agree = 4 if SER15 == 1 & CO_SER15 == 0 

lab define agree 1 "Both Yes" 2 "Both No" 3 "CO Yes - HH No" 4 "CO No - HH Yes"
lab values coord_agree agree

tab coord_agree



