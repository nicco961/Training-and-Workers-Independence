clear

use "C:\Users\nicco\OneDrive\Desktop\Firm Organization and Production in developing countries\final data\dataset with shifts.dta"

gen mainteinance_delay = total_delays - unexpected_delay_time

drop if mainteinance_delay > 240

drop if date>mdy(3,31,2003) | team == .

keep if date>mdy(6,15,2000) & date<mdy(6,15,2002)

set scheme cleanplots


cd "C:\Users\nicco\OneDrive\Desktop\Firm Organization and Production in developing countries\results\regression_results\no long delays"





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
sum blooms_rolled blooms_rolled_per_workers perc_cobbled unexpected_delay if date>mdy(6,1,2000) & date<mdy(6,1,2001)

drop if date < mdy(6,1,2000)
drop if date > mdy(6,1,2002)

tab post struct

gen rolling_rate = (blooms_rolled / (480 - total_delays))




*propensity score weighting

*training, rail


***binary

preserve

keep if struct==0 & _weight!=.

reg rolling_rate i.absences_team_head##i.post i.month i.team i.shifts_id  team_tenure team_age workers_control_furnace workers_crane workers_operative_furnace workers_operative_mill workers_plant_attendant workers_re_heating workers_saw_spell workers_SCM_team [w=_w], cluster(team_month) robust

estimate store r5

reg log_blooms_rolled_per_workers i.absences_team_head##i.post i.month i.team i.shifts_id  team_tenure team_age workers_control_furnace workers_crane workers_operative_furnace workers_operative_mill workers_plant_attendant workers_re_heating workers_saw_spell workers_SCM_team [w=_w], cluster(team_month) robust

estimate store r6

reg perc_cobbled i.absences_team_head##i.post i.month i.team i.shifts_id team_tenure team_age workers_control_furnace workers_crane workers_operative_furnace workers_operative_mill workers_plant_attendant workers_re_heating workers_saw_spell workers_SCM_team [w=_w] , cluster(team_month)robust

estimate store r7

reg unexpected_delay i.absences_team_head##i.post i.month i.team i.shifts_id team_tenure team_age workers_control_furnace workers_crane workers_operative_furnace workers_operative_mill workers_plant_attendant workers_re_heating workers_saw_spell workers_SCM_team [w=_w] , cluster(team_month) robust

estimate store r8

esttab r5 r6 r7 r8 using weighted_rail_regression_binary_treat.tex, cells(b(star fmt(3)) se(par fmt(2))) keep(1.absences_team_head 1.post 1.absences_team_head#1.post) replace
restore

*training, structural


***binary

preserve

keep if struct==1 & _weight!=.

reg rolling_rate i.absences_team_head##i.post i.month i.team i.shifts_id team_tenure team_age workers_control_furnace workers_crane workers_operative_furnace workers_operative_mill workers_plant_attendant workers_re_heating workers_saw_spell workers_SCM_team  [w=_w], cluster(team_month) robust

estimate store r13

reg log_blooms_rolled_per_workers i.absences_team_head##i.post i.month i.team i.shifts_id team_tenure team_age workers_control_furnace workers_crane workers_operative_furnace workers_operative_mill workers_plant_attendant workers_re_heating workers_saw_spell workers_SCM_team  [w=_w], cluster(team_month) robust

estimate store r14

reg perc_cobbled i.absences_team_head##i.post i.month i.team i.shifts_id team_tenure team_age workers_control_furnace workers_crane workers_operative_furnace workers_operative_mill workers_plant_attendant workers_re_heating workers_saw_spell workers_SCM_team [w=_w] , cluster(team_month) robust

estimate store r15

reg unexpected_delay i.absences_team_head##i.post  i.month i.team i.shifts_id  team_tenure team_age workers_control_furnace workers_crane workers_operative_furnace workers_operative_mill workers_plant_attendant workers_re_heating workers_saw_spell workers_SCM_team [w=_w] , cluster(team_month) robust

estimate store r16

esttab r13 r14 r15 r16 using weighted_structural_regression_binary_treat.tex, cells(b(star fmt(3)) se(par fmt(2))) keep(1.absences_team_head 1.post 1.absences_team_head#1.post) replace
restore





