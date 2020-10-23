set.seed(13489)
rm(list = ls())
setwd("/Users/scottmiller/Dropbox (UFL)/LSIL 2/Work Spaces/Scott/Lasso_Select")

#.libPaths(c("C:/Users/Conner/Documents/R/win-library/3.3"))

library(foreign)
library(readstata13)
library(glmnet)


# data setup
# -------------------------------------------------------------------------
dta <- read.csv("Data/lasso_psm_vars.csv")
dta <- dta[complete.cases(dta),]


X.main <- data.matrix(dta[,c("HHR4","HHR14","ID10","pre_goats_owned","bHHR16","mem_length","bMEM4","MEM7","n_services","index_emp",
                 "nfloors", "dirt_floor", "geo_dist_mi", "GPS_altitude")])
X <- data.matrix(subset(dta, select = -c(idx,district,co_sale,price,co_sale,LS8,LS9,net_goat_income_w)))
#Y <- dta[,"price"]
T <- dta[,"co_sale"]
# -------------------------------------------------------------------------


# Lasso variable selection
# -------------------------------------------------------------------------
# Pscore lasso
fit_pscore <- glmnet(X,T, family=c("binomial"), alpha=1, nlambda=100)

  # save lambdas to csv
  lambda_pscore <- as.matrix(fit_pscore$lambda)
  #write.csv(lambda_pscore, file="lasso output/lambda_pscore.csv")

  # save coefficients to csv 
  coef_pscore <- as.matrix(coef(fit_pscore))
  #write.csv(coef_pscore, file="lasso output/coef_pscore.csv")

  
## outcome lasso
# price
fit_price <- glmnet(X,dta$price, family=c("gaussian"), alpha=1, nlambda=100)

  # save lambdas to csv
  lambda_price <- as.matrix(fit_price$lambda)
  #write.csv(lambda_price, file="lasso output/lambda_price.csv")
  
  # save coefficients to csv 
  coef_price <- as.matrix(coef(fit_price))
  #write.csv(coef_price, file="lasso output/coef_price.csv")
  
#LS8  
fit_LS8 <- glmnet(X,dta$LS8, family=c("gaussian"), alpha=1, nlambda=100)
  
  # save lambdas to csv
  lambda_LS8 <- as.matrix(fit_LS8$lambda)
  write.csv(lambda_LS8, file="lasso output/lambda_LS8.csv")
  
  # save coefficients to csv 
  coef_LS8 <- as.matrix(coef(fit_LS8))
  write.csv(coef_LS8, file="lasso output/coef_LS8.csv")  
  
#net goat income  
fit_netinc <- glmnet(X,dta$LS8, family=c("gaussian"), alpha=1, nlambda=100)
  
  # save lambdas to csv
  lambda_netinc <- as.matrix(fit_netinc$lambda)
  write.csv(lambda_netinc, file="lasso output/lambda_netinc.csv")
  
  # save coefficients to csv 
  coef_netinc <- as.matrix(coef(fit_netinc))
  write.csv(coef_netinc, file="lasso output/coef_net_goat_income_w.csv")    
  
# -------------------------------------------------------------------------


