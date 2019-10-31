
/*******************************************************************************
dis0_6.d0		
					
- Generates a merged dataset at the HH level
	Collapses HH data from ind. level to HH level
	Saves respective datasets as CO_Merged.dta
	and HH_Merged.dta
	
*******************************************************************************/


clear all
set more off, perm


** create merged dataset at HH level **
cd "$d3"

clear
use "$d3/HH_Ind.dta"


* Collapse to one row per HH.
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

ds *HHR* *ID* *LND* *HSE* *MEM* *SER* *MGT* *COM* *GTT* *TRN* *SV* *BR* *FC* *EMP* *LS* *GP* region district idx *salevalue *goatno, has(type string)
local HHstrings = "`r(varlist)'"
ds *HHR* *ID* *LND* *HSE* *MEM* *SER* *MGT* *COM* *GTT* *TRN* *SV* *BR* *FC* *EMP* *LS* *GP* region district idx *salevalue *goatno, has(type numeric)
local HHnumeric = "`r(varlist)'"

collapse (firstnm) `HHstrings' (mean) `HHnumeric', by(___index)

* re-assign labels post-collapse
foreach v of var * {
	label var `v' "`l`v''"
	cap label val `v' "`ll`v''"
}

* Merge and save dataset
merge m:m idx using "CO_Merged_Ind.dta", force
drop _merge

save HH_Merged_Ind.dta, replace






