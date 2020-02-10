# you need to install packages only for the 1st time
install.packages("sf")
install.packages("tmap")
install.packages("dplyr")

library(sf)
library(tmap)
library(dplyr)

# set your working directly
# you can also select it from the following:
# "Session" -> "Set Working Directly" -> "Choose Directly"
setwd("~/Documents/GitHub/gis-data/maping_burkina_faso/BFA_shp")

# inport a shapefile and name "bf.shape"
bf.shape <- st_read("gadm36_BFA_3.shp")

# checkl N of rows 
nrow(bf.shape)

# bf.shape <- bf.shape %>% 
#   dplyr::slice(1:100)

breaks <- c(0, 1, 2, 3, 4, 5, 6, 7, Inf)
jpeg("ave_night_lights.jpeg", height=1920, width=1920, res=288) 
tm_shape(bf.shape) + 
  tm_polygons(col = "X_mean",
              breaks = breaks,
              title = "Nighttime Lights",
              border.col = "black",
              border.alpha = .4,
              legend.show = TRUE) + 
              # palette = rev(terrain.colors(7))) +
  tm_layout(frame = FALSE,
            main.title = "",
            main.title.size = 2.0, 
            main.title.position = c("left","top"),
            fontfamily = "Times", 
            legend.title.size = 1.6,
            legend.text.size = 1.0,
            legend.position = c("left","top")) + 
  tm_compass(type = "8star", 
             position = c("right", "top"),
             size = 4.5) + 
  tm_scale_bar(position = c("right", "bottom"),
               breaks = c(0, 100, 200, 300),
               text.size = 1.0)
dev.off()


