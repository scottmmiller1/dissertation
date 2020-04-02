
/*******************************************************************************
dis1_3.d0		
					
- Oaxaca Decomposition Analysis						
	
*******************************************************************************/

*ssc install oaxaca


** HH level dataset
********************************************* 

* gen goat revenue per member
cap drop goatrev_mem
gen goatrev_mem = REC2 / MAN3
replace goatrev_mem = 0 if goatrev_mem ==.
replace goatrev_mem = . if CO_SER15 == 0

* revenue from co-op goats sold
replace co_opsalevalue = . if LS8 == 0

* number of co-op goats sold
replace co_opgoatno_w = . if LS8 ==0

* price per co-op goat sold
cap drop co_opsaleprice
gen co_opsaleprice = co_opsalevalue / co_opgoatno_w

* co-op loan amount
forvalues i=1/10 {
	gen co_loan_`i' = BR2_`i' if BR4_`i' == "C"
	replace co_loan_`i' = 0 if co_loan_`i' ==.
}
gen co_loan_amt = co_loan_1 + co_loan_2 + co_loan_3 + co_loan_4 + co_loan_5 + co_loan_6 + co_loan_7 + co_loan_8 + co_loan_9 + co_loan_10
replace co_loan_amt =. if BR1 == 2
drop co_loan_1-co_loan_10


* goat revenue & loan amount index
do "$d1/dis0_3.do"
local local_saleloan co_opsalevalue co_loan_amt
	make_index_gr saleloan wgt stdgroup `local_saleloan' 

* ----------------------------------------------------
** Gap analysis

* household level

** full gap
* outcome: revenue from co-op goats
* sale info
ttest co_opsalevalue, by(gr_pct_COM3)	// significant -- most inclusive - higher performance
* non-sale info
ttest co_opsalevalue, by(gr_pct_COM3)	// significant -- most inclusive - higher performance
* loans
ttest co_opsalevalue, by(gr_pct_loan)	// significant -- most inclusive - higher performance
* membership fee
ttest co_opsalevalue, by(gr_avg_MAN2)	// not significant	
* low goats
ttest co_opsalevalue, by(gr_pct_low_goats)	// ** significant -- most inclusive - lower performance	
* cv goats
ttest co_opsalevalue, by(gr_cv_goats)	// not significant
* voting
ttest co_opsalevalue, by(gr_pct_MEM14)	// significant -- most inclusive - higher performance
* literacy
ttest co_opsalevalue, by(gr_pct_HHR14)	// not significant


** full gap
* outcome: number of goats sold
* sale info
ttest co_opgoatno_w, by(gr_pct_COM3)	// significant -- most inclusive - higher performance
* non-sale info
ttest co_opgoatno_w, by(gr_pct_COM3)	// significant -- most inclusive - higher performance	
* loans
ttest co_opgoatno_w, by(gr_pct_loan)	// significant -- most inclusive - higher performance
* membership fee
ttest co_opgoatno_w, by(gr_avg_MAN2)	// not significant
* low goats
ttest co_opgoatno_w, by(gr_pct_low_goats)	// ** significant -- most inclusive - lower performance	
* cv goats
ttest co_opgoatno_w, by(gr_cv_goats)	// not significant
* voting
ttest co_opgoatno_w, by(gr_pct_MEM14)	// not significant
* literacy
ttest co_opgoatno_w, by(gr_pct_HHR14)	// ** significant -- most inclusive - lower performance	


** full gap
* outcome: co-op loan amount
* sale info
ttest co_loan_amt, by(gr_pct_COM3)	// not significant
* non-sale info
ttest co_loan_amt, by(gr_pct_COM3)	// not significant
* loans
ttest co_loan_amt, by(gr_pct_loan)	// significant -- most inclusive - higher performance
* membership fee
ttest co_loan_amt, by(gr_avg_MAN2)	// not significant
* low goats
ttest co_loan_amt, by(gr_pct_low_goats)	// not significant
* cv goats
ttest co_loan_amt, by(gr_cv_goats)	// not significant
* voting
ttest co_loan_amt, by(gr_pct_MEM14)	// not significant
* literacy
ttest co_loan_amt, by(gr_pct_HHR14)	// not significant


** full gap
* outcome: co-op sale loan index
* sale info
ttest index_saleloan, by(gr_pct_COM3)	// significant -- most inclusive - higher performance		
* non-sale info
ttest index_saleloan, by(gr_pct_COM3)	// significant -- most inclusive - higher performance	
* loans
ttest index_saleloan, by(gr_pct_loan)	// significant -- most inclusive - higher performance
* membership fee
ttest index_saleloan, by(gr_avg_MAN2)	// not significant
* low goats
ttest index_saleloan, by(gr_pct_low_goats)	// ** significant -- most inclusive - lower performance	
* cv goats
ttest index_saleloan, by(gr_cv_goats)	// not significant
* voting
ttest index_saleloan, by(gr_pct_MEM14)	// not significant
* literacy
ttest index_saleloan, by(gr_pct_HHR14)	// ** significant -- most inclusive - lower performance	



* ----------------------------------------------------
** OLS regressions	  
		 
* total revenue per member
reg co_opgoatno_w HHR14 HHR4 ID10 goats_owned mem_length travel_time MAN2 MAN4 MAN10 no_services, vce(cluster idx)


* --------------
* Oaxaca command

* revenue from co-op goats low goats
oaxaca co_opgoatno_w HHR14 HHR4 ID10 goats_owned mem_length travel_time MAN2 MAN4 MAN10, by(gr_pct_low_goats) vce(cluster idx)

oaxaca co_loan_amt HHR14 HHR4 ID10 goats_owned mem_length travel_time MAN2 MAN4 MAN10, by(gr_pct_loan) vce(cluster idx)

		 
		
