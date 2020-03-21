
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

	
** participation table
* ----------------------------------------------------------------------
* co-op meetings
gl hh_inc_1 MEM8 MEM11 MEM9_1 MEM9_2 MEM9_3 MEM9_4 MEM9_5 MEM9_6 MEM9_7
	
local listsize : list sizeof global(hh_inc_1)
tokenize $hh_inc_1

forv i = 1/`listsize' {
		
	quietly {
		sum ``i''
		return list
		*scalar N_``i'' = r(N) // N
		scalar mean_``i'' = r(mean) // mean
		*scalar sd_``i'' = r(sd)  // sd
		*scalar min_``i'' = r(min)  // sd
		*scalar max_``i'' = r(max)  // sd
		
	* matrix for table
		matrix mat_`i' = (mean_``i'')
		}
}
matrix A = mat_1 \ mat_2 \ (.) \ (.)

forv i = 3/`listsize' { // appends into single matrix
	matrix A = A \ mat_`i'
}

* annual general meeting
gl hh_inc_2 MEM12 MEM13_1 MEM13_2 MEM13_3 MEM13_4 MEM13_5 MEM13_6 MEM13_7
	
local listsize : list sizeof global(hh_inc_2)
tokenize $hh_inc_2

forv i = 1/`listsize' {
		
	quietly {
		sum ``i''
		return list
		*scalar N_``i'' = r(N) // N
		scalar mean_``i'' = r(mean) // mean
		*scalar sd_``i'' = r(sd)  // sd
		*scalar min_``i'' = r(min)  // sd
		*scalar max_``i'' = r(max)  // sd
		
	* matrix for table
		matrix mat_`i' = (mean_``i'')
		}
}
matrix B = mat_1 \ (.) \ (.) \ (.)

forv i = 2/`listsize' { // appends into single matrix
	matrix B = B \ mat_`i'
}

* Table
frmttable using E1_HH_inc.tex, tex statmat(A) sdec(2) coljust(l;c;l;l) title("Household Indicators - Summmary Statistics") ///
ctitle("","Cooperative") ///
rtitle("Ever attended a meeting (0/1)"\"Number of meetings attended in last 6-months (count)"\""\ ///
		"Reason for not attending meetings:"\"Too far away (0/1)"\"No interest (0/1)"\"Not enough time (0/1)"\ ///
		"I did not have permission to leave the house (0/1)"\"There are no cooperative meetings (0/1)"\ ///
		"Do not know where/when cooperative meetings take place (0/1)"\"Someone attended on my behalf (0/1)") replace	
frmttable using E1_HH_inc.tex, tex statmat(B) sdec(2) coljust(l;c;l;l) title("Household Indicators - Summmary Statistics") ///
ctitle("Annual general meeting") merge
	
	


** Group variable definitons

* pct of members receiving co-op sale info
sum COM3, d
sum bCOM3 

	* percentage variable
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
	bysort idx: egen pct_COM8 = mean(bCOM8)
	
	* group var
	sum pct_COM8, d
	gen gr_pct_COM8 = (pct_COM8 > `r(p50)')

	
save "$d3/HH_Final.dta", replace


