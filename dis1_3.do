
/*******************************************************************************
dis1_3.d0		
					
- Oaxaca Decomposition Analysis						
	
*******************************************************************************/

*ssc install oaxaca

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
		scalar par_``i'' = _b[``i''] // mean
		scalar se_``i'' = _se[``i'']  // sd
		scalar df_1_`i' = `e(df_r)'
		* matrix for table
		matrix mat_1_`i' = (par_``i'', se_``i'')
		
		reg co_opgoatno_w ``i''
		ereturn list
		scalar par_``i'' = _b[``i''] // mean
		scalar se_``i'' = _se[``i'']  // sd
		scalar df_2_`i' = `e(df_r)'
		* matrix for table
		matrix mat_2_`i' = (par_``i'', se_``i'')
		
		reg co_loan_amt ``i''
		ereturn list
		scalar par_``i'' = _b[``i''] // mean
		scalar se_``i'' = _se[``i'']  // sd
		scalar df_3_`i' = `e(df_r)'
		* matrix for table
		matrix mat_3_`i' = (par_``i'', se_``i'')
		
		reg index_benefits ``i''
		ereturn list
		scalar par_``i'' = _b[``i''] // mean
		scalar se_``i'' = _se[``i'']  // sd
		scalar df_4_`i' = `e(df_r)'
		* matrix for table
		matrix mat_4_`i' = (par_``i'', se_``i'')
		
		}
}
matrix A = mat_1_1
matrix B = mat_2_1
matrix C = mat_3_1
matrix D = mat_4_1

forv i = 2/`listsize' { // appends into single matrix
	matrix A = A \ mat_1_`i'
	matrix B = B \ mat_2_`i'
	matrix C = C \ mat_3_`i'
	matrix D = D \ mat_4_`i'
}


gl mat A B C D
local mlistsize : list sizeof global(mat)
tokenize $mat

