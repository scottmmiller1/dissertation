

** HH level dataset
********************************************* 
clear
use "$d3/HH_Final.dta"

drop if LS8 == 0

* binary side selling
gen side_sell = outsidegoatno > 0
label define sidesel 1 "outside" 0 "co-op"
label values side_sell sidesel

gen rev_goat = LS9 / LS8 if LS8 != 0
replace rev_goat = 0 if rev_goat ==.
replace rev_goat = rev_goat*(0.0099)

** Winsorize rev_goat
* -----------------------------------------------
gen rev_goat_w = rev_goat

sum rev_goat_w, d
scalar t_99 = r(p99)

replace rev_goat_w = t_99 if rev_goat_w > t_99 & !missing(rev_goat_w)

sum rev_goat_w, d
scalar t_1= r(p1)

replace rev_goat_w = t_1 if rev_goat_w < t_1 & !missing(rev_goat_w)
* -----------------------------------------------


ttest rev_goat_w, by(side_sell)

tab idx co_opgoatno_w

* MW test
* revenue
ranksum LS9_w, by(side_sell)

* price
ranksum rev_goat_w, by(side_sell)

* goats sold
ranksum LS8_w, by(side_sell)

* density - price
kdensity rev_goat_w if (side_sell==1), plot(kdensity rev_goat_w if (side_sell==0)) ///
			legend(ring(0) pos(2) ///
			label(1 "Outside") label(2 "Co-op")) ///
			ylabel(,labsize(small)) ///
			xlabel(,labsize(small)) ///
			xtitle(Price (USD)) ///
			graphregion(color(white)) ///
			title("") note("") ///
			ylabel(, angle(0)) ytitle(Density, angle(0)) ///
			plotregion(margin(zero))
	
* density - revenue
kdensity net_goat_income_w if (side_sell==1), plot(kdensity net_goat_income_w if (side_sell==0)) legend(ring(0) pos(2) ///
	label(1 "Outside") label(2 "Co-op")) xtitle(Revenue) graphregion(color(white)) title("") note("")

