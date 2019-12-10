

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
			legend(ring(0) pos(2) cols(1) size(large) region(lwidth(none)) ///
			label(1 "Outside Sale") label(2 "Cooperative Sale")) ///
			ylabel(,labsize(medium)) ///
			xlabel(,labsize(medium)) ///
			xtitle(Price (USD), placement(6) margin(top) size(medlarge)) ///
			graphregion(color(white) ilcolor(white)) ///
			title("") note("") ///
			ylabel(, angle(0)) ytitle(Density, size(medlarge)) ///
			plotregion(margin(zero)) 
graph export "$d0/Figures/Essay 2/E2_PriceDensity_Annual.png", replace	


	
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

gen month = LS2
label define mnt 1 "Apr." 2 "May" 3 "Jun." 4 "Jul." 5 "Aug." 6 "Sept." 7 "Oct." 8 "Nov." 9 "Dec." 10 "Jan." 11 "Feb." 12 "Mar."
label values month mnt

graph bar (sum) outside_goats (sum) coop_goats, over(month, label(angle(horizontal) labsize(medlarge))) ///
		 legend(ring(0) pos(2) cols(1) size(large) region(lwidth(none)) ///
         label(1 "Outside Sale") label(2 "Cooperative Sale")) ///
		 graphregion(color(white) ilcolor(white)) ///
		 ytitle(Goats Sold, orientation(vertical) size(medlarge)) 
graph export "$d0/Figures/Essay 2/E2_SaleMonth.png", replace	
			

			
* total revenue through co-op		
gen co_opsalevalue = LS9 if LS3==1 			
lab var co_opsalevalue "Total revenue, goats sold through co-op"

* goats sold through co-op	
gen co_opgoatno = LS8 if LS3==1		
lab var co_opgoatno "Total goats sold through co-op"

* total revenue outside co-op		
gen outsidesalevalue = LS9 if LS3==2 			
lab var outsidesalevalue "Total revenue, goats sold outside co-op"

* goats sold outside co-op	
gen outsidegoatno = LS8 if LS3==2		
lab var outsidegoatno "Total goats sold outside co-op"

* binary festival season sale
forvalues i=1/12 {
	gen LS2_`i' = 1 if LS2 == `i' 
	replace LS2_`i' = 0 if LS2_`i' ==.
}
gen festival = 0 
replace festival = 1 if LS2_5 == 1 | LS2_6 == 1 | LS2_7 == 1 | LS2_8 == 1 | LS2_9 == 1


* binary side-selling
gen side_sell = 1 if outsidegoatno > 0
replace side_sell = 0 if outsidegoatno ==.
label define sidesel 1 "outside" 0 "co-op"
label values side_sell sidesel

* revenue per goat
gen rev_goat = LS9 / LS8 if LS8 !=0
sum rev_goat, d
replace rev_goat = `r(p99)' if rev_goat > `r(p99)'

* festival season
kdensity rev_goat if (side_sell==1 & festival ==1), plot(kdensity rev_goat if (side_sell==0 & festival ==1), bwidth(12) lwidth(thick)) ///
			bwidth(12) lwidth(thick) ///
			legend(ring(0) pos(2) cols(1) size(large) region(lwidth(none)) ///
			label(1 "Outside Sale") label(2 "Cooperative Sale")) ///
			ylabel(,labsize(medium)) ///
			xlabel(,labsize(medium)) ///
			xtitle(Price (USD), placement(6) margin(top) size(medlarge)) ///
			graphregion(color(white) ilcolor(white)) ///
			title("") note("") ///
			ylabel(, angle(0)) ytitle(Density, orientation(vertical) size(medlarge)) ///
			plotregion(margin(zero)) 	
graph export "$d0/Figures/Essay 2/E2_PriceDensity_Festival.png", replace				

* non-festival season
kdensity rev_goat if (side_sell==1 & festival ==0), plot(kdensity rev_goat if (side_sell==0 & festival ==0), bwidth(15) lwidth(thick)) ///
			bwidth(15) lwidth(thick) ///
			legend(ring(0) pos(2) cols(1) size(large) region(lwidth(none)) ///
			label(1 "Outside Sale") label(2 "Cooperative Sale")) ///
			ylabel(,labsize(medium)) ///
			xlabel(,labsize(medium)) ///
			xtitle(Price (USD), placement(6) margin(top) size(medlarge)) ///
			graphregion(color(white) ilcolor(white)) ///
			title("") note("") ///
			ylabel(, angle(0)) ytitle(Density, orientation(vertical) size(medlarge)) ///
			plotregion(margin(zero)) ylabel(0(.005).015)				
graph export "$d0/Figures/Essay 2/E2_PriceDensity_NonFest.png", replace

