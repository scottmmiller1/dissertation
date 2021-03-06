version 15.1
/*******************************************************************************
DO FILE DIRECTORY 
	
dis0_1:
	Cleans co-op and HH datasets
	
dis0_2:
	Generates a merged dataset at the HH level
	Collapses HH data from individual level to HH level
	
dis0_3: 
	Creates command for ICW Summary Indices
	(published by Cyrus Samii, NYU, December 2017) 	

dis0_4: 
	Creates indicator variables at the co-op and household levels
	
dis0_5:
	Merges treatment status from LSIL VCC project into datasets
	
dis0_6: 
	Generates summmary statistis tables



*******************************************************************************/
clear all
*packages
*ssc install outreg2
*ssc install ietoolkit

*pathways
gl d0 = "/Users/scottmiller/Dropbox (UFL)/Dissertation/Analysis" // master file
gl d1 = "/Users/scottmiller/GitHub/dissertation" // do files stored here
gl d2 = "$d0/Output" // used to store output
gl d3 = "$d0/Data" // data folder

cd "$d0"

* To run all do files


/*

* Data cleaning & dataset creating
forv i = 1/6 {
	do "$d1/dis0_`i'.do"
}

* Essay 1
forv i = 1/ {
	do "$d1/dis1_`i'.do"
}

* Essay 2
forv i = 1/ {
	do "$d1/dis2_`i'.do"
}

* Essay 3
forv i = 1/ {
	do "$d1/dis3_`i'.do"
}
