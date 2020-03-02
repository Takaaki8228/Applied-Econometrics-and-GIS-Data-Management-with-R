# summary of basic data management: Stata to R (mostly using dplyr)


# --------------------------------------------
# Note for this script
# Stata code that are the same operation are written in "###" columns
# --------------------------------------------


data(BostonHousing, package = "mlbench")
# https://www.rdocumentation.org/packages/mlbench/versions/2.1-1/topics/BostonHousing

library(mlbench)
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
house %>% count(chas)
house %>% count(access_road)

### Stata: sum house
# skimr::skim
skim(house)

skim(house) %>% summary()

### Stata: sum house age distance ptratio
skim(house, age, dis, ptratio)

# dplyr::summarise
house %>%
  summarise(age = mean(age),
            ptratio = mean(ptratio),
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
  group_by(dis) %>%
  summarise_each(funs(n(), mean, sd, min, max), 
                 ptratio)
  





# --------------------------------------------
# generate variables, drop, etc
# --------------------------------------------

# dplyr::rename
# new_varname = old_varname
### rename crim crime_rate
### rename zn resi_land
# and so on
house <- house %>%
  rename(crime_rate = crim,
         resi_land = zn,
         business = indus,
         river = chas,
         ave_room = rm, 
         distance = dis,
         access_road = rad, 
         race = b)




# dplyr::mutate
# Add new variables 
# Besides selecting sets of existing columns, add new columns (variables) with dplyr::mutate
### Stata: gen high_access = 1 if access_road > 5
house <- house %>%
  mutate(high_access = ifelse(access_road >= 6,1,0))

### Stata: table high_access
house %>% count(high_access)

# Stata: gen crime100 = crime_rate * 100
#        gen teach_crime = crime100 / ptratio
house <- house %>%
  mutate(crime100 = crime_rate * 100,
         teach_crime = crime100 / ptratio)




# dplyr::select
# Stata: drop distance
house <- house %>% 
  select(-distance)
# "keep distance" in Stata is w/o minus sign, "select(distance)"

# Stata: keep crime_rate business river
house1 <- house %>%
  select(crime_rate, business, river)

View(house1)





# --------------------------------------------
# impute missing values 
# --------------------------------------------

library(missForest)

# set the seed of R's random number generator
set.seed(123)

# 10% of obs will be replaced by NA (missing)
house <- missForest::prodNA(house, noNA = 0.1)

# we see that complete_rate is now about 90%
skim(house)


# dplyr::mutate_at
# Stata: impute is the similar command 
# impute all variables instead of river
# "0302_data_management.R" shows more examples
house <- house %>%
  mutate_at(vars(-river),
            funs(if_else(is.na(.), mean(., na.rm = T), .)))

