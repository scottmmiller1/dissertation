
/*******************************************************************************
dis1_4.d0		
					
- Decomposition Charts					
	
*******************************************************************************/

*ssc install sensemakr, replace

* run group definitions code 
do "$d1/dis1_2.do"

cd "$d2"

** HH level dataset
********************************************* 

* revenue from co-op goats sold
replace co_opsalevalue = . if LS8 == 0
replace co_opsalevalue = co_opsalevalue*(0.0099)

* number of co-op goats sold
replace co_opgoatno_w = . if LS8 ==0

* co-op loan amount
forvalues i=1/10 {
	gen co_loan_`i' = BR2_`i' if BR4_`i' == "C"
	replace co_loan_`i' = 0 if co_loan_`i' ==.
}
gen co_loan_amt = co_loan_1 + co_loan_2 + co_loan_3 + co_loan_4 + co_loan_5 + co_loan_6 + co_loan_7 + co_loan_8 + co_loan_9 + co_loan_10
replace co_loan_amt =. if BR1 == 2
replace co_loan_amt = co_loan_amt*(0.0099)
drop co_loan_1-co_loan_10

/*
* goat revenue & loan amount index
do "$d1/dis0_3.do"
local local_benefits co_opsalevalue co_opgoatno_w co_loan_amt
	make_index_gr benefits wgt stdgroup `local_benefits' 
*/
	   
* ------------------------------------	   
quietly tab district, gen(dist_)

gen married = (HHR7 == 1)


** Standardized outcome plots
* ---------------------------------------------------------------------------------------

gen bLS8 = (LS8_w > 0 & LS8_w !=.)
gen bco_goat = (co_opgoatno_w > 0 & co_opgoatno_w !=.)

replace LS8_w = . if LS8_w == 0
replace LS9_w = . if LS9_w == 0

* standardized variables
foreach v of varlist bLS8 LS9_w bco_goat co_opsalevalue co_loan_amt MEM7 {
	quietly sum `v', d
	gen `v'_st = (`v' - `r(mean)') / `r(sd)'
	sum `v'_st
}

* extensive (drop certain controls)
gl outcomes bLS8_st LS9_w_st bco_goat_st co_opsalevalue_st co_loan_amt_st
	
local listsize : list sizeof global(outcomes)
tokenize $outcomes	

forv i = 1/`listsize' {
	quietly {
	* Extensive index
		oaxaca ``i'' HHR4 ID10 bHHR16 bMEM4 travel_time index_emp nfloors dirt_floor married ///
					MAN3 no_services REV4 MAN4 dist_*, ///
					by(gr_extensive_index) vce(cluster idx) swap weight(0) relax level(90)
		ereturn list
		matrix p = r(table)
		matrix d_`i'_1 = (_b[difference], p[5,3], p[6,3])
		matrix e_`i'_1 = (_b[explained], p[5,4], p[6,4])
		matrix u_`i'_1 = (_b[unexplained], p[5,5], p[6,5])			
		

* Intensive
	* by intensive index
		oaxaca ``i'' HHR4 ID10 bHHR16 bMEM4 travel_time index_emp nfloors dirt_floor married ///
					MAN3 no_services REV4 MAN4 dist_*, ///
					by(gr_intensive_index) vce(cluster idx) swap weight(0) relax level(90)
		ereturn list
		matrix p = r(table)
		matrix d_`i'_6 = (_b[difference], p[5,3], p[6,3])
		matrix e_`i'_6 = (_b[explained], p[5,4], p[6,4])
		matrix u_`i'_6 = (_b[unexplained], p[5,5], p[6,5])	 	
		
		
		}
}		

* outcome matrices
	matrix d_ex = d_1_1
	matrix e_ex = e_1_1
	matrix u_ex = u_1_1
	matrix d_in = d_1_6
	matrix e_in = e_1_6
	matrix u_in = u_1_6
	* groups
	forv i = 2/5 {
		matrix d_ex = d_ex \ d_`i'_1
		matrix e_ex = e_ex \ e_`i'_1
		matrix u_ex = u_ex \ u_`i'_1
		
		matrix d_in = d_in \ d_`i'_6
		matrix e_in = e_in \ e_`i'_6
		matrix u_in = u_in \ u_`i'_6
		
	}
	
