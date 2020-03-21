
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
rtitle("Cooperative has an initial membership fee (0/1)"\"Size of initial membership fee (USD)"\ ///
		"Size of current management committee (count)"\"Share of members the attending last general assembly (count)"\ ///
		"Cooperative organizes goat sales (0/1)"\"Cooperative accepts savings deposits (0/1)"\ ///
		"Cooperative Offers loans (0/1)"\"Cooperative provides goat price information (0/1)"\ ///
		"Cooperative pays dividends to share owners (0/1)")replace
 


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
rtitle("Length of membership (years)"\"Number of self-help group meetings attended (count)"\ ///
		"Number of cooperative meetings attended (count)"\"Round-trip travel time to cooperative meetings (minutes)"\ ///
		"Participates in annual general meeting (0/1)"\"Voted in elections in last 2-years (0/1)"\ ///
		"Voted on policies in last 2-years (0/1)"\ "Value of dividend payments received (USD)"\ ///
		"Contacted about cooperative sales in last 6-months (0/1)"\ ///
		"Contacted about cooperative activities in last 6-months (0/1)") replace
 

** Meeting attendance table
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



