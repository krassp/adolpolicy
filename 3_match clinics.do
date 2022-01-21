/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Title X Clinics
Author: Polina Krass krassp@email.chop.edu
Last updated: 1/14/2020
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
cd "/Users/apple/Desktop/NCSP/Contraception/Title X/Code"  
use titleX2018.DTA, clear  

/*~~~~~~~~~~~~~~~~~~~~COMPARE 2018 to 2020 USING EXCEL~~~~~~~~~~~~~~~~~~~~*/
*replace with matched values with corresponding id_2020 
replace matchedname=matchedname-1
destring matchedphone, replace force
replace matchedphone=matchedphone-1
replace matchedaddress=matchedaddress-1

*find all matches per excel
g anymatch=.

***replace matching including sub-recipients
replace anymatch=matchedphone if matchedphone !=.
replace anymatch=matchedname if matchedname!=. 
replace anymatch=matchedaddress if matchedaddress!=.

***replace if two are the same
replace anymatch=matchedname if matchedname==matchedaddress & matchedaddress !=.
replace anymatch=matchedaddress if matchedaddress==matchedphone & matchedphone !=.

rename anymatch id_2020
codebook id_2020

*join all excel matches
joinby id_2020 using "/Users/apple/Desktop/NCSP/Contraception/Title X/Code/titleX2020.DTA"
order id_2018 id_2020 name_2018 name_2020 address_2018 address_2020 state state_2020 city city_2020

*double check match accuracy
gen match_check=3
replace match_check=4 if category != category_2020 /*categories don't match*/
replace match_check=1 if city != city_2020	/*excel matched incorrectly*/	 
replace match_check=1 if state != state_2020 /*excel matched incorrectly*/	
replace match_check=0 if id_2020==. | id_2020<1 /*there is no match*/	

*manual removal of incorrect matches
replace match_check=0 if id_2018==221 & id_2020==48 /*incorrectmatch*/
replace match_check=0 if id_2018!=982 & id_2020==128 /*incorrectmatch*/
replace match_check=0 if id_2020==272 /*incorrectmatches*/
***replace match_check=0 if id_2020==2585 & id_2018 !=3563, replace match_check=0 if id_2018==1102 & id_2020!=516 replace match_check=0 if id_2018==3930 & id_2020!=3006 replace match_check=0 if id_2020==2938 & id_2018 !=4174 replace match_check=0 if id_2018==27 & id_2020!=78 replace match_check=0 if id_2018==4103 & id_2020!=2859 /*incorrectmatch*/
replace match_check=0 if id_2020==353 & id_2018 !=614 /*incorrectmatch*/
replace match_check=0 if id_2020==2279
replace match_check=0 if id_2018==4232 & id_2020==2861
replace match_check=0 if id_2018==3931 & id_2020!=3003
replace match_check=0 if id_2018==30 & id_2020!=17
replace match_check=0 if id_2018==3921 & id_2020!=3065
replace match_check=0 if id_2018==4237 & id_2020!=3082
replace match_check=0 if id_2018==4355 & id_2020!=3204
replace match_check=0 if id_2018==1378 & id_2020!=940
replace match_check=0 if id_2018==3563 & id_2020!=2586			
replace match_check=0 if id_2018==3928 & id_2020!=3008
replace match_check=0 if id_2018==2741 & id_2020!=1812
replace match_check=0 if id_2018==3445 & id_2020!=2534
replace match_check=0 if id_2018==4059 & id_2020!=3052
replace match_check=0 if id_2018==4354 & id_2020!=3202
replace match_check=0 if id_2018==1359 & id_2020!=792
replace match_check=0 if id_2018==1446 &id_2020!=879
replace match_check=0 if id_2018==3806 &id_2020!=2816
replace match_check=0 if id_2018==238 & id_2020!=70
replace match_check=0 if id_2018==205 & id_2020!=2
replace match_check=0 if id_2018==928 & id_2020!=216
replace match_check=0 if id_2018==4360 & id_2020!=3173
replace match_check=0 if id_2018==2717 & id_2020!=1795
replace match_check=0 if id_2018==1494 & id_2020!=918
replace match_check=0 if id_2018==960 & id_2020!=226
replace match_check=0 if id_2018==2251 & id_2020!=1061
replace match_check=0 if id_2018==3564 & id_2020!=2573
replace match_check=0 if id_2018==3565 & id_2020!=2574

