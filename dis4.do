
/*******************************************************************************
dis3.d0		
					
- Creates indicator variables & ICW Summary Indices from
	r_CO_Merged_PAP.dta (co-op level dataset)
	and r_HH_Merged_PAP.dta (HH level dataset)
	Saves new datasets respectively as: 
	r_CO_Merged_Ind.dta
	r_HH_Merged_Ind.dta
	
*******************************************************************************/


clear
set more off, perm


cd "$d3" 

** co-op dataset **
clear
use "CO_Merged.dta"



** Communication **

* factors that limit communication
/* Variables
Mobile Network : COMM8b
Distance : COMM8d
*/


* transparency
/* Variables
Mandate : CO_TRN1
Annual Report : CO_TRN2
Annual Budget : CO_TRN3
Financial Report: CO_TRN4
Meeting minutes : CO_TRN5
Election Results : CO_TRN6
Sale Records : CO_TRN7
*/


** Planning and Goals **

/* Variables 

Time Horizon : PNG2
Expected Goats Sold : PNG3
Expected Rev. : PNG4
*/

replace PNG2 =. if PNG2 == 99

* replace missing values with median
* ----------------------------------
forvalues i=2/4 {
	quietly sum PNG`i', d
	replace PNG`i' = `r(p50)' if PNG`i' ==. 
}
* ----------------------------------

* convert to USD
gen expected_rev = PNG4*(0.0099)


** Winsorize PNG3
* -----------------------------------------------
gen PNG3_w = PNG3

* treatment
sum PNG3_w, d
scalar t_99 = r(p99)

replace PNG3_w = t_99 if PNG3_w > t_99 & !missing(PNG3_w)

sum PNG3_w, d
scalar t_1= r(p1)

replace PNG3_w = t_1 if PNG3_w < t_1 & !missing(PNG3_w)
* -----------------------------------------------


** Winsorize expected_rev
* -----------------------------------------------
gen expected_rev_w = expected_rev

* treatment
sum expected_rev_w, d
scalar t_99 = r(p99)

replace expected_rev_w = t_99 if expected_rev_w > t_99 & !missing(expected_rev_w)

sum expected_rev_w, d
scalar t_1= r(p1)

replace expected_rev_w = t_1 if expected_rev_w < t_1 & !missing(expected_rev_w)
* -----------------------------------------------



** Cooperative Characteristics **

/* Variables 
Members : MAN3
Revenue from all activities : REV4
# of computers owned : EQP1_2
# of phones owned : EQP2_2
# of printers owned : EQP2_2X
# of weighing scales owned : EQP4_2
# of trucks or vans : EQP5_2
# of covered collection centers : EQP6_2
*/

gen goats_sold = REC1

* Convert to USD as of 1/1/18

gen revenue = REV4*(0.0099)
gen costs = REC7*(0.0099)
gen assets = FAL1*(0.0099)
gen liabilities = FAL2*(0.0099)
gen goatrev = REC4_1*(0.0099)

gen net_rev = revenue - costs
gen net_finances = (revenue - costs) + (assets - liabilities)

* per member
gen rev_member = revenue / MAN3
gen cost_member =  costs / MAN3
gen assets_member = assets / MAN3
gen liab_member = liabilities / MAN3
gen net_rev_member = net_rev / MAN3
gen net_finances_member = net_finances / MAN3
gen goatrev_member = goatrev / MAN3

** Replace Missing values with zero 
foreach v of varlist EQP1_2 EQP2_2 EQP2_2X EQP4_2 EQP5_2 EQP6_2 {
	replace `v' = 0 if `v' ==.
}
replace goats_sold = 0 if goats_sold ==.
replace revenue = 0 if revenue ==.

replace rev_member = 0 if rev_member ==.
replace costs = 0 if costs ==.
replace cost_mem = 0 if cost_mem ==.		


* ICT and non-ICT assets
gen ICTassets = EQP1_2 + EQP2_2
gen Otherassets = EQP2_2X + EQP4_2 + EQP5_2 + EQP6_2



save "$d3/CO_Merged_Ind.dta", replace



****************
** HH dataset **
clear
use "$d3/HH_Merged.dta"

* Weights = 1 & control group
generate wgt = 1
generate stdgroup = treat

** Communication **

/* Variables 
Total times contacted about livestock sales : COM3
*/

replace COM3 = 0 if COM3 ==.
gen bCOM3 = 1 if COM3 > 0
replace bCOM3 = 0 if bCOM3 ==.


