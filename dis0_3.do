
/*******************************************************************************
dis0_3.d0		
					
- Creates command for ICW Summary Indices
	(published by Cyrus Samii, NYU, December 2017) 
	
*******************************************************************************/



/***********************************************
*INVERSE COVARIANCE WEIGHTED INDEX V.0.2
*Cyrus Samii, NYU, December 2017
*(cds2083@nyu.edu)
*
*This ado file creates an index using inverse covariance weighting, 
*a la Anderson (2008, p. 1485).

***********************************************/


capture program drop make_index_gr
capture mata: mata drop icwxmata()
program make_index_gr
version 11.1
    syntax anything [if]
    gettoken newname anything: anything
    gettoken wgt anything: anything
	gettoken sgroup anything: anything
    local Xvars `anything'
	marksample touse
  	mata: icwxmata(("`Xvars'"),"`wgt'","`sgroup'", "index")
	rename index index_`newname'
end
 
mata:
	function icwxmata(xvars, wgts, sgroups, indexname)
	{
		st_view(X=0,.,tokens(xvars))
		st_view(wgt=.,.,wgts)
		st_view(sgroup=.,.,sgroups)
		nr = rows(X)
		nc = cols(X)	
		sg_wgt = wgt:*sgroup
		sg_wgtst = sg_wgt/sum(sg_wgt)
		all_wgtst = wgt/sum(wgt)
		sg_wgtstdM = J(1,nc,1) # sg_wgtst
		all_wgtstdM = J(1,nc,1) # all_wgtst
		sg_wgtdmeans = colsum(X:*sg_wgtstdM)
		sgroup2 = sgroup
		sgroupdM = J(1,nc,1) # sgroup2
		sg_meandevs = ((X:*sgroupdM) - (J(nr,1,1) # sg_wgtdmeans):*sgroupdM)
		all_wgtdmeandevs = X - (J(nr,1,1) # sg_wgtdmeans)
		sg_wgtdstds = sqrt(colsum(sg_wgt:*(sg_meandevs:*sg_meandevs)):/(sum(sg_wgt)-1))
		Xs = all_wgtdmeandevs:/(J(nr,1,1) # sg_wgtdstds)
		S = variance(Xs, wgt)
		invS = invsym(S)
		ivec = J(nc,1,1)
		indexout_sc = (invsym(ivec'*invS*ivec)*ivec'*invS*Xs')'
		indexout = indexout_sc/sqrt(variance(indexout_sc, sg_wgt))
		st_addvar("float",indexname)
		st_store(.,indexname,indexout)
	}
end
