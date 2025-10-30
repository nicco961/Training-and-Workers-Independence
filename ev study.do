clear

use "C:\Users\nicco\OneDrive\Desktop\Firm Organization and Production in developing countries\final data\dataset with shifts.dta"

drop if total_delays==480

drop if date>mdy(3,31,2003) | team == .

keep if date>mdy(6,15,2000) & date<mdy(6,15,2002)

set scheme cleanplots


*event study regressions*******************
****

*matching

psmatch2 absences_team_head team_tenure team_age workers_control_furnace workers_crane workers_operative_furnace workers_operative_mill workers_plant_attendant workers_re_heating workers_saw_spell workers_SCM_team i.month i.team i.struct if date>mdy(6,15,2000) & date<mdy(6,15,2001), neighbor(1) noreplacement

rename _n1 _n2
rename _treated _treated2

rename  _weight nnm_1
replace _id = _n2 if _n2 != .
sort _id

gen pairs_id = _id if nnm_1 != . 

drop  _support _id  _nn _pdif
rename _pscore pscore

replace pairs_id = pairs_id * 10

psmatch2 absences_team_head team_tenure team_age workers_control_furnace workers_crane workers_operative_furnace workers_operative_mill workers_plant_attendant workers_re_heating workers_saw_spell workers_SCM_team i.month i.team i.struct if date>mdy(6,14,2001) & date<mdy(6,15,2002), neighbor(1) noreplacement 

replace  nnm_1 = _weight if _weight != .

replace _id = _n1 if _n1 != .
sort _id

replace pairs_id = _id if _weight != . 

replace pscore = _pscore if _pscore != .

replace _weight=.






gen post = 1 if date > mdy(6,15,2001)
replace post = 0 if post == .

replace _weight = 1/(1-pscore) if absences_team_head == 0

replace _weight = 1/(pscore) if absences_team_head == 1


*****************regressions*******************

xtset team date

gen log_blooms_rolled_per_workers = log(blooms_rolled_per_workers)

gen production_stock_per_worker = production_stock/floor_workers




******************************************
*
*
******************************************
cd "C:\Users\nicco\OneDrive\Desktop\Firm Organization and Production in developing countries\results\figures"
*
*
******************************************
sum blooms_rolled blooms_rolled_per_workers perc_cobbled unexpected_delay if date>mdy(6,1,2000) & date<mdy(6,1,2001)

drop if date < mdy(6,1,2000)
drop if date > mdy(6,1,2002)

tab post struct

gen rolling_rate = (blooms_rolled / (480 - total_delays))



tab absences_team_head if post == 0
tab absences_team_head if post == 1

total blooms_rolled if post == 0


*training, rail



***binary
*****************************************************
* Combined Event Study Plot: Pre- and Post-Training *
*****************************************************

*--- Pre-training regression ---*
preserve
keep if struct == 0 & post == 0

reg blooms_rolled D_2 x D_4 D_5 D_6 D_7 D_13 ///
    i.month i.team i.shifts_id team_tenure team_age ///
    workers_control_furnace workers_crane workers_operative_furnace ///
    workers_operative_mill workers_plant_attendant workers_re_heating ///
    workers_saw_spell workers_SCM_team [w=_w], cluster(team_month) robust

* Store results
estimates store pre_train

restore

*--- Post-training regression ---*
preserve
keep if struct == 0 & post == 1 & _weight != .

reg blooms_rolled D_2 x D_4 D_5 D_6 D_7 D_13 ///
    i.month i.team i.shifts_id team_tenure team_age ///
    workers_control_furnace workers_crane workers_operative_furnace ///
    workers_operative_mill workers_plant_attendant workers_re_heating ///
    workers_saw_spell workers_SCM_team [w=_w], cluster(team_month) robust

* Store results
estimates store post_train

restore


coefplot ///
    (pre_train, keep(D_2 x D_4 D_5 D_6) label("Pre-training") ///
                msymbol(D) msize(medium) ciopts(recast(rcap))) ///
    (post_train, keep(D_2 x D_4 D_5 D_6) label("Post-training") ///
                msymbol(O) msize(medium) ciopts(recast(rcap))), ///
    rename(D_2 = "-4" x = "-2" D_4 = "0" D_5 = "2" D_6 = "4") ///
    vertical omitted ///
    xtitle("Days from Absence") ///
    ytitle("Change in Output") ///
    yscale(range(-80 40)) ///
    ylabel(-80(20)40, labsize(small)) ///
    xline(2, lpattern(dash) lcolor(black)) ///
    yline(0, lpattern(dash) lcolor(black)) ///
    legend(position(4) ring(0) cols(1) region(lstyle(none))) ///
    scheme(s1color)

graph export "event_study_combined.png", replace





