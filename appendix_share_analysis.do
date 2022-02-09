

* Side-selling appendix - keep only festival season goat-sellers

use "$d3/share_monthly_final.dta", clear

*log using "/Users/scottmiller/Dropbox (UFL)/LSIL 2/Work Spaces/Scott/Side-Selling/Logs/share_analysis.smcl", replace

* panel indicator
xtset ___parent_index_n

drop if LS8 ==.

* generate binary sale indicator by month - accounts for zero price values
gen bLS8 = (LS8 > 0)

replace price =. if price ==0
replace LS8 =. if LS8 ==0

/*
replace LS8 = 0 if LS8 ==.
replace LS3 = 0 if LS3 ==.
replace LS9 = 0 if LS9 ==.
replace price = 0 if price ==.
*/



* variable labels for table

lab var price "Price (USD)"
lab var LS8 "Goats sold (count)"
lab var LS3 "Cooperative sale (0/1)"
lab var share_co "Share selling through cooperative (cont.)"
lab var bLS8 "Household sold goats (0/1)"
lab var ___parent_index_n "Households"


* Distance to Kathmandu
gen KTM_latitude = 27.700769
gen KTM_longitude = 85.300140
geodist CO_GPS_latitude CO_GPS_longitude KTM_latitude KTM_longitude, generate(ktm_dist_mi) miles

* distance from co-op
geodist GPS_latitude GPS_longitude CO_GPS_latitude CO_GPS_longitude, generate(co_dist_mi) miles
replace co_dist_mi = 50 if co_dist_mi > 50

* IHS transformations
gen price_ihs = ln(price + sqrt(price^2 + 1))
gen LS8_ihs = ln(LS8 + sqrt(LS8^2 + 1))

lab var price_ihs "Log price (USD)"
lab var LS8_ihs "Log goats sold (count)"

gen price_log = ln(price)
gen LS8_log = ln(LS8)


* Table 1
* ---------------------------------------------------------	

* sells goats - HH & Month FE
xtreg bLS8 share_co i.month, fe cluster(idx)
outreg2 using "$d2/E2_appendix_results_table", tex addtext(Household FE, Yes, Month FE, Yes) label replace
	
* price - HH & Month FE
xtreg price c.LS3##c.share_co i.month, fe cluster(idx)
outreg2 using "$d2/E2_appendix_results_table", tex addtext(Household FE, Yes, Month FE, Yes) label

	
* goats sold - HH & Month FE	
xtreg LS8 c.LS3##c.share_co i.month, fe cluster(idx)
outreg2 using "$d2/E2_appendix_results_table", tex addtext(Household FE, Yes, Month FE, Yes) label



* Table 2 - Month*Distance
* ---------------------------------------------------------	

* sells goats - HH & Month FE
xtreg bLS8 share_co i.month, fe cluster(idx)
outreg2 using "$d2/E2_appendix_results_table2", tex drop(i.month*) addtext(Household FE, Yes, Month FE, Yes, Month X Distance FE, No) label replace

* sells goats - HH, Month & Month*distnace FE 
xtreg bLS8 share_co i.month#c.ktm_dist_mi, fe cluster(idx)
outreg2 using "$d2/E2_appendix_results_table2", tex drop(i.month*) addtext(Household FE, Yes, Month FE, No, Month X Distance FE, Yes) label	

	
* price - HH & Month FE
xtreg price c.LS3##c.share_co i.month, fe cluster(idx)
outreg2 using "$d2/E2_appendix_results_table2", tex drop(i.month*) addtext(Household FE, Yes, Month FE, Yes, Month X Distance FE, No) label

* price - HH, Month & Month*distnace FE 
xtreg price c.LS3##c.share_co i.month#c.ktm_dist_mi, fe cluster(idx)
outreg2 using "$d2/E2_appendix_results_table2", tex drop(i.month*) addtext(Household FE, Yes, Month FE, No, Month X Distance FE, Yes) label

	
* goats sold - HH & Month FE	
xtreg LS8 c.LS3##c.share_co i.month, fe cluster(idx)
outreg2 using "$d2/E2_appendix_results_table2", tex drop(i.month*) addtext(Household FE, Yes, Month FE, Yes, Month X Distance FE, No) label

