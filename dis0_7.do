
/*******************************************************************************
dis0_7.d0		
					
- Merges treatment status from LSIL VCC RCT into dataset
	
*******************************************************************************/


clear all
set more off, perm

** Load merged baseline dataset
use "$d3/Baseline_Merged.dta", clear

* Merge treatment status from original randomization

** Household Data
clear
use "$d3/treat.dta", replace

merge 1:m idx using "$d3/HH_Merged_Ind.dta"
replace treat = 1 if idx == "Lekhbesi SEWC 1"
replace treat = 0 if district == "Banke"
*drop if district == "Banke"

save "$d3/HH_Final.dta", replace


** Household Data
clear
use "$d3/treat.dta", replace

merge 1:1 idx using "$d3/CO_Merged_Ind.dta"
replace treat = 1 if idx == "Lekhbesi SEWC 1"
replace treat = 0 if district == "Banke"
*drop if district == "Banke"

save "$d3/CO_Final.dta", replace




*------------------------------------------------------------------------------ 
** Remove intermediary datasets
/*
erase "$d3/Borrowing_edit.dta"
erase "$d3/Children_edit.dta"
erase "$d3/Cooperative_collapse.dta"
erase "$d3/Household_edit.dta"
erase "$d3/Household_Merged.dta"
erase "$d3/Livestocksales_collapse_edit.dta"
erase "$d3/Livestocksales_collapse.dta"
erase "$d3/modules_merged.dta"
erase "$d3/Roster_edit.dta"
*erase "$d3/Baseline_Merged_treat.dta"
*erase "$d3/Baseline_Merged.dta"
erase "$d3/CO_Merged_Ind.dta"
erase "$d3/CO_Ind.dta"
erase "$d3/HH_Merged_Ind.dta"
erase "$d3/HH_Ind.dta"
erase "$d3/Household_Merged_Edit.dta"
*/
