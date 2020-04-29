

*ssc install "geodist", replace

** CO level dataset
********************************************* 
clear
use "$d3/CO_Final.dta"


** HH level dataset
********************************************* 
clear
use "$d3/HH_Final.dta"

* calculate geographic distance with GPS coordinates
geodist GPS_latitude GPS_longitude CO_GPS_latitude CO_GPS_longitude, generate(geo_dist_mi) miles

* drop non goat-sellers
drop if LS8_w == 0

* generate side-selling variable
gen side_sell = outsidegoatno > 0
replace rev_co_opgoat_w = . if co_opgoatno_w == 0 



** relevance
* -------------------------------	
* side-sell ~ distance
reg side_sell geo_dist_mi, vce(cluster idx)	
	* significant at 10%-level (+)
* side-sell ~ distance | # goats sold
reg side_sell geo_dist_mi LS8_w, vce(cluster idx)	
	* significant at 10%-level (+)

/* 
The farther you live from the cooperative, the more likely you are to
side-sell (signicant at 10%-level). This is true even when conditioning on the
number of goats sold. 
*/


* Exclusion
* -------------------------------	
* # of goats sold
reg LS8_w geo_dist_mi, vce(cluster idx)						// Full sample
	* insignificant
reg LS8_w geo_dist_mi if CO_SER15 == 1, vce(cluster idx)	// Co-op sells goats
	* insignificant
reg LS8_w geo_dist_mi if CO_SER15 == 0, vce(cluster idx)	// Co-op does not sell goats
	* insignificant
	
* goat revenue								
reg LS9_w geo_dist_mi, vce(cluster idx)						// Full sample
	* insignificant
reg LS9_w geo_dist_mi if CO_SER15 == 1, vce(cluster idx)	// Co-op sells goats
	* insignificant
reg LS9_w geo_dist_mi if CO_SER15 == 0, vce(cluster idx)	// Co-op does not sell goats
	* significant at 10%-level (-)

* revenue per goat sold		
reg rev_goat_w geo_dist_mi, vce(cluster idx)					// Full sample
	* insignificant
reg rev_goat_w geo_dist_mi if CO_SER15 == 1, vce(cluster idx)	// Co-op sells goats
	* significant at 10%-level (+)
reg rev_goat_w geo_dist_mi if CO_SER15 == 0, vce(cluster idx)	// Co-op does not sell goats
	* significant at 5%-level (-)


	
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
* HH characteristics	
gl covariates HHR4 HHR14 ID10 goats_owned bHHR16 mem_length bMEM4 MEM7
* district FE
encode district, gen(n_district)



* without goat type controls
* -------------

** Revenue per goat - OLS vs. 2sls
reg rev_goat_w side_sell $covariates i.n_district, vce(cluster idx)
	* significant at 0%-level (-)
ivregress 2sls rev_goat_w $covariates i.n_district (side_sell = geo_dist_mi), vce(cluster idx)
	* insignificant

** Goats sold - OLS vs. 2sls
reg LS8_w side_sell $covariates i.n_district, vce(cluster idx)
	* insignificant
ivregress 2sls LS8_w $covariates i.n_district (side_sell = geo_dist_mi), vce(cluster idx)
	* insignificant
	
** Goat revenue - OLS vs. 2sls
reg LS9_w side_sell LS8_w $covariates i.n_district, vce(cluster idx)
	* significant at 1%-level (-)
ivregress 2sls LS9_w LS8_w $covariates i.n_district (side_sell = geo_dist_mi), vce(cluster idx)
	* insignificant		


* with goat type controls
* -------------

** Revenue per goat - OLS vs. 2sls
reg rev_goat_w side_sell $covariates $goat_type i.n_district, vce(cluster idx)
	* significant at 1%-level (-)
ivregress 2sls rev_goat_w $covariates $goat_type i.n_district (side_sell = geo_dist_mi), vce(cluster idx)
	* insignificant

** Goats sold - OLS vs. 2sls
reg LS8_w side_sell $covariates $goat_type i.n_district, vce(cluster idx)
	* insignificant
ivregress 2sls LS8_w $covariates $goat_type i.n_district (side_sell = geo_dist_mi), vce(cluster idx)
	* insignificant
	
** Goat revenue - OLS vs. 2sls
reg LS9_w side_sell LS8_w $covariates $goat_type i.n_district, vce(cluster idx)
	* significant at ~5%-level (-)
ivregress 2sls LS9_w LS8_w $covariates $goat_type i.n_district (side_sell = geo_dist_mi), vce(cluster idx) first
	* insignificant	
	

