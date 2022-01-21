/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Affiliations
krassp@email.chop.edu
Last updated: 4/12/2021
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
****import 2018 affiliations
cd "/Users/apple/Desktop/NCSP/Contraception/Title X/Code/"  
use "affiliations.dta"
clear
import excel using ///
	"/Users/apple/Desktop/NCSP/Contraception/Title X/FQHC/Affiliations_Master.xlsx", sheet("2018 all") firstrow

drop affiliation
rename finalaffiliation affiliation	
drop aff_cat
	
g aff_cat=.
replace aff_cat=0 if affiliation=="fqhc"
replace aff_cat=1 if affiliation=="school"
replace aff_cat=2 if affiliation=="hospital"
replace aff_cat=3 if affiliation=="publichealth"
replace aff_cat=4 if affiliation=="university"
replace aff_cat=5 if affiliation=="plannedparenthood"
replace aff_cat=6 if affiliation=="justice"
replace aff_cat=7 if affiliation=="socservices"
replace aff_cat=8 if affiliation=="homeless"
replace aff_cat=10 if affiliation=="nonprofit"
replace aff_cat=11 if affiliation=="" | affiliation=="unknown"
label define afflabel 0 fqhc 1 school 2 hospital 3 publichealth 4 university 5 plannedparenthood 6 justice 7 socservice 8 homeless 9 CBO 10 nonprofit 11 unknown
label values aff_cat afflabel 	
tab2 affiliation aff_cat, miss 
keep id_2018 name_2018 aff_cat

****label 2018 fqhc or not fqhc
gen fqhc=. 
replace fqhc=1 if aff_cat==0
tab2 fqhc aff_cat, miss
replace fqhc=0 if aff_cat==10 | aff_cat==2 | aff_cat==5 | aff_cat==11
tab2 fqhc aff_cat, miss 

cd "/Users/apple/Desktop/NCSP/Contraception/Title X/Code/"  
save "affiliations.DTA", replace

****add new affiliations

cd "/Users/apple/Desktop/NCSP/Contraception/Title X/Code/"  
use "affiliations2.dta"
clear
import excel using ///
	"/Users/apple/Desktop/NCSP/Contraception/Title X/Affiliations/affiliations_full.xls", firstrow

order anyfqhc affiliation aff_cat fqhc

rename aff_cat affiliation2
drop anyfqhc
	
g aff_cat=.
replace aff_cat=0 if affiliation=="fqhc"
replace aff_cat=1 if affiliation=="school"
replace aff_cat=2 if affiliation=="hospital"
replace aff_cat=3 if affiliation=="publichealth"
replace aff_cat=4 if affiliation=="university"
replace aff_cat=5 if affiliation=="plannedparenthood"
replace aff_cat=6 if affiliation=="justice"
replace aff_cat=7 if affiliation=="socservices"
replace aff_cat=8 if affiliation=="homeless"
replace aff_cat=10 if affiliation=="nonprofit"
replace aff_cat=11 if affiliation=="" | affiliation=="unknown"
label define afflabel 0 fqhc 1 school 2 hospital 3 publichealth 4 university 5 plannedparenthood 6 justice 7 socservice 8 homeless 9 CBO 10 nonprofit 11 unknown
label values aff_cat afflabel 	


replace aff_cat=0 if aff_cat==11 & affiliation2=="fqhc"
replace aff_cat=1 if aff_cat==11 & affiliation2=="school"
replace aff_cat=2 if aff_cat==11 & affiliation2=="hospital"
replace aff_cat=3 if aff_cat==11 & affiliation2=="publichealth"
replace aff_cat=4 if aff_cat==11 & affiliation2=="university"
replace aff_cat=5 if aff_cat==11 & affiliation2=="plannedparenthood"
replace aff_cat=6 if aff_cat==11 & affiliation2=="justice"
replace aff_cat=7 if aff_cat==11 & affiliation2=="socservices"
replace aff_cat=8 if aff_cat==11 & affiliation2=="homeless"
replace aff_cat=10 if aff_cat==11 & affiliation2=="nonprofit"
tab2 affiliation aff_cat, miss 

