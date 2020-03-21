
/*******************************************************************************
dis1_3.d0		
					
- Oaxaca Decomposition Analysis						
	
*******************************************************************************/

*ssc install oaxaca


** HH level dataset
********************************************* 
use "$d3/HH_Final.dta", clear

* --------------
* OLS regression

* predictors of participation / membership / benefits

* leadership role
tab MEM4
gen bMEM4 = (MEM4 > 1 & MEM4 !=.)
replace bMEM4 = . if MEM4 ==.

logit bMEM4 goats_owned HHR14 mem_length HHR4 travel_time




* --------------
* Oaxaca command

oaxaca co_opsalevalue goats_owned, by(gr_pct_COM3) swap


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

