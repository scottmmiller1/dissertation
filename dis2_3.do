
gl d0 = "/Users/scottmiller/Dropbox (UFL)/Dissertation/Analysis/Data"

ssc install "geodist", replace


** CO level dataset
********************************************* 
clear
use "$d0/CO_Final.dta"


** HH level dataset
********************************************* 
clear
use "$d0/HH_Final.dta"


* drop non goat-sellers
drop if LS8_w == 0

* generate side-selling variable
gen side_sell = outsidegoatno > 0
replace rev_co_opgoat_w = . if co_opgoatno_w == 0 

* district FE
encode district, gen(n_district)



* calculate geographic distance with GPS coordinates
* -------------------------------	
geodist GPS_latitude GPS_longitude CO_GPS_latitude CO_GPS_longitude, generate(geo_dist_mi) miles

* summary stats of distance variable
sum geo_dist_mi, d
/*
	75th% and below seems reasonable, <= 2 miles from co-op. 
	90th% and above are problematic (38-141 miles). I'm not sure what a reasonable
	cutoff is, but 140 miles can't be right. 
*/

* altitude
* -------------------------------	
sum CO_GPS_altitude, d
sum GPS_altitude, d
sum dist_alt, d
/*
	Both Co-op and HH altitude have a few negative values, as well as some very
	high values (the high values could be reasonable, I don't know what negative 
	means.
*/



** instrument relevance
* -------------------------------	

** intrument : distance
* side-sell ~ distance (clustered SE)
reg side_sell geo_dist_mi, vce(cluster idx)	
	* significant at 10%-level (+)
	* F-stat: 3.02		
	
** intrument : HH altitude
* side-sell ~ altitude difference (clustered SE)
reg side_sell GPS_altitude, vce(cluster idx)	
	* insignificant
	* F-stat: 0.05	

** intrument : distance and HH altitude
* side-sell ~ altitude difference (clustered SE)
reg side_sell geo_dist_mi GPS_altitude, vce(cluster idx)	
	* distance: significant at 10%-level (+)
	* altitude: insignificant
	* F-stat: 1.67		
	
** intrument : distanceX(HH altitude)							** strongest instrument
* side-sell ~ altitude difference (clustered SE)
reg side_sell c.geo_dist_mi#c.GPS_altitude, vce(cluster idx)	
	* significant at 1%-level (+)
	* F-stat: 7.85		
	
** intrument : distance, HH alt., interaction
* side-sell ~ altitude difference (clustered SE)
reg side_sell c.geo_dist_mi##c.GPS_altitude, vce(cluster idx)	
	* all insignificant
	* F-stat: 2.56			


/* 
Distance has a positive relationship with side-selling. Altitude alone does not 
appear to have any effect on side-selling. Interaction between distance and side-selling
is clearly the strongest IV. 
*/


* Exclusion
* -------------------------------	
* # of goats sold ~ instrument 
reg LS8_w c.geo_dist_mi#c.GPS_altitude, vce(cluster idx)					// Full sample
	* insignificant
reg LS8_w c.geo_dist_mi#c.GPS_altitude if CO_SER15 == 1, vce(cluster idx)	// Co-op sells goats
	* insignificant
reg LS8_w c.geo_dist_mi#c.GPS_altitude if CO_SER15 == 0, vce(cluster idx)	// Co-op does not sell goats
	* insignificant
	
* goat revenue ~ instrument 								
reg LS9_w c.geo_dist_mi#c.GPS_altitude, vce(cluster idx)					// Full sample
	* insignificant
reg LS9_w c.geo_dist_mi#c.GPS_altitude if CO_SER15 == 1, vce(cluster idx)	// Co-op sells goats
	* insignificant
reg LS9_w c.geo_dist_mi#c.GPS_altitude if CO_SER15 == 0, vce(cluster idx)	// Co-op does not sell goats
	* insignificant

* revenue per goat sold	~ instrument 	
reg rev_goat_w c.geo_dist_mi#c.GPS_altitude, vce(cluster idx)					// Full sample
	* insignificant
reg rev_goat_w c.geo_dist_mi#c.GPS_altitude if CO_SER15 == 1, vce(cluster idx)	// Co-op sells goats
	* insignificant
reg rev_goat_w c.geo_dist_mi#c.GPS_altitude if CO_SER15 == 0, vce(cluster idx)	// Co-op does not sell goats
	* significant at 0%-level (-)					*** Could be problematic


	
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



* without goat type controls
* -------------

** Revenue per goat - OLS vs. 2sls
reg rev_goat_w side_sell $covariates i.n_district, vce(cluster idx)
	* significant at 0%-level (-)
ivregress 2sls rev_goat_w $covariates i.n_district (side_sell = c.geo_dist_mi#c.GPS_altitude), vce(cluster idx)
	* insignificant

** Goats sold - OLS vs. 2sls
reg LS8_w side_sell $covariates i.n_district, vce(cluster idx)
	* insignificant
ivregress 2sls LS8_w $covariates i.n_district (side_sell = c.geo_dist_mi#c.GPS_altitude), vce(cluster idx)
	* insignificant
	
** Goat revenue - OLS vs. 2sls
reg LS9_w side_sell LS8_w $covariates i.n_district, vce(cluster idx)
	* significant at 1%-level (-)
ivregress 2sls LS9_w LS8_w $covariates i.n_district (side_sell = c.geo_dist_mi#c.GPS_altitude), vce(cluster idx)
	* insignificant		


* with goat type controls
* -------------

** Revenue per goat - OLS vs. 2sls
reg rev_goat_w side_sell $covariates $goat_type i.n_district, vce(cluster idx)
	* significant at 1%-level (-)
ivregress 2sls rev_goat_w $covariates $goat_type i.n_district (side_sell = c.geo_dist_mi#c.GPS_altitude), vce(cluster idx)
	* insignificant

** Goats sold - OLS vs. 2sls
reg LS8_w side_sell $covariates $goat_type i.n_district, vce(cluster idx)
	* insignificant
ivregress 2sls LS8_w $covariates $goat_type i.n_district (side_sell = c.geo_dist_mi#c.GPS_altitude), vce(cluster idx)
	* insignificant
	
** Goat revenue - OLS vs. 2sls
reg LS9_w side_sell LS8_w $covariates $goat_type i.n_district, vce(cluster idx)
	* significant at ~5%-level (-)
ivregress 2sls LS9_w LS8_w $covariates $goat_type i.n_district (side_sell = c.geo_dist_mi#c.GPS_altitude), vce(cluster idx) first
	* insignificant	
	

/*
	In almost every case, initial OLS shows that side-selling decreases revenue
	and goats sold. 
	
	2SLS with distanceXaltitude as the instrument shows that side-selling has no 
	significant effect on these outcomes. 
	
	Its not a strong instrument, and this is just a first crack at the covariate list, 
	but this overall story doesn't surprise me. Selling through the co-op appears
	beneficial at first glance, but isn't significantly better once selection is 
	accounted for. If this turns out to be the general conclusion after a more rigorous
	attempt, heterogeneity should be interesting to look at.
*/	