matrix rownames d_ex = "Sells goats" "Total goat revenue" "Sells goats through cooperative" "Cooperative goat revenue" "Cooperative loan amount"
matrix rownames e_ex = "Sells goats" "Total goat revenue" "Sells goats through cooperative" "Cooperative goat revenue" "Cooperative loan amount"
matrix rownames u_ex = "Sells goats" "Total goat revenue" "Sells goats through cooperative" "Cooperative goat revenue" "Cooperative loan amount"

matrix rownames d_in = "Sells goats" "Total goat revenue" "Sells goats through cooperative" "Cooperative goat revenue" "Cooperative loan amount"
matrix rownames e_in = "Sells goats" "Total goat revenue" "Sells goats through cooperative" "Cooperative goat revenue" "Cooperative loan amount"
matrix rownames u_in = "Sells goats" "Total goat revenue" "Sells goats through cooperative" "Cooperative goat revenue" "Cooperative loan amount"
	

* Revenue
coefplot (matrix(d_ex[,1]), ci((2 3)) label(Difference) msymbol(S) msize(5pt) ciopts(recast(rcap) lwidth(0.65)) citop offset(0.25)) ///
		 (matrix(e_ex[,1]), ci((2 3)) label(Characteristics) msymbol(T) msize(2pt) ciopts(lwidth(0.15))) /// 
		 (matrix(u_ex[,1]), ci((2 3)) label(Returns) msymbol(D) msize(2pt) ciopts(lwidth(0.15)) offset(-0.15)), ///
		 xline(0) ylab(, labs(small)) legend(rows(1) size(small) pos(6)) ///
		 graphregion(color(white) ilcolor(white)) plotregion(margin(zero)) xlabel(-0.75(0.25)0.5) aspectratio(1.2) coeflabels(, wrap(15))
graph export "$d2/decomp_1_ex_st.png", replace

coefplot (matrix(d_in[,1]), ci((2 3)) label(Difference) msymbol(S) msize(5pt) ciopts(recast(rcap) lwidth(0.65)) citop offset(0.25)) ///
		 (matrix(e_in[,1]), ci((2 3)) label(Characteristics) msymbol(T) msize(2pt) ciopts(lwidth(0.15))) /// 
		 (matrix(u_in[,1]), ci((2 3)) label(Returns) msymbol(D) msize(2pt) ciopts(lwidth(0.15)) offset(-0.15)), ///
		 xline(0) ylab(, labs(small)) legend(rows(1) size(small) pos(6)) ///
		 graphregion(color(white) ilcolor(white)) plotregion(margin(zero)) xlabel(-0.5(0.25)0.75) aspectratio(1.2) coeflabels(, wrap(15))
graph export "$d2/decomp_1_in_st.png", replace
* ---------------------------------------------------------------------------------------



* extensive (drop certain controls)
gl outcomes bLS8 LS8_w LS9_w bco_goat co_opgoatno_w co_opsalevalue co_loan_amt
	
local listsize : list sizeof global(outcomes)
tokenize $outcomes	

