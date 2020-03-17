# summary of basic data management: Stata to R (using dplyr)


# --------------------------------------------
# Note for this script
# Stata code that are the same operation are written in "###" columns
# --------------------------------------------

library(mlbench)

data(BostonHousing, package = "mlbench")
# https://www.rdocumentation.org/packages/mlbench/versions/2.1-1/topics/BostonHousing


library(tidyverse)
library(skimr)

house <- BostonHousing

# show the variable names
names(house)





# --------------------------------------------
# summary statistics
# --------------------------------------------

### Stata: table chas
# dplyr::count
house %>% dplyr::count(chas)
house %>% dplyr::count(rad)

### Stata: sum house
# skimr::skim
skim(house)

skim(house) %>% summary()

### Stata: sum house age distance ptratio
skim(house, age, dis, ptratio)

# dplyr::summarise
house %>%
  dplyr::summarise(age = mean(age),
                   ptratio = sd(ptratio),
                   observation = dplyr::n()
                   )


# dplyr::summarise_each
# most similar to "sum ptratio" in Stata
# but result presented in display look a bit different
house %>% 
  summarise_each(funs(n(), mean, sd, min, max), 
                 ptratio)

# Stata: sum ptratio business tax
house %>% 
  summarise_each(funs(n(), mean, sd, min, max), 
                 ptratio, indus, tax)

# Note: we can select statistics (i.e., mean, ed, etc...)

# dplyr::group_by
house %>% 
  group_by(rad) %>%
  summarise_each(funs(n(), mean, sd, min, max), 
                 ptratio)
  




# --------------------------------------------
# generate variables, drop, keep
# --------------------------------------------

# dplyr::rename
# new_varname = old_varname
### rename crim crime_rate
### rename zn resi_land
# and so on
house <- house %>%
  dplyr::rename(crime_rate = crim,
                resi_land = zn,
                business = indus,
                river = chas,
                ave_room = rm, 
                distance = dis,
                access_road = rad, 
                race = b)

house.renamed <- house  # save as new name for the next practice 


# dplyr::mutate
# Add new variables 
# Besides selecting sets of existing columns, add new columns (variables) with dplyr::mutate
### Stata: gen high_access = 1 if access_road >= 6
###      : replace high_access = 0 if access_road < 6
house <- house %>%
  mutate(high_access = ifelse(access_road >= 6,1,0))

### Stata: gen highest_access = 1 if access_road == 24
###      : replace highest_access = 0 if access_road != 24
house <- house %>%
  mutate(highest_access = ifelse(access_road == 24,1,0))


### Stata: table high_access
house %>% dplyr::count(high_access)


### Stata: gen crime100 = crime_rate * 100
###        gen teach_crime = crime100 / ptratio
house <- house %>%
  mutate(crime100 = crime_rate * 100,
         teach_crime = crime100 / ptratio)




# dplyr::select
### Stata: drop distance
house <- house %>% 
  dplyr::select(-distance)
# "keep distance" in Stata is w/o minus sign, "select(distance)"


### Stata: keep crime_rate business river
house1 <- house %>%
  dplyr::select(crime_rate, business, river)


# dplyr::filter
### Stata: keep access_road == 4
house2 <- house %>%
  dplyr::filter(access_road == 4)

### Stata: keep if crime_rate > 0.2 & crime_rate < 0.4
house2 <- house %>%
  dplyr::filter(crime_rate > 0.2, crime_rate < 0.4)


# --------------------------------------------
# impute missing values 
# --------------------------------------------

library(missForest)

# set the seed of R's random number generator
set.seed(123)

# 10% of obs will be replaced by NA (missing)
house <- missForest::prodNA(house.renamed, noNA = 0.1)

# we see that complete_rate is now about 90%
skim(house)


### Stata: drop crime_rate == "NA"
house <- house %>%
  dplyr::filter(crime_rate != "NA")


# re-create missing values in house.renamed data
set.seed(123)
house <- missForest::prodNA(house.renamed, noNA = 0.1)


# dplyr::mutate_at
### Stata: impute is the similar command but not exactly the same
# impute all variables except river
# ("0302_data_management.R" shows more examples)
house <- house %>%
  mutate_at(vars(-river),
            funs(if_else(is.na(.), mean(., na.rm = T), .)))

class(house$river)
# because river is  factor variable, we need to covert it into numeric
house <- house %>% 
  dplyr::mutate(river = as.numeric(as.character(river)))

# (sometimes) when factor variable is converted into numeric, [0,1] variable becomes [1,2]. 
# to account for this problem, we first convert variable into character, then convert to numeric. 

house <- house %>%
  mutate_at(vars(river),
            funs(if_else(is.na(.), mean(., na.rm = T), .)))
