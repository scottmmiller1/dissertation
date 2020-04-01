
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
replace co_opsalevalue = . if co_opgoatno_w == 0

* number of co-op goats sold
replace co_opgoatno_w = . if co_opgoatno_w ==0

* price per co-op goat sold
cap drop co_opsaleprice
gen co_opsaleprice = co_opsalevalue / co_opgoatno_w


* ----------------------------------------------------
** Gap analysis

* household level

** full gap
* outcome: revenue from co-op goats
* membership fee
ttest co_opsalevalue, by(gr_avg_MAN2)	// not significant -- ~ equal performance	
* low goats
ttest co_opsalevalue, by(gr_pct_low_goats)	// ** significant -- most inclusive - lower performance	
* cv goats
ttest co_opsalevalue, by(gr_cv_goats)	// not significant -- ~ equal performance
* voting
ttest co_opsalevalue, by(gr_pct_MEM14)	// not significant -- ~ equal performance
* literacy
ttest co_opsalevalue, by(gr_pct_HHR14)	// not significant -- ~ equal performance

** full gap
* outcome: number of goats sold
* membership fee
ttest co_opgoatno_w, by(gr_avg_MAN2)	// not significant -- ~ equal performance 
* loan
ttest co_opgoatno_w, by(gr_pct_loan)	// significant -- most inclusive - higher performance		 	
* low goats
ttest co_opgoatno_w, by(gr_pct_low_goats)	// ** significant -- most inclusive - lower performance	
* cv goats
ttest co_opgoatno_w, by(gr_cv_goats)	// not significant -- ~ equal performance
* voting
ttest co_opgoatno_w, by(gr_pct_MEM14)	// not significant -- ~ equal performance
* literacy
ttest co_opgoatno_w, by(gr_pct_HHR14)	// not significant -- ~ equal performance

** full gap
* outcome: price per co-op goat sold
* membership fee
ttest co_opsaleprice, by(gr_avg_MAN2)	// not significant -- ~ equal performance 
* loan
ttest co_opsaleprice, by(gr_pct_loan)	// not significant -- most inclusive - lower performance		 
* low goats
ttest co_opsaleprice, by(gr_pct_low_goats)	// not significant -- most inclusive - lower performance	
* cv goats
ttest co_opsaleprice, by(gr_cv_goats)	// not significant -- ~ equal performance
* voting
ttest co_opsaleprice, by(gr_pct_MEM14)	// significant -- most inclusive - higher performance	
* literacy
ttest co_opsaleprice, by(gr_pct_HHR14)	// not significant -- ~ equal performance


* ----------------------------------------------------
** OLS regressions	  
		 
* total revenue per member
reg co_opgoatno_w HHR14 HHR4 ID10 goats_owned mem_length travel_time MAN2 MAN4 MAN10 no_services, vce(cluster idx)


* --------------
* Oaxaca command

* revenue from co-op goats low goats
oaxaca co_opsalevalue HHR14 HHR4 ID10 goats_owned mem_length travel_time MAN2 MAN4 MAN10, by(gr_pct_low_goats) vce(cluster idx)

oaxaca co_opgoatno_w HHR14 HHR4 ID10 goats_owned mem_length travel_time MAN2 MAN4 MAN10, by(gr_pct_low_goats) vce(cluster idx)


** cooperative level
********************************************* 

collapse (firstnm) totrev_member totcost_mem REC2 REV4 MAN3 MAN2 MAN4 MAN10 REC1 ///
		 goatssold_mem goatrev_mem no_services ///
		 gr_pct_COM3 gr_pct_COM8 gr_avg_MAN2 gr_pct_loan gr_pct_SER19 gr_pct_low_goats gr_pct_MEM14 gr_cv_goats gr_pct_HHR14  ///
		 (mean) HHR14 HHR4 ID10 goats_owned mem_length travel_time, by(idx)

*replace goatrev_mem = goatrev_mem*(0.0099)	 



* ----------------------------------------------------
** Gap analysis
		 
* outcome: revenue
* membership fee
ttest totrev_member, by(gr_avg_MAN2)	// not significant -- most inclusive - higher performance
* loan
ttest totrev_member, by(gr_pct_loan)	// significant -- most inclusive - higher performance		 
* low goats
ttest totrev_member, by(gr_pct_low_goats)	// not significant -- most inclusive - lower performance					 
* cv goats
ttest totrev_member, by(gr_cv_goats)	// ** significant -- most inclusive - lower performance	
* voting
ttest totrev_member, by(gr_pct_MEM14)	// not significant -- most inclusive - lower performance		
* literacy
ttest totrev_member, by(gr_pct_HHR14)	// not significant -- most inclusive - lower performance	 

		 
** full gap
* outcome: goats sold per member 
* membership fee
ttest goatssold_mem, by(gr_avg_MAN2)	// not significant -- most inclusive - higher performance
* loan
ttest goatssold_mem, by(gr_pct_loan)	// not significant -- most inclusive - lower performance		 
* low goats
ttest goatssold_mem, by(gr_pct_low_goats)	// not significant -- most inclusive - higher performance	
* cv goats
ttest goatssold_mem, by(gr_cv_goats)	// not significant -- most inclusive - lower performance	
* voting
ttest goatssold_mem, by(gr_pct_MEM14)	// not significant -- most inclusive - higher performance				 
* literacy
ttest goatssold_mem, by(gr_pct_HHR14)	// not significant -- most inclusive - lower performance
			 

** full gap
* outcome: goat revenue per member
* membership fee
ttest goatrev_mem, by(gr_avg_MAN2)	// not significant -- most inclusive - lower performance
* loan
ttest goatrev_mem, by(gr_pct_loan)	// not significant -- most inclusive - lower performance		 
* low goats
ttest goatrev_mem, by(gr_pct_low_goats)	// not significant -- most inclusive - lower performance
* cv goats
ttest goatrev_mem, by(gr_cv_goats)	// not significant -- most inclusive - lower performance	
* voting
ttest goatrev_mem, by(gr_pct_MEM14)	// not significant -- most inclusive - higher performance	
* literacy
ttest goatrev_mem, by(gr_pct_HHR14)	// not significant -- most inclusive - higher performance	
		 
		 
		 
* ----------------------------------------------------
** OLS regressions	 
		 
* total revenue per member
reg totrev_member HHR14 HHR4 ID10 goats_owned mem_length travel_time MAN2 MAN4 MAN10 no_services


* --------------
* Oaxaca command

oaxaca totrev_member HHR14 HHR4 ID10 goats_owned mem_length travel_time MAN2 MAN4 MAN10, by(gr_cv_goats)


