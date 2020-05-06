

** Create dataset with all sales
********************************************* 
clear
use "$d0/HH_Final.dta"

drop LS1* LS2* LS3* LS4* LS6* LS7* LS8* LS9*

rename ___index ___parent_index

drop _merge

merge 1:m ___parent_index using "$d0/Livestocksales.dta"


* fix outliers and incorrect data
*browse ___parent_index LS3 LS8 LS9 if LS8 > 20 & LS8 !=.

* quantity and revenue in wrong columns
replace LS8 = 1 if LS8 == 18500 & ___parent_index == "2049"
replace LS9 = 18500 if LS9 == 1 & ___parent_index == "2049"

replace LS8 = 0 if LS8 == 9000 & ___parent_index == "2217"
replace LS9 = 9000 if LS9 == 0 & ___parent_index == "2217"

replace LS8 = 1 if LS8 == 6000 & ___parent_index == "2260"
replace LS9 = 6000 if LS9 == 1 & ___parent_index == "2260"

replace LS8 = 1 if LS8 == 2800 & ___parent_index == "2261"
replace LS9 = 2800 if LS9 == 1 & ___parent_index == "2261"

replace LS8 = 0 if LS8 == 1500 & ___parent_index == "2262"
replace LS9 = 1500 if LS9 == 0 & ___parent_index == "2262"

replace LS8 = 1 if LS8 == 5000 & ___parent_index == "64"
replace LS9 = 5000 if LS9 == 1 & ___parent_index == "64"


* quantity not reported but revenue is
	* generate average price (quantity / revenue) and replace quantity so that
	* price = average price for sample. 
gen price = LS9 / LS8
replace price = . if ___parent_index == "1054" | ___parent_index == "118B" | ___parent_index == "2035" | ///
					___parent_index == "74"
sum price
replace LS8 = LS9 / 8622.859 if ___parent_index == "1054" | ___parent_index == "118B" | ___parent_index == "2035" | ///
					___parent_index == "74"				

					
* winsorize quantity, revenue and price
sum price, d
replace price = `r(p99)' if price > `r(p99)' & price !=.
sum LS8, d
replace LS8 = `r(p99)' if LS8 > `r(p99)' & LS8 !=.
sum LS9, d
replace LS9 = `r(p99)' if LS9 > `r(p99)' & LS9 !=.
	

save "$d0/sales_final.dta", replace


* district FE
encode district, gen(n_district)


* calculate geographic distance with GPS coordinates
* -------------------------------	
geodist GPS_latitude GPS_longitude CO_GPS_latitude CO_GPS_longitude, generate(geo_dist_mi) miles


* check distance outliers
sum geo_dist_mi if LS8 !=., d
count if geo_dist_mi > 40 & LS8 !=.

gen dist_outlier = (geo_dist_mi > 40) // above 90th percentile

* distance outliers by sale type
tab LS3 dist_outlier
* distance outliers by enumerator ID
tab HH_IDEID dist_outlier


* co-op sale
gen co_sale = (LS3 == 1)
replace co_sale = . if LS8 ==.




** instrument relevance
* -------------------------------	

** intrument : distance
* co-op sale ~ distance
reg co_sale geo_dist_mi	
	* significant at 1%-level (-)
	* F-stat: 10.23		
	
** intrument : HH altitude
reg co_sale GPS_altitude
	* insignificant
	* F-stat: 0.07	

** intrument : distance and HH altitude
reg co_sale geo_dist_mi GPS_altitude
	* distance: significant at 1%-level (-)
	* altitude: insignificant
	* F-stat: 5.12		
	
** intrument : distanceX(HH altitude)	
reg co_sale c.geo_dist_mi#c.GPS_altitude
	* significant at 1%-level (-)
	* F-stat: 11.25		
	
** intrument : distance, HH alt., interaction
reg co_sale c.geo_dist_mi##c.GPS_altitude
	* interaction: significant at 5% level (-)
	* F-stat: 4.84			
	
	
	

* Exclusion
* -------------------------------	
** distance
* # of goats sold ~ instrument + month of sale
reg LS8 geo_dist_mi						// Full sample
	* insignificant
reg LS8 geo_dist_mi if CO_SER15 == 1	// Co-op sells goats
	* insignificant
reg LS8 geo_dist_mi if CO_SER15 == 0	// Co-op does not sell goats
	* insignificant
	
* goat revenue ~ instrument 								
reg LS9 geo_dist_mi 					// Full sample
	* insignificant
reg LS9 geo_dist_mi if CO_SER15 == 1	// Co-op sells goats
	* significant at 10%-level (+)
