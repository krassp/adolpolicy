/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Title X: Data cleaning
Author: Polina Krass krassp@email.chop.edu
Last updated: 1/4/2020
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
***"/Users/apple/Desktop/NCSP/Contraception/Title X/Grantees/Updated extracted data /Cleaned Data.xlsx" 

***FOR 2018***
use "/Users/apple/Desktop/NCSP/Contraception/Title X/Code/titleX2018.dta"
clear
import excel using ///
	"/Users/apple/Desktop/NCSP/Contraception/Title X/Grantees/Updated extracted data /Cleaned Data.xlsx", ///
	sheet("2018") firstrow case(lower)

*clean dataset*/
drop grantee 
drop subrecipient 
drop servicesite
drop phone
drop q
rename unformattedphone phone 

***make all lowercase
replace name=lower(name)
replace category=lower(category)
replace staddress =lower(staddress)
replace city=lower(city)
replace state=lower(state)

***reorder
order id name city state 

***drop non-service sites
drop if category=="grantee"
drop if extra=="duplicate"
***drop if category=="sub-recipient"

***standardize name
stnd_compname name, gen(stn_name stn_dbaname stn_fkaname entitytype attn_name) ///
patpath(/Users/apple/Desktop/NCSP/Contraception/Title X/Pattern)
drop stn_dbaname stn_fkaname entitytype attn_name
rename name namefull
rename stn_name name_2018
replace name_2018=lower(name_2018)

***standardize address
stnd_address staddress, gen(add1 pobox unit bldg floor) ///
patpath(/Users/apple/Desktop/NCSP/Contraception/Title X/Pattern)
drop pobox unit bldg floor
replace add1=lower(add1)
rename add1 address_2018
rename staddress address_full

***order
order id_2018 name_2018 address_2018 
order address_full namefull, last
format phone %10.0f

/***send to excel - no affiliation
cd "/Users/apple/Desktop/NCSP/Contraception/Title X/Output"  
outsheet id_2018 name_2018 address_2018 city state zip phone address_full extra parent using 2018_cleaned.csv, comma replace*/
  
***save
save "/Users/apple/Desktop/NCSP/Contraception/Title X/Code/titleX2018.dta", replace


/***FOR 2020****/
use "/Users/apple/Desktop/NCSP/Contraception/Title X/Code/titleX2020.dta"
clear
import excel using ///
	"/Users/apple/Desktop/NCSP/Contraception/Title X/Grantees/Updated extracted data /Cleaned Data.xlsx", ///
	sheet("2020") firstrow case(lower)

*clean
drop phone unmatched
rename unformattedphone phone_2020
rename zip zip_2020

***make all lowercase, rename
g name_2020=lower(trimmedname)
drop name
g category_2020=lower(category)
drop category
g address_2020=lower(staddress)
drop staddress
g city_2020=lower(city)
drop city
g state_2020=lower(state)
drop state

format phone_2020 %10.0f
  
order id name city state phone zip   

***drop grantee
drop if category=="grantee"
drop if extra=="duplicate"
***CHECK THAT 100 WAS DROPPED
***drop if category=="sub-recipient"

***standardize name
stnd_compname name_2020, gen(stn_name stn_dbaname stn_fkaname entitytype attn_name) ///
patpath(/Users/apple/Desktop/NCSP/Contraception/Title X/Pattern)
drop stn_dbaname stn_fkaname entitytype attn_name
drop trimmedname
rename name_2020 namefull_2020
rename stn_name name_2020
replace name_2020=lower(name_2020)

***standardize address
stnd_address address_2020, gen(add1 pobox unit bldg floor) ///
patpath(/Users/apple/Desktop/NCSP/Contraception/Title X/Pattern)
drop pobox unit bldg floor
rename address_2020 address_full2020
replace add1=lower(add1)
rename add1 address_2020

/***export to excel 
cd "/Users/apple/Desktop/NCSP/Contraception/Title X/Output"  
outsheet id_2020 name_2020 address_2020 city state zip phone_2020 address_full parent using 2020_cleaned.csv, comma replace*/
  
***save
save "/Users/apple/Desktop/NCSP/Contraception/Title X/Code/titleX2020.dta", replace

***next-> affiliate clinics using affiliation.do

