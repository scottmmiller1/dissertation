
/*******************************************************************************
dis0_2.d0		
					
- Clean datasets 											
- Create single HH dataset that contains all separete HH modules						
	
*******************************************************************************/


clear all
set more off, perm



/**************************************************

HH dataset has several separated modules. 
Merge separate HH modules into single dataset 

**************************************************/


** Load Livestock Sales Module
clear
use "$d3/Livestocksales.dta"


* drop data collection notes & time stamps 
drop LS2 LS6 LS6_1 ___id ___uuid ___submission_time ///
		___parent_table_name ___tags ___notes LS4 
		
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

* Change blank cells in string vars to missing values
ds, has(type string) 
quietly foreach v in `r(varlist)' { 
	replace `v' = trim(`v')
	replace `v' ="" if `v' == "."
	}

* destring all variables in module
destring *, replace
ds *, has(type numeric)
local numeric = "`r(varlist)'"		
recode `numeric' (99=.) (98=.) (97=.)

* make 1-2 variables binary
foreach v of varlist LS3 ///
		LS39 LS44 ///
		LS45 {
	quietly replace `v'=. if `v'==99
	quietly replace `v'=. if `v'==97
	quietly replace `v'=0 if `v'==2
}

* generate variable for # of sales
bysort ___parent_index: egen LS_n_sales=count(___parent_index)


** Collapse to 1-row per HH

** save labels and value labels in macros 
quietly {
foreach v of var * {
	cap local vv = subinstr("`v'", "Livestock_Sales", "Livestock_Sales",.) // names too long for macros
	if _rc == 0 {
		rename `v' `vv'
		local v `vv'
	}
	local l`v' : variable label `v'
	local ll`v': val lab `v'
	if `"`l`v''"' == "" {
		local l`v' "`v'"
	}
}
}

* collapse
collapse (firstnm) LS_n_sales (mean) LS3 *LS6* LS7 (sum) LS8 LS9 LS10 LS12 LS13 LS14 LS15 LS16 ///
		LS17 LS25 LS26 LS27 LS28 LS29 LS30 LS31 *LS32* LS33 LS34 LS35 LS36 LS37 ///
		LS38 LS39 LS40 LS41 LS42 *LS43* LS44 LS45 LS46 ///
		LS47 co_opsalevalue co_opgoatno outsidesalevalue outsidegoatno , by(___parent_index)

** re-assign labels post-collapse
quietly {
foreach v of var * {
	label var `v' "`l`v''"
	cap label val `v' "`ll`v''"
}
}		



save "$d3/Livestocksales_collapse.dta", replace

* ------------------------------------------------------------------------

** Merge separate modules into Household

* Load household dataset
clear
use"$d3/Household.dta"


* assign district & region names
decode ID1, gen(district)

replace district = "Arghakanchhi" if ID1== 51
replace district = "Baglung" if ID1== 45
replace district = "Banke" if ID1== 57
replace district = "Bardiya" if ID1== 58
replace district = "Chitwan" if ID1== 35
replace district = "Dang" if ID1== 56
replace district = "Dhading" if ID1== 30 
replace district = "Kaski" if ID1== 40
replace district = "Kapilbastu" if ID1== 50
replace district = "Lamjung" if ID1== 37
replace district = "Mahottari" if ID1== 18
replace district = "Morang" if ID1== 5
replace district = "Nawalparasi" if ID1== 48
replace district = "Nuwakot" if ID1== 28
replace district = "Palpa" if ID1== 47
replace district = "Parbat" if ID1== 44
replace district = "Pyuthan" if ID1== 52
replace district = "Rautahat" if ID1== 32
replace district = "Rupandehi" if ID1== 49
replace district = "Salyan" if ID1== 55
replace district = "Sarlahi" if ID1== 19
replace district = "Sindhuli" if ID1== 20
replace district = "Surkhet" if ID1== 59
replace district = "Tanahu" if ID1== 38

 
gen region = "Mid-Hills" if district=="Arghakanchhi" | district=="Baglung" | ///
	district=="Dhading" | district =="Kaski" | district =="Lamjung" | district=="Nuwakot" | ///
	district=="Palpa" | district =="Parbat" | district =="Pyuthan" | district =="Salyan" | ///
	district=="Tanahu" | district =="Sindhuli"
	 
replace region = "Terai" if district=="Banke" | district =="Bardiya" | district =="Kapilbastu" | ///
	district=="Mahottari" | district =="Morang" | district =="Nawalparasi" | ///
	district=="Rautahat" | district =="Rupandehi" | district=="Sarlahi" | district =="Surkhet" | ///
	district =="Chitwan" | district =="Dang"

	
* rename TRN vars with HH indicator (have same name as Co-op data)
foreach v of varlist TRN* GTT* {
	rename `v' HH_`v'
	}		
	
* save edited HH dataset	
save "$d3/Household_edit.dta", replace


* create single merge variable "___index" for all HH modules
* -----------------------------------------------
use "$d3/Borrowing.dta"
rename A__parent_index ___index
save "$d3/Borrowing_edit.dta", replace

use "$d3/Children.dta"
rename ___index A___index
rename ___parent_index ___index
save "$d3/Children_edit.dta", replace

use "$d3/Roster.dta"
rename ___index A___index
rename ___parent_index ___index
save "$d3/Roster_edit.dta", replace

