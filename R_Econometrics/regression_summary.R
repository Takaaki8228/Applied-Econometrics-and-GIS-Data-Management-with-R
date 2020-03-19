# Code for regression analysis (summary)

# install.packages("wooldridge")
# install.packages("stargazer")
# install.packages("lfe")
# install.packages("estimatr")
# install.packages("ivpack")

library(wooldridge)
library(stargazer)
library(lfe)
library(estimatr)
library(ivpack)



# clear all variables
rm(list=ls())



# --------------------------------------------
# OLS
# --------------------------------------------

# import data
wage <- wooldridge::wagepan
# https://www.rdocumentation.org/packages/wooldridge/versions/1.3.1
# https://www.rdocumentation.org/packages/wooldridge/versions/1.3.1/topics/wagepan

# difference in means
# exper: labor mkt experience
# hisp: =1 if Hispanic
exper_hisp <- with(wage, mean(exper[hisp == 1]))
exper_nonhisp <- with(wage, mean(exper[hisp == 0]))

diff_mean <- exper_hisp - exper_nonhisp
diff_mean

# t-statistic
t.test(exper ~ hisp, data=wage, var.equal=TRUE)
t.test(lwage ~ hisp, data=wage, var.equal=TRUE)
t.test(lwage ~ union, data=wage, var.equal=TRUE)

reg1 <- lm(lwage ~ union, data = wage) 
reg2 <- lm(lwage ~ union + educ + black + hisp + exper + expersq + married, data = wage)
# fixed effect
reg3 <- felm(lwage ~ union + expersq + married | nr + year, data = wage)

stargazer(reg1, type = "text")
stargazer(reg2, type = "text")
stargazer(reg3, type = "text")

stargazer(reg1, reg2, reg3, type = "text")


## import data
data(card.data)
card <- card.data

# fixed effect
reg4 <- felm(lwage ~ educ + exper + expersq + black + smsa + south | region, data = card) 
# cluster-robust standard error
reg5 <- felm(lwage ~ educ + exper + expersq + black + smsa + south | region | 0 | region, data = card) 
# compare SEs
stargazer(reg4, reg5, type = "text")





# --------------------------------------------
# IV
# --------------------------------------------

# import data
setwd("~/Documents/GitHub/gis-data/R_Econometrics")
# Data from Mastering 'Metrics.
# Angrist and Krueger (QJE 1991)
# IV analysis of the returns to schooling using  
# quarters of birth (QOB) as instruments for years of schooling
qob <- haven::read_dta("ak91.dta")


# make qob dummies
qob.f <- factor(qob$qob)

# model.matrix automatically converts factor into 
# a dummy variable (decomposed into separate columns)
q <- model.matrix(~qob.f + 0)
qob <- cbind(qob,q)

# (IV) regression 
# lnw: weekly wage
# s: education of the ith individual
# y ~ x1 + x2 + x3 | z + x2 + x3
# (z is the instrument)
reg1 <- lm(lnw ~ qob.f4, data = qob) 
reg2 <- lm(s ~ qob.f4, data = qob) 
reg3 <- ivreg(lnw ~ s | qob.f4, data = qob)
reg4 <- lm(lnw ~ s, data=qob)
reg5 <- ivreg(lnw ~ s + yob | qob.f4 + yob, data = qob)

summary(reg5)

# estimatr::iv_robust estimates an iv regression 
# using 2SLS with robust standard errors.

# e.g.,
# iv1 <- iv_robust(y ~ x1 + x2 + x3 | z + x2 + x3,
#                  clusters = cluster, se_type = "CR0", 
#                  data = your_data)

iv1 <- iv_robust(lnw ~ s | qob.f4, 
                 se_type = "stata",
                 data = qob)

summary(iv1)