forv i = 1/`listsize' {
	quietly {
	* Extensive index
		oaxaca ``i'' HHR4 ID10 bHHR16 bMEM4 travel_time index_emp nfloors dirt_floor married ///
					MAN3 no_services REV4 MAN4 dist_*, ///
					by(gr_extensive_index) vce(cluster idx) swap weight(0) relax level(90)
		ereturn list
		matrix p = r(table)
		matrix d_`i'_1 = (_b[difference], p[5,3], p[6,3])
		matrix e_`i'_1 = (_b[explained], p[5,4], p[6,4])
		matrix u_`i'_1 = (_b[unexplained], p[5,5], p[6,5])			
		
	* by literacy
		oaxaca ``i'' HHR4 ID10 bHHR16 bMEM4 travel_time index_emp nfloors dirt_floor married ///
					 MAN3 no_services REV4 MAN4 dist_*, ///
					by(gr_pct_HHR14) vce(cluster idx) swap weight(0) relax level(90)
		ereturn list
		matrix p = r(table)
		matrix d_`i'_2 = (_b[difference], p[5,3], p[6,3])
		matrix e_`i'_2 = (_b[explained], p[5,4], p[6,4])
		matrix u_`i'_2 = (_b[unexplained], p[5,5], p[6,5])
		
		
	* by low goats
		oaxaca ``i'' HHR4 ID10 bHHR16 bMEM4 travel_time index_emp nfloors dirt_floor married ///
					 MAN3 no_services REV4 MAN4 dist_*, ///
					by(gr_pct_low_goats) vce(cluster idx) swap weight(0) relax level(90)
		ereturn list
		matrix p = r(table)
		matrix d_`i'_3 = (_b[difference], p[5,3], p[6,3])
		matrix e_`i'_3 = (_b[explained], p[5,4], p[6,4])
		matrix u_`i'_3 = (_b[unexplained], p[5,5], p[6,5])
		
	* by cv goats
		oaxaca ``i'' HHR4 ID10 bHHR16 bMEM4 travel_time index_emp nfloors dirt_floor ///
					 MAN3 no_services REV4 MAN4 dist_*, ///
					by(gr_cv_goats) vce(cluster idx) swap weight(0) relax level(90)
		ereturn list
		matrix p = r(table)
		matrix d_`i'_4 = (_b[difference], p[5,3], p[6,3])
		matrix e_`i'_4 = (_b[explained], p[5,4], p[6,4])
		matrix u_`i'_4 = (_b[unexplained], p[5,5], p[6,5])

	* by membership fee
		oaxaca ``i'' HHR4 ID10 bHHR16 bMEM4 travel_time index_emp nfloors dirt_floor married ///
					MAN3 no_services REV4 MAN4 dist_*, ///
					by(gr_avg_MAN2) vce(cluster idx) swap weight(0) relax level(90)
		ereturn list
		matrix p = r(table)
		matrix d_`i'_5 = (_b[difference], p[5,3], p[6,3])
		matrix e_`i'_5 = (_b[explained], p[5,4], p[6,4])
		matrix u_`i'_5 = (_b[unexplained], p[5,5], p[6,5])		
		

