

* selling decision analysis
use "/Users/scottmiller/Dropbox (UFL)/LSIL 2/Work Spaces/Scott/Side-Selling/Data/HH_final.dta", clear

*ssc install sumdist, replace

replace LS3 = 0 if LS3 == 2
replace LS3 = 0 if LS3 ==.
replace LS3 = 1 if LS3 > 0
*gen bLS8 = (LS8 > 0 & LS8 !=.)

** control variables
* leadership role
gen bMEM4 = (MEM4 > 1 & MEM4 !=.)
replace bMEM4 = . if MEM4 ==.
* primary activitiy is agriculture
gen bHHR16 = (HHR16=="1")

** co-op services aware offered
gen n_services = SER1 + SER2 + SER3 + SER4 + SER6 + SER7 + SER8 + SER9 + SER10 + SER11 + SER12 + SER13 + SER14 + SER15 + SER16 + SER17 + SER18 + SER19


* geographic distance from cooperative
geodist GPS_latitude GPS_longitude CO_GPS_latitude CO_GPS_longitude, generate(geo_dist_mi) miles

	sum geo_dist_mi, d
	* co-ops with significant distance outliers. 
	drop if idx == "Digopan SEWC 1" | idx == "Lagansil SEWC 1" | idx == "Sakriya SEWC 1" | idx == "Sundhara SEWC 1" | idx == "Upahar SEWC 1"
	sum geo_dist_mi, d

	* One remaining outlier
	replace geo_dist_mi =. if geo_dist_mi > 20


* HH characteristics	
gl covariates HHR4 HHR14 ID10 goats_owned bHHR16 mem_length bMEM4 MEM7 index_emp nfloors dirt_floor n_services 

/*
	Covariates include: age, literacy, household size, # goats owned, household's
	primary activity is agriculture (0/1), membership length (years), member is in 
	a leadership role (0/1), # of SHG meetings attended in last 6-months, empowerment index, 
	number of floors, HH has dirt floors (0/1), number of services aware that co-op offers, 
	
*/

* distance squared
gen geo_dist_mi_sq = geo_dist_mi*geo_dist_mi


* polynomial distance + covariates	
*probit LS3 c.geo_dist_mi##c.geo_dist_mi LS8_w COM3 $covariates, cluster(idx)	

probit LS3 geo_dist_mi geo_dist_mi_sq COM3 LS8_w $covariates, cluster(idx)	

	margins, dydx(geo_dist_mi geo_dist_mi_sq COM3 LS8_w $covariates) atmeans
	outreg2 using "$d2/E2_margins_table", tex label replace

probit bCOM3 geo_dist_mi geo_dist_mi_sq LS8_w $covariates, cluster(idx)		
	
	margins, dydx(geo_dist_mi geo_dist_mi_sq LS8_w $covariates) atmeans
	outreg2 using "$d2/E2_margins_table", tex label

	
* margins plots	

* distance in discrete levels
sumdist geo_dist_mi_sq, n(5)

