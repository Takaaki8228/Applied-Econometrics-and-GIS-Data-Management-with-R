# First, we will work on Stata do file "0226_data_gen.do"
# Then, export DHS dta file to csv file
# Although we can inport dta file directly in R by haven::read_dta, 
# region name is encoded implicitly and we cannnot see the actual name 

# library(haven)           # for haven::read_dta
library(tidyverse)
library(skimr)
library(sf)


# let's clear the current environment
rm(list = ls())

setwd("~/Documents/GitHub/gis-data/health_data")
# health <- haven::read_dta("BFKR62FL.dta")  # when inporting dta file directly

# na.strings=c("","NA") specifies empty (missing) values to be NA
health <- read.csv("health_data.csv", na.strings=c("","NA"))
health <- as.data.frame(health)
 
# in Stata: keep hw5 hw8 hw11 v024 v001
health <- health %>%
  dplyr::select(hw5, hw8, hw11, v024, v001) 

# in Stata: rename hw5 haz (and so on)
health <- health %>% 
  dplyr::rename(region = v024,
                cluster = v001,
                haz = hw5,
                waz = hw8,
                whz = hw11)

# summary
skim(health) 

# drop missing values
health <- health %>%
  tidyr::drop_na()

# in Stata: drop if haz==9998 | haz==9999 | whz==9998 ... ctd
# for some reason, haz/waz/whz contain value "Flagged cases".
# we also drop those observations.
health <- health %>% 
  dplyr::filter(haz != 9998,
                haz != 9999,
                waz != 9998,
                waz != 9999,
                whz != 9998,
                whz != 9999,
                haz != "Flagged cases")

is.numeric(health$haz)

health <- health %>% 
  dplyr::mutate(haz = as.numeric(haz),
                waz = as.numeric(waz),
                whz = as.numeric(whz))

# in Stata: collapse (mean) haz-whz, by(region) 
health <- health %>%
  dplyr::group_by(region) %>%
  dplyr::summarise(haz = mean(haz),
                   waz = mean(waz),
                   whz = mean(whz))

# in Stata: table waz
health %>% dplyr::count(waz)

# we actually obtained the exact same data 
# as we can obtain from 0226_data_gen.do in Stata!!!
# (note) the sign is opposite since we used as.data.frame
# for practice we ignore this change




# --------------------------------------------
# now we will combine health data from DHS with shape file
# we use region level data
# --------------------------------------------

setwd("~/Documents/GitHub/gis-data/maping_burkina_faso/BFA_shp")
bf.shape.1 <- st_read("gadm36_BFA_1.shp")
head(bf.shape.1)

# in Stata: keep NAME_1 geometry
bf.shape.1 <- bf.shape.1 %>%
  dplyr::select(NAME_1, geometry) %>%
  dplyr::rename(region = NAME_1)

# we see that three regions have different names in data
health$region
bf.shape.1$region

class(health$region)
health$region <- as.character(health$region)
health[1, "region"] <- "Boucle du Mouhoun"
health[9, "region"] <- "Haut-Bassins"
health[11, "region"] <- "Plateau-Central"

# (when bf.shape.1 is a master file,) in Stata: 
# merge 1:1 region using health (though slightly different)
region.merged <- merge(bf.shape.1, health, by = "region")


# we successfully combined health data with shape file!!!




# --------------------------------------------
# now we will plot maps using the merged file
# today we use ggplot2 instead of tmap we did previous time
# --------------------------------------------


haz <- ggplot(region.merged) + 
  geom_sf(aes(fill = haz), color = "white") +         
  coord_sf(datum = NA) +          # remove grid line
  theme_void()                    # while background

ggsave("~/Documents/GitHub/gis-data/health_data/haz.jpeg", plot = haz)

waz <- ggplot(region.merged) + 
  geom_sf(aes(fill = waz), color = "white") +         
  coord_sf(datum = NA) +          # remove grid line
  theme_void()                    # while background

whz <- ggplot(region.merged) + 
  geom_sf(aes(fill = whz), color = "white") +         
  coord_sf(datum = NA) +          # remove grid line
  theme_void()                    # while background

library(ggpubr)
three.maps <- ggarrange(haz, waz, whz,)
setwd("~/Documents/GitHub/gis-data/health_data")
ggsave("three_maps.jpeg", plot = three.maps)