tab fqhc, miss
replace fqhc="" if fqhc=="na"
destring(fqhc), replace

keep id_2018 name_2018 aff_cat fqhc
cd "/Users/apple/Desktop/NCSP/Contraception/Title X/Code/"  
save "affiliations2.DTA", replace

*****merge~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
use affiliations.DTA, clear  
sort id_2018
merge m:1 id_2018 using "/Users/apple/Desktop/NCSP/Contraception/Title X/Code/affiliations2.dta", update replace
codebook
tab2 aff_cat fqhc, miss

keep id_2018 name_2018 aff_cat fqhc
save "affiliations.DTA", replace

*****~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*** Re-run dataset clean to produce original titleX2018 file, before next step!
*****~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
cd "/Users/apple/Desktop/NCSP/Contraception/Title X/Code"  
use titleX2018.DTA, clear  
sort id_2018
merge m:1 id_2018 using "/Users/apple/Desktop/NCSP/Contraception/Title X/Code/affiliations.dta", force
drop if _merge==2
drop _merge
rename aff_cat affiliation
tab2 affiliation fqhc, miss
save titleX2018.dta, replace

*****~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*** Save and Export
*****~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
save "/Users/apple/Desktop/NCSP/Contraception/Title X/Code/titleX2018.DTA", replace
cd "/Users/apple/Desktop/NCSP/Contraception/Title X/Output"  
outsheet id_2018 name_2018 address_2018 city state zip phone address_full namefull extra parent affiliation fqhc category using 2018_cleaned.csv, comma replace

*****~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*** Repeat process for 2020 
*****~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  
cd "/Users/apple/Desktop/NCSP/Contraception/Title X/Code/"  
use "affiliations.dta"
clear
import excel using ///
	"/Users/apple/Desktop/NCSP/Contraception/Title X/FQHC/2020unaffiliated_IJ.xlsx", firstrow

g aff_cat=.
replace aff_cat=0 if affiliation=="fqhc"
replace aff_cat=1 if affiliation=="school"
replace aff_cat=2 if affiliation=="hospital"
replace aff_cat=3 if affiliation=="publichealth"
replace aff_cat=4 if affiliation=="university"
replace aff_cat=5 if affiliation=="plannedparenthood"
replace aff_cat=6 if affiliation=="justice"
replace aff_cat=7 if affiliation=="socservice"
replace aff_cat=8 if affiliation=="homeless"
replace aff_cat=9 if affiliation=="PCC"
replace aff_cat=10 if affiliation=="nonprofit"
replace aff_cat=11 if affiliation=="" | affiliation=="unknown"

label define afflabel 0 fqhc 1 school 2 hospital 3 publichealth 4 university 5 plannedparenthood 6 justice 7 socservice 8 homeless 9 PCC 10 nonprofit 11 unknown
label values aff_cat afflabel 	
tab aff_cat affiliation, miss 

gen fqhc=. 
replace fqhc=1 if aff_cat==0
replace fqhc=0 if aff_cat==10 | aff_cat==2 | aff_cat==5 | aff_cat==11
tab fqhc, miss 
rename fqhc fqhc_2020

keep id_2020 name_2020 aff_cat fqhc_2020
cd "/Users/apple/Desktop/NCSP/Contraception/Title X/Code/"  
save "affiliations.DTA", replace

*****~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*** Re-run dataset clean to produce original titleX2020 file, before next step!
*****~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

cd "/Users/apple/Desktop/NCSP/Contraception/Title X/Code"  
use titleX2020.DTA, clear  
sort id_2020
merge m:1 id_2020 using "/Users/apple/Desktop/NCSP/Contraception/Title X/Code/affiliations.dta", force
drop _merge
drop r
replace aff_cat=11 if aff_cat==.
tab aff_cat, miss
tab2 aff_cat fqhc, miss
rename aff_cat affiliation_2020
save titleX2020.dta, replace

*****~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*** Go through manual affiliations
*****~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/*add fqhc affiliation - separate do file to check for FQHC affiliaton */

