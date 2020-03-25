
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
clear
use "$d3/CO_Final.dta"







** HH level dataset
********************************************* 
clear
use "$d3/HH_Final.dta"

* length of membership
sum mem_length, d
* role in co-op
tab MEM4
* attended SHG meeting
tab MEM6
* # of SHG meetings in last 6-months
tab MEM7
* attended co-op meeting
tab MEM8
* # of co-op meetings in last 6-months
tab MEM11
* why don't you attend co-op meetings
tab MEM9

	forvalues i=1/7 {
		cap drop MEM9_`i'
		gen MEM9_`i' = (MEM9 == `i')
		replace MEM9_`i' =. if MEM9 == .
	}

* travel time to co-op
sum travel_time, d
* Participate in annual general meeting
tab MEM12
* why don't you participate
tab MEM13
	
	forvalues i=1/7 {
		cap drop MEM13_`i'
		gen MEM13_`i' = (MEM13 == `i')
		replace MEM13_`i' =. if MEM13 == .
	}

* ever voted in co-op elections
tab MEM14
* # times voted in co-op elections
tab MEM15
	
	* election votes by role 
	tab MEM4 MEM14
	
* ever voted on co-op policies
tab MEM16
* # times voted in co-op policies
tab MEM17

	* policy votes by role 
	tab MEM4 MEM16

	
* Services offered	
sum SER1-SER4 SER6-SER19	

* Number of cooperative shares
sum SER20

* services used
sum SER21-SER22 SER24-SER33


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

	
save "$d3/HH_Final.dta", replace


