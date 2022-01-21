		 
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Match by STATA
Author: Polina Krass krassp@email.chop.edu
Last updated: 1/14/2020
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

/*~~~~~~~~~~~~~~~~~COMPARE 2018 to 2020 USING MATCHIT~~~~~~~~~~~~~*/		 
cd "/Users/apple/Desktop/NCSP/Contraception/Title X/Code"  
use excelmatch.DTA, clear 
clear

*load unmatched 2018 clinics
cd "/Users/apple/Desktop/NCSP/Contraception/Title X/Output"  
import excel using excelnomatch.xlsx, case(lower) firstrow	 

save unmatchedexcel.DTA, replace

***~~~~~~~~~~~~~/*match with name of 2020 clinics*/
matchit id_2018 name_2018 using "/Users/apple/Desktop/NCSP/Contraception/Title X/Code/titleX2020.dta", idu(id_2020) txtu(name_2020) sim(token) stopw t(0.6) overr

***join previous dta files
cd "/Users/apple/Desktop/NCSP/Contraception/Title X/Code" 
joinby id_2018 using "titleX2018.dta"
joinby id_2020 using "titleX2020.dta"
order similscore id_2018 id_2020 name_2018 name_2020 address_2018 address_2020 city city_2020 state state_2020

***drop if city and state don't match
drop if city != city_2020
drop if state != state_2020

