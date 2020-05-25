
/*******************************************************************************
dis1_2.d0		

- Background statistics					
- Group definitions						
	
*******************************************************************************/


clear
set more off, perm
cd "$d2"


** HH level dataset
********************************************* 
clear
use "$d3/HH_Final.dta"

* leadership role
gen bMEM4 = (MEM4 > 1 & MEM4 !=.)
replace bMEM4 = . if MEM4 ==.

* primary activitiy is agriculture
gen bHHR16 = (HHR16=="1")

* Participate in annual general meeting
tab MEM12
* why don't you participate
tab MEM13
	
	forvalues i=1/7 {
		cap drop MEM13_`i'
		gen MEM13_`i' = (MEM13 == `i')
		replace MEM13_`i' =. if MEM13 == .
	}

* Services offered	
sum SER1-SER4 SER6-SER19	

cap drop no_services
gen no_services = CO_SER1 + CO_SER2 + CO_SER3 + CO_SER4 + CO_SER5 + CO_SER6 + CO_SER7 ///
				+ CO_SER8 + CO_SER9 + CO_SER10 + CO_SER11a + CO_SER12 + CO_SER13 + CO_SER14 ///
				+ CO_SER15 + CO_SERV2 + CO_SER18


* financial inclusion

	
* ----------------------------------------------------------------------

** Group variable definitons


** Extensive
* ----------------------------------
* Pct literate
	* 
	cap drop pct_HHR14 gr_pct_HHR14
	bysort idx: egen pct_HHR14 = mean(HHR14)
	
	* group var
	sum pct_HHR14, d
	gen gr_pct_HHR14 = (pct_HHR14 < `r(p50)')		
	
* members below median number of goats
	* 
	cap drop low_goats pct_low_goats gr_pct_low_goats
	sum goats_owned, d 
	gen low_goats = (goats_owned < `r(p50)')
	bysort idx: egen pct_low_goats = mean(low_goats)
	
	* group var
	sum pct_low_goats, d
	gen gr_pct_low_goats = (pct_low_goats > `r(p50)')
	
	
* Coefficient of variation on member assets
	* 
	cap drop goats_mean goats_sd cv_goats gr_cv_goats
	bysort idx: egen goats_mean = mean(goats_owned)
	bysort idx: egen goats_sd = sd(goats_owned)
	gen cv_goats = goats_sd / goats_mean
	
	* group var
	sum cv_goats, d
	gen gr_cv_goats = (cv_goats > `r(p50)')	

* size of membership fee
sum MAN2, d	

	* average variable
	cap drop avg_MAN2 gr_avg_MAN2
	bysort idx: egen avg_MAN2 = mean(MAN2)
	
	* group var
	sum avg_MAN2, d
	replace avg_MAN2 = `r(p50)' if avg_MAN2 ==.
	gen gr_avg_MAN2 = (avg_MAN2 < `r(p50)')

	
* Extensive summary index (PCA)
gen neg_avg_MAN2 = -1*avg_MAN2

pca pct_HHR14 pct_low_goats cv_goats neg_avg_MAN2
predict pc1, score	
rename pc1 extensive_index
sum extensive_index, d

gen gr_extensive_index = (extensive_index > `r(p50)')	


** Intensive
* ----------------------------------
* pct of members receiving co-op sale info
sum COM3, d
sum bCOM3 

	* percentage variable
	cap drop pct_COM3 gr_pct_COM3
	bysort idx: egen pct_COM3 = mean(bCOM3)
	* exclude co-ops that do not sell goats
	replace pct_COM3 = . if CO_SER15 == 0
	
	* group var
	sum pct_COM3, d
	gen gr_pct_COM3 = (pct_COM3 > `r(p50)')
	replace gr_pct_COM3 = . if CO_SER15 == 0
	
	
* pct of members receiving co-op non-sale info
sum COM8, d
sum bCOM8 

	* percentage variable
	cap drop pct_COM8 gr_pct_COM8
	bysort idx: egen pct_COM8 = mean(bCOM8)
	
	* group var
	sum pct_COM8, d
	gen gr_pct_COM8 = (pct_COM8 > `r(p50)')	
	
	
* received co-op loans	
cap drop co_loan
gen co_loan = (BR4_1 == "C") | (BR4_2 == "C") | (BR4_3 == "C") | (BR4_4 == "C") | (BR4_5 == "C") ///
				| (BR4_6 == "C") | (BR4_7 == "C") | (BR4_8 == "C") | (BR4_9 == "C") | (BR4_10 == "C")
replace co_loan =. if CO_SER2 == 0	

	* average variable
	cap drop pct_loan gr_pct_loan
	bysort idx: egen pct_loan = mean(co_loan)
	
	* group var
	sum pct_loan, d
	gen gr_pct_loan = (pct_loan > `r(p50)')
	
	
* Pct voting in co-op elections
	* 
	cap drop pct_MEM14 gr_pct_MEM14 
	bysort idx: egen pct_MEM14 = mean(MEM14)
	
	* group var
	sum pct_MEM14, d
	gen gr_pct_MEM14 = (pct_MEM14 > `r(p50)')		
	
	
* Intensive summary index (PCA)

pca pct_COM3 pct_COM8 pct_loan pct_MEM14
predict pc1, score	
rename pc1 intensive_index
sum intensive_index, d

gen gr_intensive_index = (intensive_index > `r(p50)')			
	
	


*keep idx gr_pct_COM3 gr_pct_COM8

*merge m:1 idx using "$d3/CO_Final.dta"

*save "$d3/CO_Final.dta", replace
