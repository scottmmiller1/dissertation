##########################################################################
##
##
##	WARNING: This code is not pretty, and not general. May not be 
##	easily adapted to other applications.
##
##
##	This file replications Table 1 of the paper -- NSW Analysis 
##
##	Author: Max H. Farrell
##	Date: 2014-06-26
##
##	Description / notes: 
##	-DW = Dehejia-Wahba2002_REStat
##	.DW02 = Smith-Todd2005_JoE
##	-Use the same LaLonde sample as DW (the re74 sample)
##	-Use the dta controls (not CPS)
##	-We do NOT follow .DW02, who combine NSW treated+controls into a new
##	T==1 group, then use the dta as the T==0 group. The NSW controls
##	are eligible non-participants, so for prop score estimation 
##	giving them T==1 is OK.
##	-We only apply the EIF estimator, with different specifications.
##	-Directly related, we use the SAME specification for mu_t(x) as
##	for p_t(x). Prior work (DW,.DW02, etc) only talk about prop. scores
##	so we have to use the same specification. This isn't optimal, 
##	but it's the most fair.
##
##########################################################################

#install.packages(c("foreign", "MASS", "glmnet", "grplasso", "nnet", "gglasso"))


library("foreign")
library("MASS")
library("glmnet")	#lasso, group lasso, and ridge, for outcome models, LPM, mlogit. Also, unpenalized mlogit via glmnet is far faster than the mlogit package.
library("grplasso")	#glmnet group lasso requires the same n per group (ie multi-task learning), which is perfect for mlogit but wrong for the outcome model.
# library("mlogit")	#slower than unpenalized estimation in glmnet, but glmnet won't fit only an intercept
library("nnet")	#quicker multinomial logit
library("gglasso")



dta <- read.csv("Data/sales_final.csv")
dta <- dta[complete.cases(dta[,"HHR4"], dta[,"HHR14"], dta[,"ID10"], dta[,"pre_goats_owned"], dta[,"bHHR16"], dta[,"mem_length"], 
                          dta[,"bMEM4"], dta[,"MEM7"], dta[,"n_services"], dta[,"index_emp"], dta[,"nfloors"],
                          dta[,"dirt_floor"], dta[,"geo_dist_mi"], dta[,"GPS_altitude"]),]

Y <- dta[,"price"]
T <- dta[,"co_sale"]
n <- length(T)
n.per.treatment <- as.vector(table(T))
Treatments <- 1




##################################
## 			 	##
## 	Model Selection	 	##
## 			 	##
##################################


#### 2. X = Many more terms for flexibility	####

X.main <- cbind(dta[,"HHR4"], dta[,"HHR14"], dta[,"ID10"], dta[,"pre_goats_owned"], dta[,"bHHR16"], dta[,"mem_length"], 
                dta[,"bMEM4"], dta[,"MEM7"], dta[,"n_services"], dta[,"index_emp"], dta[,"nfloors"],
                dta[,"dirt_floor"], dta[,"geo_dist_mi"], dta[,"GPS_altitude"])

X.main <- dta[,c("HHR4","HHR14","ID10","pre_goats_owned","bHHR16","mem_length","bMEM4","MEM7","n_services","index_emp",
                 "nfloors", "dirt_floor", "geo_dist_mi", "GPS_altitude")]

