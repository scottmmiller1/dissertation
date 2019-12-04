
/*******************************************************************************
dis0_1.d0		
					
- Clean datasets 							
- Create Co-op dataset that is collapsed		
	at the co-op level						
- Create HH dataset that is collapsed at	
	at the co-op level						
- Merge Co-op & HH datasets to create a 	
	single dataset at the co-op level	
	
*******************************************************************************/


clear all
set more off, perm

* Load Co-op dataset 
clear
use "$d3/Cooperative.dta"


** Clean Co-op data **

* drop data collection notes & time stamps
drop *start* *end* *note* consent *GPS* ____version metainstanceID ///
		___id ___parent* ___tags ___uuid ___sub*
		
* rename variables with invalid names	
rename role_CPSerLiv_rel_serLive_rel_se role_CPSerLiv_rel_serLive_rel

* rename co-op variable to match HH & Co-op dataset
rename IDX idx


** Assign district & region names
destring ID1, replace
gen district = "Arghakanchhi" if ID1==51
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
	

** save labels and value labels in macros
quietly  {
	foreach v of var * {
		cap local vv = subinstr("`v'", "GMequipment", "GMeqpmt",.) // names too long for macros
		if _rc == 0 {
			rename `v' `vv'
			local v `vv'
		}
		cap local vv = subinstr("`v'", "GMFinancial", "GMFin",.) // names too long for macros
		if _rc == 0 {
			rename `v' `vv'
			local v `vv'
		}
		cap local vv = subinstr("`v'", "planning", "plan",.) // names too long for macros
		if _rc == 0 {
			rename `v' `vv'
			local v `vv'
		}	
		cap local vv = subinstr("`v'", "evalassment", "eval",.) // names too long for macros
		if _rc == 0 {
			rename `v' `vv'
			local v `vv'
		}
		cap local vv = subinstr("`v'", "transpernacy", "trans",.) // names too long for macros
		if _rc == 0 {
			rename `v' `vv'
			local v `vv'
		}	
		cap local vv = subinstr("`v'", "intro", "in",.) // names too long for macros
		if _rc == 0 {
			rename `v' `vv'
			local v `vv'
		}
		cap local vv = subinstr("`v'", "transactions", "trans",.) // names too long for macros
		if _rc == 0 {
			rename `v' `vv'
			local v `vv'
		}
		cap local vv = subinstr("`v'", "Planning", "plan",.) // names too long for macros
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

* Change Yes / No variables to binary
foreach v of varlist MAN1 MAN11 MAN15 MAN17 REC8 {
	quietly replace `v'=. if `v'==99
	quietly replace `v'=. if `v'==97
	quietly replace `v'=0 if `v'==2
}

* Change 'I don't know' to 'No' for awareness variables	
foreach v of varlist TRN* EQP1_1 EQP2_1 EQP3_1 EQP4_1 EQP5_1 EQP6_1 EQP7_1 EQP8_1 ///
		EQP9_1 EQP10_1 EQP11_1 EQP12_1 EQP13_1 EQP14_1 EQP15_1 EQP16 EQP17 EQP18 EQP19 ///
		FAL3 FAL4 EAA1 EAA3 PNG1 SER1 SER2 SER3 SER4 SER5 SER6 SER7 SER8 SER9 SER10 ///
		SER1* SERV2 SERV3 SERV4 SERV8  {
	quietly replace `v'=0 if `v'==99
	quietly replace `v'=0 if `v'==97
	quietly replace `v'=0 if `v'==2
}	

* rename vars with Co-op indicator (have same name as HH data)
foreach v of varlist TRN* SER* *GTT* {
	rename `v' CO_`v'
}	
	

* Change COMM8 to string
foreach v of varlist COMM8a COMM8b ///
COMM8c COMM8d COMM8e ///
COMM8f {
	tostring `v', replace force
	replace `v' ="" if `v' == "." 
}	

* Change MAN18 to string
foreach v of varlist MAN18a MAN18b ///
MAN18c MAN18d MAN18e {
	tostring `v', replace force
	replace `v' ="" if `v' == "97" 
}	

* Change blank cells in strings to missing values
ds, has(type string) 
quietly foreach v in `r(varlist)' { 
	replace `v' = trim(`v')
	replace `v' ="" if `v' == "."
	}
	
** Collapse to 1-row per co-op
* strings
ds *ID* *MEM* *role* *IND* *REC* *REV* *EQP* *FAL* PNG* *EAA* *COMM* *GTT* *MAN* *SER* *GPR* CO_TRN* region district ___index, has(type string)
local Co_opstrings = "`r(varlist)'"

* numerics
ds *ID* *MEM* *role* *IND* *REC* *REV* *EQP* *FAL* PNG* *EAA* *COMM* *GTT* *MAN* *SER* *GPR* CO_TRN* region district ___index, has(type numeric)
local Co_opnumeric = "`r(varlist)'"

* collapse
collapse (mean) `Co_opnumeric' (firstnm) `Co_opstrings', by(idx)
*collapse (firstnm) `Co-opstrings', by(idx)


* re-assign labels post-collapse
quietly {
	foreach v of var * {
		label var `v' "`l`v''"
		cap label val `v' "`ll`v''"
	}
}

* save collapsed dataset
save "$d3/Cooperative_collapse.dta", replace


* ------------------------------------------------------------------------


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
foreach v of varlist LS3 LS39 LS44 LS45 {
	quietly replace `v'=. if `v'==99
	quietly replace `v'=. if `v'==97
	quietly replace `v'=0 if `v'==2
}

* generate variable for # of sales
bysort ___parent_index: egen LS_n_sales=count(___parent_index)


** Collapse to 1-row per HH

** save labels and value labels in macros 
quietly foreach v of var * {
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

* collapse
collapse (firstnm) LS_n_sales (mean) LS3 *LS6* LS7 (sum) LS8 LS9 LS10 LS12 LS13 LS14 LS15 LS16 ///
		LS17 LS25 LS26 LS27 LS28 LS29 LS30 LS31 *LS32* LS33 LS34 LS35 LS36 LS37 ///
		LS38 LS39 LS40 LS41 LS42 *LS43* LS44 LS45 LS46 ///
		LS47 co_opsalevalue co_opgoatno outsidesalevalue outsidegoatno, by(___parent_index)

** re-assign labels post-collapse
quietly foreach v of var * {
	label var `v' "`l`v''"
	cap label val `v' "`ll`v''"
}
		
		
/*	
** Top code LS9 -- obvious outliers

g price = LS9/LS8
g n = _n

*scatter LS9 price, mlabel(n)
*br n LS8 LS9 price if n == 658 | n == 859 | n == 833 | n == 521 | n == 577

su price, d
replace LS9 = r(p50)*LS8 if n == 658 | n == 859 | n == 833 | n == 521 | n == 577

drop n price

su *LS8, d
replace LS8 = r(p50) if LS8 > 25 & ///
LS8 < . // Replaces outliers with median
*/


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
	Co_opstart_coop MEM4_1 MEM9_1 Co_opMembershipMEM10MEM10_Header MEM13_1 ///
	Co_opServiceService_note MGT1_1 COM1_1 COM2_1 COM6_1 ///
	COM11_1 Co_opGoat_transactionsGTT4_1 Co_opFollow_up_transparency_ques ///
	Savingsstart_savings SavingsSavings_Note ///
	SV2_1 Savingsend_savings Borrowingstart_borrowing Borrowingend_borrowing ///
	Food_Consumptionstart_food Food_ConsumptionGrainsGrains_N Food_ConsumptionPulsesPulses_n ///
	Food_ConsumptionMeat_fish_and_eg Food_ConsumptionDairy_productsDa Food_ConsumptionFruitsFruits_not ///
	Food_ConsumptionVegetablesVegeta Food_ConsumptionSugar_and_or_swe Food_ConsumptionOilOil_note ///
	time_food start_stockR Live_rel_emp_stockR Live_Entsta_liveE Live_Ent_liveE  ///
	Goat_Prod_Sys_goat GP2_1 GP4_1 GP8_1 Goat_Pro_Sys_goat Live_Sale_sales Live_Sale_sale ///
	PQ1_1 PQ1 GPS ____version metainstanceID ___uuid ___submission_time ___tags ___notes ///
	merge1 merge2 Rosterstart_Rooster RosterRoster_Note merge3 _merge ///
	LSE10_2 LSE10_3 LSE10_1 SV8_1 LSE1 GP22_1 GP22_2 HHR1 HHR2 GP22_1 GP22_2

	
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

save "$d3/Household_Merged_Edit.dta", replace
 
*-------------------------------------------------------------------------
 
** Collapse HH into 1 row per cooperative
 
use "$d3/Household_Merged_Edit.dta", clear

* rename co-op indicator
rename IDX idx
* rename vars with invalid names
rename Co_opTransparencyTransparency_no Co_opTransparencyTransparency
rename Live_EntexofemaleExotic_Female Live_EntexofemaleExotic_F
rename Live_EntcrofemaleCross_Breed_F Live_EntcrofemaleCross
rename Live_EntCro_breed_female_goats Live_EntCro_breed_female
drop Co_opTransparencyTransparency


** save labels and value labels in macros 
foreach v of var * {
	cap local vv = subinstr("`v'", "Follow_up_", "Follup",.) // names too long for macros
	if _rc == 0 {
		rename `v' `vv'
		local v `vv'
	}
	cap local vv = subinstr("`v'", "Food_Consumption", "Food_Cons",.) // names too long for macros
	if _rc == 0 {
		rename `v' `vv'
		local v `vv'
	}
	cap local vv = subinstr("`v'", "Livestock_related_empowerment", "Livestock_empowerment",.) // names too long for macros
	if _rc == 0 {
		rename `v' `vv'
		local v `vv'
	}
	cap local vv = subinstr("`v'", "Livestock_Enterprises", "Livestock_Enter",.) // names too long for macros
	if _rc == 0 {
		rename `v' `vv'
		local v `vv'
	}
	cap local vv = subinstr("`v'", "Post_questionnaire", "Post_",.) // names too long for macros
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

* collapse to one row per co-op
ds *HHR* *ID* *LND* *HSE* *MEM* *SER* *MGT* *COM* *GTT* *TRN* *SV* *BR* *FC* *EMP* *LS* *GP* region district, has(type string)
local HHstrings = "`r(varlist)'"
ds *HHR* *ID* *LND* *HSE* *MEM* *SER* *MGT* *COM* *GTT* *TRN* *SV* *BR* *FC* *EMP* *LS* *GP* region district, has(type numeric)
local HHnumeric = "`r(varlist)'"

collapse (firstnm) `HHstrings' (mean) `HHnumeric' co_opsalevalue co_opgoatno outsidesalevalue outsidegoatno, by(idx)

* re-assign labels post-collapse
foreach v of var * {
	label var `v' "`l`v''"
	cap label val `v' "`ll`v''"
}

drop if idx == "" | idx == "2"


save "$d3/Household_Collapsed.dta", replace


*------------------------------------------------------------------------------ 
** Merge collapse HH and Co-op datasets

clear 
use "$d3/Household_Collapsed.dta"  

merge 1:1 idx using "$d3/Cooperative_collapse.dta", force

drop *merge*



* Create per member measures of revenue and cost
destring REC7, replace
lab var REC7 "Total co-op cost"
destring REV4, replace
lab var REV4 "Total co-op revenue"

gen totrev_member = REV4 / MAN3
gen totcost_mem = REC7 / MAN3
gen goatssold_mem = REC1 / MAN3

lab var totrev_member "Co-op revenue (all sources) per member"
lab var totcost_mem "Co-op cost (all sources) per member"
lab var goatssold_mem "Co-op goats sold per member"

save "$d3/Dis_Merged.dta", replace


*------------------------------------------------------------------------------ 
** Remove intermediary datasets
erase "$d3/Borrowing_edit.dta"
erase "$d3/Children_edit.dta"
erase "$d3/Cooperative_collapse.dta"
erase "$d3/Household_Collapsed.dta"
erase "$d3/Household_edit.dta"
erase "$d3/Household_Merged.dta"
erase "$d3/Livestocksales_collapse_edit.dta"
erase "$d3/Livestocksales_collapse.dta"
erase "$d3/modules_merged.dta"
erase "$d3/Roster_edit.dta"
 
 *********************************************