*identify true matches
g statamatch=.
replace statamatch=2 if similscore>0.76	
replace statamatch=2 if category != category_2020
replace statamatch=1 if id_2018==1378 & id_2020==940
replace statamatch=1 if id_2018==3563 & id_2020==2586			
replace statamatch=1 if id_2018==3928 & id_2020==3008
replace statamatch=1 if id_2018==2741 & id_2020==1812
replace statamatch=1 if id_2018==3445 & id_2020==2534
replace statamatch=1 if id_2018==4059 & id_2020==3052
replace statamatch=1 if id_2018==4354 & id_2020==3202
replace statamatch=1 if id_2018==3930 & id_2020==3006
replace statamatch=1 if id_2018==3931 & id_2020==3003	
replace statamatch=1 if id_2018==239 & id_2020==71
replace statamatch=1 if id_2018==1378 & id_2020==940
replace statamatch=1 if id_2018==3563 & id_2020==2586			
replace statamatch=1 if id_2018==3928 & id_2020==3008
replace statamatch=1 if id_2018==2741 & id_2020==1812
replace statamatch=1 if id_2018==3445 & id_2020==2534
replace statamatch=1 if id_2018==4059 & id_2020==3052
replace statamatch=1 if id_2018==4354 & id_2020==3202
replace statamatch=1 if id_2018==3930 & id_2020==3006
replace statamatch=1 if id_2018==3931 & id_2020==3003	
replace statamatch=1 if id_2018==648 & id_2020==309
replace statamatch=1 if id_2018==1358 & id_2020==810
replace statamatch=1 if id_2018==1448 & id_2020==879
replace statamatch=1 if id_2018==2743 & id_2020==1852
replace statamatch=1 if id_2018==928 & id_2020==216	
replace statamatch=1 if id_2018==977 & id_2020==232
replace statamatch=1 if id_2018==4360 & id_2020==3173	
replace statamatch=1 if id_2018==4361 & id_2020==3182	
replace statamatch=1 if id_2018==4258 & id_2020==3111
replace statamatch=1 if id_2018==4257 & id_2020==3110
replace statamatch=1 if id_2018==4217 & id_2020==3101
replace statamatch=1 if id_2018==4149 & id_2020==3060
replace statamatch=1 if id_2018==3878 & id_2020==2970
replace statamatch=1 if id_2018==4151 & id_2020==3064
replace statamatch=1 if id_2018==4167 & id_2020==2948
replace statamatch=1 if id_2018==4166 & id_2020==2947
replace statamatch=1 if id_2018==4146 & id_2020==2866
replace statamatch=1 if id_2018==3817 & id_2020==2809
replace statamatch=1 if id_2018==3617 & id_2020==2682
replace statamatch=1 if id_2018==3576 & id_2020==2645
replace statamatch=1 if id_2018==3565 & id_2020==2574
replace statamatch=1 if id_2018==3526 & id_2020==2576
replace statamatch=1 if id_2018==3606 & id_2020==2626
replace statamatch=1 if id_2018==3567 & id_2020==2561
replace statamatch=1 if id_2018==3437 & id_2020==2524
replace statamatch=1 if id_2018==3327 & id_2020==2423
replace statamatch=1 if id_2018==3356 & id_2020==2414
replace statamatch=1 if id_2018==3327 & id_2020==2402
replace statamatch=1 if id_2018==3253 & id_2020==2365
replace statamatch=1 if id_2018==3252 & id_2020==2364
replace statamatch=1 if id_2018==3227 & id_2020==2531
replace statamatch=1 if id_2018==3267 & id_2020==2317
replace statamatch=1 if id_2018==3212 & id_2020==2284
replace statamatch=1 if id_2018==3074 & id_2020==2120
replace statamatch=1 if id_2018==2671 & id_2020==1859
replace statamatch=1 if id_2018==2734 & id_2020==1852
replace statamatch=1 if id_2018==2515 & id_2020==1681
replace statamatch=1 if id_2018==2321 & id_2020==996
replace statamatch=1 if id_2018==2354 & id_2020==1082
replace statamatch=1 if id_2018==2369 & id_2020==990
replace statamatch=1 if id_2018==2218 & id_2020==992
replace statamatch=1 if id_2018==1448 & id_2020==877
replace statamatch=1 if id_2018==1446 & id_2020==879
replace statamatch=1 if id_2018==1356 & id_2020==863
replace statamatch=1 if id_2018==731 & id_2020==423
replace statamatch=1 if id_2018==734 & id_2020==421
replace statamatch=1 if id_2018==732 & id_2020==418
replace statamatch=1 if id_2018==497 & id_2020==419
replace statamatch=1 if id_2018==977 & id_2020==232
replace statamatch=1 if id_2018==976 & id_2020==231
replace statamatch=1 if id_2018==960 & id_2020==226
replace statamatch=1 if id_2018==3335 & id_2020==2405
replace statamatch=1 if id_2018==3482 & id_2020==2505
replace statamatch=1 if id_2018==3565 & id_2020==2574
replace statamatch=1 if id_2018==3356 & id_2020==2414
replace statamatch=1 if phone==phone_2020 & similscore>0.75
replace statamatch=1 if address_2018==address_2020 & similscore>0.75				
replace statamatch=0 if city != city_2020
replace statamatch=0 if state != state_2020
replace statamatch=0 if id_2018==615
replace statamatch=0 if id_2018==4181 & id_2020==2943
replace statamatch=0 if id_2018==205 & id_2020!=2
replace statamatch=0 if id_2018==4144 & id_2020==2865
replace statamatch=0 if id_2018==2369 & id_2020!=990
replace statamatch=0 if id_2018==2218 & id_2020!=992
replace statamatch=0 if id_2018==3356 & id_2020!=2414


label define statalabel 0 statamatchwrong 1 statamatchright 2 mayberight
label values statamatch statalabel 		
tab statamatch,miss

list name_2018 name_2020 if statamatch==.

***generate maxscore
bysort id_2018: egen maxscore = max(similscore)
format maxscore %8.0g
drop if (maxscore-0.005)>similscore

quietly bysort id_2018:  gen dup = cond(_N==1,0,_n) 
tab dup
drop if dup>1 & statamatch !=1
drop if dup>1

