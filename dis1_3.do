
/*******************************************************************************
dis1_3.d0		
					
- Oaxaca Decomposition Analysis						
	
*******************************************************************************/

*ssc install oaxaca


** HH level dataset
********************************************* 
use "$d3/HH_Final.dta", clear
cd "$d2"

* ----------------------------------------------------
* predictors of participation / membership / benefits

* leadership role
tab MEM4
gen bMEM4 = (MEM4 > 1 & MEM4 !=.)
replace bMEM4 = . if MEM4 ==.

* received co-op loan
gen co_loan = (BR4 == "C")
replace co_loan =. if CO_SER2 == 0

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
margins, dydx(HHR14 ID10 HHR4 goats_owned mem_length travel_time MAN3) atmeans
outreg2 using mem_predict.tex, stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex replace label

* receive sale information
logit bCOM3 HHR14 ID10 HHR4 goats_owned mem_length travel_time MAN3
margins, dydx(HHR14 ID10 HHR4 goats_owned mem_length travel_time MAN3) atmeans
outreg2 using mem_predict.tex, stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex append label

* receive activity information
logit bCOM8 HHR14 ID10 HHR4 goats_owned mem_length travel_time MAN3 
margins, dydx(HHR14 ID10 HHR4 goats_owned mem_length travel_time MAN3) atmeans
outreg2 using mem_predict.tex, stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex append label

* Voted in co-op elections
logit MEM14 HHR14 ID10 HHR4 goats_owned mem_length travel_time MAN3
margins, dydx(HHR14 ID10 HHR4 goats_owned mem_length travel_time MAN3) atmeans
outreg2 using mem_predict.tex, stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex append label

/*
* Voted on co-op policies
logit MEM16 HHR14 ID10 HHR4 goats_owned mem_length travel_time MAN3
margins, dydx(HHR14 ID10 HHR4 goats_owned mem_length travel_time MAN3) atmeans
outreg2 using mem_predict.tex, stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex append label
*/

* received co-op loan
logit co_loan HHR14 ID10 HHR4 goats_owned mem_length travel_time MAN3
margins, dydx(HHR14 ID10 HHR4 goats_owned mem_length travel_time MAN3) atmeans
outreg2 using mem_predict.tex, stats(coef se) dec(3) alpha(0.01,0.05,0.1) tex append label



* ----------------------------------------------------
** OLS regressions

collapse (firstnm) totrev_member totcost_mem REV4 MAN3 MAN2 MAN4 MAN10 gr_pct_COM3 gr_pct_COM8  ///
		 (mean) HHR14 HHR4 ID10 goats_owned mem_length travel_time, by(idx)

* total revenue per member
reg totrev_member HHR14 HHR4 ID10 goats_owned mem_length travel_time MAN2 MAN4 MAN10




* --------------
* Oaxaca command

oaxaca totrev_member HHR14 HHR4 ID10 goats_owned mem_length travel_time MAN2 MAN4 MAN10, by(gr_pct_COM8) swap


* --------------
* Oaxaca - by hand

* high
reg co_opsalevalue goats_owned if gr_pct_COM3 == 1

scalar b1_h = _b[goats_owned]

sum co_opsalevalue if gr_pct_COM3 == 1

scalar Ybar_h = `r(mean)'

sum goats_owned if gr_pct_COM3 == 1

scalar Xbar_h = `r(mean)'


* low
reg co_opsalevalue goats_owned if gr_pct_COM3 == 0

scalar b1_l = _b[goats_owned]

sum co_opsalevalue if gr_pct_COM3 == 0

scalar Ybar_l = `r(mean)'

sum goats_owned if gr_pct_COM3 == 0

scalar Xbar_l = `r(mean)'



* components

scalar gap = Ybar_h - Ybar_l
scalar full = b1_l*[Xbar_h - Xbar_l] + Xbar_h*[b1_h - b1_l]
scalar chars = b1_l*[Xbar_h - Xbar_l]
scalar returns = Xbar_h*[b1_h - b1_l]

display gap
display full
display chars
display returns


display Ybar_h

