
/*******************************************************************************
dis1_3.d0		
					
- Decomposition Charts					
	
*******************************************************************************/


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


* goat revenue & loan amount index
do "$d1/dis0_3.do"
local local_benefits co_opsalevalue co_opgoatno_w co_loan_amt
	make_index_gr benefits wgt stdgroup `local_benefits' 


* ----------------------------------------------------
** Gap analysis

gl gap_1 gr_pct_HHR14 gr_pct_low_goats gr_cv_goats gr_avg_MAN2 gr_pct_COM3 gr_pct_COM8 gr_pct_loan gr_pct_MEM14 
	
local listsize : list sizeof global(gap_1)
tokenize $gap_1

forv i = 1/`listsize' {
		
	quietly {
		reg co_opsalevalue ``i''
		ereturn list
		scalar par_1_``i'' = _b[``i''] // mean
		matrix p = r(table)
		scalar ll_1_``i'' = p[5,1]
		scalar ul_1_``i'' = p[6,1]
		
		reg co_opgoatno_w ``i''
		ereturn list
		scalar par_2_``i'' = _b[``i''] // mean
		matrix p = r(table)
		scalar ll_2_``i'' = p[5,1]
		scalar ul_2_``i'' = p[6,1]
		
		
		reg co_loan_amt ``i''
		ereturn list
		scalar par_3_``i'' = _b[``i''] // mean
		matrix p = r(table)
		scalar ll_3_``i'' = p[5,1]
		scalar ul_3_``i'' = p[6,1]
		
		reg index_benefits ``i''
		ereturn list
		scalar par_4_``i'' = _b[``i''] // mean
		matrix p = r(table)
		scalar ll_4_``i'' = p[5,1]
		scalar ul_4_``i'' = p[6,1]
		
		}
}

matrix A = (par_1_gr_pct_HHR14)
matrix B = (par_2_gr_pct_HHR14)


forv i = 2/`listsize' {
	matrix A = A \ par_1_``i''
	matrix B = B \ par_2_``i''
}

matrix A = A'
matrix B = B'
matrix colnames A = "% non-literate" "% below median number of goats" "CV on goats owned" ///
					"Size of membership fee" "% receiving sale information" "% receiving non-sale information" ///
					"% receiving loans" "% voted in elections"
matrix colnames B = "% non-literate" "% below median number of goats" "CV on goats owned" ///
					"Size of membership fee" "% receiving sale information" "% receiving non-sale information" ///
					"% receiving loans" "% voted in elections"					

matrix A_ci = (ll_1_gr_pct_HHR14, ul_1_gr_pct_HHR14)
matrix B_ci = (ll_2_gr_pct_HHR14, ul_2_gr_pct_HHR14)

forv i = 2/`listsize' {
	matrix A_ci = A_ci \ (ll_1_``i'', ul_1_``i'')
	matrix B_ci = B_ci \ (ll_1_``i'', ul_1_``i'')
}
matrix A_ci = A_ci'
matrix B_ci = B_ci'




* graph with confidence intervals
coefplot matrix(A), ci(A_ci) xline(0)


coefplot (matrix(A), ci(A_ci)), bylabel(Revenue from cooperative goat sales)   ///
      || (matrix(B), ci(B_ci)), bylabel(Cooperative goats sold) ///
	  ||, xline(0) byopts(xrescale)
    
	   
	   
* ------------------------------------	   
quietly tab district, gen(dist_)



* extensive (drop certain controls)
gl outcomes co_opsalevalue co_opgoatno_w co_loan_amt index_benefits
	
local listsize : list sizeof global(outcomes)
tokenize $outcomes	