reg LS9 geo_dist_mi if CO_SER15 == 0	// Co-op does not sell goats
	* insignificant

* revenue per goat sold	~ instrument 	
reg price geo_dist_mi					// Full sample
	* significant at 1%-level (+)
reg price geo_dist_mi if CO_SER15 == 1	// Co-op sells goats
	* significant at 0%-level (+)
reg price geo_dist_mi if CO_SER15 == 0	// Co-op does not sell goats
	* insignificant	

** distanceXaltitude	
* # of goats sold ~ instrument + month of sale
reg LS8 c.geo_dist_mi#c.GPS_altitude 					// Full sample
	* insignificant
reg LS8 c.geo_dist_mi#c.GPS_altitude if CO_SER15 == 1	// Co-op sells goats
	* insignificant
reg LS8 c.geo_dist_mi#c.GPS_altitude if CO_SER15 == 0	// Co-op does not sell goats
	* insignificant
	
* goat revenue ~ instrument 								
reg LS9 c.geo_dist_mi#c.GPS_altitude					// Full sample
	* insignificant
reg LS9 c.geo_dist_mi#c.GPS_altitude if CO_SER15 == 1	// Co-op sells goats
	* insignificant
reg LS9 c.geo_dist_mi#c.GPS_altitude if CO_SER15 == 0	// Co-op does not sell goats
	* insignificant

* revenue per goat sold	~ instrument 	
reg price c.geo_dist_mi#c.GPS_altitude					// Full sample
	* insignificant
reg price c.geo_dist_mi#c.GPS_altitude if CO_SER15 == 1	// Co-op sells goats
	* insignificant
reg price c.geo_dist_mi#c.GPS_altitude if CO_SER15 == 0	// Co-op does not sell goats
	* significant at 10%-level (-)
	
	

* intital OLS & IV regressions
* -------------------------------

** control variables
* leadership role
gen bMEM4 = (MEM4 > 1 & MEM4 !=.)
replace bMEM4 = . if MEM4 ==.
* primary activitiy is agriculture
gen bHHR16 = (HHR16=="1")

** globals
* type of goat sold
gl goat_type LS10 LS12 LS14 LS16 LS25 LS26 LS28 LS30 LS32 LS32_1 LS34 LS36 

/*
	Each of these is a binary variable inidicating the type of goat that was sold. 
	(i.e. medium male meat goat, etc.). So most will be zero in any given regression, 
	but including this set of variables should control for differences in goat quality,
	size, etc.
*/

* HH characteristics	
gl covariates HHR4 HHR14 ID10 goats_owned bHHR16 mem_length bMEM4 MEM7

/*
	Covariates include: age, literacy, household size, # goats owned, household's
	primary activity is agriculture (0/1), membership length (years), member is in 
	a leadership role (0/1), # of SHG meetings attended in last 6-months.
*/


* -------------
* instrument: distance

** Goats sold - OLS vs. 2sls
reg LS8 co_sale $covariates i.LS2 i.n_district
	* significant at ~1%-level
ivregress 2sls LS8 i.LS2 $covariates i.n_district (co_sale = geo_dist_mi)
	* insignificant

** Goat revenue - OLS vs. 2sls
reg LS9 co_sale $covariates i.LS2 i.n_district
	* significant at 0%-level (+)
ivregress 2sls LS9 $covariates i.LS2 i.n_district (co_sale = geo_dist_mi)
	* insignificant
	
** Price - OLS vs. 2sls
reg price co_sale $covariates i.LS2 i.n_district
	* significant at 0%-level (+)
ivregress 2sls price $covariates i.LS2 i.n_district (co_sale = geo_dist_mi)
	* insignificant		

	
* instrument: distanceXaltitude

** Goats sold - OLS vs. 2sls
reg LS8 co_sale $covariates i.LS2 i.n_district
	* significant at ~1%-level
ivregress 2sls LS8 $covariates i.LS2 i.n_district (co_sale = c.geo_dist_mi#c.GPS_altitude)
	* insignificant

** Goat revenue - OLS vs. 2sls
reg LS9 co_sale $covariates i.LS2 i.n_district
	* significant at 0%-level (+)
ivregress 2sls LS9 $covariates i.LS2 i.n_district (co_sale = c.geo_dist_mi#c.GPS_altitude)
	* insignificant
	
** Price - OLS vs. 2sls
reg price co_sale $covariates i.LS2 i.n_district
	* significant at 0%-level (+)
ivregress 2sls price $covariates i.LS2 i.n_district (co_sale = c.geo_dist_mi#c.GPS_altitude)
	* insignificant	
	




