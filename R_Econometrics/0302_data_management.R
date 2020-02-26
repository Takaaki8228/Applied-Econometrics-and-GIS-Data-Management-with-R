# We will learn about how to 
# deal with missing value in R


install.packages("mlbench")
install.packages("missForest")
# install.packages("VIM")

library(tidyverse)
library(skimr)
library(missForest)
# library(VIM)
library(mlbench)

# import data from mlbench
data(BostonHousing, package = "mlbench")
# https://www.rdocumentation.org/packages/mlbench/versions/2.1-1/topics/BostonHousing

house <- BostonHousing
names(house)

skim(house)
skim(house) %>% summary()
skim(house, age, dis, ptratio)
# View(house)




# --------------------------------------------
# let's do rename as we often do in Stata
# we use dplyr::rename like last week
# --------------------------------------------

# new_varname = old_varname
house <- house %>%
  dplyr::rename(crime_rate = crim,
                resi_land = zn,
                business = indus,
                river = chas,
                ave_room = rm, 
                distance = dis,
                access_road = rad, 
                race = b)

skim(house)

is.numeric(house$river)
house$river

# sometimes when factor variable is converted into 
# numeric, [0,1] variable becomes [1,2]. 
# to account for this, we first convert into 
# character, then convert to numeric. 
house <- house %>% 
  dplyr::mutate(river = as.numeric(as.character(river)))






# --------------------------------------------
# impute missing values 
# we first create missing values for practice
# --------------------------------------------

# set the seed of R's random number generator
set.seed(123)

# 10% of obs will be replaced by NA (missing)
house.mis <- missForest::prodNA(house, noNA = 0.1)

summary(house.mis)
skim(house.mis) 
# note some mean values: 
# mean of crime_rate is 3.66
# mean of ave_room is 6.26

# impute missing in crime_rate
house.mis <- house.mis %>%
  dplyr::mutate_at(vars(crime_rate),
            funs(if_else(is.na(.), mean(., na.rm = T), .)))

skim(house.mis) 
# missings in crime_rate is imputed, 
# and mean of crime_rate is still 3.66!


# impute missing in ave_room
house.mis <- house.mis %>%
  dplyr::mutate_at(vars(ave_room),
            funs(if_else(is.na(.), mean(., na.rm = T), .)))

skim(house.mis) 
# as in crime_rate, mean value is kept at previous level!



# we can apply this to multiple variables 
# by repeating mutate_at
house.mis <- house.mis %>%
  dplyr::mutate_at(vars(resi_land),
            funs(if_else(is.na(.), mean(., na.rm = T), .))) %>%
  dplyr::mutate_at(vars(business),
            funs(if_else(is.na(.), mean(., na.rm = T), .)))

skim(house.mis) 




# let's work on dummy variable

house.mis %>% count(river)

house.mis %>% select(river) %>%
  summary()
  
house.mis <- house.mis %>%
  dplyr::mutate_at(vars(river),
                   funs(if_else(is.na(.), mean(., na.rm = T), .)))

skim(house.mis) 