forv i = 1/`listsize' {
	quietly {
	* by literacy
		oaxaca ``i'' HHR4 ID10 goats_owned bHHR16 mem_length bMEM4 travel_time MEM7 ///
					MAN2 MAN3 no_services REV4 CO_SER15 CO_SER2 MAN4 dist_*, ///
					by(gr_pct_HHR14) vce(cluster idx) swap weight(0) relax
		ereturn list
		matrix p = r(table)
		matrix d_`i'_1 = (_b[difference], p[5,3], p[6,3])
		matrix e_`i'_1 = (_b[explained], p[5,4], p[6,4])
		matrix u_`i'_1 = (_b[unexplained], p[5,5], p[6,5])
		
		
	* by low goats
		oaxaca ``i'' HHR14 HHR4 ID10 bHHR16 mem_length bMEM4 travel_time MEM7 ///
					MAN2 MAN3 no_services REV4 CO_SER15 CO_SER2 MAN4 dist_*, ///
					by(gr_pct_low_goats) vce(cluster idx) swap weight(0) relax
		ereturn list
		matrix p = r(table)
		matrix d_`i'_2 = (_b[difference], p[5,3], p[6,3])
		matrix e_`i'_2 = (_b[explained], p[5,4], p[6,4])
		matrix u_`i'_2 = (_b[unexplained], p[5,5], p[6,5])
		
	* by cv goats
		oaxaca ``i'' HHR14 HHR4 ID10 bHHR16 mem_length bMEM4 travel_time MEM7 ///
					MAN2 MAN3 no_services REV4 CO_SER15 CO_SER2 MAN4 dist_*, ///
					by(gr_cv_goats) vce(cluster idx) swap weight(0) relax
		ereturn list
		matrix p = r(table)
		matrix d_`i'_3 = (_b[difference], p[5,3], p[6,3])
		matrix e_`i'_3 = (_b[explained], p[5,4], p[6,4])
		matrix u_`i'_3 = (_b[unexplained], p[5,5], p[6,5])

	* by membership fee
		oaxaca ``i'' HHR14 HHR4 ID10 goats_owned bHHR16 mem_length bMEM4 travel_time MEM7 ///
					MAN3 no_services REV4 CO_SER15 CO_SER2 MAN4 dist_*, ///
					by(gr_avg_MAN2) vce(cluster idx) swap weight(0) relax
		ereturn list
		matrix p = r(table)
		matrix d_`i'_4 = (_b[difference], p[5,3], p[6,3])
		matrix e_`i'_4 = (_b[explained], p[5,4], p[6,4])
		matrix u_`i'_4 = (_b[unexplained], p[5,5], p[6,5])		
		

* extensive (drop certain controls)

	* by sale info
		oaxaca ``i'' HHR14 HHR4 ID10 goats_owned bHHR16 mem_length bMEM4 travel_time MEM7 ///
					MAN2 MAN3 no_services REV4 CO_SER15 CO_SER2 MAN4 dist_*, ///
					by(gr_pct_COM3) vce(cluster idx) swap weight(0) relax
		ereturn list
		matrix p = r(table)
		matrix d_`i'_5 = (_b[difference], p[5,3], p[6,3])
		matrix e_`i'_5 = (_b[explained], p[5,4], p[6,4])
		matrix u_`i'_5 = (_b[unexplained], p[5,5], p[6,5])
		
	* by non-sale info
		oaxaca ``i'' HHR14 HHR4 ID10 goats_owned bHHR16 mem_length bMEM4 travel_time MEM7 ///
					MAN2 MAN3 no_services REV4 CO_SER15 CO_SER2 MAN4 dist_*, ///
					by(gr_pct_COM8) vce(cluster idx) swap weight(0) relax
		ereturn list
		matrix p = r(table)
		matrix d_`i'_6 = (_b[difference], p[5,3], p[6,3])
		matrix e_`i'_6 = (_b[explained], p[5,4], p[6,4])
		matrix u_`i'_6 = (_b[unexplained], p[5,5], p[6,5])
		
	* by pct loans
		oaxaca ``i'' HHR14 HHR4 ID10 goats_owned bHHR16 mem_length bMEM4 travel_time MEM7 ///
					MAN2 MAN3 no_services REV4 CO_SER15 CO_SER2 MAN4 dist_*, ///
					by(gr_pct_loan) vce(cluster idx) swap weight(0) relax
		ereturn list
		matrix p = r(table)
		matrix d_`i'_7 = (_b[difference], p[5,3], p[6,3])
		matrix e_`i'_7 = (_b[explained], p[5,4], p[6,4])
		matrix u_`i'_7 = (_b[unexplained], p[5,5], p[6,5])

	* by voting
		oaxaca ``i'' HHR14 HHR4 ID10 goats_owned bHHR16 mem_length bMEM4 travel_time MEM7 ///
					MAN2 MAN3 no_services REV4 CO_SER15 CO_SER2 MAN4 dist_*, ///
					by(gr_pct_MEM14) vce(cluster idx) swap weight(0) relax
		ereturn list
		matrix p = r(table)
		matrix d_`i'_8 = (_b[difference], p[5,3], p[6,3])
		matrix e_`i'_8 = (_b[explained], p[5,4], p[6,4])
		matrix u_`i'_8 = (_b[unexplained], p[5,5], p[6,5])		
		
		}
}		

* revenue
forv j = 1/4 {
	matrix d_`j'_ex = d_`j'_1
	matrix e_`j'_ex = e_`j'_1
	matrix u_`j'_ex = u_`j'_1
	matrix d_`j'_in = d_`j'_5
	matrix e_`j'_in = e_`j'_5
	matrix u_`j'_in = u_`j'_5
	
	forv i = 2/4 {
		matrix d_`j'_ex = d_`j'_ex \ d_`j'_`i'
		matrix e_`j'_ex = e_`j'_ex \ e_`j'_`i'
		matrix u_`j'_ex = u_`j'_ex \ u_`j'_`i'
	}
	forv i = 6/8 {
		matrix d_`j'_in = d_`j'_in \ d_`j'_`i'
		matrix e_`j'_in = e_`j'_in \ e_`j'_`i'
		matrix u_`j'_in = u_`j'_in \ u_`j'_`i'
	}

	matrix rownames d_`j'_ex = "% non-literate" "% below median number of goats" "CV on goats owned" ///
					"Size of membership fee"	
	matrix rownames e_`j'_ex = "% non-literate" "% below median number of goats" "CV on goats owned" ///
					"Size of membership fee"	
	matrix rownames u_`j'_ex = "% non-literate" "% below median number of goats" "CV on goats owned" ///
					"Size of membership fee"	
	matrix rownames d_`j'_in = "% receiving sale information" "% receiving non-sale information" ///
					"% receiving loans" "% voted in elections"	
	matrix rownames e_`j'_in = "% receiving sale information" "% receiving non-sale information" ///
					"% receiving loans" "% voted in elections"	
	matrix rownames u_`j'_in = "% receiving sale information" "% receiving non-sale information" ///
					"% receiving loans" "% voted in elections"					
}	
	

