
# read csv version of this file (saved from QGIS)
bf.shape.csv <- read.csv("bf.shape.csv")

# same operation
bf.shape.csv <- bf.shape.csv %>%
  dplyr::select(-GID_0, -NAME_0, -GID_1,
                -NL_NAME_1:-GID_3,
                -VARNAME_3:-HASC_3)

bf.shape.csv <- bf.shape.csv %>%
  dplyr::rename(region = NAME_1,
                village = NAME_3)

# check how it works
head(bf.shape.csv)

# check how many variables the bf.shape.csv has
ncol(bf.shape.csv)
# bf.shape.csv now has 9 columns

colnames(bf.shape.csv)
# 9th column is Apr07_mean
# for example, the 9th column has... 
bf.shape.csv[, 9]

# create a new variable and locate in the 10th column
# sum up mean precipitation from January to April

bf.shape.csv[, 10] <- 
  bf.shape.csv[, "Jan07_mean"] + bf.shape.csv[, "Feb07_mean"] + 
  bf.shape.csv[, "Mar07_mean"] + bf.shape.csv[, "Apr07_mean"] 

# check how it works
head(bf.shape.csv)

# change variable name 
colnames(bf.shape.csv)[10] <- "sum_precipitation"




# --------------------------------------------

# merge at the village level: the following is the Stata script
# merge 1:1 village
bf.merged <- merge(bf.shape, bf.shape.csv[, c("village", "sum_precipitation")], by = "village")

head(bf.merged)


# --------------------------------------------



# now work on csv file 

# same as collapse in Stata
bf.shape.csv <- bf.shape.csv %>%
  dplyr::group_by(region) %>%
  dplyr::summarise(January = sum(Jan07_mean),
                   February = sum(Feb07_mean),
                   March = sum(Mar07_mean),
                   April = sum(Apr07_mean))

# change data format
bf.shape.csv.long <- bf.shape.csv %>%
  tidyr::gather(2:5, key = Month, value = value)


# plot
g1 <- ggplot(bf.shape.csv.long,
             aes(x = Month, y = value, group = region,
                 color = as.factor(region)))

g1 <- g1 + geom_line() + 
  geom_point(aes(shape=region), size = 2) +
  xlab("Month") + 
  ylab("Precipitation") + 
  labs(colour="region")

g1 <- g1 + theme_classic(base_size=14) 
g1 <- g1 + theme(legend.position = "bottom", 
                 legend.direction = "horizontal",
                 legend.title = element_text(size = 10),
                 legend.text  = element_text(size = 8),
                 legend.background = element_rect(
                   size=0.5, linetype = "solid", color ="black"),
                 axis.text=element_text(size=10),
                 axis.title=element_text(size=12),
                 # remove the vertical grid lines
                 panel.grid.major.x = element_blank() ,
                 # explicitly set the horizontal lines (or they will disappear too)
                 panel.grid.major.y = element_line(size=.1, color="black"))
g1 <- g1 + scale_x_discrete(limits=c("January", "February", "March", "April"))
plot(g1)
ggsave("precipitation.pdf", plot = g1, width = 7, height = 5)










# save bf.merged as a csv file "bf.shape.csv"
# setwd("~/Documents/GitHub/gis-data/maping_burkina_faso/BFA_shp")
# write.csv(bf.merged, "bf.merged.csv")