***label and check 
label define matchlabel 0 noexcelmatch 1 excelmatchwrong 3 excelmatchcorrect 4 excelmatchmaybewrong
label values match_check matchlabel 

tab match_check, miss

/*manual check of excel match maybe wrong
cd "/Users/apple/Desktop/NCSP/Contraception/Title X/Output"  
outsheet name_2018 name_2020 id_2018 id_2020 city city_2020 state state_2020 address_2018 address_2020 phone phone_2020 category category_2020 match_check ///
  using excelmatch_check.csv if match_check==4 | match_check==1, comma replace */
  
***drop if city and state don't match or based on manual review of address mistmatch
replace id_2020=. if match_check !=3

***save
save "/Users/apple/Desktop/NCSP/Contraception/Title X/Code/excelmatch.dta", replace	

*create new database of excel matched
cd "/Users/apple/Desktop/NCSP/Contraception/Title X/Output"  
export excel id_2018 id_2020 name_2018 name_2020 address_2018 address_2020 address_full city city_2020 state state_2020 phone phone_2020 category category_2020 affiliation fqhc parent ///
 using matches.xls if match_check==3, replace sheet("excelmatch") firstrow(variable)

***create new database of excel unmatched
export excel name_2018 id_2018 address_2018 city state zip phone namefull address_full affiliation fqhc category category_2020 ///
			using excelnomatch.xlsx if match_check !=3, firstrow(variable) replace
			
save "/Users/apple/Desktop/NCSP/Contraception/Title X/Code/excelmatch.dta", replace	

/*~~~~~~~~~~~~~~~~~~~~COMPARE 2020 to 2018~~~~~~~~~~~~~~~~~~~~*/
cd "/Users/apple/Desktop/NCSP/Contraception/Title X/Code"  
use titleX2020.DTA, clear 

/*identify 2020 clinics not already matched */
merge 1:m id_2020 using "/Users/apple/Desktop/NCSP/Contraception/Title X/Code/excelmatch.dta"
order id_2020 id_2018 _merge
drop if _merge==3 /*drop matched 2020 clinics*/
drop *_2018
drop match_check
drop _merge 
sum id_2020

save "/Users/apple/Desktop/NCSP/Contraception/Title X/Code/unmatched2020.dta", replace	

*matchit on this cohort 
matchit id_2020 address_2020 using "/Users/apple/Desktop/NCSP/Contraception/Title X/Code/titleX2018.dta", idu(id_2018) txtu(address_2018) sim(token) stopw t(0.6) overr

cd "/Users/apple/Desktop/NCSP/Contraception/Title X/Code" 
joinby id_2018 using "titleX2018.dta"
joinby id_2020 using "titleX2020.dta"
order similscore id_2018 id_2020 name_2018 name_2020 address_2018 address_2020 city city_2020 state state_2020
drop matched*
save matching_2020.dta, replace
 
*identify true matches
g statamatch=.
replace statamatch=2 if similscore>0.76	
replace statamatch=1 if id_2018==1378 & id_2020==940
replace statamatch=1 if id_2018==238 & id_2020==70
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
replace statamatch=1 if id_2018==2743 & id_2020==1851
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
replace statamatch=1 if id_2018==3227 & id_2020==2351
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
replace statamatch=1 if id_2018==968 & id_2020==234
replace statamatch=1 if id_2018==2336 & id_2020==1025
replace statamatch=1 if id_2018==2367 & id_2020==1055
replace statamatch=1 if id_2018==2734 & id_2020==1852
replace statamatch=1 if id_2018==3318 & id_2020==2396
replace statamatch=1 if id_2018==3482 & id_2020==2505
replace statamatch=1 if id_2018==3465 & id_2020==2574
replace statamatch=1 if id_2018==3606 & id_2020==2626
replace statamatch=1 if id_2018==4146 & id_2020==2866
replace statamatch=1 if id_2018==4164 & id_2020==2944
replace statamatch=1 if id_2018==3878 & id_2020==2970
replace statamatch=1 if id_2018==4238 & id_2020==3086
replace statamatch=1 if id_2018==4361 & id_2020==3182
replace statamatch=1 if id_2018==4092 & id_2020==3092
replace statamatch=1 if id_2018==3317 & id_2020==2395
replace statamatch=1 if id_2018==3318 & id_2020==2396
replace statamatch=1 if id_2018==3333 & id_2020==2403
replace statamatch=1 if id_2018==3335 & id_2020==2405
replace statamatch=1 if id_2018==3482 & id_2020==2505
replace statamatch=1 if id_2018==3565 & id_2020==2574
replace statamatch=1 if id_2018==3606 & id_2020==2626
replace statamatch=1 if id_2018==3353 & id_2020==2402
replace statamatch=1 if id_2018==2255 & id_2020==1062
replace statamatch=1 if phone==phone_2020 & similscore>0.74
replace statamatch=1 if name_2018==name_2020 & similscore>0.74	
			
