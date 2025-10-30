clear

use "C:\Users\nicco\OneDrive\Desktop\Firm Organization and Production in developing countries\final data\dataset with shifts.dta"

drop if total_delays==480

drop if date>mdy(3,31,2003) | team == .

keep if date>mdy(6,15,2000) & date<mdy(6,15,2002)

gen post = 1 if date > mdy(6,15,2001)
replace post = 0 if post == .

gen pscore_exact_match = .
gen exact_nnm = .
egen group = group(team)
levels g, local(gr)

keep if struct == 0

foreach j of num 1/3 { 
                psmatch2 absences_team_head workers_crane workers_operative_furnace workers_operative_mill workers_plant_attendant workers_saw_spell workers_SCM_team i.month  if g==`j', neighbor(1) noreplacement
                replace pscore_exact_match  = _pscore if  g==`j'
				replace exact_nnm  = _weight if  g==`j'
        }
        

*post matching stats

drop _weight

gen _weight = 1/(1-pscore_exact_match) if absences_team_head == 0

replace _weight = 1/(pscore_exact_match) if absences_team_head == 1


*****************regressions*******************

xtset team date

gen log_blooms_rolled_per_workers = log(blooms_rolled_per_workers)

gen production_stock_per_worker = production_stock/floor_workers

gen log_unexpected_delay = log(unexpected_delay+1)



******************************************
*
*
******************************************
cd "C:\Users\nicco\OneDrive\Desktop\Firm Organization and Production in developing countries\results\regression_results\exact matching"
*
*
******************************************


gen rolling_rate = blooms_rolled / (480 - total_delays)


*nnm regression


***binary

preserve

keep if exact_nnm == 1



reg rolling_rate i.absences_team_head##i.post i.month i.team i.shifts_id team_tenure team_age workers_control_furnace workers_crane workers_operative_furnace workers_operative_mill workers_plant_attendant workers_re_heating workers_saw_spell workers_SCM_team, cluster(team_month) robust

estimate store r5

reg log_blooms_rolled_per_workers i.absences_team_head##i.post  i.month i.team i.shifts_id  team_tenure team_age workers_control_furnace workers_crane workers_operative_furnace workers_operative_mill workers_plant_attendant workers_re_heating workers_saw_spell workers_SCM_team, cluster(team_month) robust

estimate store r6

reg perc_cobbled i.absences_team_head##i.post i.month i.team i.shifts_id team_tenure team_age workers_control_furnace workers_crane workers_operative_furnace workers_operative_mill workers_plant_attendant workers_re_heating workers_saw_spell workers_SCM_team, cluster(team_month)robust

estimate store r7

reg unexpected_delay i.absences_team_head##i.post i.month i.team i.shifts_id team_tenure team_age workers_control_furnace workers_crane workers_operative_furnace workers_operative_mill workers_plant_attendant workers_re_heating workers_saw_spell workers_SCM_team, cluster(team_month) robust

estimate store r8

esttab r5 r6 r7 r8 using exact_team_nnm_rail_regression_binary_treat.tex, cells(b(star fmt(3)) se(par fmt(2))) keep(1.absences_team_head 1.post 1.absences_team_head#1.post) replace
restore
