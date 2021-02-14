
* Side-selling appendix - keep only festival season goat-sellers

* generate share selling through co-op in each month
* load full dataset
use "/Users/scottmiller/Dropbox (UFL)/LSIL 2/Work Spaces/Scott/Side-Selling/Data/sales_final.dta", clear

keep ___parent_index idx HH_IDSHG LS2 LS3 LS8 LS9 price

* give non-sellers zero values
replace LS8 = 0 if LS8 ==.
replace LS3 = 0 if LS3 ==.
replace LS9 = 0 if LS9 ==.
replace price = 0 if price ==.

* make co-op sale binary
replace LS3 = 0 if LS3 == 2


* assign months during festival season
gen month = 1 if LS2 == 5
replace month = 2 if LS2 == 6
replace month = 3 if LS2 == 7
replace month = 4 if LS2 == 8
*replace month = 1 if LS2 ==.
drop if month ==.

	/*
	* give sellers outside of festival season zero values during festival season
	replace LS8 = 0 if month ==.
	replace LS9 = 0 if month ==.
	replace LS3 = 0 if month ==.
	replace price = 0 if month ==.
	*replace month = 1 if month ==.
	*/
	
drop LS2

* collapse to HH level
collapse (mean) LS3 (sum) LS8 LS9 price (firstnm) idx HH_IDSHG, by(___parent_index month)

foreach v of varlist LS3 LS8 LS9 price {
	rename `v' `v'_
}

* reshape to wide format
reshape wide LS3 LS8 LS9 price, i(___parent_index) j(month)

foreach v of varlist LS3_* LS8_* LS9_* price_* {
	replace `v' = 0 if `v' ==.
}
foreach v of varlist LS3_* {
	replace `v' = 1 if `v' > 0
}

* create share selling through co-op variable
sort idx HH_IDSHG

forv i = 1/4 {
	by idx: egen share_co_`i' = mean(LS3_`i')
	by idx HH_IDSHG: egen share_shg_`i' = mean(LS3_`i')	
}

* reshape back to long format after creating share through co-op var
reshape long LS3_ LS8_ LS9_ price_ share_co_ share_shg_, i(___parent_index) j(month)

sort idx HH_IDSHG ___parent_index month

sort idx

rename LS3_ LS3
rename LS8_ LS8
rename LS9_ LS9
rename price_ price
rename share_co_ share_co
rename share_shg_ share_shg



encode ___parent_index, gen(___parent_index_n)
encode idx, gen(idx_n)
encode HH_IDSHG, gen(shg_n)


save "$d3/share_monthly.dta", replace


use "$d3/HH_Final.dta"

drop LS3 LS8 LS9
rename ___index ___parent_index
drop _merge

merge 1:m ___parent_index using "$d3/share_monthly.dta"

save "$d3/share_monthly_final.dta", replace