replace statamatch=0 if id_2018==615
replace statamatch=0 if id_2018==4181 & id_2020==2943
replace statamatch=0 if id_2018==4361 & id_2020!=3182
replace statamatch=0 if id_2018==4258 & id_2020!=3111
replace statamatch=0 if id_2018==4257 & id_2020!=3110
replace statamatch=0 if id_2018==4217 & id_2020!=3101
replace statamatch=0 if id_2018==4149 & id_2020!=3060
replace statamatch=0 if id_2018==4151 & id_2020!=3064
replace statamatch=0 if id_2018==3878 & id_2020!=2970
replace statamatch=0 if id_2018==4166 & id_2020!=2947
replace statamatch=0 if id_2018==4167 & id_2020!=2948
replace statamatch=0 if id_2018==4146 & id_2020!=2866
replace statamatch=0 if id_2018==3817 & id_2020!=2809
replace statamatch=0 if id_2018==3617 & id_2020!=2682
replace statamatch=0 if id_2018==3576 & id_2020!=2645
replace statamatch=0 if id_2018==3565 & id_2020!=2574
replace statamatch=0 if id_2018==3526 & id_2020!=2576
replace statamatch=0 if id_2018==3606 & id_2020!=2626
replace statamatch=0 if id_2018==3567 & id_2020!=2561
replace statamatch=0 if id_2018==3482 & id_2020!=2505
replace statamatch=0 if id_2018==3478 & id_2020!=2504
replace statamatch=0 if id_2018==3327 & id_2020!=2423
replace statamatch=0 if id_2018==3253 & id_2020!=2365
replace statamatch=0 if id_2018==3252 & id_2020!=2364
replace statamatch=0 if id_2018==3227 & id_2020!=2351
replace statamatch=0 if id_2018==3267 & id_2020!=2317
replace statamatch=0 if id_2018==3212 & id_2020!=2284
replace statamatch=0 if id_2018==3074 & id_2020!=2120
replace statamatch=0 if id_2018==2734 & id_2020!=1852
replace statamatch=0 if id_2018==2515 & id_2020!=1681
replace statamatch=0 if id_2018==2354 & id_2020!=1082
replace statamatch=0 if id_2018==2321 & id_2020!=996
replace statamatch=0 if id_2018==2218 & id_2020!=992
replace statamatch=0 if id_2018==2369 & id_2020!=990
replace statamatch=0 if id_2018==1448 & id_2020!=877
replace statamatch=0 if id_2018==1446 & id_2020!=879
replace statamatch=0 if id_2018==1356 & id_2020!=863
replace statamatch=0 if id_2018==731 & id_2020!=423
replace statamatch=0 if id_2018==732 & id_2020!=418
replace statamatch=0 if id_2018==976 & id_2020!=231
replace statamatch=0 if id_2018==960 & id_2020!=226
replace statamatch=0 if id_2018==781 & id_2020!=206
replace statamatch=0 if id_2018==205 & id_2020!=2
replace statamatch=0 if id_2018==3333 & id_2020!=2403
replace statamatch=0 if id_2018==2335 & id_2020!=1018
replace statamatch=0 if id_2018==2366 & id_2020!=1054
replace statamatch=0 if id_2018==2354 & id_2020!=1082
replace statamatch=0 if id_2018==1887 & id_2020!=1377
replace statamatch=0 if id_2018==1906 & id_2020!=1464
replace statamatch=0 if id_2018==1909 & id_2020!=1467
replace statamatch=0 if id_2018==3318 & id_2020!=2396
replace statamatch=0 if id_2018==2734 & id_2020!=1852
replace statamatch=0 if id_2018==3482 & id_2020!=2505
replace statamatch=0 if id_2018==3437 & id_2020!=2524
replace statamatch=0 if id_2018==3435 & id_2020!=2521
replace statamatch=0 if id_2018==3465 & id_2020!=2574
replace statamatch=0 if id_2018==3606 & id_2020!=2626
replace statamatch=0 if id_2018==4146 & id_2020!=2866
replace statamatch=0 if id_2018==4164 & id_2020!=2944
replace statamatch=0 if id_2018==3878 & id_2020!=2970
replace statamatch=0 if id_2018==4238 & id_2020!=3086
replace statamatch=0 if id_2018==4092 & id_2020!=3092
replace statamatch=0 if id_2018==4360 & id_2020!=3173
replace statamatch=0 if id_2018==3317 & id_2020!=2395
replace statamatch=0 if id_2018==3318 & id_2020!=2396
replace statamatch=0 if id_2018==4237 & id_2020!=3086
replace statamatch=0 if id_2018==238 & id_2020!=70	
replace statamatch=0 if id_2018==967 & id_2020!=233
replace statamatch=0 if id_2018==967 & id_2020!=233	
replace statamatch=0 if id_2018==2717 & id_2020!=1795
replace statamatch=0 if id_2018==3564 & id_2020!=2573
replace statamatch=0 if id_2018==3565 & id_2020!=2574
replace statamatch=0 if id_2018==3605 & id_2020!=2625
replace statamatch=0 if id_2018==4088 & id_2020!=3089
replace statamatch=0 if id_2018==3353 & id_2020!=2402
replace statamatch=0 if id_2018==2353 & id_2020!=1081
replace statamatch=0 if id_2018==2251 & id_2020!=1061
replace statamatch=0 if city != city_2020
replace statamatch=0 if state != state_2020


