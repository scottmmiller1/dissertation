
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
use "$d3/CO_Final.dta"

replace REV4 = REV4*(0.0099)
cap drop no_services
gen no_services = CO_SER1 + CO_SER2 + CO_SER3 + CO_SER4 + CO_SER5 + CO_SER6 + CO_SER7 ///
				+ CO_SER8 + CO_SER9 + CO_SER10 + CO_SER11a + CO_SER12 + CO_SER13 + CO_SER14 ///
				+ CO_SER15 + CO_SERV2 + CO_SER18


** Co-op variables **

gl co_summ MAN3 REV4 MAN1 MAN2 assembly_pct MAN4 no_services SER15 SER2

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
rtitle("Number of members (count)"\"Total revenue over last 6-months (USD)"\"Cooperative has an initial membership fee (0/1)"\"Size of initial membership fee (USD)"\ ///
		"Share of members the attending last general assembly (count)"\ ///
		"Size of management committee (count)"\"Number of services offered (count)"\ ///
		"Coordinates goat sales (0/1)"\"Offers loans to members  (0/1)")replace
 


** HH level dataset
********************************************* 
clear
use "$d3/HH_Final.dta"

/*
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
*/
gen bLS8 = (LS8 > 0)
gen bHHR16 = (HHR16=="1")



** HH indicators **

gl hh_summ HHR4 HHR14 mem_length travel_time MEM14 bCOM3 bCOM8 bHHR16 goats_owned bLS8 LS8_w rev_goat
	

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
rtitle("Age (years)"\"Literacy (0/1)"\"Length of membership (years)"\"Round-trip travel time to cooperative meetings (minutes)"\ ///
		"Voted in elections in last 2-years (0/1)"\ ///
		"Contacted about cooperative sales in last 6-months (0/1)"\ ///
		"Contacted about cooperative activities in last 6-months (0/1)"\"Primary activity is agriculture (0/1)"\ ///
		"Total number of goats owned (count)"\ ///
		"Sold goats in the last 12-months (0/1)"\"Annual number of goats sold (count)"\ ///
		"Annual revenue per goat (USD)") replace
 
 

* Cooperative services
* ----------------------------------------------------------------------
clear
use "$d3/CO_Final.dta"

* co-op services offered
gl co_ser_1 CO_SER1 CO_SER2 CO_SERV2 CO_SER15 CO_SER14 CO_SER18 CO_SER12 CO_SER13 CO_SER4 CO_SER3 CO_SER8 CO_SER7 CO_SER11a CO_SER6 CO_SER10 CO_SER9
	
local listsize : list sizeof global(co_ser_1)
tokenize $co_ser_1

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
matrix A = mat_1

forv i = 2/`listsize' { // appends into single matrix
	matrix A = A \ mat_`i'
}



clear
use "$d3/HH_Final.dta"

* member awareness
gl hh_ser_1 SER1 SER2 SER19 SER15 SER14 SER18 SER12 SER13 SER4 SER3 SER8 SER7 SER11 SER6 SER10 SER9
	
local listsize : list sizeof global(hh_ser_1)
tokenize $hh_ser_1

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
matrix B = mat_1

forv i = 2/`listsize' { // appends into single matrix
	matrix B = B \ mat_`i'
}


* members using services
gen bSER33 = (SER33 > 0)

gen co_loan = (BR4_1 == "C") | (BR4_2 == "C") | (BR4_3 == "C") | (BR4_4 == "C") | (BR4_5 == "C") ///
				| (BR4_6 == "C") | (BR4_7 == "C") | (BR4_8 == "C") | (BR4_9 == "C") | (BR4_10 == "C")


replace co_loan =. if CO_SER2 == 0
gen co_sale = (co_opgoatno > 0)
replace co_sale =. if CO_SER15 == 0
gen price_info = 1 if COM1A == 1 | COM1B == 1 | COM1C == 1 | COM1D == 1 | COM1E == 1 | COM1G == 1
replace price_info = 0 if COM1F == 1
replace price_info =. if CO_SERV2 == 0


gl hh_ser_2 SER21 co_loan co_sale SER32 bSER33 SER30 SER31 SER22 SER26 SER25 SER29 SER24 SER28 SER27
	