*manually check maybe right
tab statamatch
list if statamatch==2
cd "/Users/apple/Desktop/NCSP/Contraception/Title X/Output"  
outsheet similscore statamatch id_2018 id_2020 name_2018 name_2020 address_2018 address_2020 ///
			city city_2020 state state_2020 phone phone_2020 zip zip_2020 dup ///
			using statamatch.csv if statamatch==2 |statamatch==. , comma replace	

*create unmatched spreadsheet
cd "/Users/apple/Desktop/NCSP/Contraception/Title X/Output" 
outsheet similscore id_2018 id_2020 name_2018 name_2020 address_2018 address_2020 ///
			city city_2020 state state_2020 phone phone_2020 zip zip_2020 affiliation fqhc dup ///
			using stataunmatched.csv if statamatch !=1, comma replace			

*save dta and excel
export excel id_2018 id_2020 name_2018 name_2020 address_2018 address_2020 address_full city city_2020 state state_2020 phone phone_2020 category category_2020 affiliation fqhc parent ///
 using matches.xls if statamatch==1, sheet("statamatch", replace) firstrow(variable)
 
cd "/Users/apple/Desktop/NCSP/Contraception/Title X/Code"  
save "/Users/apple/Desktop/NCSP/Contraception/Title X/Code/statamatch.dta", replace	

***~~~~~~~~~~~~~/
***~~~~~~~~~~~~~/*double check 2020 new***~~~~~~~~~~~~~/
***~~~~~~~~~~~~~/
cd "/Users/apple/Desktop/NCSP/Contraception/Title X/Code"  
use unmatched2020.DTA, clear 

drop if statamatch==1
quietly bysort id_2020:  gen dup = cond(_N==1,0,_n)
drop if dup>1
tab dup, miss
keep id_2020 name_2020 address_2020 city_2020 state_2020 phone_2020 zip_2020 
sort id_2020
matchit id_2020 name_2020 using "/Users/apple/Desktop/NCSP/Contraception/Title X/Code/titleX2018.dta", idu(id_2018) txtu(name_2018) sim(token) stopw t(0.6) overr

cd "/Users/apple/Desktop/NCSP/Contraception/Title X/Code" 
joinby id_2018 using "titleX2018.dta"
joinby id_2020 using "titleX2020.dta"
order similscore id_2018 id_2020 name_2018 name_2020 address_2018 address_2020 city city_2020 state state_2020

***pick correct matches
drop if city != city_2020
drop if state != state_2020

outsheet similscore id_2018 id_2020 name_2018 name_2020 address_2018 address_2020 category category_2020 ///
			city city_2020 state state_2020 phone phone_2020 zip zip_2020 ///
			using finalcheck.csv, comma replace
			
*identify true matches
gen statamatch=.
replace statamatch=1 if similscore==1
replace statamatch=1 if id_2018==2251 & id_2020==1062
replace statamatch=1 if address_2018==address_2020

***generate maxscore
bysort id_2018: egen maxscore = max(similscore)
format maxscore %8.0g
drop if (maxscore-0.005)>similscore & statamatch !=1

quietly bysort id_2018:  gen dup = cond(_N==1,0,_n) 
tab dup
drop if dup>1 & statamatch !=1
drop if dup>1

*manually check
cd "/Users/apple/Desktop/NCSP/Contraception/Title X/Output" 

outsheet similscore id_2018 id_2020 name_2018 name_2020 address_2018 address_2020 ///
			city city_2020 state state_2020 phone phone_2020 zip zip_2020 affiliation fqhc dup ///
			using statamatch.csv if statamatch==1, comma replace		

cd "/Users/apple/Desktop/NCSP/Contraception/Title X/Code" 
save unmatchedexcel.DTA, replace

*export
cd "/Users/apple/Desktop/NCSP/Contraception/Title X/Output" 
export excel id_2018 id_2020 name_2018 name_2020 address_2018 address_2020 address_full city city_2020 state state_2020 phone phone_2020 category category_2020 affiliation fqhc parent ///
 using matches.xls if statamatch==1, sheet("statamatchcheck", replace) firstrow(variable)
	
