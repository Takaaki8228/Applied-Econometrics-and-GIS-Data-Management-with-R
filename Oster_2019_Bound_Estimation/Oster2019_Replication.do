/*

	Oster (2019)
	self-replication 

*/

clear
set more off

global localpath /Users/Takaaki/Documents/Econometrics/Oster2019/DataAnalysis
cd $localpath

* global codepath "./analysis/code"
* global outputfilename "./analysis/output"
global inputfilename "./derived/output"
* global tempfilename "./temp"


*****************************************************************
* Table 2 (Appendix B)
*****************************************************************
program sum_stat_table

	di "Panel A"
	
	use $inputfilename/NLSY_for_IQ.dta
	keep if bf_sample~=. | drink_sample~=. | lbw_sample~=.
	sum iq_std
	sum BF_months mom_drink_preg_all lbw_preterm
	sum age female black motherAge motherEDU mom_married income 
	
	di "Panel B"
	
	use $inputfilename/NLSY_for_BW.dta, clear
	keep if drink_sample~=. | smoke_sample~=.
	sum birth_wt
	sum any_smoke mom_drink_preg_cont
	sum female black motherAge motherEDU mom_married income
	

end

sum_stat_table





*****************************************************************
* Table 3
* Col 1, 2, 5
*****************************************************************

* row 1 of Table 3
global always_control "_Iage_* sex"
global fullcontrols "_Irace_* income motherAge motherEDU mom_married"
	
di as result "Row 1: Breastfeed, IQ"
	
use $inputfilename/NLSY_for_IQ.dta, clear
xi i.age i.race
* preserve
keep if bf_sample~=.

* Baseline Effect (Uncontrolled, without controls)
reg iq_std BF_months $always_control

* Controlled Effect (with full control set)
reg iq_std BF_months $always_control $fullcontrols
local beta = _b[BF_months]
di `beta'
psacalc beta BF_months, mcontrol("$always_control") rmax(.61) delta(1)

/*

	Note on Row 1: 
	1. bias-adjusted treatment effect is in (Beta, Estimate) in - Treatment Effect Estimate -
	2. identified set is (bias-adjusted treatment effect, controlled effect)
	
*/





* row 2 of Table 3 
di as result "Row 2: Drinking, IQ"

use $inputfilename/NLSY_for_IQ.dta, clear
xi i.age i.race

keep if drink_sample~=.

reg iq_std mom_drink_preg_all $always_control
reg iq_std mom_drink_preg_all $always_control $fullcontrols	
psacalc beta mom_drink_preg_all, mcontrol("$always_control") rmax(.61) delta(1)





* row 3 of Table 3 
di as result "Row 3: LBW, IQ"

use $inputfilename/NLSY_for_IQ.dta, clear
xi i.age i.race
	
keep if lbw_sample~=.

reg iq_std lbw_preterm $always_control
reg iq_std lbw_preterm $always_control $fullcontrols
psacalc beta lbw_preterm, mcontrol("$always_control") rmax(.61) delta(1)

/*

	Note on Row 3: 
	identified set is (controlled effect, bias-adjusted treatment effect)
					  (-0.125           , -0.033						)
	
	This identified set (bounding set) does not include zero!
	
*/




* row 4 of Table 3 

di as result "Row 4: Smoke, BW"
	
global always_control "sex _Igesweek_*"
global fullcontrols "_Irace_* income motherAge motherEDU mom_married"

use $inputfilename/NLSY_for_BW.dta, clear
xi i.race i.gesweek
	
keep if smoke_sample~=.

reg birth_wt any_smoke $always_control
reg birth_wt any_smoke $always_control $fullcontrols	
* sub_idset birth_wt any_smoke .53
psacalc beta any_smoke, mcontrol("$always_control") rmax(.53) delta(1)





* row 5 of Table 3 
di as result "Row 5: Drink, BW"
	
use $inputfilename/NLSY_for_BW.dta, clear
xi i.race i.gesweek
keep if drink_sample~=.

reg birth_wt mom_drink_preg_cont $always_control
reg birth_wt mom_drink_preg_cont $always_control $fullcontrols	
* sub_idset birth_wt mom_drink_preg_cont .53
psacalc beta mom_drink_preg_cont, mcontrol("$always_control") rmax(.53) delta(1)











********

scalar adj_beta = -0.12 - (1.19 - (-0.12)) * ((1 - 0.825) / 0.825 - 0.24)
disp adj_beta


scalar betaf95=beta_tilde-(beta_c-beta_tilde)*((0.95-R_tilde)/(R_tilde-R_c))
disp betaf95