* Revenue
coefplot (matrix(d_1_ex[,1]), ci((2 3)) label(Difference) msymbol(S)) ///
		 (matrix(e_1_ex[,1]), ci((2 3)) label(Characteristics) msymbol(T)) /// 
		 (matrix(u_1_ex[,1]), ci((2 3)) label(Returns) msymbol(D)), bylabel(Revenue) ///
		 xline(0) ylab(, labs(small)) legend(rows(1) size(small)) ///
		 graphregion(color(white) ilcolor(white)) plotregion(margin(zero)) aspectratio(1.15) coeflabels(, wrap(15))
graph export "$d2/decomp_1_ex.png", replace
coefplot (matrix(d_1_in[,1]), ci((2 3)) label(Difference) msymbol(S)) ///
		 (matrix(e_1_in[,1]), ci((2 3)) label(Characteristics) msymbol(T)) /// 
		 (matrix(u_1_in[,1]), ci((2 3)) label(Returns) msymbol(D)), bylabel(Revenue) ///
		 xline(0) ylab(, labs(small)) legend(rows(1) size(small)) ///
		 graphregion(color(white) ilcolor(white)) plotregion(margin(zero)) aspectratio(1.15) coeflabels(, wrap(15))
graph export "$d2/decomp_1_in.png", replace

