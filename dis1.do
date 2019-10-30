
/*******************************************************************************
dis1.d0		
					
- Merges treatment status from LSIL VCC RCT into dataset
	
*******************************************************************************/


clear all
set more off, perm

** Load merged baseline dataset
use "$d3/Baseline_Merged.dta", clear

* Merge treatment status from original randomization
clear
use "$d3/treat.dta", replace
drop r_treat

merge 1:1 idx using "$d3/Baseline_Merged.dta"
replace treat = 1 if idx == "Lekhbesi SEWC 1"
replace treat = 0 if district == "Banke"
*drop if district == "Banke"

save "$d3/Baseline_Merged_treat.dta", replace

 