X.cont.interactions <- cbind(
  dta[,"HHR4"]*dta[,"HHR4"], 
  dta[,"HHR4"]*dta[,"HHR14"], 
  dta[,"HHR4"]*dta[,"ID10"],
  dta[,"HHR4"]*dta[,"pre_goats_owned"],
  dta[,"HHR4"]*dta[,"bHHR16"],
  dta[,"HHR4"]*dta[,"mem_length"],
  dta[,"HHR4"]*dta[,"bMEM4"],
  dta[,"HHR4"]*dta[,"MEM7"],
  dta[,"HHR4"]*dta[,"n_services"],
  dta[,"HHR4"]*dta[,"index_emp"],
  dta[,"HHR4"]*dta[,"nfloors"],
  dta[,"HHR4"]*dta[,"dirt_floor"],
  dta[,"HHR4"]*dta[,"geo_dist_mi"],
  dta[,"HHR4"]*dta[,"GPS_altitude"],
  dta[,"HHR14"]*dta[,"HHR14"], 
  dta[,"HHR14"]*dta[,"ID10"],
  dta[,"HHR14"]*dta[,"pre_goats_owned"],
  dta[,"HHR14"]*dta[,"bHHR16"],
  dta[,"HHR14"]*dta[,"mem_length"],
  dta[,"HHR14"]*dta[,"bMEM4"],
  dta[,"HHR14"]*dta[,"MEM7"],
  dta[,"HHR14"]*dta[,"n_services"],
  dta[,"HHR14"]*dta[,"index_emp"],
  dta[,"HHR14"]*dta[,"nfloors"],
  dta[,"HHR14"]*dta[,"dirt_floor"],
  dta[,"HHR14"]*dta[,"geo_dist_mi"],
  dta[,"HHR14"]*dta[,"GPS_altitude"],
  dta[,"ID10"]*dta[,"ID10"],
  dta[,"ID10"]*dta[,"pre_goats_owned"],
  dta[,"ID10"]*dta[,"bHHR16"],
  dta[,"ID10"]*dta[,"mem_length"],
  dta[,"ID10"]*dta[,"bMEM4"],
  dta[,"ID10"]*dta[,"MEM7"],
  dta[,"ID10"]*dta[,"n_services"],
  dta[,"ID10"]*dta[,"index_emp"],
  dta[,"ID10"]*dta[,"nfloors"],
  dta[,"ID10"]*dta[,"dirt_floor"],
  dta[,"ID10"]*dta[,"geo_dist_mi"],
  dta[,"ID10"]*dta[,"GPS_altitude"],
  dta[,"pre_goats_owned"]*dta[,"pre_goats_owned"],
  dta[,"pre_goats_owned"]*dta[,"bHHR16"],
  dta[,"pre_goats_owned"]*dta[,"mem_length"],
  dta[,"pre_goats_owned"]*dta[,"bMEM4"],
  dta[,"pre_goats_owned"]*dta[,"MEM7"],
  dta[,"pre_goats_owned"]*dta[,"n_services"],
  dta[,"pre_goats_owned"]*dta[,"index_emp"],
  dta[,"pre_goats_owned"]*dta[,"nfloors"],
  dta[,"pre_goats_owned"]*dta[,"dirt_floor"],
  dta[,"pre_goats_owned"]*dta[,"geo_dist_mi"],
  dta[,"pre_goats_owned"]*dta[,"GPS_altitude"],
  dta[,"bHHR16"]*dta[,"mem_length"],
  dta[,"bHHR16"]*dta[,"MEM7"],
  dta[,"bHHR16"]*dta[,"n_services"],
  dta[,"bHHR16"]*dta[,"index_emp"],
  dta[,"bHHR16"]*dta[,"nfloors"],
  dta[,"bHHR16"]*dta[,"geo_dist_mi"],
  dta[,"bHHR16"]*dta[,"GPS_altitude"],
  dta[,"mem_length"]*dta[,"mem_length"],
  dta[,"mem_length"]*dta[,"bMEM4"],
  dta[,"mem_length"]*dta[,"MEM7"],
  dta[,"mem_length"]*dta[,"n_services"],
  dta[,"mem_length"]*dta[,"index_emp"],
  dta[,"mem_length"]*dta[,"nfloors"],
  dta[,"mem_length"]*dta[,"dirt_floor"],
  dta[,"mem_length"]*dta[,"geo_dist_mi"],
  dta[,"mem_length"]*dta[,"GPS_altitude"],
  dta[,"bMEM4"]*dta[,"MEM7"],
  dta[,"bMEM4"]*dta[,"n_services"],
  dta[,"bMEM4"]*dta[,"index_emp"],
  dta[,"bMEM4"]*dta[,"nfloors"],
  dta[,"bMEM4"]*dta[,"geo_dist_mi"],
  dta[,"bMEM4"]*dta[,"GPS_altitude"],
  dta[,"MEM7"]*dta[,"MEM7"],
  dta[,"MEM7"]*dta[,"n_services"],
  dta[,"MEM7"]*dta[,"index_emp"],
  dta[,"MEM7"]*dta[,"nfloors"],
  dta[,"MEM7"]*dta[,"dirt_floor"],
  dta[,"MEM7"]*dta[,"geo_dist_mi"],
  dta[,"MEM7"]*dta[,"GPS_altitude"],
  dta[,"n_services"]*dta[,"n_services"],
  dta[,"n_services"]*dta[,"index_emp"],
  dta[,"n_services"]*dta[,"nfloors"],
  dta[,"n_services"]*dta[,"dirt_floor"],
  dta[,"n_services"]*dta[,"geo_dist_mi"],
  dta[,"n_services"]*dta[,"GPS_altitude"],
  dta[,"index_emp"]*dta[,"index_emp"],
  dta[,"index_emp"]*dta[,"nfloors"],
  dta[,"index_emp"]*dta[,"dirt_floor"],
  dta[,"index_emp"]*dta[,"geo_dist_mi"],
  dta[,"index_emp"]*dta[,"GPS_altitude"],
  dta[,"nfloors"]*dta[,"nfloors"],
  dta[,"nfloors"]*dta[,"dirt_floor"],
  dta[,"nfloors"]*dta[,"geo_dist_mi"],
  dta[,"nfloors"]*dta[,"GPS_altitude"],
  dta[,"dirt_floor"]*dta[,"geo_dist_mi"],
  dta[,"dirt_floor"]*dta[,"GPS_altitude"],
  dta[,"geo_dist_mi"]*dta[,"geo_dist_mi"],
  dta[,"geo_dist_mi"]*dta[,"GPS_altitude"],
  dta[,"GPS_altitude"]*dta[,"GPS_altitude"]
)

