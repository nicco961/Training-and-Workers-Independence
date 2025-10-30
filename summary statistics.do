clear

use "C:\Users\nicco\OneDrive\Desktop\Firm Organization and Production in developing countries\final data\dataset with shifts.dta"

drop if total_delays==480

drop if date>mdy(3,31,2003) | team == .

keep if date>mdy(6,1,1999) & date<mdy(6,1,2003)

set scheme cleanplots

cd "C:\Users\nicco\OneDrive\Desktop\Firm Organization and Production in developing countries\results\tables"

**absences over time


preserve

keep date absences_team_head
sort date
collapse (mean) absences_team_head, by(date)

tsset date, daily
tssmooth ma ma_absences = absences_team_head, window(90)

reg ma_absences date
predict trend_absences, xb
gen ma_detrended = ma_absences - trend_absences

keep if date>mdy(5,1,2000) & date<mdy(6,1,2002)
lgraph ma_detrended date if date>mdy(7,1,2000), ylabel(-2(1)2) ytitle("Manager Absences") xtitle("Day") tline(01jun2001)

graph export "C:\Users\nicco\OneDrive\Desktop\Firm Organization and Production in developing countries\results\figures\absences_over_time.png", as(png) name("Graph") replace

restore


**workers over time


preserve

keep date team_members
sort date
collapse (mean) team_members, by(date)

tsset date, daily
tssmooth ma ma_members = team_members, window(90)

reg ma_members date
predict trend_members, xb
gen ma_detrended = ma_members - trend_members

keep if date>mdy(6,1,2000) & date<mdy(6,1,2002)
lgraph ma_detrended date if date>mdy(7,1,2000), ylabel(-15(5)15) ytitle("Workers") xtitle("Day") tline(01jun2001)

graph export "C:\Users\nicco\OneDrive\Desktop\Firm Organization and Production in developing countries\results\figures\workers_over_time.png", as(png) name("Graph") replace

restore

****


* Export the summary statistics to LaTeX

keep if date>mdy(6,1,2000) & date<mdy(6,1,2002)

estpost summarize workers_control_furnace workers_crane workers_operative_furnace workers_operative_mill workers_plant_attendant workers_re_heating workers_saw_spell workers_SCM_team workers_services workers_techincians team_age team_tenure team_members blooms_rolled blooms_cobbled unexpected_absences total_delays absences_team_head struct
esttab using "summary_statistics.tex", ///
    cells("mean sd") ///
    label ///
    title("Summary Statistics") ///
    replace

***********************************

eststo clear
eststo noasbsence: quietly estpost summarize blooms_rolled total_delays floor_workers cast_share team_age team_tenure workers_control_furnace workers_crane workers_operative_furnace workers_operative_mill workers_plant_attendant workers_re_heating workers_saw_spell workers_SCM_team workers_services workers_techincians if absences_team_head == 0

eststo absence: quietly estpost summarize blooms_rolled total_delays floor_workers cast_share team_age team_tenure workers_control_furnace workers_crane workers_operative_furnace workers_operative_mill workers_plant_attendant workers_re_heating workers_saw_spell workers_SCM_team workers_services workers_techincians if absences_team_head == 1
esttab, cells("mean sd") label nodepvar		

eststo diff: quietly estpost ttest blooms_rolled total_delays floor_workers team_age cast_share team_tenure workers_control_furnace workers_crane workers_operative_furnace workers_operative_mill workers_plant_attendant workers_re_heating workers_saw_spell workers_SCM_team workers_services workers_techincians, by(absences_team_head)	

cd "C:\Users\nicco\OneDrive\Desktop\Firm Organization and Production in developing countries\results\tables"

*GENERATE TABLE	
esttab noasbsence absence diff using differences_absence_no_absences.tex, cells("mean(pattern(1 1 0) fmt(2)) sd(pattern(1 1 0)) b(star pattern(0 0 1) fmt(2)) p(pattern(0 0 1) par fmt(2))")  label replace