* Intensive
	* by intensive index
		oaxaca ``i'' HHR4 ID10 bHHR16 bMEM4 travel_time index_emp nfloors dirt_floor married ///
					 MAN3 no_services REV4 MAN4 dist_*, ///
					by(gr_intensive_index) vce(cluster idx) swap weight(0) relax level(90)
		ereturn list
		matrix p = r(table)
		matrix d_`i'_6 = (_b[difference], p[5,3], p[6,3])
		matrix e_`i'_6 = (_b[explained], p[5,4], p[6,4])
		matrix u_`i'_6 = (_b[unexplained], p[5,5], p[6,5])	 	

	* by sale info
		oaxaca ``i'' HHR14 HHR4 ID10 bHHR16 bMEM4 travel_time index_emp nfloors dirt_floor married ///
					 MAN3 no_services REV4 MAN4 dist_*, ///
					by(gr_pct_COM3) vce(cluster idx) swap weight(0) relax level(90)
		ereturn list
		matrix p = r(table)
		matrix d_`i'_7 = (_b[difference], p[5,3], p[6,3])
		matrix e_`i'_7 = (_b[explained], p[5,4], p[6,4])
		matrix u_`i'_7 = (_b[unexplained], p[5,5], p[6,5])
		
	* by non-sale info
		oaxaca ``i'' HHR4 ID10 bHHR16 bMEM4 travel_time index_emp nfloors dirt_floor married ///
					 MAN3 no_services REV4 MAN4 dist_*, ///
					by(gr_pct_COM8) vce(cluster idx) swap weight(0) relax level(90)
		ereturn list
		matrix p = r(table)
		matrix d_`i'_8 = (_b[difference], p[5,3], p[6,3])
		matrix e_`i'_8 = (_b[explained], p[5,4], p[6,4])
		matrix u_`i'_8 = (_b[unexplained], p[5,5], p[6,5])
		
	* by pct loans
		oaxaca ``i'' HHR4 ID10 bHHR16 bMEM4 travel_time index_emp nfloors dirt_floor married ///
					 MAN3 no_services REV4 MAN4 dist_*, ///
					by(gr_pct_loan) vce(cluster idx) swap weight(0) relax level(90)
		ereturn list
		matrix p = r(table)
		matrix d_`i'_9 = (_b[difference], p[5,3], p[6,3])
		matrix e_`i'_9 = (_b[explained], p[5,4], p[6,4])
		matrix u_`i'_9 = (_b[unexplained], p[5,5], p[6,5])

	* by voting
		oaxaca ``i'' HHR4 ID10 bHHR16 bMEM4 travel_time index_emp nfloors dirt_floor married ///
					 MAN3 no_services REV4 MAN4 dist_*, ///
					by(gr_pct_MEM14) vce(cluster idx) swap weight(0) relax level(90)
		ereturn list
		matrix p = r(table)
		matrix d_`i'_10 = (_b[difference], p[5,3], p[6,3])
		matrix e_`i'_10 = (_b[explained], p[5,4], p[6,4])
		matrix u_`i'_10 = (_b[unexplained], p[5,5], p[6,5])		
		
		
		}
}		

* outcome matrices
forv j = 1/7 {
	matrix d_`j'_ex = d_`j'_1
	matrix e_`j'_ex = e_`j'_1
	matrix u_`j'_ex = u_`j'_1
	matrix d_`j'_in = d_`j'_6
	matrix e_`j'_in = e_`j'_6
	matrix u_`j'_in = u_`j'_6
	* extensive groups
	forv i = 2/5 {
		matrix d_`j'_ex = d_`j'_ex \ d_`j'_`i'
		matrix e_`j'_ex = e_`j'_ex \ e_`j'_`i'
		matrix u_`j'_ex = u_`j'_ex \ u_`j'_`i'
	}
	* intensive groups
	forv i = 7/10 {
		matrix d_`j'_in = d_`j'_in \ d_`j'_`i'
		matrix e_`j'_in = e_`j'_in \ e_`j'_`i'
		matrix u_`j'_in = u_`j'_in \ u_`j'_`i'
	}

	matrix rownames d_`j'_ex = "Extensive index" "% non-literate" "% below median number of goats" "CV on goats owned" "Size of membership fee"		
	matrix rownames e_`j'_ex = "Extensive index" "% non-literate" "% below median number of goats" "CV on goats owned" "Size of membership fee"	
	matrix rownames u_`j'_ex = "Extensive index" "% non-literate" "% below median number of goats" "CV on goats owned" "Size of membership fee"	
	matrix rownames d_`j'_in = "Intensive index" "% receiving sale information" "% receiving non-sale information" "% receiving loans" "% voted in elections"	
	matrix rownames e_`j'_in = "Intensive index" "% receiving sale information" "% receiving non-sale information" "% receiving loans" "% voted in elections"		
	matrix rownames u_`j'_in = "Intensive index" "% receiving sale information" "% receiving non-sale information" "% receiving loans" "% voted in elections"							
}	
	

* Sells goats
coefplot (matrix(d_1_ex[,1]), ci((2 3)) label(Difference) msymbol(S) msize(5pt) ciopts(recast(rcap) lwidth(0.65)) citop offset(0.25)) ///
		 (matrix(e_1_ex[,1]), ci((2 3)) label(Characteristics) msymbol(T) msize(2pt) ciopts(lwidth(0.15))) /// 
		 (matrix(u_1_ex[,1]), ci((2 3)) label(Returns) msymbol(D)msize(2pt) ciopts(lwidth(0.15)) offset(-0.15)), ///
		 xline(0) ylab(, labs(small)) legend(rows(1) size(small) pos(6)) ///
		 graphregion(color(white) ilcolor(white)) plotregion(margin(zero)) xlabel(-0.2(0.1)0.2) aspectratio(1.2) coeflabels(, wrap(15))
