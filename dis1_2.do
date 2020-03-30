
/*******************************************************************************
dis1_2.d0		

- Background statistics					
- Group definitions						
	
*******************************************************************************/


clear
set more off, perm
cd "$d2"


** Co-op level dataset
********************************************* 
*clear
*use "$d3/CO_Final.dta"






** HH level dataset
********************************************* 
clear
use "$d3/HH_Final.dta"


* why don't you attend co-op meetings
tab MEM9

	forvalues i=1/7 {
		cap drop MEM9_`i'
		gen MEM9_`i' = (MEM9 == `i')
		replace MEM9_`i' =. if MEM9 == .
	}


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
	
	
* pct of members receiving co-op non-sale info
sum COM8, d
sum bCOM8 

	* percentage variable
	cap drop pct_COM8 gr_pct_COM8
	bysort idx: egen pct_COM8 = mean(bCOM8)
	
	* group var
	sum pct_COM8, d
	gen gr_pct_COM8 = (pct_COM8 > `r(p50)')	
	

* size of membership fee
sum MAN2, d	

	* average variable
	cap drop avg_MAN2 gr_avg_MAN2
	bysort idx: egen avg_MAN2 = mean(MAN2)
	
	* group var
	sum avg_MAN2, d
	gen gr_avg_MAN2 = (avg_MAN2 < `r(p50)')
	
	
* received co-op loans	
cap drop co_loan
gen co_loan = (BR4 == "C")
replace co_loan =. if CO_SER2 == 0	

	* average variable
	cap drop pct_loan gr_pct_loan
	bysort idx: egen pct_loan = mean(co_loan)
	
	* group var
	sum pct_loan, d
	gen gr_pct_loan = (pct_loan > `r(p50)')


* aware that co-op provides price info
	* average variable
	cap drop pct_SER19 gr_pct_SER19
	bysort idx: egen pct_SER19 = mean(SER19)
		replace pct_SER19 =. if CO_SERV2 == 0
	
	* group var
	sum pct_SER19, d
	gen gr_pct_SER19 = (pct_SER19 > `r(p50)')
	

* members without goats
	* 
	cap drop low_goats pct_low_goats gr_pct_low_goats
	sum goats_owned, d 
	gen low_goats = (goats_owned < `r(p50)')
	bysort idx: egen pct_low_goats = mean(low_goats)
	
	* group var
	sum pct_low_goats, d
	gen gr_pct_low_goats = (pct_low_goats > `r(p50)')
	

save "$d3/HH_Final.dta", replace

*keep idx gr_pct_COM3 gr_pct_COM8

*merge m:1 idx using "$d3/CO_Final.dta"

*save "$d3/CO_Final.dta", replace