forv m = 1/`mlistsize' {
matrix stars``m''=J(`listsize',2,0)
		forvalues k = 1/`listsize'{
			matrix stars``m''[`k',1] =   ///
			(abs(``m''[`k',1]/``m''[`k',2]) > invttail(df_`m'_`k',0.1/2)) +  ///
			(abs(``m''[`k',1]/``m''[`k',2]) > invttail(df_`m'_`k',0.05/2)) +  ///
			(abs(``m''[`k',1]/``m''[`k',2]) > invttail(df_`m'_`k',0.01/2))
		}
}

* Table
frmttable using avg_gap.tex, tex statmat(A) sdec(2) substat(1) coljust(l;c;l;l) title("Average Gap") annotate(starsA) asymbol(*,**,***) ///
ctitle("Group Definition","Cooperative goat"\"","revenue (USD)") ///
rtitle("Percentage of non-literate members"\""\ ///
		"Percentage of members below the median number of goats owned"\""\ ///
		"Coefficient of variation on members' goats"\""\ ///
		"Size of membership fee"\""\ ///
		"Percentage of members receiving sale information"\""\ ///
		"Percentage of members receiving non-sale information"\""\ ///
		"Percentage of members receiving loans"\""\ ///
		"Percentage of members who voted in cooperative elections"\"") replace	
frmttable using avg_gap.tex, tex statmat(B) sdec(2) substat(1) coljust(l;c;l;l) annotate(starsB) asymbol(*,**,***) ///
ctitle("Cooperative goats"\"sold (count)") merge
frmttable using avg_gap.tex, tex statmat(C) sdec(2) substat(1) coljust(l;c;l;l) annotate(starsC) asymbol(*,**,***) ///
ctitle("Cooperative loan"\"amount (USD)") merge
frmttable using avg_gap.tex, tex statmat(D) sdec(2) substat(1) coljust(l;c;l;l) annotate(starsD) asymbol(*,**,***) ///
ctitle("Cooperative benefits"\"index") merge




* ----------------------------------------------------
** Oaxaca decomposition

* generate district dummies
quietly tab district, gen(dist_)


* cooperative goat revenue
gl gap_1 gr_pct_HHR14 gr_pct_low_goats gr_cv_goats gr_avg_MAN2 gr_pct_COM3 gr_pct_COM8 gr_pct_loan gr_pct_MEM14 
	
local listsize : list sizeof global(gap_1)
tokenize $gap_1

forv i = 1/`listsize' {
		
	quietly {
		oaxaca co_opsalevalue HHR14 HHR4 ID10 goats_owned mem_length travel_time MAN2 MAN3 MAN4 MAN10 no_services, by(``i'') vce(cluster idx) swap weight(0) relax
		ereturn list
		scalar par_d_``i'' = _b[difference] // mean
		scalar se_d_``i'' = _se[difference]  // sd
		return list 
		matrix p1 = r(table)
		scalar p_`i'_1 = p1[4,3]
		* matrix for table
		matrix mat_1_`i' = (par_d_``i'', se_d_``i'')
		
		scalar par_e_``i'' = _b[explained] // mean
		scalar se_e_``i'' = _se[explained]  // sd
		scalar p_`i'_2 = p1[4,4]
		* matrix for table
		matrix mat_2_`i' = (par_e_``i'', se_e_``i'')
		
		scalar par_c_``i'' = _b[unexplained] // mean
		scalar se_c_``i'' = _se[unexplained]  // sd
		scalar p_`i'_3 = p1[4,5]
		* matrix for table
		matrix mat_3_`i' = (par_c_``i'', se_c_``i'')
		/*
		scalar par_i_``i'' = _b[interaction] // mean
		scalar se_i_``i'' = _se[interaction]  // sd
		scalar p_`i'_4 = p1[4,6]
		* matrix for table
		matrix mat_4_`i' = (par_i_``i'', se_i_``i'')
		*/
		
		}
}
matrix A = mat_1_1
matrix B = mat_2_1
matrix C = mat_3_1
*matrix D = mat_4_1

forv i = 2/`listsize' { // appends into single matrix
	matrix A = A \ mat_1_`i'
	matrix B = B \ mat_2_`i'
	matrix C = C \ mat_3_`i'
	*matrix D = D \ mat_4_`i'
}

gl mat A B C
local mlistsize : list sizeof global(mat)
tokenize $mat

forv m = 1/`mlistsize' {
matrix stars``m''=J(`listsize',1,0)
		forvalues k = 1/`listsize'{
			matrix stars``m''[`k',1] =   ///
			(.1 > p_`k'_`m') +  ///
			(.05 > p_`k'_`m') +  ///
			(.01 > p_`k'_`m')
		}
}


* Table
frmttable using E1_decomp_1.tex, tex statmat(A) sdec(2) substat(1) coljust(l;c;l;l) title("Oaxaca Decomposition") annotate(starsA) asymbol(*,**,***) ///
ctitle("Cooperative goat revenue","Difference") ///
rtitle("Percentage of non-literate members"\""\ ///
		"Percentage of members below the median number of goats owned"\""\ ///
		"Coefficient of variation on members' goats"\""\ ///
		"Size of membership fee"\""\ ///
		"Percentage of members receiving sale information"\""\ ///
		"Percentage of members receiving non-sale information"\""\ ///
		"Percentage of members receiving loans"\""\ ///
		"Percentage of members who voted in cooperative elections"\"") replace	
frmttable using E1_decomp_1.tex, tex statmat(B) sdec(2) substat(1) coljust(l;c;l;l) annotate(starsB) asymbol(*,**,***) ///
ctitle("Characteristics") merge
frmttable using E1_decomp_1.tex, tex statmat(C) sdec(2) substat(1) coljust(l;c;l;l) annotate(starsC) asymbol(*,**,***) ///
ctitle("Returns") merge
*frmttable using E1_decomp_1.tex, tex statmat(D) sdec(2) substat(1) coljust(l;c;l;l) annotate(starsD) asymbol(*,**,***) ///
*ctitle("Interaction") merge



* cooperative goats sold
gl gap_1 gr_pct_HHR14 gr_pct_low_goats gr_cv_goats gr_avg_MAN2 gr_pct_COM3 gr_pct_COM8 gr_pct_loan gr_pct_MEM14 
	
local listsize : list sizeof global(gap_1)
tokenize $gap_1

forv i = 1/`listsize' {
		
	quietly {
		oaxaca co_opgoatno_w HHR14 HHR4 ID10 goats_owned mem_length travel_time MAN2 MAN3 MAN4 MAN10 no_services, by(``i'') vce(cluster idx) swap weight(0) relax
		ereturn list
		scalar par_d_``i'' = _b[difference] // mean
		scalar se_d_``i'' = _se[difference]  // sd
		return list 
		matrix p1 = r(table)
		scalar p_`i'_1 = p1[4,3]
		* matrix for table
		matrix mat_1_`i' = (par_d_``i'', se_d_``i'')
		
		scalar par_e_``i'' = _b[explained] // mean
		scalar se_e_``i'' = _se[explained]  // sd
		scalar p_`i'_2 = p1[4,4]
		* matrix for table
		matrix mat_2_`i' = (par_e_``i'', se_e_``i'')
		
		scalar par_c_``i'' = _b[unexplained] // mean
		scalar se_c_``i'' = _se[unexplained]  // sd
		scalar p_`i'_3 = p1[4,5]
		* matrix for table
		matrix mat_3_`i' = (par_c_``i'', se_c_``i'')
		/*
		scalar par_i_``i'' = _b[interaction] // mean
		scalar se_i_``i'' = _se[interaction]  // sd
		scalar p_`i'_4 = p1[4,6]
		* matrix for table
		matrix mat_4_`i' = (par_i_``i'', se_i_``i'')
		*/
		
		}
}
matrix A = mat_1_1
matrix B = mat_2_1
matrix C = mat_3_1
*matrix D = mat_4_1

forv i = 2/`listsize' { // appends into single matrix
	matrix A = A \ mat_1_`i'
	matrix B = B \ mat_2_`i'
	matrix C = C \ mat_3_`i'
	*matrix D = D \ mat_4_`i'
}

gl mat A B C
local mlistsize : list sizeof global(mat)
tokenize $mat

forv m = 1/`mlistsize' {
matrix stars``m''=J(`listsize',1,0)
		forvalues k = 1/`listsize'{
			matrix stars``m''[`k',1] =   ///
			(.1 > p_`k'_`m') +  ///
			(.05 > p_`k'_`m') +  ///
			(.01 > p_`k'_`m')
		}
}


* Table
frmttable using E1_decomp_2.tex, tex statmat(A) sdec(2) substat(1) coljust(l;c;l;l) title("Oaxaca Decomposition") annotate(starsA) asymbol(*,**,***) ///
ctitle("Cooperative goats sold","Difference") ///
rtitle("Percentage of non-literate members"\""\ ///
		"Percentage of members below the median number of goats owned"\""\ ///
		"Coefficient of variation on members' goats"\""\ ///
		"Size of membership fee"\""\ ///
		"Percentage of members receiving sale information"\""\ ///
		"Percentage of members receiving non-sale information"\""\ ///
		"Percentage of members receiving loans"\""\ ///
		"Percentage of members who voted in cooperative elections"\"") replace	
frmttable using E1_decomp_2.tex, tex statmat(B) sdec(2) substat(1) coljust(l;c;l;l) annotate(starsB) asymbol(*,**,***) ///
ctitle("Characteristics") merge
frmttable using E1_decomp_2.tex, tex statmat(C) sdec(2) substat(1) coljust(l;c;l;l) annotate(starsC) asymbol(*,**,***) ///
ctitle("Returns") merge
*frmttable using E1_decomp_2.tex, tex statmat(D) sdec(2) substat(1) coljust(l;c;l;l) annotate(starsD) asymbol(*,**,***) ///
*ctitle("Interaction") merge


* cooperative loan amount
gl gap_1 gr_pct_HHR14 gr_pct_low_goats gr_cv_goats gr_avg_MAN2 gr_pct_COM3 gr_pct_COM8 gr_pct_loan gr_pct_MEM14 
	
local listsize : list sizeof global(gap_1)
tokenize $gap_1

forv i = 1/`listsize' {
		
	quietly {
		oaxaca co_loan_amt HHR14 HHR4 ID10 goats_owned mem_length travel_time MAN2 MAN3 MAN4 MAN10 no_services, by(``i'') vce(cluster idx) swap weight(0) relax
		ereturn list
		scalar par_d_``i'' = _b[difference] // mean
		scalar se_d_``i'' = _se[difference]  // sd
		return list 
		matrix p1 = r(table)
		scalar p_`i'_1 = p1[4,3]
		* matrix for table
		matrix mat_1_`i' = (par_d_``i'', se_d_``i'')
		
		scalar par_e_``i'' = _b[explained] // mean
		scalar se_e_``i'' = _se[explained]  // sd
		scalar p_`i'_2 = p1[4,4]
		* matrix for table
		matrix mat_2_`i' = (par_e_``i'', se_e_``i'')
		
		scalar par_c_``i'' = _b[unexplained] // mean
		scalar se_c_``i'' = _se[unexplained]  // sd
		scalar p_`i'_3 = p1[4,5]
		* matrix for table
		matrix mat_3_`i' = (par_c_``i'', se_c_``i'')
		/*
		scalar par_i_``i'' = _b[interaction] // mean
		scalar se_i_``i'' = _se[interaction]  // sd
		scalar p_`i'_4 = p1[4,6]
		* matrix for table
		matrix mat_4_`i' = (par_i_``i'', se_i_``i'')
		*/
		
		}
}
matrix A = mat_1_1
matrix B = mat_2_1
matrix C = mat_3_1
*matrix D = mat_4_1

forv i = 2/`listsize' { // appends into single matrix
	matrix A = A \ mat_1_`i'
	matrix B = B \ mat_2_`i'
	matrix C = C \ mat_3_`i'
	*matrix D = D \ mat_4_`i'
}

gl mat A B C
local mlistsize : list sizeof global(mat)
tokenize $mat

forv m = 1/`mlistsize' {
matrix stars``m''=J(`listsize',1,0)
		forvalues k = 1/`listsize'{
			matrix stars``m''[`k',1] =   ///
			(.1 > p_`k'_`m') +  ///
			(.05 > p_`k'_`m') +  ///
			(.01 > p_`k'_`m')
		}
}




* Table
frmttable using E1_decomp_3.tex, tex statmat(A) sdec(2) substat(1) coljust(l;c;l;l) title("Oaxaca Decomposition") annotate(starsA) asymbol(*,**,***) ///
ctitle("Cooperative loan amount","Difference") ///
rtitle("Percentage of non-literate members"\""\ ///
		"Percentage of members below the median number of goats owned"\""\ ///
		"Coefficient of variation on members' goats"\""\ ///
		"Size of membership fee"\""\ ///
		"Percentage of members receiving sale information"\""\ ///
		"Percentage of members receiving non-sale information"\""\ ///
		"Percentage of members receiving loans"\""\ ///
		"Percentage of members who voted in cooperative elections"\"") replace	
frmttable using E1_decomp_3.tex, tex statmat(B) sdec(2) substat(1) coljust(l;c;l;l) annotate(starsB) asymbol(*,**,***) ///
ctitle("Characteristics") merge
frmttable using E1_decomp_3.tex, tex statmat(C) sdec(2) substat(1) coljust(l;c;l;l) annotate(starsC) asymbol(*,**,***) ///
ctitle("Returns") merge
*frmttable using E1_decomp_3.tex, tex statmat(D) sdec(2) substat(1) coljust(l;c;l;l) annotate(starsD) asymbol(*,**,***) ///
*ctitle("Interaction") merge


* cooperative benefits index
gl gap_1 gr_pct_HHR14 gr_pct_low_goats gr_cv_goats gr_avg_MAN2 gr_pct_COM3 gr_pct_COM8 gr_pct_loan gr_pct_MEM14 
	
local listsize : list sizeof global(gap_1)
tokenize $gap_1

forv i = 1/`listsize' {
		
	quietly {
		oaxaca index_benefits HHR14 HHR4 ID10 goats_owned mem_length travel_time MAN2 MAN3 MAN4 MAN10 no_services, by(``i'') vce(cluster idx) swap weight(0) relax
		ereturn list
		scalar par_d_``i'' = _b[difference] // mean
		scalar se_d_``i'' = _se[difference]  // sd
		return list 
		matrix p1 = r(table)
		scalar p_`i'_1 = p1[4,3]
		* matrix for table
		matrix mat_1_`i' = (par_d_``i'', se_d_``i'')
		
		scalar par_e_``i'' = _b[explained] // mean
		scalar se_e_``i'' = _se[explained]  // sd
		scalar p_`i'_2 = p1[4,4]
		* matrix for table
		matrix mat_2_`i' = (par_e_``i'', se_e_``i'')
		
		scalar par_c_``i'' = _b[unexplained] // mean
		scalar se_c_``i'' = _se[unexplained]  // sd
		scalar p_`i'_3 = p1[4,5]
		* matrix for table
		matrix mat_3_`i' = (par_c_``i'', se_c_``i'')
		/*
		scalar par_i_``i'' = _b[interaction] // mean
		scalar se_i_``i'' = _se[interaction]  // sd
		scalar p_`i'_4 = p1[4,6]
		* matrix for table
		matrix mat_4_`i' = (par_i_``i'', se_i_``i'')
		*/
		
		}
}
matrix A = mat_1_1
matrix B = mat_2_1
matrix C = mat_3_1
*matrix D = mat_4_1

forv i = 2/`listsize' { // appends into single matrix
	matrix A = A \ mat_1_`i'
	matrix B = B \ mat_2_`i'
	matrix C = C \ mat_3_`i'
	*matrix D = D \ mat_4_`i'
}

gl mat A B C
local mlistsize : list sizeof global(mat)
tokenize $mat

forv m = 1/`mlistsize' {
matrix stars``m''=J(`listsize',1,0)
		forvalues k = 1/`listsize'{
			matrix stars``m''[`k',1] =   ///
			(.1 > p_`k'_`m') +  ///
			(.05 > p_`k'_`m') +  ///
			(.01 > p_`k'_`m')
		}
}


* Table
frmttable using E1_decomp_4.tex, tex statmat(A) sdec(2) substat(1) coljust(l;c;l;l) title("Oaxaca Decomposition") annotate(starsA) asymbol(*,**,***) ///
ctitle("Benefits Index","Difference") ///
rtitle("Percentage of non-literate members"\""\ ///
		"Percentage of members below the median number of goats owned"\""\ ///
		"Coefficient of variation on members' goats"\""\ ///
		"Size of membership fee"\""\ ///
		"Percentage of members receiving sale information"\""\ ///
		"Percentage of members receiving non-sale information"\""\ ///
		"Percentage of members receiving loans"\""\ ///
		"Percentage of members who voted in cooperative elections"\"") replace	
frmttable using E1_decomp_4.tex, tex statmat(B) sdec(2) substat(1) coljust(l;c;l;l) annotate(starsB) asymbol(*,**,***) ///
ctitle("Characteristics") merge
frmttable using E1_decomp_4.tex, tex statmat(C) sdec(2) substat(1) coljust(l;c;l;l) annotate(starsC) asymbol(*,**,***) ///
ctitle("Returns") merge
*frmttable using E1_decomp_4.tex, tex statmat(D) sdec(2) substat(1) coljust(l;c;l;l) annotate(starsD) asymbol(*,**,***) ///
*ctitle("Interaction") merge



* ----------------------------------------------------
** OLS regressions	  

encode district, gen(n_district)
replace REV4 = REV4*(0.0099)

lab var HHR14 "Literacy (0/1)"
lab var HHR4 "Age (years)"
lab var ID10 "Number of household members (count)"
lab var goats_owned "Total number of goats owned (count)"
lab var bHHR16 "Primary activity is agriculture (0/1)"
lab var mem_length "Length of membership (years)"
lab var bMEM4 "Cooperative leadership role (0/1)"
lab var travel_time "Round-trip travel time to cooperative meetings (minutes)"
lab var MEM7 "SHG meetings attended in last 6-months (count)"

lab var MAN2 "Membership fee (USD)"
lab var MAN3 "Number of cooperative members (count)"
lab var no_services "Number of servcies offered (count)"
lab var REV4 "Total revenue in last 6-months (USD)"
lab var CO_SER15 "Cooperative organizes goat sales (0/1)"
lab var CO_SER2 "Cooperative offers loans to members (0/1)"
lab var MAN4 "Size of management committee (count)"
			
		

* extensive (drop certain controls)
gl outcomes co_opsalevalue co_opgoatno_w co_loan_amt index_benefits
	
local listsize : list sizeof global(outcomes)
tokenize $outcomes	

forv i = 1/`listsize' {
	quietly {

	* by literacy (remove literacy control)
reg ``i'' HHR4 ID10 goats_owned bHHR16 mem_length bMEM4 travel_time MEM7 ///
					MAN2 MAN3 no_services REV4 CO_SER15 CO_SER2 MAN4 i.n_district ///
					if gr_pct_HHR14 == 1, vce(cluster idx)
outreg2 using E1_ols_`i'_1.tex, drop(i.n_district) stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex replace label ///
		addtext(District dummies, Yes) 

reg ``i'' HHR4 ID10 goats_owned bHHR16 mem_length bMEM4 travel_time MEM7 ///
					MAN2 MAN3 no_services REV4 CO_SER15 CO_SER2 MAN4 i.n_district ///
					if gr_pct_HHR14 == 0, vce(cluster idx)
outreg2 using E1_ols_`i'_1.tex, drop(i.n_district) stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex append label ///
		addtext(District dummies, Yes) 
		
* by low goats
reg ``i'' HHR14 HHR4 ID10 goats_owned bHHR16 mem_length bMEM4 travel_time MEM7 ///
					MAN2 MAN3 no_services REV4 CO_SER15 CO_SER2 MAN4 i.n_district ///
					if gr_pct_low_goats == 1, vce(cluster idx)
outreg2 using E1_ols_`i'_1.tex, drop(i.n_district) stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex append label ///
		addtext(District dummies, Yes) 

reg ``i'' HHR14 HHR4 ID10 goats_owned bHHR16 mem_length bMEM4 travel_time MEM7 ///
					MAN2 MAN3 no_services REV4 CO_SER15 CO_SER2 MAN4 i.n_district ///
					if gr_pct_low_goats == 0, vce(cluster idx)
outreg2 using E1_ols_`i'_1.tex, drop(i.n_district) stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex append label ///
		addtext(District dummies, Yes) 		
		
* by CV goats
reg ``i'' HHR14 HHR4 ID10 goats_owned bHHR16 mem_length bMEM4 travel_time MEM7 ///
					MAN2 MAN3 no_services REV4 CO_SER15 CO_SER2 MAN4 i.n_district ///
					if gr_cv_goats == 1, vce(cluster idx)
outreg2 using E1_ols_`i'_1.tex, drop(i.n_district) stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex append label ///
		addtext(District dummies, Yes) 

reg ``i'' HHR14 HHR4 ID10 goats_owned bHHR16 mem_length bMEM4 travel_time MEM7 ///
					MAN2 MAN3 no_services REV4 CO_SER15 CO_SER2 MAN4 i.n_district ///
					if gr_cv_goats == 0, vce(cluster idx)
outreg2 using E1_ols_`i'_1.tex, drop(i.n_district) stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex append label ///
		addtext(District dummies, Yes) 				
		
* by size of membership fee (remove membership fee control)
reg ``i'' HHR14 HHR4 ID10 goats_owned bHHR16 mem_length bMEM4 travel_time MEM7 ///
					MAN3 no_services REV4 CO_SER15 CO_SER2 MAN4 i.n_district ///
					if gr_avg_MAN2 == 1, vce(cluster idx)
outreg2 using E1_ols_`i'_1.tex, drop(i.n_district) stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex append label ///
		addtext(District dummies, Yes) 

reg ``i'' HHR14 HHR4 ID10 goats_owned bHHR16 mem_length bMEM4 travel_time MEM7 ///
					MAN3 no_services REV4 CO_SER15 CO_SER2 MAN4 i.n_district ///
					if gr_avg_MAN2 == 0, vce(cluster idx)
outreg2 using E1_ols_`i'_1.tex, drop(i.n_district) stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex append label ///
		addtext(District dummies, Yes) 					

	}
}

* intensive (full set of controls)
gl outcomes co_opsalevalue co_opgoatno_w co_loan_amt index_benefits
	
local listsize : list sizeof global(outcomes)
tokenize $outcomes	

forv i = 1/`listsize' {
	quietly {

* by sale info
reg ``i'' HHR14 HHR4 ID10 goats_owned bHHR16 mem_length bMEM4 travel_time MEM7 ///
					MAN2 MAN3 no_services REV4 CO_SER15 CO_SER2 MAN4 i.n_district ///
					if gr_pct_COM3 == 1, vce(cluster idx)
outreg2 using E1_ols_`i'_2.tex, drop(i.n_district) stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex replace label ///
		addtext(District dummies, Yes) 

reg ``i'' HHR14 HHR4 ID10 goats_owned bHHR16 mem_length bMEM4 travel_time MEM7 ///
					MAN2 MAN3 no_services REV4 CO_SER15 CO_SER2 MAN4 i.n_district ///
					if gr_pct_COM3 == 0, vce(cluster idx)
outreg2 using E1_ols_`i'_2.tex, drop(i.n_district) stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex append label ///
		addtext(District dummies, Yes) 
		
* by nonsale info
reg ``i'' HHR14 HHR4 ID10 goats_owned bHHR16 mem_length bMEM4 travel_time MEM7 ///
					MAN2 MAN3 no_services REV4 CO_SER15 CO_SER2 MAN4 i.n_district ///
					if gr_pct_COM8 == 1, vce(cluster idx)
outreg2 using E1_ols_`i'_2.tex, drop(i.n_district) stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex append label ///
		addtext(District dummies, Yes) 

reg ``i'' HHR14 HHR4 ID10 goats_owned bHHR16 mem_length bMEM4 travel_time MEM7 ///
					MAN2 MAN3 no_services REV4 CO_SER15 CO_SER2 MAN4 i.n_district ///
					if gr_pct_COM8 == 0, vce(cluster idx)
outreg2 using E1_ols_`i'_2.tex, drop(i.n_district) stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex append label ///
		addtext(District dummies, Yes) 		
		
* by loan pct
reg ``i'' HHR14 HHR4 ID10 goats_owned bHHR16 mem_length bMEM4 travel_time MEM7 ///
					MAN2 MAN3 no_services REV4 CO_SER15 CO_SER2 MAN4 i.n_district ///
					if gr_pct_loan == 1, vce(cluster idx)
outreg2 using E1_ols_`i'_2.tex, drop(i.n_district) stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex append label ///
		addtext(District dummies, Yes) 

reg ``i'' HHR14 HHR4 ID10 goats_owned bHHR16 mem_length bMEM4 travel_time MEM7 ///
					MAN2 MAN3 no_services REV4 CO_SER15 CO_SER2 MAN4 i.n_district ///
					if gr_pct_loan == 0, vce(cluster idx)
outreg2 using E1_ols_`i'_2.tex, drop(i.n_district) stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex append label ///
		addtext(District dummies, Yes) 				
		
* by voting
reg ``i'' HHR14 HHR4 ID10 goats_owned bHHR16 mem_length bMEM4 travel_time MEM7 ///
					MAN2 MAN3 no_services REV4 CO_SER15 CO_SER2 MAN4 i.n_district ///
					if gr_pct_MEM14 == 1, vce(cluster idx)
outreg2 using E1_ols_`i'_2.tex, drop(i.n_district) stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex append label ///
		addtext(District dummies, Yes) 

reg ``i'' HHR14 HHR4 ID10 goats_owned bHHR16 mem_length bMEM4 travel_time MEM7 ///
					MAN2 MAN3 no_services REV4 CO_SER15 CO_SER2 MAN4 i.n_district ///
					if gr_pct_MEM14 == 0, vce(cluster idx)
outreg2 using E1_ols_`i'_2.tex, drop(i.n_district) stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex append label ///
		addtext(District dummies, Yes) 					

	}
}


		

* oaxaca regression model
* benefits index by literacy
oaxaca index_benefits HHR4 ID10 goats_owned mem_length travel_time MAN2 MAN3 MAN4 MAN10 no_services, by(gr_pct_HHR14) vce(cluster idx) swap
		
		
		
