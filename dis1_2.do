
/*******************************************************************************
dis1_2.d0		
					
- K-means clustering for Oaxaca Decomposition						
	
*******************************************************************************/


cd "$d3" 


** Co-op level dataset
********************************************* 
clear
use "$d3/CO_Final.dta"

cluster kmeans goatssold_mem totrev_member MAN3 LS9, k(2) gen(high_low)


tab high_low
tabstat goatssold_mem totrev_member MAN3, by(high_low) stat(min mean max)


drop high_low

cluster kmeans totrev_member, k(2) gen(high_low)

tab high_low
tabstat totrev_member, by(high_low) stat(min mean max)
