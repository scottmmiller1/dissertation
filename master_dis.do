version 15.1
/*******************************************************************************
DO FILE DIRECTORY 
	
dis0:
	creates collapsed co-op and HH datasets

dis1: 
	Merges true and randomized treatment status from lsilPAP_rand1/2
	into clean datasets to be used for power calculations
	
dis2: 
	Generates a merged dataset at the HH level
	Collapses HH data from individual level to HH level
	
dis3:
	Creates command for ICW Summary Indices
	(published by Cyrus Samii, NYU, December 2017) 
	
dis4: 
	Creates indicator variables & ICW Summary Indices
	at the co-op and household levels
	Saves new datasets respectively as: 
	r_CO_Merged_Ind.dta
	r_HH_Merged_Ind.dta


*******************************************************************************/
clear all
*packages
*ssc install outreg
*ssc install ietoolkit

*pathways
gl d0 = "/Users/scottmiller/Dropbox (UFL)/Dissertation/Analysis" // master file
gl d1 = "/Users/scottmiller/GitHub/dissertation" // do files stored here
gl d2 = "$d0/Output" // used to store output
gl d3 = "$d0/Data" // data folder

cd "$d0"

* To run all do files


/*
forv i = 0/4 {
	do "$d1/dis`i'.do"
}