gen dist_levels = 0
replace dist_levels = 1 if (geo_dist_mi_sq >= `r(q1)' & geo_dist_mi_sq < `r(q2)')
replace dist_levels = 2 if (geo_dist_mi_sq >= `r(q2)' & geo_dist_mi_sq < `r(q3)')
replace dist_levels = 3 if (geo_dist_mi_sq >= `r(q3)' & geo_dist_mi_sq < `r(q4)')
replace dist_levels = 4 if (geo_dist_mi_sq >= `r(q4)')
	
probit LS3 i.dist_levels LS8_w COM3 $covariates, cluster(idx)	
	
	margins, atmeans dydx(dist_levels)
	
	marginsplot, yline(0) title("") ///
			ylabel(,labsize(medium)) ///
			xlabel(1 "2nd Quintile" 2 "3rd Quintile." 3 "4th Quintile" 4 "5th Quintile.",labsize(medium) angle(45)) ///
			xtitle(Distance from the Cooperative Squared (Miles), placement(6) margin(top) size(medium)) ///
			graphregion(color(white) ilcolor(white)) ///
			title("") note("") ///
			ylabel(, angle(0)) ytitle(Marginal Effect on Probability of Cooperative Sale, orientation(vertical)  size(medium))
			graph export "$d0/Figures/Essay 2/E2_Margins_distance.png", replace	
			
			
* # of times contacted in discrete levels			
gen COM3_levels = 0 
forvalues i = 1/6 {
	replace COM3_levels = `i' if COM3 == `i'	
}
replace COM3_levels = 6 if COM3 > 6 & COM3 !=.	


probit LS3 i.COM3_levels geo_dist_mi geo_dist_mi_sq LS8_w $covariates, cluster(idx)		

		
		margins, atmeans dydx(COM3_levels)
		
		marginsplot, yline(0) title("") ///
			ylabel(,labsize(medium)) ///
			xlabel(1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6+",labsize(medium)) ///
			xtitle(Number of Times Contacted about Cooperative Sales (count), placement(6) margin(top) size(medium)) ///
			graphregion(color(white) ilcolor(white)) ///
			title("") note("") ///
			ylabel(, angle(0)) ytitle(Marginal Effect on Probability of Cooperative Sale, orientation(vertical)  size(medium))
			graph export "$d0/Figures/Essay 2/E2_Margins_contact.png", replace	


* number of cooperative services in discrete levels					
sumdist n_services, n(5)
			
gen n_services_levels = 0
replace n_services_levels = 1 if (n_services >= `r(q1)' & n_services < `r(q2)')
replace n_services_levels = 2 if (n_services >= `r(q2)' & n_services < `r(q3)')
replace n_services_levels = 3 if (n_services >= `r(q3)' & n_services < `r(q4)')
replace n_services_levels = 4 if (n_services >= `r(q4)')			


probit LS3 i.n_services_levels geo_dist_mi geo_dist_mi_sq LS8_w COM3 HHR4 HHR14 ID10 goats_owned ///
			bHHR16 bMEM4 MEM7 index_emp nfloors dirt_floor mem_length, cluster(idx)		
			
		margins, atmeans dydx(n_services_levels)	
		
		marginsplot, yline(0) title("") ///
			ylabel(,labsize(medium)) ///
			xlabel(1 "2nd Quintile" 2 "3rd Quintile." 3 "4th Quintile" 4 "5th Quintile.",labsize(medium) angle(45)) ///
			xtitle(Cooperative Services Offered (Count), placement(6) margin(top) size(medium)) ///
			graphregion(color(white) ilcolor(white)) ///
			title("") note("") ///
			ylabel(, angle(0)) ytitle(Marginal Effect on Probability of Cooperative Sale, orientation(vertical)  size(medium))
			graph export "$d0/Figures/Essay 2/E2_Margins_services.png", replace	

			
* goats sold in discrete levels					
sumdist LS8_w if LS8_w > 0, n(5)
			
gen LS8_w_levels = 0
replace LS8_w_levels = 1 if (LS8_w > 0 & LS8_w <= 1)
replace LS8_w_levels = 2 if (LS8_w > 1 & LS8_w <= 2)
replace LS8_w_levels = 3 if (LS8_w > 2 & LS8_w <= 3)
replace LS8_w_levels = 4 if (LS8_w > 3)			


probit LS3 i.n_services_levels geo_dist_mi geo_dist_mi_sq LS8_w COM3 HHR4 HHR14 ID10 goats_owned ///
			bHHR16 bMEM4 MEM7 index_emp nfloors dirt_floor mem_length, cluster(idx)		
			
		margins, atmeans dydx(n_services_levels)	
		
		marginsplot, yline(0) title("") ///
			ylabel(,labsize(medium)) ///
			xlabel(1 "1" 2 "2" 3 "3" 4 "4+",labsize(medium)) ///
			xtitle(Total Goats Sold (Count), placement(6) margin(top) size(medium)) ///
			graphregion(color(white) ilcolor(white)) ///
			title("") note("") ///
			ylabel(, angle(0)) ytitle(Marginal Effect on Probability of Cooperative Sale, orientation(vertical)  size(medium))
			graph export "$d0/Figures/Essay 2/E2_Margins_goatssold.png", replace				
			
