
/*******************************************************************************
dis1_1.d0		
					
- Generates Summary Statistic Tables						
	
*******************************************************************************/



clear
set more off, perm
cd "$d2"


** Co-op level dataset
********************************************* 
clear
use "$d3/CO_Merged_Ind.dta"


replace MAN2 = MAN2*(0.0099)
replace MAN2 = 0 if MAN2 ==.
gen assembly_pct = MAN10 / MAN3
replace assembly_pct = 1 if assembly_pct > 1
replace CO_SER15 = 1 if CO_SER15 > 0
replace CO_SER2 = 1 if CO_SER2 > 0
replace CO_SER1 = 1 if CO_SER1 > 0
replace CO_SERV2 = 1 if CO_SERV2 > 0
replace CO_SER18 = 1 if CO_SER18 > 0


** Co-op variables **

gl co_summ MAN1 MAN2 MAN4 assembly_pct CO_SER15 CO_SER1 CO_SER2 CO_SERV2 CO_SER18

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
frmttable using E1_CO_summary.tex, tex statmat(A) sdec(2) coljust(l;c;l;l) title("Cooperative Indicators - Summmary Statistics") ///
ctitle("","N","Mean","sd","Min","Max") ///
rtitle("Cooperative has a membership fee (0/1)"\"Size of membership fee (USD)"\ ///
		"Size of management committee (count)"\"Share attending last general assembly (count)"\ ///
		"Organizes goat sales (0/1)"\"Accepts savings deposits (0/1)"\ ///
		"Offers loans (0/1)"\"Provides goat price information (0/1)"\ ///
		"Pays dividends to share owners (0/1)")replace
 


** HH level dataset
********************************************* 
clear
use "$d3/HH_Merged_Ind.dta"

gen travel_time = MEM10_a*60 + MEM10_b
sum travel_time, d
replace travel_time = `r(p99)' if travel_time > `r(p99)'
replace SER33 = SER33*(0.0099)
replace SER33 = 0 if SER33 ==.
gen mem_length = MEM2_1 + (MEM2_2 / 12)
sum mem_length, d
replace mem_length = `r(p99)' if mem_length > `r(p99)'
replace COM8 = 0 if COM8 ==.
gen bCOM8 = 1 if COM8 > 0 
replace bCOM8 = 0 if COM8 ==0
replace MEM7 = 0 if MEM7 ==.


** HH indicators **

gl hh_summ mem_length MEM7 MEM11 travel_time MEM12 MEM14 MEM16 SER33 bCOM3 bCOM8
	

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
frmttable using E1_HH_summary.tex, tex statmat(A) sdec(2) coljust(l;c;l;l) title("Household Indicators - Summmary Statistics") ///
ctitle("","N","Mean","sd","Min","Max") ///
rtitle("Length of membership (years)"\"Self-help group meetings attended (count)"\ ///
		"Cooperative meetings attended (count)"\"Round-trip travel time (minutes)"\ ///
		"Participates in annual general meeting (0/1)"\"Voted in elections (0/1)"\ ///
		"Voted on policies (0/1)"\ "Dividend payments received (USD)"\ ///
		"Contacted about cooperative sales (0/1)"\ ///
		"Contacted about cooperative activities (0/1)") replace
 

