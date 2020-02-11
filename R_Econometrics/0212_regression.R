# Data From AER: Applied Econometrics with R (Version 1.2-7)
# https://CRAN.R-project.org/package=AER
# Example from Stock and Watson Chapter 6
# In addition to the textbook, this explains 
# how to cluster the standard error
# like option cluster(cluster) in Stata

# install.packages("AER")
library(AER)

data(CASchools)   

# student teacher ratio
CASchools$STR <- CASchools$students / CASchools$teachers       

# average test score
CASchools$score <- (CASchools$read + CASchools$math)/2