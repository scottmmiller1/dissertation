
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

* Pre-sales herd size
gen pre_goats_owned = goats_owned + LS8_w - LSE11_A + LSE13_A + LSE14_A	
replace pre_goats_owned = 0 if pre_goats_owned < 0 	

* return on goat assets
	gen return_assets = co_opsalevalue / pre_goats_owned if pre_goats_owned > 0
	replace return_assets = . if pre_goats_owned == 0
	
	gen return_assets_all = LS9_w / pre_goats_owned if pre_goats_owned > 0
	replace return_assets = . if pre_goats_owned == 0
	

replace LS9_w = . if LS8_w == 0		
replace LS8_w = . if LS8_w == 0		


* goat revenue & loan amount index
do "$d1/dis0_3.do"
local local_benefits LS9_w LS8_w co_loan_amt
	make_index_gr benefits wgt stdgroup `local_benefits' 


sum co_opsalevalue, d
sum co_opgoatno_w, d
sum co_loan_amt, d
sum index_benefits, d



gen married = (HHR7 == 1)
	
* ----------------------------------------------------
** Gap analysis

gl gap_1 gr_pct_HHR14 gr_pct_low_goats gr_cv_goats gr_avg_MAN2 gr_extensive_index gr_pct_COM3 gr_pct_COM8 gr_pct_loan gr_pct_MEM14 gr_intensive_index
	
local listsize : list sizeof global(gap_1)
tokenize $gap_1

forv i = 1/`listsize' {
		
		reg LS9_w gr_pct_HHR14, vce(cluster idx)
		
	quietly {
		reg LS9_w ``i'', vce(cluster idx)
		ereturn list
		scalar par_``i'' = _b[``i''] // mean
		scalar se_``i'' = _se[``i'']  // sd
		scalar df_1_`i' = `e(df_r)'
		* matrix for table
		matrix mat_1_`i' = (par_``i'', se_``i'')
		
		reg LS8_w ``i'', vce(cluster idx)
		ereturn list
		scalar par_``i'' = _b[``i''] // mean
		scalar se_``i'' = _se[``i'']  // sd
		scalar df_2_`i' = `e(df_r)'
		* matrix for table
		matrix mat_2_`i' = (par_``i'', se_``i'')
		
		reg co_loan_amt ``i'', vce(cluster idx)
		ereturn list
		scalar par_``i'' = _b[``i''] // mean
		scalar se_``i'' = _se[``i'']  // sd
		scalar df_3_`i' = `e(df_r)'
		* matrix for table
		matrix mat_3_`i' = (par_``i'', se_``i'')
		
		reg index_benefits ``i'', vce(cluster idx)
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
ctitle("Group Definition","Total goat"\"","revenue (USD)") ///
rtitle("Percentage of non-literate members"\""\ ///
		"Percentage of members below the median number of goats owned"\""\ ///
		"Coefficient of variation on members' goats"\""\ ///
		"Size of membership fee"\""\"Extensive inclusion index"\""\ ///
		"Percentage of members receiving sale information"\""\ ///
		"Percentage of members receiving non-sale information"\""\ ///
		"Percentage of members receiving loans"\""\ ///
		"Percentage of members who voted in cooperative elections"\""\"Intensive inclusion index"\"") replace	
frmttable using avg_gap.tex, tex statmat(B) sdec(2) substat(1) coljust(l;c;l;l) annotate(starsB) asymbol(*,**,***) ///
ctitle("Total goats"\"sold (count)") merge	
frmttable using avg_gap.tex, tex statmat(C) sdec(2) substat(1) coljust(l;c;l;l) annotate(starsC) asymbol(*,**,***) ///
ctitle("Cooperative loan"\"amount (USD)") merge
frmttable using avg_gap.tex, tex statmat(D) sdec(2) substat(1) coljust(l;c;l;l) annotate(starsD) asymbol(*,**,***) ///
ctitle("Cooperative benefits"\"index") merge




* ----------------------------------------------------
** Oaxaca decomposition

* generate district dummies
quietly tab district, gen(dist_)


gen bLS8 = (LS8_w > 0 & LS8_w !=.)
gen bco_goat = (co_opgoatno_w > 0 & co_opgoatno_w !=.)

replace LS8_w = . if LS8_w == 0
replace LS9_w = . if LS9_w == 0


* controls
/*
lab var HHR14 "Literacy (0/1)" - REMOVE
lab var HHR4 "Age (years)"
lab var ID10 "Number of household members (count)"
lab var goats_owned "Total number of goats owned (count)" - REMOVE
lab var bHHR16 "Primary activity is agriculture (0/1)"
lab var mem_length "Length of membership (years)" - REMOVE
lab var bMEM4 "Cooperative leadership role (0/1)"
lab var travel_time "Round-trip travel time to cooperative meetings (minutes)"
lab var MEM7 "SHG meetings attended in last 6-months (count)" - REMOVE

lab var MAN2 "Membership fee (USD)"  - REMOVE
lab var MAN3 "Number of cooperative members (count)"
lab var no_services "Number of servcies offered (count)"
lab var REV4 "Total revenue in last 6-months (USD)"
lab var CO_SER15 "Cooperative organizes goat sales (0/1)"  - REMOVE
lab var CO_SER2 "Cooperative offers loans to members (0/1)" - REMOVE
lab var MAN4 "Size of management committee (count)"
*/

* extensive (drop certain controls)
gl outcomes bLS8 LS8_w LS9_w bco_goat co_opgoatno_w co_opsalevalue co_loan_amt
	
local listsize : list sizeof global(outcomes)
tokenize $outcomes	

forv i = 1/`listsize' {
	quietly {
	* by literacy
		oaxaca ``i'' HHR4 ID10 bHHR16 bMEM4 travel_time index_emp nfloors dirt_floor married ///
					 MAN3 no_services REV4  CO_SER2 MAN4 dist_*, ///
					by(gr_pct_HHR14) vce(cluster idx) swap weight(0) relax level(90)
		ereturn list
		scalar par_d_`i'_1 = _b[difference] // mean
		scalar se_d_`i'_1 = _se[difference]  // sd
		return list 
		matrix p1 = r(table)
		scalar p_`i'_1_d = p1[4,3]
		* matrix for table
		matrix mat_`i'_1_d = (par_d_`i'_1, se_d_`i'_1)
		
		scalar par_e_`i'_1 = _b[explained] // mean
		scalar se_e_`i'_1 = _se[explained]  // sd
		scalar p_`i'_1_e = p1[4,4]
		* matrix for table
		matrix mat_`i'_1_e = (par_e_`i'_1, se_e_`i'_1)
		
		scalar par_u_`i'_1 = _b[unexplained] // mean
		scalar se_u_`i'_1 = _se[unexplained]  // sd
		scalar p_`i'_1_u = p1[4,5]
		* matrix for table
		matrix mat_`i'_1_u = (par_u_`i'_1, se_u_`i'_1)
		
	* by low goats
		oaxaca ``i'' HHR4 ID10 bHHR16 bMEM4 travel_time index_emp nfloors dirt_floor married ///
					 MAN3 no_services REV4   MAN4 dist_*, ///
					by(gr_pct_low_goats) vce(cluster idx) swap weight(0) relax level(90)
		ereturn list
		scalar par_d_`i'_2 = _b[difference] // mean
		scalar se_d_`i'_2 = _se[difference]  // sd
		return list 
		matrix p1 = r(table)
		scalar p_`i'_2_d = p1[4,3]
		* matrix for table
		matrix mat_`i'_2_d = (par_d_`i'_2, se_d_`i'_2)
		
		scalar par_e_`i'_2 = _b[explained] // mean
		scalar se_e_`i'_2 = _se[explained]  // sd
		scalar p_`i'_2_e = p1[4,4]
		* matrix for table
		matrix mat_`i'_2_e = (par_e_`i'_2, se_e_`i'_2)
		
		scalar par_u_`i'_2 = _b[unexplained] // mean
		scalar se_u_`i'_2 = _se[unexplained]  // sd
		scalar p_`i'_2_u = p1[4,5]
		* matrix for table
		matrix mat_`i'_2_u = (par_u_`i'_2, se_u_`i'_2)
		
	* by cv goats
		oaxaca ``i'' HHR4 ID10 bHHR16 bMEM4 travel_time index_emp nfloors dirt_floor married ///
					 MAN3 no_services REV4   MAN4 dist_*, ///
					by(gr_cv_goats) vce(cluster idx) swap weight(0) relax level(90)
		ereturn list
		scalar par_d_`i'_3 = _b[difference] // mean
		scalar se_d_`i'_3 = _se[difference]  // sd
		return list 
		matrix p1 = r(table)
		scalar p_`i'_3_d = p1[4,3]
		* matrix for table
		matrix mat_`i'_3_d = (par_d_`i'_3, se_d_`i'_3)
		
		scalar par_e_`i'_3 = _b[explained] // mean
		scalar se_e_`i'_3 = _se[explained]  // sd
		scalar p_`i'_3_e = p1[4,4]
		* matrix for table
		matrix mat_`i'_3_e = (par_e_`i'_3, se_e_`i'_3)
		
		scalar par_u_`i'_3 = _b[unexplained] // mean
		scalar se_u_`i'_3 = _se[unexplained]  // sd
		scalar p_`i'_3_u = p1[4,5]
		* matrix for table
		matrix mat_`i'_3_u = (par_u_`i'_3, se_u_`i'_3)	

	* by membership fee
		oaxaca ``i'' HHR4 ID10 bHHR16 bMEM4 travel_time index_emp nfloors dirt_floor married ///
					MAN3 no_services REV4   MAN4 dist_*, ///
					by(gr_avg_MAN2) vce(cluster idx) swap weight(0) relax level(90)
		ereturn list
		scalar par_d_`i'_4 = _b[difference] // mean
		scalar se_d_`i'_4 = _se[difference]  // sd
		return list 
		matrix p1 = r(table)
		scalar p_`i'_4_d = p1[4,3]
		* matrix for table
		matrix mat_`i'_4_d = (par_d_`i'_4, se_d_`i'_4)
		
		scalar par_e_`i'_4 = _b[explained] // mean
		scalar se_e_`i'_4 = _se[explained]  // sd
		scalar p_`i'_4_e = p1[4,4]
		* matrix for table
		matrix mat_`i'_4_e = (par_e_`i'_4, se_e_`i'_4)
		
		scalar par_u_`i'_4 = _b[unexplained] // mean
		scalar se_u_`i'_4 = _se[unexplained]  // sd
		scalar p_`i'_4_u = p1[4,5]
		* matrix for table
		matrix mat_`i'_4_u = (par_u_`i'_4, se_u_`i'_4)	
		
	* by extensive index
		oaxaca ``i'' HHR4 ID10 bHHR16 bMEM4 travel_time index_emp nfloors dirt_floor married  ///
					MAN3 no_services REV4   MAN4 dist_*, ///
					by(gr_extensive_index) vce(cluster idx) swap weight(0) relax level(90)
		ereturn list
		scalar par_d_`i'_5 = _b[difference] // mean
		scalar se_d_`i'_5 = _se[difference]  // sd
		return list 
		matrix p1 = r(table)
		scalar p_`i'_5_d = p1[4,3]
		* matrix for table
		matrix mat_`i'_5_d = (par_d_`i'_5, se_d_`i'_5)
		
		scalar par_e_`i'_5 = _b[explained] // mean
		scalar se_e_`i'_5 = _se[explained]  // sd
		scalar p_`i'_5_e = p1[4,4]
		* matrix for table
		matrix mat_`i'_5_e = (par_e_`i'_5, se_e_`i'_5)
		
		scalar par_u_`i'_5 = _b[unexplained] // mean
		scalar se_u_`i'_5 = _se[unexplained]  // sd
		scalar p_`i'_5_u = p1[4,5]
		* matrix for table
		matrix mat_`i'_5_u = (par_u_`i'_5, se_u_`i'_5)		
		
		

* intensive (drop certain controls)

	* by sale info
		oaxaca ``i'' HHR4 ID10 bHHR16 bMEM4 travel_time index_emp nfloors dirt_floor married  ///
					 MAN3 no_services REV4   MAN4 dist_*, ///
					by(gr_pct_COM3) vce(cluster idx) swap weight(0) relax level(90)
		ereturn list
		scalar par_d_`i'_6 = _b[difference] // mean
		scalar se_d_`i'_6 = _se[difference]  // sd
		return list 
		matrix p1 = r(table)
		scalar p_`i'_6_d = p1[4,3]
		* matrix for table
		matrix mat_`i'_6_d = (par_d_`i'_6, se_d_`i'_6)
		
		scalar par_e_`i'_6 = _b[explained] // mean
		scalar se_e_`i'_6 = _se[explained]  // sd
		scalar p_`i'_6_e = p1[4,4]
		* matrix for table
		matrix mat_`i'_6_e = (par_e_`i'_6, se_e_`i'_6)
		
		scalar par_u_`i'_6 = _b[unexplained] // mean
		scalar se_u_`i'_6 = _se[unexplained]  // sd
		scalar p_`i'_6_u = p1[4,5]
		* matrix for table
		matrix mat_`i'_6_u = (par_u_`i'_6, se_u_`i'_6)
		
	* by non-sale info
		oaxaca ``i'' HHR4 ID10 bHHR16 bMEM4 travel_time index_emp nfloors dirt_floor married  ///
					 MAN3 no_services REV4   MAN4 dist_*, ///
					by(gr_pct_COM8) vce(cluster idx) swap weight(0) relax level(90)
		ereturn list
		scalar par_d_`i'_7 = _b[difference] // mean
		scalar se_d_`i'_7 = _se[difference]  // sd
		return list 
		matrix p1 = r(table)
		scalar p_`i'_7_d = p1[4,3]
		* matrix for table
		matrix mat_`i'_7_d = (par_d_`i'_7, se_d_`i'_7)
		
		scalar par_e_`i'_7 = _b[explained] // mean
		scalar se_e_`i'_7 = _se[explained]  // sd
		scalar p_`i'_7_e = p1[4,4]
		* matrix for table
		matrix mat_`i'_7_e = (par_e_`i'_7, se_e_`i'_7)
		
		scalar par_u_`i'_7 = _b[unexplained] // mean
		scalar se_u_`i'_7 = _se[unexplained]  // sd
		scalar p_`i'_7_u = p1[4,5]
		* matrix for table
		matrix mat_`i'_7_u = (par_u_`i'_7, se_u_`i'_7)
		
	* by pct loans
		oaxaca ``i'' HHR4 ID10 bHHR16 bMEM4 travel_time index_emp nfloors dirt_floor married  ///
					 MAN3 no_services REV4   MAN4 dist_*, ///
					by(gr_pct_loan) vce(cluster idx) swap weight(0) relax level(90)
		ereturn list
		scalar par_d_`i'_8 = _b[difference] // mean
		scalar se_d_`i'_8 = _se[difference]  // sd
		return list 
		matrix p1 = r(table)
		scalar p_`i'_8_d = p1[4,3]
		* matrix for table
		matrix mat_`i'_8_d = (par_d_`i'_8, se_d_`i'_8)
		
		scalar par_e_`i'_8 = _b[explained] // mean
		scalar se_e_`i'_8 = _se[explained]  // sd
		scalar p_`i'_8_e = p1[4,4]
		* matrix for table
		matrix mat_`i'_8_e = (par_e_`i'_8, se_e_`i'_8)
		
		scalar par_u_`i'_8 = _b[unexplained] // mean
		scalar se_u_`i'_8 = _se[unexplained]  // sd
		scalar p_`i'_8_u = p1[4,5]
		* matrix for table
		matrix mat_`i'_8_u = (par_u_`i'_8, se_u_`i'_8)	

	* by voting
		oaxaca ``i'' HHR4 ID10 bHHR16 bMEM4 travel_time index_emp nfloors dirt_floor married  ///
					 MAN3 no_services REV4   MAN4 dist_*, ///
					by(gr_pct_MEM14) vce(cluster idx) swap weight(0) relax level(90)
		ereturn list
		scalar par_d_`i'_9 = _b[difference] // mean
		scalar se_d_`i'_9 = _se[difference]  // sd
		return list 
		matrix p1 = r(table)
		scalar p_`i'_9_d = p1[4,3]
		* matrix for table
		matrix mat_`i'_9_d = (par_d_`i'_9, se_d_`i'_9)
		
		scalar par_e_`i'_9 = _b[explained] // mean
		scalar se_e_`i'_9 = _se[explained]  // sd
		scalar p_`i'_9_e = p1[4,4]
		* matrix for table
		matrix mat_`i'_9_e = (par_e_`i'_9, se_e_`i'_9)
		
		scalar par_u_`i'_9 = _b[unexplained] // mean
		scalar se_u_`i'_9 = _se[unexplained]  // sd
		scalar p_`i'_9_u = p1[4,5]
		* matrix for table
		matrix mat_`i'_9_u = (par_u_`i'_9, se_u_`i'_9)	
		
	* by intensive index
		oaxaca ``i'' HHR4 ID10 bHHR16 bMEM4 travel_time index_emp nfloors dirt_floor married  ///
					 MAN3 no_services REV4   MAN4 dist_*, ///
					by(gr_intensive_index) vce(cluster idx) swap weight(0) relax level(90)
		ereturn list
		scalar par_d_`i'_10 = _b[difference] // mean
		scalar se_d_`i'_10 = _se[difference]  // sd
		return list 
		matrix p1 = r(table)
		scalar p_`i'_10_d = p1[4,3]
		* matrix for table
		matrix mat_`i'_10_d = (par_d_`i'_10, se_d_`i'_10)
		
		scalar par_e_`i'_10 = _b[explained] // mean
		scalar se_e_`i'_10 = _se[explained]  // sd
		scalar p_`i'_10_e = p1[4,4]
		* matrix for table
		matrix mat_`i'_10_e = (par_e_`i'_10, se_e_`i'_10)
		
		scalar par_u_`i'_10 = _b[unexplained] // mean
		scalar se_u_`i'_10 = _se[unexplained]  // sd
		scalar p_`i'_10_u = p1[4,5]
		* matrix for table
		matrix mat_`i'_10_u = (par_u_`i'_10, se_u_`i'_10)		
		
		}
}
	