graph export "$d2/decomp_1_ex.png", replace
coefplot (matrix(d_1_in[,1]), ci((2 3)) label(Difference) msymbol(S) msize(5pt) ciopts(recast(rcap) lwidth(0.65)) citop offset(0.25)) ///
		 (matrix(e_1_in[,1]), ci((2 3)) label(Characteristics) msymbol(T) msize(2pt) ciopts(lwidth(0.15))) /// 
		 (matrix(u_1_in[,1]), ci((2 3)) label(Returns) msymbol(D)msize(2pt) ciopts(lwidth(0.15)) offset(-0.15)), ///
		 xline(0) ylab(, labs(small)) legend(rows(1) size(small) pos(6)) ///
		 graphregion(color(white) ilcolor(white)) plotregion(margin(zero)) aspectratio(1.2) coeflabels(, wrap(15))
graph export "$d2/decomp_1_in.png", replace


* Total goat revenue
coefplot (matrix(d_3_ex[,1]), ci((2 3)) label(Difference) msymbol(S) msize(5pt) ciopts(recast(rcap) lwidth(0.65)) citop offset(0.25)) ///
		 (matrix(e_3_ex[,1]), ci((2 3)) label(Characteristics) msymbol(T) msize(2pt) ciopts(lwidth(0.15))) /// 
		 (matrix(u_3_ex[,1]), ci((2 3)) label(Returns) msymbol(D)msize(2pt) ciopts(lwidth(0.15)) offset(-0.15)), ///
		 xline(0) ylab(, labs(small)) legend(rows(1) size(small) pos(6)) ///
		 graphregion(color(white) ilcolor(white)) plotregion(margin(zero)) xlabel(-100(50)100) aspectratio(1.2) coeflabels(, wrap(15))
graph export "$d2/decomp_3_ex.png", replace
coefplot (matrix(d_3_in[,1]), ci((2 3)) label(Difference) msymbol(S) msize(5pt) ciopts(recast(rcap) lwidth(0.65)) citop offset(0.25)) ///
		 (matrix(e_3_in[,1]), ci((2 3)) label(Characteristics) msymbol(T) msize(2pt) ciopts(lwidth(0.15))) /// 
		 (matrix(u_3_in[,1]), ci((2 3)) label(Returns) msymbol(D)msize(2pt) ciopts(lwidth(0.15)) offset(-0.15)), ///
		 xline(0) ylab(, labs(small)) legend(rows(1) size(small) pos(6)) ///
		 graphregion(color(white) ilcolor(white)) plotregion(margin(zero)) aspectratio(1.2) coeflabels(, wrap(15))
graph export "$d2/decomp_3_in.png", replace

* Sells co-op goats
coefplot (matrix(d_4_ex[,1]), ci((2 3)) label(Difference) msymbol(S) msize(5pt) ciopts(recast(rcap) lwidth(0.65)) citop offset(0.25)) ///
		 (matrix(e_4_ex[,1]), ci((2 3)) label(Characteristics) msymbol(T) msize(2pt) ciopts(lwidth(0.15))) /// 
		 (matrix(u_4_ex[,1]), ci((2 3)) label(Returns) msymbol(D)msize(2pt) ciopts(lwidth(0.15)) offset(-0.15)), ///
		 xline(0) ylab(, labs(small)) legend(rows(1) size(small) pos(6)) ///
		 graphregion(color(white) ilcolor(white)) plotregion(margin(zero)) aspectratio(1.2) coeflabels(, wrap(15))
