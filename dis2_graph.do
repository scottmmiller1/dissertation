

** HH level dataset
********************************************* 
clear
use "$d3/HH_Final.dta"

drop if LS8 == 0

* binary side selling
gen side_sell = outsidegoatno > 0
label define sidesel 1 "outside" 0 "co-op"
label values side_sell sidesel


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
kdensity rev_goat_w if (side_sell==1), plot(kdensity rev_goat_w if (side_sell==0), bwidth(12) lwidth(thick)) ///
			bwidth(12) lwidth(thick) ///
			legend(ring(0) pos(2) cols(1) region(lwidth(none)) ///
			label(1 "Outside Sale") label(2 "Cooperative Sale")) ///
			ylabel(,labsize(small)) ///
			xlabel(,labsize(small)) ///
			xtitle(Price (USD), placement(6) margin(top)) ///
			graphregion(color(white) ilcolor(white)) ///
			title("") note("") ///
			ylabel(, angle(0)) ytitle(Density, orientation(horizontal)) ///
			plotregion(margin(zero)) 
graph export "$d0/Figures/Essay 2/E2_PriceDensity.png", replace	
	
	
/*
* density - revenue
kdensity net_goat_income_w if (side_sell==1), plot(kdensity net_goat_income_w if (side_sell==0)) legend(ring(0) pos(2) ///
	label(1 "Outside") label(2 "Co-op")) xtitle(Revenue) graphregion(color(white)) title("") note("")
*/


* ----------------------------------------------
use "$d3/Livestocksales.dta", clear

drop if LS8 ==0

sum LS8, d
replace LS8 =`r(p99)' if LS8 > `r(p99)'

replace LS9 = LS9*(0.0099)
sum LS9, d
replace LS9 =`r(p99)' if LS9 > `r(p99)'

gen coop_goats = LS8 if LS3 == 1
gen outside_goats = LS8 if LS3 == 2

xlabel(1 "04" 2 "05" 3 "06" 4 "07" 5 "08" 6 "09" 7 "10" 8 "11" 9 "12" 10 "01" 11 "02" 12 "03")

gen month = LS2
label define mnt 1 "Apr." 2 "May" 3 "Jun." 4 "Jul." 5 "Aug." 6 "Sept." 7 "Oct." 8 "Nov." 9 "Dec." 10 "Jan." 11 "Feb." 12 "Mar."
label values month mnt

graph bar (sum) outside_goats (sum) coop_goats, over(month, label(angle(horizontal))) ///
		 legend(ring(0) pos(2) cols(1) region(lwidth(none)) ///
         label(1 "Outside Sale") label(2 "Cooperative Sale")) ///
		 graphregion(color(white) ilcolor(white)) ///
		 ytitle(Goats Sold, orientation(horizontal)) 
graph export "$d0/Figures/Essay 2/E2_SaleMonth.png", replace	
			 



