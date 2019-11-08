
/*******************************************************************************
dis1_3.d0		
					
- Oaxaca Decomposition Analysis						
	
*******************************************************************************/

ssc install oaxaca


** HH level dataset
********************************************* 
use "$d3/HH_Final.dta"

replace co_opsalevalue = 0 if co_opsalevalue ==.

sort idx
by idx: egen co_rev_mean = mean(co_opsalevalue)


gen low = 0 

sum co_rev_mean, d

replace low = 1 if co_rev_mean <= `r(p50)'




* --------------
* Oaxaca command

oaxaca co_opsalevalue LS9_w, by(low)


* --------------
* Oaxaca - by hand

* high
reg co_opsalevalue LS9_w if low == 0

scalar b1_h = _b[LS9_w]

sum co_opsalevalue if low == 0

scalar Ybar_h = `r(mean)'

sum LS9_w if low == 0

scalar Xbar_h = `r(mean)'


* low
reg co_opsalevalue LS9_w if low == 1

scalar b1_l = _b[LS9_w]

sum co_opsalevalue if low == 1

scalar Ybar_l = `r(mean)'

sum LS9_w if low == 1

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

