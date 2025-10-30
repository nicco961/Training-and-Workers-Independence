clear

use "C:\Users\nicco\OneDrive\Desktop\Firm Organization and Production in developing countries\final data\dataset with shifts.dta"

drop if total_delays==480

drop if date>mdy(3,31,2003) | team == .

set scheme cleanplots

keep if date>mdy(6,15,2000) & date<mdy(6,15,2002)

drop if struct == 1


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




*****************regressions*******************

xtset team date

gen log_blooms_rolled_per_workers = log(blooms_rolled_per_workers)

gen production_stock_per_worker = production_stock/floor_workers

gen log_unexpected_delay = log(unexpected_delay+1)

gen post=1 if date>mdy(6,15,2001)
replace post = 0 if post == .

******************************************
*
*
******************************************
cd "C:\Users\nicco\OneDrive\Desktop\Firm Organization and Production in developing countries\results\regression_results\matching"
*
*
******************************************

gen rolling_rate = blooms_rolled / (480 - total_delays)


**************************

*nnm regression


***binary

preserve

keep if pairs_id != .


reg rolling_rate i.absences_team_head##i.post i.month i.team i.shifts_id team_tenure team_age workers_control_furnace workers_crane workers_operative_furnace workers_operative_mill workers_plant_attendant workers_re_heating workers_saw_spell workers_SCM_team, cluster(team_month) robust

estimate store r5

reg log_blooms_rolled_per_workers i.absences_team_head##i.post i.month i.team i.shifts_id  team_tenure team_age workers_control_furnace workers_crane workers_operative_furnace workers_operative_mill workers_plant_attendant workers_re_heating workers_saw_spell workers_SCM_team , cluster(team_month) robust

estimate store r6

reg perc_cobbled i.absences_team_head##i.post i.month i.team i.shifts_id team_tenure team_age workers_control_furnace workers_crane workers_operative_furnace workers_operative_mill workers_plant_attendant workers_re_heating workers_saw_spell workers_SCM_team, cluster(team_month)robust

estimate store r7

reg unexpected_delay i.absences_team_head##i.post i.month i.team i.shifts_id team_tenure team_age workers_control_furnace workers_crane workers_operative_furnace workers_operative_mill workers_plant_attendant workers_re_heating workers_saw_spell workers_SCM_team, cluster(team_month) robust

estimate store r8

esttab r5 r6 r7 r8 using nnm_rail_regression_binary_treat.tex, cells(b(star fmt(3)) se(par fmt(2))) keep(1.absences_team_head 1.post 1.absences_team_head#1.post) replace
restore
