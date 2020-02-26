# We use the DHS for this practice

library(haven)               # for haven::read_dta
library(tidyverse)
library(skimr)
library(estimatr)
library(stargazer)

setwd("~/Documents/GitHub/gis-data/health_data")
dhs <- haven::read_dta("BFKR62FL.dta")  # when inporting a stata file directly

dhs <- dhs %>%
  dplyr::select(b8, hw5, hw8, hw11, v001, v024, 
                v106, v136, v151, v152, v218, v190)

# create dummy variables

dhs %>% dplyr::count(v106)
dhs %>% count(v151)
dhs %>% count(v190)


dhs <- dhs %>%
  dplyr::mutate(high_educ = ifelse(v106 == 3,1,0),
                second_educ = ifelse(v106 == 2,1,0),
                prim_educ = ifelse(v106 == 1,1,0),
                
                femaleHH = ifelse(v151 == 2,1,0), 
                
                richest = ifelse(v190 == 5,1,0),
                richer = ifelse(v190 == 4,1,0),
                middle = ifelse(v190 == 3,1,0),
                poorer = ifelse(v190 == 2,1,0)
                )
            
dhs %>% count(prim_educ)

skim(dhs) 

# same result as "su hhsize-poorer" in Stata
dhs %>%
  dplyr::summarise(high_educ = mean(high_educ),
                   second_educ = mean(second_educ),
                   prim_educ = mean(prim_educ),
                   
                   richest = mean(richest),
                   richer = mean(richer),
                   middle = mean(middle),
                   poorer = mean(poorer),
                   observation = dplyr::n()
                   )


dhs <- dhs %>%
  dplyr::rename(haz = hw5,
                waz = hw8,
                whz = hw11,
                cluster = v001,
                region = v024, 
                hhsize = v136,
                ageHH = v152,
                n_of_child = v218,
                age = b8) %>%
  dplyr::select(-v106, -v151, -v190)






# --------------------------------------------
# reg haz high_educ second_educ prim_educ richest richer // 
# middle poorer hhsize ageHH n_of_child femaleHH age
# --------------------------------------------


# equation (1)
reg1 <- lm(
  haz ~ high_educ + second_educ + prim_educ + richest +
    richer + middle + poorer + hhsize + ageHH + 
    n_of_child + femaleHH + age,
  data = dhs) 

# present the results 
# (obviously?) the result is identical to equation (1) in Stata
summary(reg1) 
stargazer(reg1, type = "text")
stargazer(reg1)



# equation (2)
# use robust SE like "~, r" in Stata
reg2 <- estimatr::lm_robust(
  haz ~ high_educ + second_educ + prim_educ + richest +
    richer + middle + poorer + hhsize + ageHH + 
    n_of_child + femaleHH + age,
  se_type = "stata",
  data = dhs) 

# exactly same as the Stata result in equation (2) in do file
summary(reg2) 
coef(summary(reg2))



# equation (3)
reg3 <- estimatr::lm_robust(
  haz ~ high_educ + second_educ + prim_educ + richest +
    richer + middle + poorer + hhsize + ageHH + 
    n_of_child + femaleHH + age,
  fixed_effects = ~ cluster,
  clusters = cluster, 
  se_type = "stata",
  data = dhs) 

# coefs are exactly same as in Stata,
# but SEs are slightly different
summary(reg3) 









# --------------------------------------------
# Appendix
# When creating dummy variables, we have to be 
# very careful about how to deal with missing values
# Particularly, imputation is necessary
# --------------------------------------------

# For example, we can use impute command in Stata
# Suppose we have a variable college (college dummy)
# following four sentences can do this.

### gen one = 1
### impute college one, gen(college1) 
### drop college
### rename college1 college

dhs <- haven::read_dta("BFKR62FL.dta")  # when inporting a stata file directly

dhs <- dhs %>%
  dplyr::select(b8, hw5, hw8, hw11, v001, v024, 
                v106, v136, v151, v152, v218, v190) 
  
# in Stata: table v106 
dhs %>% dplyr::count(v106)


# create dummy variables 
# value 9 is missing in v106 (perhaps)
dhs <- dhs %>%
  dplyr::mutate(high_educ = ifelse(v106 == 3,1,
                            ifelse(v106 == 9,NA,0)),
                second_educ = ifelse(v106 == 2,1,
                              ifelse(v106 == 9, NA,0)),
                prim_educ = ifelse(v106 == 1,1,
                            ifelse(v106 == 9,NA,0)),
                # No education is reference
                femaleHH = ifelse(v151 == 2,1,0), 
                
                richest = ifelse(v190 == 5,1,0),
                richer = ifelse(v190 == 4,1,0),
                middle = ifelse(v190 == 3,1,0),
                poorer = ifelse(v190 == 2,1,0)
  )

# in Stata: table high_educ (and so on)
dhs %>% count(high_educ)
dhs %>% count(high_educ, second_educ)
dhs %>% count(high_educ, second_educ, prim_educ)

# in Stata: sort high_educ
# we see that last five obs have NA in education dummies
dhs <- dhs %>%
  dplyr::arrange(high_educ)
