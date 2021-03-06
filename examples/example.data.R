\dontrun{
require(MASS)

nsubj <- 40             # number of participants
nobs <- 30              # number of observations per cell
ncont <- 1              # number of continuous IVs
ncat <- 1               # number of categorical IVs
ntrials <- nobs * ncont * ncat #total number of trials per subject
xcont <- seq(1,5,1)     # values of continuous IV
xcont.mc <- xcont-mean(xcont) # mean-centered values of continuous IV
xcat <- c(-.5,.5)             # Simple coded categorical IV
eff.size.cont <- c(0.3)       # effect size of continuous IV
eff.size.cat <- c(0.8)       # effect size of categorical IV
eff.size.interaction <- c(0)  # effect size of interaction
correlation.predictors <- 0.5     # correlation between b<-subject slopes of the two predictors
intercept <- 0          # grand intercept
error.sd <- 1           # standard deviation of error term

#-------------------------
#  Create Simulated Data -
#-------------------------
#  correlation between by-subject continuous slope, and by-subject categorical slope
subj.cont1.cat1.corr <- mvrnorm(n = nsubj,
                                mu = c(eff.size.cont,eff.size.cat),
                                Sigma = matrix(data = c(1,correlation.predictors,
                                                        correlation.predictors,1),
                                               nrow = 2, ncol = 2, byrow = TRUE),
                                empirical = TRUE)

b.cont.subj <- data.frame(subject = 1:nsubj, vals = subj.cont1.cat1.corr[,1])
b.cat.subj <- data.frame(subject = 1:nsubj, vals = subj.cont1.cat1.corr[,2])
b.subj.rand <- data.frame(subject = 1:nsubj, vals = rnorm(n = nsubj, mean = 0, sd = 1))
b.ia.subj <- data.frame(subject = 1:nsubj, vals = rnorm(n = nsubj,
                                                        mean = eff.size.interaction, sd = 1))

# generate according to lin reg formula
bayesrsdata <- data.frame(subject = rep(1:nsubj, each = ntrials),
                          x.time = rep(xcont, each = ntrials/5),
                          x.domain= rep(xcat, each = ntrials/10))

bayesrsdata$y <- 0

for (i in 1:nrow(bayesrsdata)){
  bayesrsdata$y[i] <- b.subj.rand$vals[bayesrsdata$subject[i]==b.subj.rand$subject] +
    bayesrsdata$x.time[i] * (eff.size.cont+b.cont.subj$vals[bayesrsdata$subject[i]==
                                                              b.cont.subj$subject]) +
    bayesrsdata$x.domain[i] * (eff.size.cat+b.cat.subj$vals[bayesrsdata$subject[i]==
                                                              b.cat.subj$subject]) +
    bayesrsdata$x.time[i] * bayesrsdata$x.domain[i] *
    (eff.size.interaction+b.ia.subj$vals[bayesrsdata$subj[i]==b.ia.subj$subject])
}

# add measurement error
bayesrsdata$y <- bayesrsdata$y + rnorm(n = nrow(bayesrsdata), mean = 0, sd = 1)

# create final data set
recvars <- which(names(bayesrsdata) %in% c("subject", "item", "x.domain"))
bayesrsdata[,recvars] <- lapply(bayesrsdata[,recvars], as.factor)

save(bayesrsdata, file= "bayesrsdata.rda")

}
