# To use this file as your Rprofile file:
# 1. Copy the file to your project directory
# 2. From within RStudio, rename the file as .Rprofile
# 3. You may add library commands for additional packages you want loaded
# when R starts up. You can also source functions.

# Set the system locale.
# The locale describes aspects of the internationalization of a program.
Sys.setlocale("LC_ALL", "en_US.UTF-8")


# Auto-load packages as R starts up using the library commands below
# Note that the package must be installed BEFORE you can use the library command
library(AER)
library(quantreg)
library(quantmod)
library(dynlm)
library(zoo)
library(rmarkdown)
library(knitr)
library(KernSmooth)
library(ggplot2)
library(reshape2)
library(ggsci)
library(plotly)
library(timeSeries)
library(estimatr)
library(xts)
library(fBasics)
library(tseries)
library(texreg)
library(stargazer)
library(xtable)
library(Hmisc)
library(tidyr)
library(tidyverse)
library(quantreg)
library(KernSmooth)
library(RCurl)
library(quantmod)
library(Quandl)
library(makedummies)
library(MASS)
library(lmtest)
library(Rmisc)
library(forecast)
library(aTSA)
library(rugarch)
library(fGarch)

# Source a function for downloading data from GitHub.
# past the loaction for your function's file into the line below.
# source('~/Dropbox/syncd_r_data/econometrics/toolbox/load_github_data.R')

# Change R's default options
options(prompt="R> ", scipen=999, digits=4, width=70)
