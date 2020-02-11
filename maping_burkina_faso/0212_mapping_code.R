# you need "install.packages" only for the first time
# install.packages("sf")
# install.packages("tmap")
# install.packages("tidyverse")
# install.packages("dplyr")
# install.packages("RColorBrewer")
# install.packages("ggplot2")

library(sf)
library(tmap)
library(tidyverse)
library(dplyr)
library(RColorBrewer)
library(ggplot2)

# set your working directly
# you can also select it from the following:
# "Session" -> "Set Working Directly" -> "Choose Directly"
setwd("~/Documents/GitHub/gis-data/maping_burkina_faso/BFA_shp")

# inport a shapefile and name "bf.shape"
bf.shape <- st_read("gadm36_BFA_3.shp")

# see first six rows in the bf.shape data 
head(bf.shape)

# drop unnecessary variables 
# this is identical to the following drop command in Stata
# "drop GID_0 NAME_0 GID_1 NL_NAME_1-GID_3 VARNAME_3 HASC_3"
bf.shape <- bf.shape %>%
  dplyr::select(-GID_0, -NAME_0, -GID_1,
                -NL_NAME_1:-GID_3,
                -VARNAME_3:-HASC_3)

# check how it works
head(bf.shape)

# now change the variable name: in Stata we can run
# rename NAME_1 region
# rename NAME_3 village
bf.shape <- bf.shape %>%
  dplyr::rename(region = NAME_1,
                village = NAME_3)

# check how it works
head(bf.shape)




# --------------------------------------------
# we did this last week (Feb 6)
# plot mean-level nighttime lights 
# --------------------------------------------

# use tmap package
# variable X_mean is a mean precipitation in a certain month
display.brewer.all()

# set breaks
breaks <- c(0, 1, 2, 3, 4, 5, 6, 7, Inf)

tm_shape(bf.shape) + 
  tm_polygons(col = "X_mean",
              breaks = breaks,
              title = "Nighttime Lights", # legend title name 
              border.col = "black",       # border color
              border.alpha = 0.1,         # border thickness
              legend.show = TRUE,  
              palette = "RdBu") +
  tm_layout(frame = FALSE,                # set frame line off
            main.title = "",              # title name empty
            main.title.size = 2.0,      
            main.title.position = c("left","top"),
            # fontfamily = "Times", 
            legend.title.size = 1.6,
            legend.text.size = 1.0,
            legend.position = c("left","top")) + 
  tm_compass(type = "8star",                       # option
             position = c("right", "top"),
             size = 4.5) + 
  tm_scale_bar(position = c("right", "bottom"),    # option
               breaks = c(0, 100, 200, 300),
               text.size = 1.0)
# --------------------------------------------
# --------------------------------------------






# plot precipiration from January to April in 2007

jan <- tm_shape(bf.shape) + 
  tm_polygons(col = "Jan07_mean",
              border.col = "black",       
              border.alpha = 0.1,         
              legend.show = TRUE,  
              palette = "Blues") +
  tm_layout(frame = FALSE,                
            main.title = "",              
            legend.position = c("left","top"))

feb <- tm_shape(bf.shape) + 
  tm_polygons(col = "Feb07_mean",
              border.col = "black",   
              border.alpha = 0.1,     
              legend.show = TRUE,  
              palette = "Blues") +
  tm_layout(frame = FALSE,            
            main.title = "",          
            legend.position = c("left","top"))

mar <- tm_shape(bf.shape) + 
  tm_polygons(col = "Mar07_mean",
              border.col = "black",      
              border.alpha = 0.1,        
              legend.show = TRUE,  
              palette = "Blues") +
  tm_layout(frame = FALSE,               
            main.title = "",             
            legend.position = c("left","top"))

apr <- tm_shape(bf.shape) + 
  tm_polygons(col = "Apr07_mean",
              border.col = "black",      
              border.alpha = 0.1,        
              legend.show = TRUE,  
              palette = "Blues") +
  tm_layout(frame = FALSE,               
            main.title = "",             
            legend.position = c("left","top"))

jpeg("monthly_precipitation.jpeg", height=1920, width=1920, res=288) 
tmap_arrange(jan, feb, mar, apr)
dev.off()