X.dummy.interactions <- cbind(
  dta[,"bHHR16"]*dta[,"bHHR16"],
  dta[,"bHHR16"]*dta[,"bMEM4"],
  dta[,"bHHR16"]*dta[,"dirt_floor"],
  dta[,"bMEM4"]*dta[,"bMEM4"],
  dta[,"bMEM4"]*dta[,"dirt_floor"],
  dta[,"dirt_floor"]*dta[,"dirt_floor"]
)

X.poly <- poly(cbind(dta[,"HHR4"], dta[,"pre_goats_owned"], dta[,"geo_dist_mi"], dta[,"GPS_altitude"]), degree=5)

#X.educ.dummies <- model.matrix(~as.factor(dta[,"education"]) - 1)[,-1]

X <- scale(cbind(X.main,X.cont.interactions,X.dummy.interactions,X.poly),center=FALSE,scale=TRUE)

p <- dim(X)[2]

#delta choices, see paper
delta.Y <- 2
delta.D <- 3

# Set up the data for group lasso
#Big matrixes for the grplasso command
Tnew <- matrix(rep(T),nrow=n,ncol=p)
Xnew <- matrix(0,nrow=n,ncol=p*Treatments)
for (t in 0:1) {
  Xnew[,(t*p + 1):((t+1)*p)] <- X*(Tnew==t)
}

grouping.index <- rep(1:p,times=Treatments)    

