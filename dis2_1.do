
/*******************************************************************************
dis2_1.d0		
					
- Generates Summary Statistic Tables						
	
*******************************************************************************/


clear
set more off, perm
cd "$d2"

/*
** Co-op level dataset
********************************************* 
clear
use "$d3/CO_Final.dta"


** Co-op variables **

gl co_summ MAN3 revenue costs net_rev rev_member net_rev_member goatrev ///
		PNG2

local listsize : list sizeof global(co_summ)
tokenize $co_summ

forv i = 1/`listsize' {
		
	quietly {
		sum ``i''
		return list
		scalar N_``i'' = r(N) // N
		scalar mean_``i'' = r(mean) // mean
		scalar sd_``i'' = r(sd)  // sd
		scalar min_``i'' = r(min)  // sd
		scalar max_``i'' = r(max)  // sd
		
	* matrix for table
		matrix mat_`i' = (N_``i'',mean_``i'',sd_``i'',min_``i'',max_``i'')
		}
}
matrix A = mat_1
forv i = 2/`listsize' { // appends into single matrix
	matrix A = A \ mat_`i'
}

* Table
frmttable using CO_summary.tex, tex statmat(A) sdec(2) coljust(l;c;l;l) title("Cooperative Indicators - Summmary Statistics") ///
ctitle("","N","Mean","sd","Min","Max") ///
rtitle("Members (count)"\"Revenue (USD)"\"Costs (USD)"\"Net revenue (USD)"\"Revenue per member (USD)"\"Net revenue per member (USD)"\"Goat revenue (USD)"\"Planning time horizon (years)")replace
 
*/

** HH level dataset
********************************************* 
clear
use "$d3/HH_Final.dta"

*drop if LS8 == 0
gen side_sell = outsidegoatno > 0
replace rev_co_opgoat_w = . if co_opgoatno_w == 0
replace rev_goat_w = . if rev_goat_w == 0
replace co_opgoatno_w = .  if LS8_w == 0
replace net_goat_income_w = .  if LS8_w == 0
replace side_sell = .  if LS8_w == 0
replace LS8_w = .  if LS8_w == 0


** HH indicators **

gl hh_summ HHR4 HHR14 bCOM3 goats_owned goat_seller side_sell LS8_w ///
			co_opgoatno_w rev_goat_w rev_co_opgoat_w net_goat_income_w  ///
	

local listsize : list sizeof global(hh_summ)
tokenize $hh_summ

forv i = 1/`listsize' {
		
	quietly {
		sum ``i''
		return list
		scalar N_``i'' = r(N) // N
		scalar mean_``i'' = r(mean) // mean
		scalar sd_``i'' = r(sd)  // sd
		scalar min_``i'' = r(min)  // sd
		scalar max_``i'' = r(max)  // sd
		
	* matrix for table
		matrix mat_`i' = (N_``i'',mean_``i'',sd_``i'',min_``i'',max_``i'')
		}
}
matrix A = mat_1
forv i = 2/`listsize' { // appends into single matrix
	matrix A = A \ mat_`i'
}

* Table
frmttable using E2_HH_summary.tex, tex statmat(A) sdec(2) coljust(l;c;l;l) title("Household Indicators - Summmary Statistics") ///
ctitle("","N","Mean","sd","Min","Max") ///
rtitle("Age (years)"\"Literacy (0/1)"\"Received sale information (0/1)"\ ///
		"Goats owned (count)"\"Household sells goats (0/1)"\"Household side-sells goats (0/1)" ///
		\"Total goats sold (count)"\"Cooperative goats sold (count)"\ ///
		"Revenue per goat (USD)"\"Revenue per cooperative goat (USD)"\ ///
		"Net goat income (USD)") replace
		
		
		
		
		
		