use "$d3/Livestocksales_collapse.dta"
*rename ___index A___index
rename ___parent_index ___index
save "$d3/Livestocksales_collapse_edit.dta", replace
* -----------------------------------------------



*create merged dataset 'modules_merged'
*Livestock Sales - Borrowing
use "$d3/Household_edit.dta", clear
merge m:m ___index using "$d3/Borrowing_edit.dta", force
rename _merge merge1
save "$d3/modules_merged.dta", replace

*Number of Children
use "$d3/modules_merged.dta", clear
merge m:m ___index using "$d3/Children_edit.dta", force
rename _merge merge2
save "$d3/modules_merged.dta", replace 

*Roster
use "$d3/modules_merged.dta", clear
merge m:m ___index using "$d3/Roster_edit.dta", force
rename _merge merge3
save "$d3/modules_merged.dta", replace  

*merge modules_merged into Household
use "$d3/modules_merged.dta", clear
merge m:m ___index using "$d3/Livestocksales_collapse_edit.dta", force
save "$d3/Household_Merged.dta", replace
 

* ------------------------------------------------------------------------ 

 
** Clean Household_Merged to be collapsed to the co-op level
clear
use "$d3/Household_Merged.dta"
 
*drop unused vars vars
*section timing, notes, section headers, other (specificy), etc.
drop start end *Note* HH_IDstartHHID HH_IDendHHID end_rooster Number_children_count ///
	Land_and_homestart_land Land_and_homeLand_and_home_note Land_and_homeEnd_land ///
	Co_opstart_coop Co_opMembershipMEM10MEM10_Header ///
	Co_opServiceService_note GP2_1 ///
	Co_opGoat_transactionsGTT4_1 Co_opFollow_up_transparency_ques ///
	Savingsstart_savings SavingsSavings_Note ///
	SV2_1 Savingsend_savings Borrowingstart_borrowing Borrowingend_borrowing ///
	Food_Consumptionstart_food Food_ConsumptionGrainsGrains_N Food_ConsumptionPulsesPulses_n ///
	Food_ConsumptionMeat_fish_and_eg Food_ConsumptionDairy_productsDa Food_ConsumptionFruitsFruits_not ///
	Food_ConsumptionVegetablesVegeta Food_ConsumptionSugar_and_or_swe Food_ConsumptionOilOil_note ///
	time_food start_stockR Live_rel_emp_stockR Live_Entsta_liveE Live_Ent_liveE  ///
	Goat_Prod_Sys_goat Goat_Pro_Sys_goat Live_Sale_sales Live_Sale_sale ///
	PQ1_1 PQ1 GPS ____version metainstanceID ___uuid ___submission_time ___tags ___notes ///
	merge1 merge2 Rosterstart_Rooster RosterRoster_Note merge3 _merge ///

	
* Change blank cells in string vars to missing values
ds, has(type string) 
quietly foreach v in `r(varlist)' { 
	replace `v' = trim(`v')
	}
	
*drop multi-choice vars with individual dummys already created
drop COM1 COM2 COM6 COM7 SV2 LSE22 GP4 GP12 GP18 GP22 ///
		GP25 LS48 PQ2 BR5 GP3 BR56 HHR10_1

* Change 1-2 vars to binary
 foreach v of varlist MGT5 COM5 ///
		SV3 SV4 SV7 BR1 FC1A FC1B FC1E FC1F FC1H GP7 ///
		GP13 GP16 GP19 GP21 {
	quietly replace `v'=. if `v'==99
	quietly replace `v'=. if `v'==97
	quietly replace `v'=0 if `v'==2
}

* Change 1-2 vars to binary
foreach v of varlist HHR3 HHR5 HHR11 HHR13 HHR14 ///
		HHR15 HHR17 HHR18 HHR19 {
	quietly destring `v', replace
	quietly replace `v'=. if `v'==99
	quietly replace `v'=. if `v'==97
	quietly replace `v'=0 if `v'==2
}

* Change 'I don't know' to 'No' for awareness variables
foreach v of varlist MEM3 MEM6 MEM8 MEM12 MEM14 MEM16 SER* HH_TRN1 ///
		HH_TRN2 HH_TRN3 HH_TRN4 HH_TRN5 HH_TRN6 HH_TRN7 HH_TRN8 {
	quietly replace `v'=0 if `v'==99
	quietly replace `v'=0 if `v'==98
	quietly replace `v'=0 if `v'==97
	quietly replace `v'=0 if `v'==3
	quietly replace `v'=0 if `v'==2
}

* destring relevant vars
quietly {
	destring *COM1* *COM2* *COM6*, replace 
	destring *COM7* *GTT* *SV2*, replace 
	destring *EMP* *LSE*, replace 
	destring *BR5* N0_childcal *HHR8* HHR12 *LS6*, replace 
	destring *GP* Roster_count Live_Sale_count, replace
}


* rename co-op indicator
rename IDX idx
* rename vars with invalid names
rename Co_opTransparencyTransparency_no Co_opTransparencyTransparency
rename Live_EntexofemaleExotic_Female Live_EntexofemaleExotic_F
rename Live_EntcrofemaleCross_Breed_F Live_EntcrofemaleCross
rename Live_EntCro_breed_female_goats Live_EntCro_breed_female
drop Co_opTransparencyTransparency


save "$d3/Household_Merged.dta", replace
 
