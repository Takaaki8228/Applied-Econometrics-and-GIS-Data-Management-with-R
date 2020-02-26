cd "/Users/takaaki/Documents/GitHub/gis-data/health_data"
use "/Users/takaaki/Documents/GitHub/gis-data/health_data/BFKR62FL.DTA", clear
set more off

outsheet using health_data.csv, comma


/*

	(1) data management: same as gis-data/health_data/0226_health.R

*/

keep hw5 hw8 hw11 v024 v001

rename hw5 haz
rename hw8 waz
rename hw11 whz 
rename v024 region 
rename v001 cluster

drop if haz==9999 | haz==9998 | waz==9999 | waz==9998 | whz==9999 | whz==9998

collapse (mean) haz-whz, by(region) 

* save "/Users/takaaki/Documents/GitHub/gis-data/health_data/0226_burkina.dta", replace

* we will execute these in R






/*

	(2) regression: same as gis-data/R_Econometrics/0226_regression.R

*/

set matsize 800

use "/Users/takaaki/Documents/GitHub/gis-data/health_data/BFKR62FL.DTA", clear
keep b8 hw5 hw8 hw11 v001 v024 v106 v136 v151 v152 v218 v190  

* education 
ta v106, nolab
g high_educ = 1 if v106 == 3
g second_educ = 1 if v106 == 2
g prim_educ = 1 if v106 == 1
replace high_educ = 0 if high_educ == .
replace second_educ = 0 if second_educ == .
replace prim_educ = 0 if prim_educ == .

* female headed HH
ta v151, nolab
g femaleHH = 1 if v151 == 2
replace femaleHH = 0 if femaleHH == .

* wealth 
ta v190, nolab
g richest = 1 if v190 == 5
g richer = 1 if v190 == 4
g middle = 1 if v190 == 3
g poorer = 1 if v190 == 2
replace richest = 0 if richest == . 
replace richer = 0 if richer == . 
replace middle = 0 if middle == . 
replace poorer = 0 if poorer == . 


rename hw5 haz
rename hw8 waz
rename hw11 whz 
rename v001 cluster
rename v024 region 
rename v136 hhsize
rename v152 ageHH
rename v218 n_of_child
rename b8 age

drop v106 v151 v190


* some regressions

su hhsize-poorer

* equation (1)
reg haz high_educ second_educ prim_educ richest richer middle poorer hhsize ageHH n_of_child femaleHH age

* equation (2)
reg haz high_educ second_educ prim_educ richest richer middle poorer hhsize ageHH n_of_child femaleHH age, r

* equation (3)
xtreg haz high_educ second_educ prim_educ richest richer middle poorer hhsize ageHH n_of_child femaleHH age, fe i(cluster) cluster(cluster)

* i.cluster