* transparency
/* Variables
Mandate : HH_TRN1
Annual Report : HH_TRN2
Annual Budget : HH_TRN3
Financial Report: HH_TRN4 
Meeting minutes : HH_TRN5
Election Results : HH_TRN6
Sale Records : HH_TRN7
Evaluations : HH_TRN8
*/

** Transparency Discrepancy index
	forvalues i=1/7 { 
		gen dTRN`i' = 1 if CO_TRN`i' == HH_TRN`i' ///
			&  !missing(CO_TRN`i') & !missing(HH_TRN`i')
		replace dTRN`i' = 0 if CO_TRN`i' != HH_TRN`i' ///
			&  !missing(CO_TRN`i') & !missing(HH_TRN`i')
		}
		
local local_dTRN dTRN1 dTRN2 dTRN3 dTRN4 dTRN5 dTRN6 dTRN7
make_index_gr dTRN wgt stdgroup `local_dTRN' 




** Goat Sales ** 

/* Variables 
goats sold through co-op : co_opgoatno
# of goats sold : LS8
*/


** Replace Missing values with zero
* ----------------------------------------------- 
replace LS8 = 0 if LS8 ==.
replace co_opgoatno = 0 if co_opgoatno ==.
replace outsidegoatno = 0 if outsidegoatno ==.
* -----------------------------------------------


** Winsorize LS8
* -----------------------------------------------
gen LS8_w = LS8

sum LS8_w, d
scalar t_99 = r(p99)

replace LS8_w = t_99 if LS8_w > t_99 & !missing(LS8_w)

sum LS8_w, d
scalar t_1= r(p1)

replace LS8_w = t_1 if LS8_w < t_1 & !missing(LS8_w)
* -----------------------------------------------


** Winsorize LS9
* -----------------------------------------------
gen LS9_w = LS9*(0.0099)

sum LS9_w, d
scalar t_99 = r(p99)

replace LS9_w = t_99 if LS9_w > t_99 & !missing(LS9_w)

sum LS9_w, d
scalar t_1= r(p1)

replace LS9_w = t_1 if LS9_w < t_1 & !missing(LS9_w)
* -----------------------------------------------


** Winsorize co_opgoatno
* -----------------------------------------------
gen co_opgoatno_w = co_opgoatno

sum co_opgoatno_w, d
scalar t_99 = r(p99)

replace co_opgoatno_w = t_99 if co_opgoatno_w > t_99 & !missing(co_opgoatno_w)

sum co_opgoatno_w, d
scalar t_1= r(p1)

replace co_opgoatno_w = t_1 if co_opgoatno_w < t_1 & !missing(co_opgoatno_w)
* -----------------------------------------------


** Winsorize outsidegoatno
* -----------------------------------------------
gen outsidegoatno_w = outsidegoatno

sum outsidegoatno_w, d
scalar t_99 = r(p99)

replace outsidegoatno_w = t_99 if outsidegoatno_w > t_99 & !missing(outsidegoatno_w)

sum outsidegoatno_w, d
scalar t_1= r(p1)

replace outsidegoatno_w = t_1 if outsidegoatno_w < t_1 & !missing(outsidegoatno_w)
* -----------------------------------------------



** Goat Prices ** 

/* Variables 
Revenue per goat sold : LS9 / LS8
Revenue per goat sold through co-op : co_opsalevalue / co_opgoatno
*/

*drop rev_goat
gen rev_goat = LS9 / LS8 if LS8 != 0
gen rev_co_opgoat = co_opsalevalue / co_opgoatno if co_opgoatno != 0
gen rev_outsidegoat = outsidesalevalue / outsidegoatno if outsidegoatno != 0

** Replace Missing values with zero
* ----------------------------------------------- 
replace rev_goat = 0 if rev_goat ==.
replace rev_co_opgoat = 0 if rev_co_opgoat ==.
* -----------------------------------------------

* covert to USD
* ----------------------------------------------- 
replace rev_goat = rev_goat*(0.0099)
replace rev_co_opgoat = rev_co_opgoat*(0.0099)
replace rev_outsidegoat = rev_outsidegoat*(0.0099)
* ----------------------------------------------- 


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


** Winsorize rev_co_opgoat
* -----------------------------------------------
gen rev_co_opgoat_w = rev_co_opgoat

sum rev_co_opgoat_w, d
scalar t_99 = r(p99)

replace rev_co_opgoat_w = t_99 if rev_co_opgoat_w > t_99 & !missing(rev_co_opgoat_w)

sum rev_co_opgoat_w, d
scalar t_1= r(p1)

replace rev_co_opgoat_w = t_1 if rev_co_opgoat_w < t_1 & !missing(rev_co_opgoat_w)
* -----------------------------------------------


** Winsorize rev_outsidegoat
* -----------------------------------------------
gen rev_outsidegoat_w = rev_outsidegoat

sum rev_outsidegoat_w, d
scalar t_99 = r(p99)

replace rev_outsidegoat_w = t_99 if rev_outsidegoat_w > t_99 & !missing(rev_outsidegoat_w)

sum rev_outsidegoat_w, d
scalar t_1= r(p1)

replace rev_outsidegoat_w = t_1 if rev_outsidegoat_w < t_1 & !missing(rev_outsidegoat_w)


** Goat Income ** 

/* Variables 
Revenue per goat sold : rev_goat
# of goats: LS8

Amount spent purchasing goats: LSE12
Amount spent on feed/fodder : LSE15
Amount spent on vet care : LSE16
Amount spent on breeding fees : LSE17a * LSE17b
Amount spent on shelters : LSE18
Net goat income
*/



** Replace Missing values with zero
* ----------------------------------------------- 
replace LS9 = 0 if LS9 ==.
foreach v of varlist LSE12 LSE15 LSE16 LSE17a LSE17b LSE18 {
	replace `v' = 0 if `v'==.
	}
* -----------------------------------------------


* generate net income
gen goat_costs = LSE12*(0.0099) + LSE15*(0.0099) + LSE16*(0.0099) + (LSE17a*LSE17b)*(0.0099) + LSE18*(0.0099)
gen net_goat_income = LS9*(0.0099) - goat_costs


** Winsorize net goat income
* -----------------------------------------------
gen net_goat_income_w = net_goat_income

sum net_goat_income_w, d
scalar t_99 = r(p99)

replace net_goat_income_w = t_99 if net_goat_income_w > t_99 & !missing(net_goat_income_w)

sum net_goat_income_w, d
scalar t_1= r(p1)

replace net_goat_income_w = t_1 if net_goat_income_w < t_1 & !missing(net_goat_income_w)
* -----------------------------------------------



** Characteristics ** 

/* Variables 
Age : HHR4
Literacy : HHR14
Total # of SHG meetings attended in past 6 months : MEM11
Dirt floors: HSE6
More than 1 floor: HSE5
goat management index
*/

*age
sum HHR4, d
replace HHR4 = `r(p1)' if HHR4 < 20

* number of SHG meetings
replace MEM11 = 0 if MEM11 ==.

* literacy
replace HHR14 = . if HHR4 < 18

* binary dirt floor variable
gen dirt_floor = 1 if HSE6 == 1
replace dirt_floor = 0 if HSE6 != 1

* binary number of floors
gen nfloors = 1 if HSE5 > 1
replace nfloors = 0 if HSE5 <= 1

** goat management index
* management system
gen GP2_1 = 1 if GP2 == 1
replace GP2_1 = 0 if GP2 != 1
* breeds
gen GP3_b = 1 if GP3_1 == 1 | GP3_3 == 1
replace GP3_b = 0 if GP3_b ==.
* pen
gen GP5_2 = 1 if GP5 == 2
replace GP5_2 = 0 if GP5 != 2
* manure
gen GP6_1 = 1 if GP6 == 1
replace GP6_1 = 0 if GP6 != 1
* mating
gen GP8_b = 1 if GP8 == 2 | GP8 == 3 | GP8 == 4 | GP8 == 5 
replace GP8_b = 0 if GP8_b ==.
* kidding
gen GP10_b = 1 if GP10 >= 1
replace GP10_b = 0 if GP10_b ==.
* feed
gen GP12_b = 1 if GP12B == 1 | GP12C == 1 | GP12D == 1
replace GP12_b = 0 if GP12_b ==.
* concentrate
gen GP14_2 = 1 if GP14 == 2
replace GP14_2 = 0 if GP14_2 ==.
* drench
* GP19
* medication
* GP21
* CAVE 
gen GP24_b = 1 if GP24 == 1 | GP24 == 2 | GP24 == 3 | GP24 == 4
replace GP24_b = 0 if GP24_b ==. 

* Goat management index
gen index_mgt = GP2_1 + GP3_b + GP5_2 + GP6_1 + GP8_b + GP10_b + GP12_b + GP14_2 + GP19 + GP21 + GP24_b

** goat empowerment index
gen index_emp = EMP1A + EMP2A + EMP3A + EMP4A + EMP5A + EMP6A + EMP7A + EMP8A + EMP9A + EMP10A + EMP11A + EMP12A

* loan
* BR1

save "$d3/HH_Merged_Ind.dta", replace