/*add other affiliatons
g aff_school=1 if strmatch(name_,"*school*")
replace aff_school=1 if strmatch(name_20,"*academy*")
replace aff_school=1 if strmatch(name_20,"*sbhc*")

g aff_hospital = strmatch(name_20,"*hosp*")
replace aff_hospital=1 if strmatch(name_20,"*mgh*")
replace aff_hospital=1 if strmatch(name_20,"*upmc*")
replace aff_hospital=1 if strmatch(name_20,"*grady health system*")
replace aff_hospital=1 if strmatch(name_20,"*long island jewish*")
replace aff_hospital=1 if strmatch(name_20,"jacobi*")
replace aff_hospital=1 if strmatch(name_20,"*york hosp.*")
replace aff_hospital=1 if strmatch(name_20,"*unm-health*")
replace aff_hospital=1 if strmatch(name_20,"*uic*")
replace aff_hospital=1 if strmatch(name_20,"*mt sinai*")
replace aff_hospital=1 if strmatch(name_20,"*gouverneur*")
replace aff_hospital=1 if strmatch(name_20,"*boston medical ctr*")
replace aff_hospital=1 if strmatch(name_20,"unm*") 

g aff_publichealth = strmatch(name_20, "*public health*")
replace aff_publichealth=1 if strmatch(name_20,"*of health*")
replace aff_publichealth=1 if strmatch(name_20,"*county*")
replace aff_publichealth=1 if strmatch(name_20,"*parish*")
replace aff_publichealth=1 if strmatch(name_20,"*publichealth*")
replace aff_publichealth=1 if strmatch(name_20,"*district*")
replace aff_publichealth=1 if strmatch(name_20,"*health dept*")
replace aff_publichealth=1 if strmatch(name_20,"*health department*")
replace aff_publichealth=1 if strmatch(name_20,"*health unit*")
replace aff_publichealth=1 if strmatch(name_20,"*cnty*")

g aff_highered = strmatch(name_20, "*univ*")
replace aff_highered=1 if strmatch(name_20,"*college*")
replace aff_highered=1 if strmatch(name_20,"*student health*")

g aff_pp = strmatch(name_20, "*parenthood*")
replace aff_pp=1 if strmatch(name_20,"*planned*")
replace aff_pp=1 if strmatch(name_20,"*ppmnj*")
replace aff_pp=1 if strmatch(name_20,"*ppncsnj*")
replace aff_pp=1 if strmatch(name_20,"*ppnyc*")

g aff_justice = strmatch(name_2020,"*correctional*")
replace aff_justice=1 if strmatch(name_20,"*justice*")
replace aff_justice=1 if strmatch(name_20,"*detention*")

g aff_socserv=strmatch(name_20,"*jobcorps*")
replace aff_socserv=1 if strmatch(name_20,"*career*")

gen aff_homeless = strmatch(name_20,"*homeless*")
replace aff_homeless=1 if strmatch(name_20,"*shelter*")

gen affiliation=.
replace affiliation=7 if aff_socserv==1
replace affiliation=1 if aff_school==1 
replace affiliation=2 if aff_hospital==1
replace affiliation=4 if aff_highered==1
replace affiliation=6 if aff_justice==1
replace affiliation=8 if aff_homeless==1
replace affiliation=3 if aff_publichealth==1
replace affiliation=5 if aff_pp==1

label define aff2 0 fqhc 1 school 2 hospital 3 publichealth 4 university 5 plannedparenthood 6 justice 7 socservices 8 homeless 10 nonprofit 11 unknown
label values affiliation aff2 	
tab affiliation, miss 
tab aff_cat, miss
tab affiliation aff_cat 

****ONLY PROCEED AFTER DOUBLE CHECKING!!!! 
rename affiliation aff_2
rename aff_cat affiliation */

*****~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*** Save and Export
*****~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
save "/Users/apple/Desktop/NCSP/Contraception/Title X/Code/titleX2020.DTA", replace
cd "/Users/apple/Desktop/NCSP/Contraception/Title X/Output"  
outsheet id_2020 name_2020 address_2020 city_ state_ zip_ phone_ address_full namefull_ extra parent affiliation_2020 fqhc_2020 category using 2020_cleaned.csv, comma replace
