# Data From AER: Applied Econometrics with R (Version 1.2-7)
# https://CRAN.R-project.org/package=AER

# this file explains basic data management
# some examples come from Stock & Watson Ch.6

# install.packages("AER")
# install.packages("skimr")

setwd("~/documents/GitHub/gis-data/R_Econometrics")

library(AER)
library(skimr)
library(tidyverse)

data(CASchools)   

# see what data look like
head(CASchools)

# student teacher ratio
CASchools$STR <- CASchools$students / CASchools$teachers       

# average test score
CASchools$score <- (CASchools$read + CASchools$math)/2



# --------------------------------------------
# there are several ways to show summary statistics
# summarize by default, corresponding to sum in Stata
# but hard to see in detail
summary(CASchools)

# see the dimension of the data
dim(CASchools)

# much better than summary()
skim(CASchools) 
skim(CASchools) %>% summary()

# select the variables of income, read, math
# similar to "sum income read math" in Stata
skim(CASchools, income, read, math)

CASchools %>% dplyr::group_by(grades) %>% skim()

# show each test score by each grade
CASchools %>%
  dplyr::group_by(grades) %>%
  dplyr::summarise(average_read = mean(read), 
            average_math = mean(math),
            average_score = mean(score),
            observation = dplyr::n())





# --------------------------------------------
# let's try to plot bar graph

# same as collapse in Stata
cas.county <- CASchools %>%
  dplyr::group_by(county) %>%
  dplyr::summarise(Math = mean(math))


g1 <- ggplot(cas.county, aes(x = county, 
                             y = Math, 
                             fill = county)) 
g1 <- g1 + geom_bar(stat = "identity") +
  ylab("Average Math Score")
g1 <- g1 + theme_classic(base_size=13) 
g1 <- g1 + theme(axis.title.x = element_blank(),
                 axis.title = element_text(size=16),
                 axis.text.x = element_text(angle = 40, 
                                            size = 8,
                                            face = "bold"),
                 axis.text.y = element_text(size = 14),
                 plot.margin = unit(c(0, 0, -8, 0), "mm"), 
                 # remove the vertical grid lines
                 panel.grid.major.x = element_blank() ,
                 # explicitly set the horizontal lines (or they will disappear too)
                 panel.grid.major.y = element_line(size=.1, color="black"), 
                 legend.position = "none")
plot(g1)
ggsave("math_score.pdf", plot = g1, width = 10, height = 5)