local listsize : list sizeof global(hh_ser_2)
tokenize $hh_ser_2

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
matrix C = mat_1 \ mat_2 \ (.)

forv i = 3/9 { // appends into single matrix
	matrix C = C \ mat_`i'
}

matrix C = C \ (.)

forv i = 10/`listsize' { // appends into single matrix
	matrix C = C \ mat_`i'
}


* Table
frmttable using E1_services.tex, tex statmat(A) sdec(2) coljust(l;c;l;l) title("Cooperative Services") ///
ctitle("","Share of cooperatives"\"","offering service"\"","") ///
rtitle("Accept savings deposits (0/1)"\"Offer loans (0/1)"\"Provide goat price information (0/1)"\ ///
		"Coordinate sales of goats to traders (0/1)"\"Provide assistance with animal husbandry (0/1)"\ ///
		"Give dividend payments to owners of cooperative shares (0/1)"\"Provide access to veterinary services (0/1)"\ ///
		"Provide assistance with business planning (0/1)"\ ///
		"Sell or help members access livestock insurance (0/1)"\"Help members access bank loans"\ ///
		"Sell fertilizer (0/1)"\"Sell seed (0/1)"\"Sell consumer goods, such as food (0/1)"\ ///
		"Sell animal feed (0/1)"\"Sell or rent agricultural or livestock tools (0/1)"\"Sell pesticide (0/1)") replace	
frmttable using E1_services.tex, tex statmat(B) sdec(2) coljust(l;c;l;l) ///
ctitle("Share of members"\"aware of service"\"") merge
frmttable using E1_services.tex, tex statmat(C) sdec(2) coljust(l;c;l;l) ///
ctitle("Share of members"\"using service"\"(where offered)") merge




* ----------------------------------------------------
* predictors of participation / membership / benefits

* leadership role
tab MEM4
gen bMEM4 = (MEM4 > 1 & MEM4 !=.)
replace bMEM4 = . if MEM4 ==.

lab var bMEM4 "Leadership role (0/1)" 
lab var goats_owned "Total number of goats owned (count)" 
lab var mem_length "Length of membership (years)"
lab var travel_time "Round-trip travel time to cooperative meetings (minutes)"
lab var HHR14 "Literacy (0/1)"
lab var HHR4 "Age (years)"
lab var ID10 "Number of household members (count)"
lab var MAN3 "Number of cooperative members (count)"
lab var MEM14 "Voted in cooperative election (0/1)"
lab var co_loan "Received a cooperative loan (0/1)"


* leadership role
logit bMEM4 HHR14 HHR4 ID10 goats_owned mem_length travel_time MAN3 
margins, dydx(HHR14 ID10 HHR4 goats_owned mem_length travel_time MAN3)
outreg2 using mem_predict.tex, stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex replace label

* receive sale information
logit bCOM3 HHR14 ID10 HHR4 goats_owned mem_length travel_time MAN3
margins, dydx(HHR14 ID10 HHR4 goats_owned mem_length travel_time MAN3)
outreg2 using mem_predict.tex, stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex append label

* receive activity information
logit bCOM8 HHR14 ID10 HHR4 goats_owned mem_length travel_time MAN3 
margins, dydx(HHR14 ID10 HHR4 goats_owned mem_length travel_time MAN3)
outreg2 using mem_predict.tex, stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex append label

* Voted in co-op elections
logit MEM14 HHR14 ID10 HHR4 goats_owned mem_length travel_time MAN3
margins, dydx(HHR14 ID10 HHR4 goats_owned mem_length travel_time MAN3)
outreg2 using mem_predict.tex, stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex append label

/*
* Voted on co-op policies
logit MEM16 HHR14 ID10 HHR4 goats_owned mem_length travel_time MAN3
margins, dydx(HHR14 ID10 HHR4 goats_owned mem_length travel_time MAN3) atmeans
outreg2 using mem_predict.tex, stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex append label
*/

* received co-op loan
logit co_loan HHR14 ID10 HHR4 goats_owned mem_length travel_time MAN3
margins, dydx(HHR14 ID10 HHR4 goats_owned mem_length travel_time MAN3)
outreg2 using mem_predict.tex, stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex append label

