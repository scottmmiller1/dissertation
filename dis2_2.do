
** HH level dataset
********************************************* 
clear
use "$d3/HH_Final.dta"

drop if LS8 == 0

* binary side selling
gen side_sell = outsidegoatno > 0
label define sidesel 1 "outside" 0 "co-op"
label values side_sell sidesel



* MGT1 - what do you see as the main objective of the co-op?
* 1 - sell goats, 2 - financial services, 3 - extension and animal health
* 4 - socializing, 5 - solidarity, 6 - other
tab MGT1
tab MGT1 if LS8 > 0


* COM4 - what was the month and year of the most recent co-op sale?
tab COM4
tab COM4 if LS8 > 0 

* COM5 - Did you participate in this sale?
tab COM5
tab COM5 if LS8 > 0

* COM6 - Why not? 
* 1 - Price too low, 2 - collection point too far, 3 - No goats ready, 
* 4 - Prefer not to sell through co-op, 5 - other
foreach i in A B C D {
	tab COM6`i'
	tab COM6`i' if LS8 > 0
}

* LS3 - was the sale through co-op?
tab LS3

* LS4 - who was the sale made to? 
* 1 - local trader, 2 - neighbors, 3 - relatives, 4 - friends, 5 - others
forv i=1/5 {
	tab LS4_`i'
}
* sold to trader
count if LS4_1 > 0 & LS4_1 !=.
	* sold to trader only
	count if LS4_1 > 0 & LS4_1 !=. & LS4_2 == 0 & LS4_3 == 0 & LS4_4 == 0 & LS4_5 == 0
	* sold to trader only & exclusive side-seller
	count if LS4_1 > 0 & LS4_1 !=. & LS4_2 == 0 & LS4_3 == 0 & LS4_4 == 0 & LS4_5 == 0 & co_opgoatno == 0
* sold to neighbors
count if LS4_2 > 0 & LS4_2 !=.
	* sold to neighbors only
	count if LS4_2 > 0 & LS4_2 !=. & LS4_1 == 0 & LS4_3 == 0 & LS4_4 == 0 & LS4_5 == 0
	* sold to neighbors only & exclusive side-seller
	count if LS4_2 > 0 & LS4_2 !=. & LS4_1 == 0 & LS4_3 == 0 & LS4_4 == 0 & LS4_5 == 0 & co_opgoatno == 0	
* sold to relatives
count if LS4_3 > 0 & LS4_3 !=.
	* sold to relatives only
	count if LS4_3 > 0 & LS4_3 !=. & LS4_1 == 0 & LS4_2 == 0 & LS4_4 == 0 & LS4_5 == 0
	* sold to relatives only & exclusive side-seller
	count if LS4_3 > 0 & LS4_3 !=. & LS4_1 == 0 & LS4_2 == 0 & LS4_4 == 0 & LS4_5 == 0 & co_opgoatno == 0
* sold to friends
count if LS4_4 > 0 & LS4_4 !=.
	* sold to friends only
	count if LS4_4 > 0 & LS4_4 !=. & LS4_1 == 0 & LS4_2 == 0 & LS4_3 == 0 & LS4_5 == 0
	* sold to friends only & exclusive side-seller
	count if LS4_4 > 0 & LS4_4 !=. & LS4_1 == 0 & LS4_2 == 0 & LS4_3 == 0 & LS4_5 == 0 & co_opgoatno == 0	
	
	

* LS5 - Had you ever sold to this buyer before?

* LS6 - Why wasn't the sale made through the co-op? 
* 1 - delayed payment with co-op, 2 - sale point is too far, 3 - other traders offer higher price
* 4- co-op did not arrange sale at this time, 5 - other
foreach i in A B C D X {
	tab LS6`i'
}

********************************************* 
** Reasons sold outside co-op **

gl hh_ss_reason LS6A LS6B LS6C LS6D
	

local listsize : list sizeof global(hh_ss_reason)
tokenize $hh_ss_reason

forv i = 1/`listsize' {
		
	quietly {
		preserve
			replace ``i'' =  1 if ``i'' > 0 & ``i'' !=.
			sum ``i''
			return list
			scalar N_``i'' = r(N) // N	
			scalar mean_``i'' = r(mean)*100
		restore	
	
	* matrix for table
		matrix mat_`i' = (N_``i'',mean_``i'')
		}
}
matrix A = mat_1
forv i = 2/`listsize' { // appends into single matrix
	matrix A = A \ mat_`i'
}

* Table
frmttable using E2_ss_reason.tex, tex statmat(A) sdec(2) coljust(l;c;l;l) title("Reasons for side-selling") ///
ctitle("","N","\% of households") ///
rtitle("Delayed payment with cooperative"\"Cooperative sale point is too far away"\"Trader offered a higher price"\ ///
		"Cooperative did not arrange a sale at this time") replace
		
* LS38 - where was the sale realized?

* LS39 - was the sale discussed with the trader prior to them visiting the home?

* LS40 - How many visits did the trader make prior to the sale?

* LS41 - How much time passed between initial contact and closing of sale?

* LS42 - How much money was spent transporting goats?

* LS43 - How much time was spent transporting goats? 

* LS44 - Ever negotiated with trader but failed to sell? 

* LS45 - Ever traveled to sales point but failed to sell? 

sum HH_GTT1, d
sum HH_GTT2, d
sum HH_GTT3, d


* Shocks : 
* HHR8 - where does X currently reside?

* HHR8 - Why did X leave the home?
* 1 - education, 2 - look for job, 3 - employment, 4 - military, 5 - marriage, 
* 6 - divorce, 7 - death of spouse, 8 - family problems, 9 - joining other HH members, 
* 10 - return to previous home, 11 - inadequate cultivable land, 12 - poor land quality, 
* 13 - Health problems, 14 - Drought, 15 - Floods, 16 - Earthquake, 17 - inadequate social protection, 
* 18 - Childs education, 19 - security/crime

gen memlength = (MEM2_1*12) + MEM2_2

bysort side_sell: sum memlength
bysort side_sell: sum MEM7

ttest memlength, by(side_sell)
ttest MEM7, by(side_sell)


geodist GPS_latitude GPS_longitude CO_GPS_latitude CO_GPS_longitude, generate(geo_dist_mi) miles

* co-ops with significant distance outliers. 
preserve
drop if idx == "Digopan SEWC 1" | idx == "Lagansil SEWC 1" | idx == "Sakriya SEWC 1" | idx == "Sundhara SEWC 1" | idx == "Upahar SEWC 1"

ttest geo_dist_mi, by(side_sell)

restore

ttest HH_GTT2, by(side_sell)

gen pre_goats_owned = goats_owned + LS8_w - LSE11_A + LSE13_A + LSE14_A	
replace pre_goats_owned = 0 if pre_goats_owned < 0 	

ttest pre_goats_owned, by(side_sell)

ttest COM3, by(side_sell)

ttest index_emp, by(side_sell)

gen bHHR16 = (HHR16=="1")
ttest bHHR16, by(side_sell)

ttest HHR4, by(side_sell)

ttest HHR14, by(side_sell)