# Initial Group Lasso fit
#Linear part
#Iterate to find penalty
Y.0.initial <- lm(Y~X.main - 1)$fitted.values
Y.0.initial <- lm(Y~1)$fitted.values
u.bound <- mean( (Y[T==0] - Y.0.initial[T==0])^4 )^(1/4)
x.bound <- max(X)    
for (k in 1:5) {
  lambda.Y <- ( (2*x.bound*u.bound) / (sqrt(min(n.per.treatment)*Treatments)) ) * sqrt(1 + (log(max(p,min(n.per.treatment)))^(3/2 + delta.Y))/sqrt(Treatments) )
  fit <- grplasso(Xnew, Y, index=grouping.index, model=LinReg(), lambda = lambda.Y, center=FALSE, control=grpl.control(trace=0))
  S.hat <- sort(union(c(1,3,7,8),which(fit$coefficients[1:p,1]!=0)))
  Y.0.hat <- X[,S.hat]%*%solve(crossprod(X[T==0,S.hat]))%*%crossprod(X[T==0,S.hat],Y[T==0])
  u.bound <- mean( (Y[T==0] - Y.0.hat[T==0])^4 )^(1/4)
}
#Estimation
fit.grplasso <- grplasso(Xnew, Y, index=grouping.index, model=LinReg(), lambda = lambda.Y, center=FALSE, control=grpl.control(trace=0))

S.hat.Y <- sort(union(c(1,3,7,8),which((fit.grplasso$coefficients[1:p])!=0)))


#logit part
#no need to iterate to find lambda if we use u.bound=1
u.bound <- 1	#valid for logit models
lambda.T <- ( (x.bound*u.bound*sqrt(Treatments-1)) / (sqrt(min(n.per.treatment))) ) * sqrt(1 + (log(max(p,min(n.per.treatment)))^(3/2 + delta.D))/sqrt(Treatments-1) )

#Estimation
mlogit.glmnet <- glmnet(X, as.factor(T), family=c("multinomial"), alpha=1, lambda=lambda.T/(n*(Treatments-1)), intercept=TRUE, type.multinomial="grouped")
S.hat.T <- sort(union(c(1,3,7,8),as.numeric(predict(mlogit.glmnet, type="nonzero")$'s0')))



# Post selection refitting
S.hat.Y.more <- S.hat.Y
S.hat.T.more <- S.hat.T

#Linear part
Y.0.more.noUnion <- X[,S.hat.Y]%*%(solve(crossprod(X[T==0,S.hat.Y]))%*%crossprod(X[T==0,S.hat.Y],Y[T==0]))

#logit part
p.1.more.noUnion <- multinom(T~X[,S.hat.T]-1, trace=FALSE)$fitted.values

#Impose common support
indexes.to.drop <- which(p.1.more.noUnion < min(p.1.more.noUnion[T==1]) | max(p.1.more.noUnion[T==1]) < p.1.more.noUnion)
if (length(indexes.to.drop)==0) {indexes.to.drop <- n+1}	#R throws a wobbly if [-indexes.to.drop] is negating an empty set. 
n.per.treatment.more.noUnion <- as.vector(table(T[-indexes.to.drop]))
n.trim <- n.per.treatment.more.noUnion[1]+n.per.treatment.more.noUnion[2]


#Treatment Effects on the Treated
p.1 <- n.per.treatment.more.noUnion[2]/n.trim
mu01.eif.more.noUnion <- mean((T[-indexes.to.drop]==1)*Y.0.more.noUnion[-indexes.to.drop]) + mean((T[-indexes.to.drop]==0)*p.1.more.noUnion[-indexes.to.drop]*(Y[-indexes.to.drop] - Y.0.more.noUnion[-indexes.to.drop])/(1-p.1.more.noUnion[-indexes.to.drop]))
mu01.eif.more.noUnion <- mu01.eif.more.noUnion/p.1
tot.eif.more.noUnion <- mu11.experimental - mu01.eif.more.noUnion

var.tot.eif.more.noUnion <- mean( (T[-indexes.to.drop]==1)*(Y[-indexes.to.drop] - Y.0.more.noUnion[-indexes.to.drop] - tot.eif.more.noUnion)^2 )  + mean( (T[-indexes.to.drop]==0)*((Y[-indexes.to.drop] - Y.0.more.noUnion[-indexes.to.drop])^2)*(p.1.more.noUnion[-indexes.to.drop]^2/(1-p.1.more.noUnion[-indexes.to.drop])^2) )
var.tot.eif.more.noUnion <- var.tot.eif.more.noUnion/p.1^2