* goats sold - HH, Month & Month*distnace FE 
xtreg LS8 c.LS3##c.share_co i.month#c.ktm_dist_mi, fe cluster(idx)
outreg2 using "$d2/E2_appendix_results_table2", tex drop(i.month*) addtext(Household FE, Yes, Month FE, No, Month X Distance FE, Yes) label		
	
			

* Table 3 - Month*District
* ---------------------------------------------------------	
encode district, g(district_n)	

* sells goats - HH & Month FE
xtreg bLS8 share_co i.month, fe cluster(idx)
outreg2 using "$d2/E2_appendix_results_table3", tex drop(i.month* i.month#i.district_n*) addtext(Household FE, Yes, Month FE, Yes, Month X District FE, No) label replace

* sells goats - HH, Month & Month*distnace FE 
xtreg bLS8 share_co i.month#i.district_n, fe cluster(idx)
outreg2 using "$d2/E2_appendix_results_table3", tex drop(i.month* i.month#i.district_n*) addtext(Household FE, Yes, Month FE, No, Month X District FE, Yes) label	

	
* price - HH & Month FE
xtreg price c.LS3##c.share_co i.month, fe cluster(idx)
outreg2 using "$d2/E2_appendix_results_table3", tex drop(i.month* i.month#i.district_n*) addtext(Household FE, Yes, Month FE, Yes, Month X District FE, No) label

* price - HH, Month & Month*distnace FE 
xtreg price c.LS3##c.share_co i.month#i.district_n, fe cluster(idx)
outreg2 using "$d2/E2_appendix_results_table3", tex drop(i.month* i.month#i.district_n*) addtext(Household FE, Yes, Month FE, No, Month X District FE, Yes) label

	
* goats sold - HH & Month FE	
xtreg LS8 c.LS3##c.share_co i.month, fe cluster(idx)
outreg2 using "$d2/E2_appendix_results_table3", tex drop(i.month* i.month#i.district_n*) addtext(Household FE, Yes, Month FE, Yes, Month X District FE, No) label

* goats sold - HH, Month & Month*distnace FE 
xtreg LS8 c.LS3##c.share_co i.month#i.district_n, fe cluster(idx)
outreg2 using "$d2/E2_appendix_results_table3", tex drop(i.month* i.month#i.district_n*) addtext(Household FE, Yes, Month FE, No, Month X District FE, Yes) label		



* Table 4 - Month*co-op
* ---------------------------------------------------------	


* sells goats - HH & Month FE
xtreg bLS8 share_co i.month, fe cluster(idx)
outreg2 using "$d2/E2_appendix_results_table4", tex drop(i.month* i.month#i.idx_n*) addtext(Household FE, Yes, Month FE, Yes, Month X Cooperative FE, No) label replace

* sells goats - HH, Month & Month*distnace FE 
xtreg bLS8 share_co i.month#i.idx_n, fe cluster(idx)
outreg2 using "$d2/E2_appendix_results_table4", tex drop(i.month* i.month#i.idx_n*) addtext(Household FE, Yes, Month FE, No, Month X Cooperative FE, Yes) label	

	
* price - HH & Month FE
xtreg price c.LS3##c.share_co i.month, fe cluster(idx)
outreg2 using "$d2/E2_appendix_results_table4", tex drop(i.month* i.month#i.idx*) addtext(Household FE, Yes, Month FE, Yes, Month X Cooperative FE, No) label

* price - HH, Month & Month*distnace FE 
xtreg price LS3 i.month#i.idx_n, fe cluster(idx)
outreg2 using "$d2/E2_appendix_results_table4", tex drop(i.month* i.month#i.idx_n*) addtext(Household FE, Yes, Month FE, No, Month X Cooperative FE, Yes) label

	
* goats sold - HH & Month FE	
xtreg LS8 c.LS3##c.share_co i.month, fe cluster(idx)
outreg2 using "$d2/E2_appendix_results_table4", tex drop(i.month* i.month#i.idx_n*) addtext(Household FE, Yes, Month FE, Yes, Month X Cooperative FE, No) label

* goats sold - HH, Month & Month*distnace FE 
xtreg LS8 LS3 i.month#i.idx_n, fe cluster(idx)
outreg2 using "$d2/E2_appendix_results_table4", tex drop(i.month* i.month#i.idx_n*) addtext(Household FE, Yes, Month FE, No, Month X Cooperative FE, Yes) label		
		