sort team date

******************************************



****time analysis


/*
gen relative_to_training_prod = date - 15145
gen relative_to_training_cost = date - 15300


rdplot blooms_rolled relative_to_training_prod if absences_team_head==1 & blooms_rolled!=0 & struct==0 & date<mdy(1,1,2003) &  date>mdy(1,6,2000) & date<mdy(1,1,2003), c(0) p(2) ci(95) nbins(4 4) graph_options(legend(off) ytitle("Blooms Rolled") xtitle("Days to Productivity Training"))

graph export "C:\Users\nicco\OneDrive\Desktop\Firm Organization and Production in developing countries\results\figures\production_manager_absence.png", as(png) name("Graph") replace

rdplot blooms_rolled relative_to_training_prod if absences_team_head==0 & blooms_rolled!=0 & struct==0 & date>mdy(1,6,2000) & date<mdy(1,1,2003), c(0) p(2) ci(95) nbins(4 4) graph_options(legend(off) ytitle("Blooms Rolled") xtitle("Days to Productivity Training"))

graph export "C:\Users\nicco\OneDrive\Desktop\Firm Organization and Production in developing countries\results\figures\production_no_manager_absence.png", as(png) name("Graph") replace

*/
preserve

keep date production_stock struct
sort date
keep if struct==0
collapse (mean) production_stock, by(date)

tsset date, daily
tssmooth ma ma_struct = production_stock, window(30)

keep if date>mdy(7,1,2000) & date<mdy(6,1,2002)


lgraph ma_struct date if date<mdy(6,1,2002) & date>mdy(6,1,2000), legend(off) ytitle("Average Days in Shift of Productivity Training") xtitle("Day") tline(16jun2001)

graph export "C:\Users\nicco\OneDrive\Desktop\Firm Organization and Production in developing countries\results\figures\production_training_over_time.png", as(png) name("Graph") replace

restore


****production********************************************


preserve

keep date blooms_rolled struct
sort date
keep if struct==1
collapse (mean) blooms_rolled, by(date)

tsset date, daily
tssmooth ma ma_struct = blooms_rolled, window(90)

keep if date>mdy(7,1,2000) & date<mdy(6,1,2002)
lgraph ma_struct date, ylabel(100(25)200) ytitle("Blooms Rolled") xtitle("Day") tline(01jun2001)

graph export "C:\Users\nicco\OneDrive\Desktop\Firm Organization and Production in developing countries\results\figures\structural_production.png", as(png) name("Graph") replace

restore

preserve

keep date blooms_rolled struct
sort date
keep if struct==0
collapse (mean) blooms_rolled, by(date)

tsset date, daily
tssmooth ma ma_struct = blooms_rolled, window(90)

keep if date>mdy(7,1,2000) & date<mdy(6,1,2002)
lgraph ma_struct date, ylabel(100(25)200) xtitle("Day") ytitle("Blooms Rolled") tline(01jun2001)

graph export "C:\Users\nicco\OneDrive\Desktop\Firm Organization and Production in developing countries\results\figures\rail_production.png", as(png) name("Graph") replace

restore



preserve

keep date blooms_rolled struct absences_team_head
sort date
keep if struct==0
keep if absences_team_head == 1
collapse (mean) blooms_rolled, by(date)

sort date
drop if blooms_rolled ==0
gen x = _n

tsset x, daily
tssmooth ma ma_struct = blooms_rolled, window(20)

keep if date>mdy(7,1,2000) & date<mdy(6,1,2002)
lgraph ma_struct date, ylabel(100(25)200) ytitle("Blooms Rolled") xtitle("Day") tline(01jun2001)

sum ma_struct if date>mdy(7,1,2001)
sum ma_struct if date<mdy(7,1,2001)

graph export "C:\Users\nicco\OneDrive\Desktop\Firm Organization and Production in developing countries\results\figures\rail_production_with_absences.png", as(png) name("Graph") replace

restore







