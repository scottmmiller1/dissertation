
/*******************************************************************************
dis1_3.d0		
					
- Oaxaca Decomposition Analysis						
	
*******************************************************************************/

*ssc install oaxaca


** HH level dataset
********************************************* 
use "$d3/HH_Final.dta", clear
cd "$d2"

* gen goat revenue per member
gen goatrev_mem = REC2 / MAN3
replace goatrev_mem = 0 if goatrev_mem ==.
replace goatrev_mem = . if CO_SER15 == 0

* revenue from co-op goats sold
replace co_opsalevalue = . if co_opgoatno ==0

* number of co-op goats sold
replace co_opgoatno_w = . if co_opgoatno_w ==0

* price per co-op goat sold
gen co_opsaleprice = co_opsalevalue / co_opgoatno_w



* ----------------------------------------------------
** Gap analysis

* household level

** full gap
* outcome: revenue from co-op goats
* sale info
ttest co_opsalevalue, by(gr_pct_COM3)	// not significant -- ~ equal performance
* non-sale info	 
ttest co_opsalevalue, by(gr_pct_COM8)	// not significant -- ~ equal performance 
* membership fee
ttest co_opsalevalue, by(gr_avg_MAN2)	// not significant -- most inclusive - higher performance
* loan
ttest co_opsalevalue, by(gr_pct_loan)	// not significant -- ~ equal performance	 
* price info
ttest co_opsalevalue, by(gr_pct_SER19)	// not significant -- ~ equal performance
* low goats
ttest co_opsalevalue, by(gr_pct_low_goats)	// ** significant -- most inclusive - lower performance	


** full gap
* outcome: number of goats sold
* sale info
ttest co_opgoatno_w, by(gr_pct_COM3)	// significant -- most inclusive - higher performance
* non-sale info	 
ttest co_opgoatno_w, by(gr_pct_COM8)	// significant -- most inclusive - higher performance	
* membership fee
ttest co_opgoatno_w, by(gr_avg_MAN2)	// not significant -- ~ equal performance 
* loan
ttest co_opgoatno_w, by(gr_pct_loan)	// significant -- most inclusive - higher performance		 
* price info
ttest co_opgoatno_w, by(gr_pct_SER19)	// significant -- most inclusive - higher performance	
* low goats
ttest co_opgoatno_w, by(gr_pct_low_goats)	// ** significant -- most inclusive - lower performance	


** full gap
* outcome: price per co-op goat sold
* sale info
ttest co_opsaleprice, by(gr_pct_COM3)	// not significant -- ~ equal performance 
* non-sale info	 
ttest co_opsaleprice, by(gr_pct_COM8)	// not significant -- ~ equal performance 
* membership fee
ttest co_opsaleprice, by(gr_avg_MAN2)	// not significant -- ~ equal performance 
* loan
ttest co_opsaleprice, by(gr_pct_loan)	// not significant -- most inclusive - lower performance		 
* price info
ttest co_opsaleprice, by(gr_pct_SER19)	// not significant -- ~ equal performance 	
* low goats
ttest co_opsaleprice, by(gr_pct_low_goats)	// not significant -- most inclusive - lower performance	


* ----------------------------------------------------
** OLS regressions	 
		 
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
lab var goatrev_mem "Annual goat revenue per member (USD)"	 
		 
encode idx, gen(idx_n)		 
		 
* total revenue per member
reg co_opgoatno_w HHR14 HHR4 ID10 goats_owned mem_length travel_time MAN2 MAN4 MAN10 no_services


* --------------
* Oaxaca command

* revenue from co-op goats low goats
oaxaca co_opsalevalue HHR14 HHR4 ID10 goats_owned mem_length travel_time MAN2 MAN4 MAN10, by(gr_pct_low_goats)

oaxaca co_opgoatno_w HHR14 HHR4 ID10 goats_owned mem_length travel_time MAN2 MAN4 MAN10, by(gr_pct_low_goats)


** cooperative level
********************************************* 

collapse (firstnm) totrev_member totcost_mem REV4 MAN3 MAN2 MAN4 MAN10 REC1 ///
		 goatssold_mem goatrev_mem no_services ///
		 gr_pct_COM3 gr_pct_COM8 gr_avg_MAN2 gr_pct_loan gr_pct_SER19 gr_pct_low_goats ///
		 (mean) HHR14 HHR4 ID10 goats_owned mem_length travel_time, by(idx)

*replace goatrev_mem = goatrev_mem*(0.0099)	 



* ----------------------------------------------------
** Gap analysis
		 
** full gap
* outcome: revenue per member
* sale info
ttest totrev_member, by(gr_pct_COM3)	// not significant -- most inclusive - higher performance
* non-sale info	 
ttest totrev_member, by(gr_pct_COM8)	// significant -- most inclusive - higher performance	 
* membership fee
ttest totrev_member, by(gr_avg_MAN2)	// not significant -- most inclusive - higher performance
* loan
ttest totrev_member, by(gr_pct_loan)	// significant -- most inclusive - higher performance		 
* price info
ttest totrev_member, by(gr_pct_SER19)	// significant -- most inclusive - higher performance
* low goats
ttest totrev_member, by(gr_pct_low_goats)	// not significant -- most inclusive - lower performance					 
		 
** full gap
* outcome: goats sold per member
* sale info
ttest goatssold_mem, by(gr_pct_COM3)	// not significant -- most inclusive - lower performance
* non-sale info	 
ttest goatssold_mem, by(gr_pct_COM8)	// not significant -- most inclusive - lower performance	 
* membership fee
ttest goatssold_mem, by(gr_avg_MAN2)	// not significant -- most inclusive - higher performance
* loan
ttest goatssold_mem, by(gr_pct_loan)	// not significant -- most inclusive - lower performance		 
* price info
ttest goatssold_mem, by(gr_pct_SER19)	// not significant -- most inclusive - lower performance
* low goats
ttest goatssold_mem, by(gr_pct_low_goats)	// not significant -- most inclusive - higher performance				 
			 

** full gap
* outcome: goat revenue per member
* sale info
ttest goatrev_mem, by(gr_pct_COM3)	// not significant -- ~ equal performance
* non-sale info	 
ttest goatrev_mem, by(gr_pct_COM8)	// not significant -- most inclusive - lower performance	 
* membership fee
ttest goatrev_mem, by(gr_avg_MAN2)	// not significant -- most inclusive - lower performance
* loan
ttest goatrev_mem, by(gr_pct_loan)	// not significant -- most inclusive - lower performance		 
* price info
ttest goatrev_mem, by(gr_pct_SER19)	// not significant -- most inclusive - lower performance	
* low goats
ttest goatrev_mem, by(gr_pct_low_goats)	// not significant -- most inclusive - lower performance		 
		 
		 
* ----------------------------------------------------
** OLS regressions	 
		 
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
lab var goatrev_mem "Annual goat revenue per member (USD)"	 
		 
encode idx, gen(idx_n)		 
		 
* total revenue per member
reg goatrev_mem HHR14 HHR4 ID10 goats_owned mem_length travel_time MAN2 MAN4 MAN10 no_services


* --------------
* Oaxaca command

oaxaca goatrev_mem HHR14 HHR4 ID10 goats_owned mem_length travel_time MAN2 MAN4 MAN10, by(gr_pct_COM8)