graph export "$d2/decomp_4_ex.png", replace
coefplot (matrix(d_4_in[,1]), ci((2 3)) label(Difference) msymbol(S) msize(5pt) ciopts(recast(rcap) lwidth(0.65)) citop offset(0.25)) ///
		 (matrix(e_4_in[,1]), ci((2 3)) label(Characteristics) msymbol(T) msize(2pt) ciopts(lwidth(0.15))) /// 
		 (matrix(u_4_in[,1]), ci((2 3)) label(Returns) msymbol(D)msize(2pt) ciopts(lwidth(0.15)) offset(-0.15)), ///
		 xline(0) ylab(, labs(small)) legend(rows(1) size(small) pos(6)) ///
		 graphregion(color(white) ilcolor(white)) plotregion(margin(zero)) aspectratio(1.2) coeflabels(, wrap(15))
graph export "$d2/decomp_4_in.png", replace

* Co-op goat revenue
coefplot (matrix(d_6_ex[,1]), ci((2 3)) label(Difference) msymbol(S) msize(5pt) ciopts(recast(rcap) lwidth(0.65)) citop offset(0.25)) ///
		 (matrix(e_6_ex[,1]), ci((2 3)) label(Characteristics) msymbol(T) msize(2pt) ciopts(lwidth(0.15))) /// 
		 (matrix(u_6_ex[,1]), ci((2 3)) label(Returns) msymbol(D)msize(2pt) ciopts(lwidth(0.15)) offset(-0.15)), ///
		 xline(0) ylab(, labs(small)) legend(rows(1) size(small) pos(6)) ///
		 graphregion(color(white) ilcolor(white)) plotregion(margin(zero)) xlabel(-100(50)100) aspectratio(1.2) coeflabels(, wrap(15))
graph export "$d2/decomp_6_ex.png", replace
coefplot (matrix(d_6_in[,1]), ci((2 3)) label(Difference) msymbol(S) msize(5pt) ciopts(recast(rcap) lwidth(0.65)) citop offset(0.25)) ///
		 (matrix(e_6_in[,1]), ci((2 3)) label(Characteristics) msymbol(T) msize(2pt) ciopts(lwidth(0.15))) /// 
		 (matrix(u_6_in[,1]), ci((2 3)) label(Returns) msymbol(D)msize(2pt) ciopts(lwidth(0.15)) offset(-0.15)), ///
		 xline(0) ylab(, labs(small)) legend(rows(1) size(small) pos(6)) ///
		 graphregion(color(white) ilcolor(white)) plotregion(margin(zero)) aspectratio(1.2) coeflabels(, wrap(15))
graph export "$d2/decomp_6_in.png", replace

* Loan amount
coefplot (matrix(d_7_ex[,1]), ci((2 3)) label(Difference) msymbol(S) msize(5pt) ciopts(recast(rcap) lwidth(0.65)) citop offset(0.25)) ///
		 (matrix(e_7_ex[,1]), ci((2 3)) label(Characteristics) msymbol(T) msize(2pt) ciopts(lwidth(0.15))) /// 
		 (matrix(u_7_ex[,1]), ci((2 3)) label(Returns) msymbol(D)msize(2pt) ciopts(lwidth(0.15)) offset(-0.15)), ///
		 xline(0) ylab(, labs(small)) legend(rows(1) size(small) pos(6)) ///
		 graphregion(color(white) ilcolor(white)) plotregion(margin(zero)) xlabel(-400(200)400) aspectratio(1.2) coeflabels(, wrap(15))
graph export "$d2/decomp_7_ex.png", replace
coefplot (matrix(d_7_in[,1]), ci((2 3)) label(Difference) msymbol(S) msize(5pt) ciopts(recast(rcap) lwidth(0.65)) citop offset(0.25)) ///
		 (matrix(e_7_in[,1]), ci((2 3)) label(Characteristics) msymbol(T) msize(2pt) ciopts(lwidth(0.15))) /// 
		 (matrix(u_7_in[,1]), ci((2 3)) label(Returns) msymbol(D)msize(2pt) ciopts(lwidth(0.15)) offset(-0.15)), ///
		 xline(0) ylab(, labs(small)) legend(rows(1) size(small) pos(6)) ///
		 graphregion(color(white) ilcolor(white)) plotregion(margin(zero)) aspectratio(1.2) coeflabels(, wrap(15))
graph export "$d2/decomp_7_in.png", replace