** sells goats
* -----------------------------------------------------
matrix A = mat_1_1_d
matrix B = mat_1_1_e
matrix C = mat_1_1_u


forv i = 2/10 { // appends into single matrix
	matrix A = A \ mat_1_`i'_d
	matrix B = B \ mat_1_`i'_e
	matrix C = C \ mat_1_`i'_u
}

matrix starsA=J(10,1,0)
matrix starsB=J(10,1,0)
matrix starsC=J(10,1,0)
	forvalues i = 1/10 {
		matrix starsA[`i',1] =   ///
			(.1 > p_1_`i'_d) +  ///
			(.05 > p_1_`i'_d) +  ///
			(.01 > p_1_`i'_d)
		matrix starsB[`i',1] =   ///
			(.1 > p_1_`i'_e) +  ///
			(.05 > p_1_`i'_e) +  ///
			(.01 > p_1_`i'_e)
		matrix starsC[`i',1] =   ///
			(.1 > p_1_`i'_u) +  ///
			(.05 > p_1_`i'_u) +  ///
			(.01 > p_1_`i'_u)	
		}


* Table
frmttable using E1_decomp_1.tex, tex statmat(A) sdec(2) substat(1) coljust(l;c;l;l) title("Oaxaca Decomposition") annotate(starsA) asymbol(*,**,***) ///
ctitle("Member sells goats (0/1)","Difference") ///
rtitle("Percentage of non-literate members"\""\ ///
		"Percentage of members below the median number of goats owned"\""\ ///
		"Coefficient of variation on members' goats"\""\ ///
		"Size of membership fee"\""\"Extensive index"\""\ ///
		"Percentage of members receiving sale information"\""\ ///
		"Percentage of members receiving non-sale information"\""\ ///
		"Percentage of members receiving loans"\""\ ///
		"Percentage of members who voted in cooperative elections"\""\"Intensive index"\"") replace	
frmttable using E1_decomp_1.tex, tex statmat(B) sdec(2) substat(1) coljust(l;c;l;l) annotate(starsB) asymbol(*,**,***) ///
ctitle("Characteristics") merge
frmttable using E1_decomp_1.tex, tex statmat(C) sdec(2) substat(1) coljust(l;c;l;l) annotate(starsC) asymbol(*,**,***) ///
ctitle("Returns") merge



** goat revenue
* -----------------------------------------------------
matrix A = mat_3_1_d
matrix B = mat_3_1_e
matrix C = mat_3_1_u


forv i = 2/10 { // appends into single matrix
	matrix A = A \ mat_3_`i'_d
	matrix B = B \ mat_3_`i'_e
	matrix C = C \ mat_3_`i'_u
}

matrix starsA=J(10,1,0)
matrix starsB=J(10,1,0)
matrix starsC=J(10,1,0)
	forvalues i = 1/10 {
		matrix starsA[`i',1] =   ///
			(.1 > p_3_`i'_d) +  ///
			(.05 > p_3_`i'_d) +  ///
			(.01 > p_3_`i'_d)
		matrix starsB[`i',1] =   ///
			(.1 > p_3_`i'_e) +  ///
			(.05 > p_3_`i'_e) +  ///
			(.01 > p_3_`i'_e)
		matrix starsC[`i',1] =   ///
			(.1 > p_3_`i'_u) +  ///
			(.05 > p_3_`i'_u) +  ///
			(.01 > p_3_`i'_u)	
		}


* Table
frmttable using E1_decomp_2.tex, tex statmat(A) sdec(2) substat(1) coljust(l;c;l;l) title("Oaxaca Decomposition") annotate(starsA) asymbol(*,**,***) ///
ctitle("Total goat revenue (USD)","Difference") ///
rtitle("Percentage of non-literate members"\""\ ///
		"Percentage of members below the median number of goats owned"\""\ ///
		"Coefficient of variation on members' goats"\""\ ///
		"Size of membership fee"\""\"Extensive index"\""\ ///
		"Percentage of members receiving sale information"\""\ ///
		"Percentage of members receiving non-sale information"\""\ ///
		"Percentage of members receiving loans"\""\ ///
		"Percentage of members who voted in cooperative elections"\""\"Intensive index"\"") replace	
frmttable using E1_decomp_2.tex, tex statmat(B) sdec(2) substat(1) coljust(l;c;l;l) annotate(starsB) asymbol(*,**,***) ///
ctitle("Characteristics") merge
frmttable using E1_decomp_2.tex, tex statmat(C) sdec(2) substat(1) coljust(l;c;l;l) annotate(starsC) asymbol(*,**,***) ///
ctitle("Returns") merge


** Sells co-op goats
* -----------------------------------------------------
matrix A = mat_4_1_d
matrix B = mat_4_1_e
matrix C = mat_4_1_u


forv i = 2/10 { // appends into single matrix
	matrix A = A \ mat_4_`i'_d
	matrix B = B \ mat_4_`i'_e
	matrix C = C \ mat_4_`i'_u
}

matrix starsA=J(10,1,0)
matrix starsB=J(10,1,0)
matrix starsC=J(10,1,0)
	forvalues i = 1/10 {
		matrix starsA[`i',1] =   ///
			(.1 > p_4_`i'_d) +  ///
			(.05 > p_4_`i'_d) +  ///
			(.01 > p_4_`i'_d)
		matrix starsB[`i',1] =   ///
			(.1 > p_4_`i'_e) +  ///
			(.05 > p_4_`i'_e) +  ///
			(.01 > p_4_`i'_e)
		matrix starsC[`i',1] =   ///
			(.1 > p_4_`i'_u) +  ///
			(.05 > p_4_`i'_u) +  ///
			(.01 > p_4_`i'_u)	
		}


* Table
frmttable using E1_decomp_3.tex, tex statmat(A) sdec(2) substat(1) coljust(l;c;l;l) title("Oaxaca Decomposition") annotate(starsA) asymbol(*,**,***) ///
ctitle("Member sells goats through cooperative (0/1)","Difference") ///
rtitle("Percentage of non-literate members"\""\ ///
		"Percentage of members below the median number of goats owned"\""\ ///
		"Coefficient of variation on members' goats"\""\ ///
		"Size of membership fee"\""\"Extensive index"\""\ ///
		"Percentage of members receiving sale information"\""\ ///
		"Percentage of members receiving non-sale information"\""\ ///
		"Percentage of members receiving loans"\""\ ///
		"Percentage of members who voted in cooperative elections"\""\"Intensive index"\"") replace	
frmttable using E1_decomp_3.tex, tex statmat(B) sdec(2) substat(1) coljust(l;c;l;l) annotate(starsB) asymbol(*,**,***) ///
ctitle("Characteristics") merge
frmttable using E1_decomp_3.tex, tex statmat(C) sdec(2) substat(1) coljust(l;c;l;l) annotate(starsC) asymbol(*,**,***) ///
ctitle("Returns") merge


** Cooperative goat revenue
* -----------------------------------------------------
matrix A = mat_6_1_d
matrix B = mat_6_1_e
matrix C = mat_6_1_u


forv i = 2/10 { // appends into single matrix
	matrix A = A \ mat_6_`i'_d
	matrix B = B \ mat_6_`i'_e
	matrix C = C \ mat_6_`i'_u
}

matrix starsA=J(10,1,0)
matrix starsB=J(10,1,0)
matrix starsC=J(10,1,0)
	forvalues i = 1/10 {
		matrix starsA[`i',1] =   ///
			(.1 > p_6_`i'_d) +  ///
			(.05 > p_6_`i'_d) +  ///
			(.01 > p_6_`i'_d)
		matrix starsB[`i',1] =   ///
			(.1 > p_6_`i'_e) +  ///
			(.05 > p_6_`i'_e) +  ///
			(.01 > p_6_`i'_e)
		matrix starsC[`i',1] =   ///
			(.1 > p_6_`i'_u) +  ///
			(.05 > p_6_`i'_u) +  ///
			(.01 > p_6_`i'_u)	
		}


* Table
frmttable using E1_decomp_4.tex, tex statmat(A) sdec(2) substat(1) coljust(l;c;l;l) title("Oaxaca Decomposition") annotate(starsA) asymbol(*,**,***) ///
ctitle("Cooperative goat revenue (USD)","Difference") ///
rtitle("Percentage of non-literate members"\""\ ///
		"Percentage of members below the median number of goats owned"\""\ ///
		"Coefficient of variation on members' goats"\""\ ///
		"Size of membership fee"\""\"Extensive index"\""\ ///
		"Percentage of members receiving sale information"\""\ ///
		"Percentage of members receiving non-sale information"\""\ ///
		"Percentage of members receiving loans"\""\ ///
		"Percentage of members who voted in cooperative elections"\""\"Intensive index"\"") replace	
frmttable using E1_decomp_4.tex, tex statmat(B) sdec(2) substat(1) coljust(l;c;l;l) annotate(starsB) asymbol(*,**,***) ///
ctitle("Characteristics") merge
frmttable using E1_decomp_4.tex, tex statmat(C) sdec(2) substat(1) coljust(l;c;l;l) annotate(starsC) asymbol(*,**,***) ///
ctitle("Returns") merge


** Cooperative loan amount
* -----------------------------------------------------
matrix A = mat_7_1_d
matrix B = mat_7_1_e
matrix C = mat_7_1_u


forv i = 2/10 { // appends into single matrix
	matrix A = A \ mat_7_`i'_d
	matrix B = B \ mat_7_`i'_e
	matrix C = C \ mat_7_`i'_u
}

matrix starsA=J(10,1,0)
matrix starsB=J(10,1,0)
matrix starsC=J(10,1,0)
	forvalues i = 1/10 {
		matrix starsA[`i',1] =   ///
			(.1 > p_7_`i'_d) +  ///
			(.05 > p_7_`i'_d) +  ///
			(.01 > p_7_`i'_d)
		matrix starsB[`i',1] =   ///
			(.1 > p_7_`i'_e) +  ///
			(.05 > p_7_`i'_e) +  ///
			(.01 > p_7_`i'_e)
		matrix starsC[`i',1] =   ///
			(.1 > p_7_`i'_u) +  ///
			(.05 > p_7_`i'_u) +  ///
			(.01 > p_7_`i'_u)	
		}


* Table
frmttable using E1_decomp_5.tex, tex statmat(A) sdec(2) substat(1) coljust(l;c;l;l) title("Oaxaca Decomposition") annotate(starsA) asymbol(*,**,***) ///
ctitle("Cooperative loan amount (USD)","Difference") ///
rtitle("Percentage of non-literate members"\""\ ///
		"Percentage of members below the median number of goats owned"\""\ ///
		"Coefficient of variation on members' goats"\""\ ///
		"Size of membership fee"\""\"Extensive index"\""\ ///
		"Percentage of members receiving sale information"\""\ ///
		"Percentage of members receiving non-sale information"\""\ ///
		"Percentage of members receiving loans"\""\ ///
		"Percentage of members who voted in cooperative elections"\""\"Intensive index"\"") replace	
frmttable using E1_decomp_5.tex, tex statmat(B) sdec(2) substat(1) coljust(l;c;l;l) annotate(starsB) asymbol(*,**,***) ///
ctitle("Characteristics") merge
frmttable using E1_decomp_5.tex, tex statmat(C) sdec(2) substat(1) coljust(l;c;l;l) annotate(starsC) asymbol(*,**,***) ///
ctitle("Returns") merge




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
gl outcomes bLS8 LS9_w bco_goat co_opsalevalue co_loan_amt
	
local listsize : list sizeof global(outcomes)
tokenize $outcomes	

forv i = 1/`listsize' {
	quietly {
		
	* by extensive index
reg ``i'' HHR4 ID10 bHHR16 bMEM4 travel_time index_emp nfloors dirt_floor married  ///
					MAN3 no_services REV4   MAN4 i.n_district ///
					if gr_extensive_index == 1, vce(cluster idx)
outreg2 using E1_ols_`i'_1.tex, drop(i.n_district) stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex replace label ///
		addtext(District dummies, Yes) 			
		
reg ``i'' HHR4 ID10 bHHR16 bMEM4 travel_time index_emp nfloors dirt_floor married  ///
					MAN3 no_services REV4   MAN4 i.n_district ///
					if gr_extensive_index == 0, vce(cluster idx)
outreg2 using E1_ols_`i'_1.tex, drop(i.n_district) stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex append label ///
		addtext(District dummies, Yes) 			

	* by literacy (remove literacy control)
reg ``i'' HHR4 ID10 bHHR16 bMEM4 travel_time index_emp nfloors dirt_floor married  ///
					 MAN3 no_services REV4   MAN4 i.n_district ///
					if gr_pct_HHR14 == 1, vce(cluster idx)
outreg2 using E1_ols_`i'_1.tex, drop(i.n_district) stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex append label ///
		addtext(District dummies, Yes) 

reg ``i'' HHR4 ID10 bHHR16 bMEM4 travel_time index_emp nfloors dirt_floor married  ///
					 MAN3 no_services REV4   MAN4 i.n_district ///
					if gr_pct_HHR14 == 0, vce(cluster idx)
outreg2 using E1_ols_`i'_1.tex, drop(i.n_district) stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex append label ///
		addtext(District dummies, Yes) 
		
* by low goats (remove goats owned)
reg ``i'' HHR4 ID10 bHHR16 bMEM4 travel_time index_emp nfloors dirt_floor married  ///
					 MAN3 no_services REV4   MAN4 i.n_district ///
					if gr_pct_low_goats == 1, vce(cluster idx)
outreg2 using E1_ols_`i'_1.tex, drop(i.n_district) stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex append label ///
		addtext(District dummies, Yes) 

reg ``i'' HHR4 ID10 bHHR16 bMEM4 travel_time index_emp nfloors dirt_floor married  ///
					 MAN3 no_services REV4   MAN4 i.n_district ///
					if gr_pct_low_goats == 0, vce(cluster idx)
outreg2 using E1_ols_`i'_1.tex, drop(i.n_district) stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex append label ///
		addtext(District dummies, Yes) 		
		
* by CV goats (remove goats owned)
reg ``i'' HHR4 ID10 bHHR16 bMEM4 travel_time index_emp nfloors dirt_floor married  ///
					 MAN3 no_services REV4   MAN4 i.n_district ///
					if gr_cv_goats == 1, vce(cluster idx)
outreg2 using E1_ols_`i'_1.tex, drop(i.n_district) stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex append label ///
		addtext(District dummies, Yes) 

reg ``i'' HHR4 ID10 bHHR16 bMEM4 travel_time index_emp nfloors dirt_floor married  ///
					 MAN3 no_services REV4   MAN4 i.n_district ///
					if gr_cv_goats == 0, vce(cluster idx)
outreg2 using E1_ols_`i'_1.tex, drop(i.n_district) stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex append label ///
		addtext(District dummies, Yes) 				
		
* by size of membership fee (remove membership fee control)
reg ``i'' HHR4 ID10 bHHR16 bMEM4 travel_time index_emp nfloors dirt_floor married  ///
					MAN3 no_services REV4   MAN4 i.n_district ///
					if gr_avg_MAN2 == 1, vce(cluster idx)
outreg2 using E1_ols_`i'_1.tex, drop(i.n_district) stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex append label ///
		addtext(District dummies, Yes) 

reg ``i'' HHR4 ID10 bHHR16 bMEM4 travel_time index_emp nfloors dirt_floor married  ///
					MAN3 no_services REV4   MAN4 i.n_district ///
					if gr_avg_MAN2 == 0, vce(cluster idx)
outreg2 using E1_ols_`i'_1.tex, drop(i.n_district) stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex append label ///
		addtext(District dummies, Yes) 					

	}
}

* intensive (full set of controls)
gl outcomes bLS8 LS9_w bco_goat co_opsalevalue co_loan_amt
	
local listsize : list sizeof global(outcomes)
tokenize $outcomes	

forv i = 1/`listsize' {
	quietly {

	* by intensive index
reg ``i'' HHR4 ID10 bHHR16 bMEM4 travel_time index_emp nfloors dirt_floor married  ///
					 MAN3 no_services REV4   MAN4 i.n_district ///
					if gr_intensive_index == 1, vce(cluster idx)
outreg2 using E1_ols_`i'_2.tex, drop(i.n_district) stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex replace label ///
		addtext(District dummies, Yes) 
		
reg ``i'' HHR4 ID10 bHHR16 bMEM4 travel_time index_emp nfloors dirt_floor married  ///
					 MAN3 no_services REV4   MAN4 i.n_district ///
					if gr_intensive_index == 0, vce(cluster idx)
outreg2 using E1_ols_`i'_2.tex, drop(i.n_district) stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex append label ///
		addtext(District dummies, Yes) 		
		
	
	* by sale info
reg ``i'' HHR4 ID10 bHHR16 bMEM4 travel_time index_emp nfloors dirt_floor married  ///
					 MAN3 no_services REV4   MAN4 i.n_district ///
					if gr_pct_COM3 == 1, vce(cluster idx)
outreg2 using E1_ols_`i'_2.tex, drop(i.n_district) stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex append label ///
		addtext(District dummies, Yes) 

reg ``i'' HHR4 ID10 bHHR16 bMEM4 travel_time index_emp nfloors dirt_floor married  ///
					 MAN3 no_services REV4   MAN4 i.n_district ///
					if gr_pct_COM3 == 0, vce(cluster idx)
outreg2 using E1_ols_`i'_2.tex, drop(i.n_district) stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex append label ///
		addtext(District dummies, Yes) 
		
	* by nonsale info
reg ``i'' HHR4 ID10 bHHR16 bMEM4 travel_time index_emp nfloors dirt_floor married  ///
					 MAN3 no_services REV4   MAN4 i.n_district ///
					if gr_pct_COM8 == 1, vce(cluster idx)
outreg2 using E1_ols_`i'_2.tex, drop(i.n_district) stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex append label ///
		addtext(District dummies, Yes) 

reg ``i'' HHR4 ID10 bHHR16 bMEM4 travel_time index_emp nfloors dirt_floor married ///
					 MAN3 no_services REV4   MAN4 i.n_district ///
					if gr_pct_COM8 == 0, vce(cluster idx)
outreg2 using E1_ols_`i'_2.tex, drop(i.n_district) stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex append label ///
		addtext(District dummies, Yes) 		
		
	* by loan pct
reg ``i'' HHR4 ID10 bHHR16 bMEM4 travel_time index_emp nfloors dirt_floor married  ///
					 MAN3 no_services REV4   MAN4 i.n_district ///
					if gr_pct_loan == 1, vce(cluster idx)
outreg2 using E1_ols_`i'_2.tex, drop(i.n_district) stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex append label ///
		addtext(District dummies, Yes) 

reg ``i'' HHR4 ID10 bHHR16 bMEM4 travel_time index_emp nfloors dirt_floor married  ///
					 MAN3 no_services REV4   MAN4 i.n_district ///
					if gr_pct_loan == 0, vce(cluster idx)
outreg2 using E1_ols_`i'_2.tex, drop(i.n_district) stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex append label ///
		addtext(District dummies, Yes) 				
		
	* by voting
reg ``i'' HHR4 ID10 bHHR16 bMEM4 travel_time index_emp nfloors dirt_floor married  ///
					 MAN3 no_services REV4   MAN4 i.n_district ///
					if gr_pct_MEM14 == 1, vce(cluster idx)
outreg2 using E1_ols_`i'_2.tex, drop(i.n_district) stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex append label ///
		addtext(District dummies, Yes) 

reg ``i'' HHR4 ID10 bHHR16 bMEM4 travel_time index_emp nfloors dirt_floor married  ///
					 MAN3 no_services REV4   MAN4 i.n_district ///
					if gr_pct_MEM14 == 0, vce(cluster idx)
outreg2 using E1_ols_`i'_2.tex, drop(i.n_district) stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex append label ///
		addtext(District dummies, Yes) 					

	}
}