label define statalabel 0 statamatchwrong 1 statamatchright 2 mayberight
label values statamatch statalabel 		
tab statamatch,miss

save "/Users/apple/Desktop/NCSP/Contraception/Title X/Code/unmatched2020.dta", replace

drop if city != city_2020
drop if state != state_2020

/*generate max value for match*/
format similscore %8.0g
bysort id_2020: egen maxscore = max(similscore)
format maxscore %8.0g
drop if (maxscore-0.005)>similscore
tab statamatch,miss		

***drop duplicates in order of likelihood
drop if statamatch==0 | statamatch==.

quietly bysort id_2020:  gen dup = cond(_N==1,0,_n)
drop if dup>1 & statamatch==2
tab dup, miss

drop dup
quietly bysort id_2020:  gen dup = cond(_N==1,0,_n)
tab dup, miss
drop if dup>1

tab statamatch, miss

*manually check "mayberight"
list id_2018 id_2020 name_2018 name_2020 category category_2020 if statamatch==2
list id_2018 id_2020 name_2018 name_2020 category category_2020 if statamatch==.

*export incorrect to spreadsheet
cd "/Users/apple/Desktop/NCSP/Contraception/Title X/Output" 
export excel id_2018 id_2020 name_2018 name_2020 address_2018 address_2020 address_full city city_2020 state state_2020 phone phone_2020 category category_2020 affiliation fqhc parent ///
 using unmatched2020.xls if statamatch!=1, sheet("statamatch2020", replace) firstrow(variable)
 
save "/Users/apple/Desktop/NCSP/Contraception/Title X/Code/matching_2020.dta", replace

*export correct to spreadsheet
cd "/Users/apple/Desktop/NCSP/Contraception/Title X/Output" 
export excel id_2018 id_2020 name_2018 name_2020 address_2018 address_2020 address_full city city_2020 state state_2020 phone phone_2020 category category_2020 affiliation fqhc parent ///
 using matches.xls if statamatch==1, sheet("statamatch2020", replace) firstrow(variable)
