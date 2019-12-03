
/*******************************************************************************
dis0_5.d0		
					
- Collapse HH data to Co-op level					
- Merge Co-op & HH datasets to create a 	
	single dataset at the co-op level	
	
*******************************************************************************/


clear all
set more off, perm



** Collapse HH into 1 row per cooperative
use "$d3/HH_Ind.dta", clear


** save labels and value labels in macros 
quietly {
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
}

* collapse to one row per co-op
ds *HHR* *ID* *LND* *HSE* *MEM* *SER* *MGT* *COM* *GTT* *TRN* *SV* *BR* *FC* *EMP* *LS* *GP* region district *salevalue *goatno *rev_*, has(type string)
local HHstrings = "`r(varlist)'"
ds *HHR* *ID* *LND* *HSE* *MEM* *SER* *MGT* *COM* *GTT* *TRN* *SV* *BR* *FC* *EMP* *LS* *GP* region district *salevalue *goatno *rev_*, has(type numeric)
local HHnumeric = "`r(varlist)'"

collapse (firstnm) `HHstrings' (mean) `HHnumeric', by(idx)

* re-assign labels post-collapse
quietly {
foreach v of var * {
	label var `v' "`l`v''"
	cap label val `v' "`ll`v''"
}
}
drop if idx == "" | idx == "2"


save "$d3/HH_Ind_Collapsed.dta", replace


*------------------------------------------------------------------------------ 
** Merge collapse HH and Co-op datasets

clear 
use "$d3/HH_Ind_Collapsed.dta" 

merge 1:1 idx using "$d3/CO_Ind.dta", force

drop *merge*

save "$d3/CO_Merged_Ind.dta", replace

 
 *********************************************