* Goats sold
coefplot (matrix(d_2_ex[,1]), ci((2 3)) label(Difference) msymbol(S)) ///
		 (matrix(e_2_ex[,1]), ci((2 3)) label(Characteristics) msymbol(T)) /// 
		 (matrix(u_2_ex[,1]), ci((2 3)) label(Returns) msymbol(D)), bylabel(Revenue) ///
		 xline(0) ylab(, labs(small)) legend(rows(1) size(small)) ///
		 graphregion(color(white) ilcolor(white)) plotregion(margin(zero)) aspectratio(1.15) coeflabels(, wrap(15))
graph export "$d2/decomp_2_ex.png", replace
coefplot (matrix(d_2_in[,1]), ci((2 3)) label(Difference) msymbol(S)) ///
		 (matrix(e_2_in[,1]), ci((2 3)) label(Characteristics) msymbol(T)) /// 
		 (matrix(u_2_in[,1]), ci((2 3)) label(Returns) msymbol(D)), bylabel(Revenue) ///
		 xline(0) ylab(, labs(small)) legend(rows(1) size(small)) ///
		 graphregion(color(white) ilcolor(white)) plotregion(margin(zero)) aspectratio(1.15) coeflabels(, wrap(15))
graph export "$d2/decomp_2_in.png", replace

* Loan amount
coefplot (matrix(d_3_ex[,1]), ci((2 3)) label(Difference) msymbol(S)) ///
		 (matrix(e_3_ex[,1]), ci((2 3)) label(Characteristics) msymbol(T)) /// 
		 (matrix(u_3_ex[,1]), ci((2 3)) label(Returns) msymbol(D)), bylabel(Revenue) ///
		 xline(0) ylab(, labs(small)) legend(rows(1) size(small)) ///
		 graphregion(color(white) ilcolor(white)) plotregion(margin(zero)) aspectratio(1.15) coeflabels(, wrap(15))
graph export "$d2/decomp_3_ex.png", replace
coefplot (matrix(d_3_in[,1]), ci((2 3)) label(Difference) msymbol(S)) ///
		 (matrix(e_3_in[,1]), ci((2 3)) label(Characteristics) msymbol(T)) /// 
		 (matrix(u_3_in[,1]), ci((2 3)) label(Returns) msymbol(D)), bylabel(Revenue) ///
		 xline(0) ylab(, labs(small)) legend(rows(1) size(small)) ///
		 graphregion(color(white) ilcolor(white)) plotregion(margin(zero)) aspectratio(1.15) coeflabels(, wrap(15))
graph export "$d2/decomp_3_in.png", replace

* Loan amount
coefplot (matrix(d_4_ex[,1]), ci((2 3)) label(Difference) msymbol(S)) ///
		 (matrix(e_4_ex[,1]), ci((2 3)) label(Characteristics) msymbol(T)) /// 
		 (matrix(u_4_ex[,1]), ci((2 3)) label(Returns) msymbol(D)), bylabel(Revenue) ///
		 xline(0) ylab(, labs(small)) legend(rows(1) size(small)) ///
		 graphregion(color(white) ilcolor(white)) plotregion(margin(zero)) aspectratio(1.15) coeflabels(, wrap(15))
graph export "$d2/decomp_4_ex.png", replace
coefplot (matrix(d_4_in[,1]), ci((2 3)) label(Difference) msymbol(S)) ///
		 (matrix(e_4_in[,1]), ci((2 3)) label(Characteristics) msymbol(T)) /// 
		 (matrix(u_4_in[,1]), ci((2 3)) label(Returns) msymbol(D)), bylabel(Revenue) ///
		 xline(0) ylab(, labs(small)) legend(rows(1) size(small)) ///
		 graphregion(color(white) ilcolor(white)) plotregion(margin(zero)) aspectratio(1.15) coeflabels(, wrap(15))
graph export "$d2/decomp_4_in.png", replace



