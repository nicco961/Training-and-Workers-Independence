use "C:\Users\nicco\OneDrive\Desktop\Firm Organization and Production in developing countries\cleaned data\training.dta", clear

keep if date > mdy(6,1,2001) & date<mdy(8,1,2001) & training_type == "improve production process"

collapse (sum) time_training, by(p_no)

cd "C:\Users\nicco\OneDrive\Desktop\Firm Organization and Production in developing countries\results\tables"

tab time_training


use "C:\Users\nicco\OneDrive\Desktop\Firm Organization and Production in developing countries\cleaned data\training_stock_individuals.dta", clear

keep if date == mdy(9,1,2001)

replace improve_production_process_stock = 1 if improve_production_process_stock > 0

cd "C:\Users\nicco\OneDrive\Desktop\Firm Organization and Production in developing countries\results\tables"

tab improve_production_process_stock

bysort improve_production_process_stock: sum age

