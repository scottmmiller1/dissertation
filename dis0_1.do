
/*******************************************************************************
dis0_1.d0		
					
- Clean datasets 							
- Create Co-op dataset that is collapsed		
	at the co-op level						
	
*******************************************************************************/


clear all
set more off, perm


* Load Co-op dataset 
clear
use "$d3/Cooperative.dta"


** Clean Co-op data **

* drop data collection notes & time stamps
drop *start* *end* *note* consent ____version metainstanceID ///
		___id ___parent* ___tags ___uuid ___sub* role_CPSerLiv_rel_serLive_rel_se
		

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
quietly {
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
foreach v of varlist TRN* SER* GTT* BM_GTT* {
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

* Destring numeric vars
foreach v of varlist REV4 REC7 {
	destring `v', replace
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

