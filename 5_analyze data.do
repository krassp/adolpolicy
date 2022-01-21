/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Title X: Clinic Analysis
Author: Polina Krass krassp@email.chop.edu
Last updated: 9/09/2021
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

/*~~~~~~~~~~~~~~~~~~~~COMBINE FILES~~~~~~~~~~~~~~~~~~~*/
clear
import excel using ///
	"/Users/apple/Desktop/NCSP/Contraception/Title X/Output/Matched and Unmatched3.xlsx", sheet(2018_cleaned) firstrow
save "/Users/apple/Desktop/NCSP/Contraception/Title X/Output/2018matched.dta", replace

use "/Users/apple/Desktop/NCSP/Contraception/Title X/Output/2020matched.dta"
clear
import excel using ///
	"/Users/apple/Desktop/NCSP/Contraception/Title X/Output/Matched and Unmatched3.xlsx", sheet(2020_cleaned) firstrow
save "/Users/apple/Desktop/NCSP/Contraception/Title X/Output/2020matched.dta", replace

append using "/Users/apple/Desktop/NCSP/Contraception/Title X/Output/2018matched.dta", gen(combine) force

/*~~~~~~~~~~~~~~~~~~~~Clean up states~~~~~~~~~~~~~~~~~~*/
bysort state: gen state_n=_N
table state, c(n state_n)

drop if state=="as" |state=="fm" | state=="gu" | state=="mh" | state=="mp"| ///
state=="vi" | state=="pr" 

/*~~~~~~~~~~~~~~~~~~~~Combine variables~~~~~~~~~~~~~~~~~~*/

gen name=name_2018
replace name=name_2020 if name==""
codebook name

gen address=address_full
replace address=address_full2020 if address==""
codebook address

replace city=city_2020 if city==""
codebook city

gen zipcode=zip
replace zipcode=zip_2020 if zipcode==.
codebook zipcode

replace state=state_2020 if state==""
tab state, miss
drop state_2020

replace category=category_2020 if category==""
tab category, miss
drop category_2020

gen fqhcsum=. //combo of 2018 and 2020
replace fqhcsum=fqhc if fqhc!=.
replace fqhcsum=fqhc_2020 if fqhc_2020!=.
tab fqhcsum, miss

/*~~~~~~~~~~~~~~~~~~~~Identify matches~~~~~~~~~~~~~~~~~~~*/
gen matched=.
replace matched=0 if id_2018!=. | id_2020!=.
replace matched=1 if id_match!=.
label define matchlabel 1 matched 0 "not matched"
label values matched matchlabel
sum matched id_match 
tab matched, miss
table matched, c(count id_2020 count id_2018 count id_match) row column
list if matched==.
drop if matched==.

/*~~~~~~~~~~~~~~~~~~~~Fill in missing affiliations~~~~~~~~~~~~~~~~~~~*/
sort id_match id_2018 id_2020
list id_match id_2018 id_2020 name_2018 name_2020 if id_match>1500 & id_match<1520, div

gen aff=affiliation 
replace aff=affiliation_2020 if aff==""
encode aff, gen(affn)

gen affabove = affn[_n-1] if id_match!=. & id_2020!=. //aff=affabove if part of a match AND id_2020
gen affbelow = affn[_n+1] if id_match!=. & id_2018!=. //aff=affbelow if part of a match AND id_2018
label values affbelow affn
label values affabove affn

list id_match id_2018 id_2020 aff affabove affbelow if id_match>1500 & id_match<1520, div

replace affn=affbelow if affn==12 & affabove==.
replace affn=affabove if affn==12 & affbelow==.
list name id_match id_2018 id_2020 affn affabove affbelow fqhcsum if id_match>1500 & id_match<1502, div

replace affn=8 if id_match==1501
replace affn=4 if id_2020==1873 | id_2020==1874
replace affn=6 if id_2020==394
replace affn=2 if id_2020==992
replace affn=2 if id_2020==2393


/*~~~~~~~~~~~~~~~~~~~~Create affiliation binaries~~~~~~~~~~~~~~~~~~~*/

gen school=0
replace school=1 if affn==9 | affn==11
tab school, miss

gen ph=0
replace ph=1 if affn==8
tab ph, miss

gen np=0
replace np=1 if affn==6

gen hos=0
replace hos=1 if affn==4

gen pp=0
replace pp=1 if affn==7

gen ss=0
replace ss=1 if affn==10 | affn==5 | affn==3

gen pcc=0
replace pcc=1 if affn==1

/*~~~~~~~~~~~~~~~~~~~~fill in missing fqhc~~~~~~~~~~~~~~~~~~~*/
sort id_match id_2018 
list id_match id_2018 id_2020 affn fqhc id_2020 name_2018 name_2020 if id_match>1500 & id_match<1520, div

gen fqhcabove = fqhcsum[_n-1] if id_match!=. & id_2020!=.
gen fqhcbelow = fqhcsum[_n+1] if id_match!=. & id_2018!=.

list id_match id_2018 id_2020 fqhc* if id_match>1500 & id_match<1520, div
replace fqhcsum=fqhcbelow if fqhcsum==. & fqhcbelow!=.
replace fqhcsum=fqhcabove if fqhcsum==. & fqhcabove!=.

***add new fqhc affiliations
merge m:1 id_2020 using "/Users/apple/Desktop/NCSP/Contraception/Title X/Code/fqhc2020.dta", update replace
rename _merge IJupdate
replace IJupdate=. if IJupdate==1

merge m:1 id_2018 using "/Users/apple/Desktop/NCSP/Contraception/Title X/Code/fqhc2018.dta", update replace
replace _merge=. if _merge==1
tab _merge, miss
tab IJupdate, miss
replace IJupdate=_merge if _merge!=.

replace fqhcsum=fqhc if fqhcsum==. //fqhcsum=both 2018 and 2020; replace if only 2018 value available
replace fqhcsum=1 if id_2020==2393
replace fqhcsum=1 if id_2020==992
replace fqhcsum=1 if id_match==1501
tab fqhcsum, miss

/***export inconsistent fqhcs
***export empty
cd "/Users/apple/Desktop/NCSP/Contraception/Title X/Analysis/"
export excel if fqhcsum==. using "fqhcupdates.xls", firstrow(var) replace

cd "/Users/apple/Desktop/NCSP/Contraception/Title X/Analysis/"
export excel name id_match id_2018 id_2020 address city state affn fqhcsum if check2==1 & affn!=7 using "fqhc double check.xls" , firstrow(variables) replace*/

save "titlexanalysis.dta", replace


/*~~~~~~~~~~~~~~~~~~~~Identify conflicts in affiliations between years~~~~~~~~~~~~~~~~~~~

gen conflict=1 if affn[_n+1]!=affn & id_2018!=.

tab conflict
list id_match id_2018 id_2020 name aff affn affabove affbelow conflict if id_match>1500 & id_match<1520, div


export excel id_match id_2018 id_2020 name aff affn affabove affbelow fqhc conflict using "conflict affiliation.xls", firstrow(variables) replace


cd "/Users/apple/Desktop/NCSP/Contraception/Title X/Analysis/"
save "titlexanalysis.dta", replace
use "titlexanalysis.dta"*/

/*~~~~~~~~~~~~~~~~~~~~Merge with census tract info~~~~~~~~~~~~~~~~~~~*/
drop _merge
merge m:1 id_2020o using "/Users/apple/Desktop/NCSP/Contraception/Title X/Analysis/Minor consent/facilities20.dta"
drop _merge
save "titlexanalysis.dta", replace

merge m:1 id_2018o using "/Users/apple/Desktop/NCSP/Contraception/Title X/Analysis/Minor consent/facilities18.dta", update
list if _merge==2
drop if _merge==2
list id* name* rucc* if _merge==5
mdesc sdi if _merge>3
drop _merge

save "titlexanalysis.dta", replace
merge m:1 id_match using "/Users/apple/Desktop/NCSP/Contraception/Title X/Analysis/Minor consent/facilitiesmatch.dta", update

mdesc sdi t15_19

list state if rucc_2013==""
drop if state=="as" |state=="fm" | state=="gu" | state=="mh" | state=="mp"| ///
state=="vi" | state=="pr" 
mdesc sdi t15_19

order id* name* address* city* state* zip* county*

destring(rucc_2013), replace
gen rural=.
	replace rural=1 if rucc_2013>3 & rucc_2013<10
	replace rural=0 if rucc_2013==1 | rucc_2013==2 | rucc_2013==3
tab rural, miss

gen urban=.
	replace urban=0 if rucc_2013>3 & rucc_2013<10
	replace urban=1 if rucc_2013==1 | rucc_2013==2 | rucc_2013==3
tab2 urban rural, miss

/*~~~~~~~~~~~~~~~~~~~~census regions~~~~~~~~~~~~~~~~~*/
gen stfips=substr(countyfips,1,2)
list countyfips stfips state in 1/10

generate cens_div=.
generate cens_reg=.
*NE
	replace cens_div=1 if stfips=="09" | stfips=="23" | stfips=="25" | stfips=="33" | stfips=="44" | stfips=="50" //new england
	replace cens_div=2 if stfips=="34" | stfips=="36" | stfips=="42"  //mid-atlantic
	replace cens_reg=1 if cens_div>0 & cens_div<3
**Mid-west	
	replace cens_div=3 if stfips=="18" | stfips=="17" | stfips=="26" | stfips=="39" | stfips=="55"  //east-north central
	replace cens_div=4 if stfips=="19" | stfips=="20" | stfips=="27" | stfips=="29" | stfips=="31" | stfips=="38" | stfips=="46" //west-north central
	replace cens_reg=2 if cens_div>2 & cens_div<5
**South
	replace cens_div=5 if stfips=="10" | stfips=="11" | stfips=="12" | stfips=="13" | stfips=="24"  //southatl
	replace cens_div=5 if stfips=="37" | stfips=="45" | stfips=="51" | stfips=="54"  //southatl cont
	replace cens_div=6 if stfips=="01" | stfips=="21" | stfips=="28" | stfips=="47" //east south central
	replace cens_div=7 if stfips=="05" | stfips=="22" | stfips=="40" | stfips=="48" //west-south central
	replace cens_reg=3 if cens_div>4 & cens_div<8
**West
	replace cens_div=8 if stfips=="04" | stfips=="08" | stfips=="16" | stfips=="35" | stfips=="30"  //mtn
	replace cens_div=8 if stfips=="49" | stfips=="32" | stfips=="56"  //mtncont
	replace cens_div=9 if stfips=="02" | stfips=="06" | stfips=="15" | stfips=="41"| stfips=="53"  //pacific
	replace cens_reg=4 if cens_div>7 & cens_div<10
	
label define censdiv 1 "new england" 2 "mid-atl" 3 "east north central" 4 "west north central" 5 "southatl" ///
					6 "east south central" 7 "west-south central" 8 "mountain" 9 "pacific"
label values cens_div censdiv
tab cens_div, miss

table state, c(mean cens_div)

label define censreg 1 "NE" 2 "Mid-west" 3 "South" 4 "West" 
label values cens_reg censreg

gen cens_ne=.
replace cens_ne=1 if cens_reg==1
replace cens_ne=0 if cens_reg>1 & cens_reg<5
tab cens_reg cens_ne

gen cens_mw=1 if cens_reg==2
replace cens_mw=0 if cens_reg==1 | cens_reg==3 | cens_reg==4
tab cens_reg cens_mw

gen cens_south=1 if cens_reg==3
replace cens_south=0 if cens_reg==1 | cens_reg==2 | cens_reg==4
tab cens_reg cens_south

gen cens_west=1 if cens_reg==4
replace cens_west=0 if cens_reg==1 | cens_reg==2 | cens_reg==3
tab cens_reg cens_west

	
/*~~~~~~~~~~~~~~~~~~~~Create left, stay, join variables~~~~~~~~~~~~~~~~~~~*/
drop dup
quietly bysort id_match:  gen dup = cond(_N==1,0,_n)
sum dup if id_match!=.
list id_2018 id_2020 id_match name dup in 100/200 if id_match!=.

gen contexp=.
replace contexp=1 if dup==0 & id_2018!=.
replace contexp=2 if dup==0 & id_2020!=.
label define contlabel 1 contracted 2 expanded
label values contexp contlabel
tab contexp, miss
tab2 matched contexp, miss

gen left=.
replace left=1 if matched==0 & id_2018!=. //not matched and have an id_2018 (excludes contracted)
replace left=0 if matched==1 & contexp!=2 //matched and not an expansion
label define alabel 1 left 0 stayed
label values left alabel 
tab matched left 
mdesc matched left 
list if left==. in 1/1000

gen join=.
replace join=1 if matched==0 & id_2020!=.
replace join=0 if matched==1 & contexp!=1
label define jlabel 1 joined 0 stayed
label values join jlabel 
tab matched join 
tab2 join left, miss

list name id* matched if left==. & join==.

gen yearcat=.
replace yearcat=1 if left==1
replace yearcat=2 if matched==1 & contexp==.
replace yearcat=3 if join==1
replace yearcat=4 if matched==1 & contexp==1
replace yearcat=5 if matched==1 & contexp==2
label define yearlabel 1 left 2 stayed 3 joined 4 contracted 5 expanded
label values yearcat yearlabel 
tab2 yearcat left, miss
tab2 yearcat join, miss
tab2 yearcat matched, miss

gen nyear=.
replace nyear=0 if id_2018!=. & contexp==.
replace nyear=1 if id_2020!=. & contexp==.
label define nyearlab 0 2018 1 2020
label values nyear nyearlab 
tab nyear year

gen nyear2=. //did not remove cont/exp
replace nyear2=1 if id_2018!=.
replace nyear2=0 if id_2020!=.
tab nyear nyear2

gen leftbin=. //2018 clinics broken up by left and stayed
replace leftbin=1 if year==1
replace leftbin=0 if year==2 & id_2018!=. | year==4 & id_2018!=.
tab2 leftbin year, miss

gen leftbin2=.
replace leftbin2=0 if year==1
replace leftbin2=1 if year==2 & id_2018!=. | year==4 & id_2018!=.
tab2 leftbin2 year, miss

gen joinbin=. //2020 clinics broken up by left and stayed
replace joinbin=1 if year==3
replace joinbin=0 if year==2 & id_2020!=. | year==5 & id_2020!=.
tab2 joinbin year, miss

save "titlexanalysis.dta", replace

/*~~~~~~~~~~~~~~~~~~~~Pull in Minor Consent Laws~~~~~~~~~~~~~~~~~~*/
drop _merge
merge m:1 state using "/Users/apple/Desktop/NCSP/Contraception/Title X/Analysis/Minor consent/minorconsent"
tab2 nyear law_bc, miss all
tab2 state _merge
table nyear law_bc, row column
drop if _merge==1 //drop if not 50 states/dc

***dichotomize minor confidentiality
gen law_bcbin=. 
replace law_bcbin=0 if law_bc==1 
replace law_bcbin=1 if law_bc==2 | law_bc==4 | law_bc==3
label define bclab 0 "Allowed confidentiality" 1 "Not always allowed confidentiality or no policy"
label values law_bcbin bclab
tab law_bcbin law_bc, miss

***dichotomize minor consent
gen law_bccon=. 
replace law_bccon=0 if law_bc==1 | law_bc==3
replace law_bccon=1 if law_bc==2 | law_bc==4 
label define bclab2 0 "Allowed to consent" 1 "Not always allowed to consent or no policy"
label values law_bccon bclab2
tab2 law_bccon law_bc, miss
tab2 law_bccon law_bcbin, miss

***gen state drop for sensitivity 
gen statedrop=.
	replace statedrop=1 if state=="hi" | state=="me" | state=="ny" | state=="or" | state=="vt" | state=="wa"
table state,c(mean statedrop)

***state change
table state nyear, c(n state_n) row column
table1, by(nyear) ///
		vars(state cat) one test
		
/*~~~~~~~~~~~~~~~~~~~~Create other category~~~~~~~~~~~~~~~~~~*/		
gen aff_jw=.
replace aff_jw=1 if fqhcsum==1
replace aff_jw=2 if pp==1
replace aff_jw=3 if pcc==1
replace aff_jw=4 if pp!=1 & pcc!=1 & fqhcsum!=1
label define affjw 1 fqhc 2 pp 3 pcc 4 other
label values aff_jw affjw
tab2 affn aff_jw

gen other=.
replace other=1 if aff_jw==4
replace other=0 if aff_jw<4 
tab2 aff_jw other, miss
 
/*~~~~~~~~~~~~~~~~~~~~Create quartiles~~~~~~~~~~~~~~~~~~*/	
***SVI 	
xtile svi_quar=svi_pct, n(4)
table svi_quar, c(n svi_pct mean svi_pct mean sdi mean sdi_pct)
table leftbin, c(n svi_quar mean svi_quar sum svi_quar)

***popu18
xtile popu18_30=pctpopu18, n(2)
table popu18_30, c(n pctpopu18 mean pctpopu18)

***pctaa
xtile pctaa_bi=pctaa, n(2)
table pctaa_bi, c(n pctaa mean pctaa)

***pcthisp
xtile pcthisp_bi=pcthisp, n(2)
table pcthisp_bi, c(n pcthisp mean pcthisp)

/*~~~~~~~~~~~~~~~~~~~~ Analyses~~~~~~~~~~~~~~~~~~*/
*table1: descriptive + bivariate, unadjusted ORs

***comparison of proportions by year chi square tests
tab2 fqhcsum nyear, column chi 
tab2 pp nyear, column chi
tab2 pcc nyear, column chi
tab2 other nyear, column chi
tab2 urban nyear, column chi
tab2 cens_south nyear, column chi
tab2 cens_ne nyear, column chi
tab2 cens_mw nyear, column chi
tab2 cens_west nyear, column chi
tab2 cens_reg nyear, column chi
tab2 law_bcbin nyear, column chi

***comparison of leftbin via OR
tab2 aff_jw leftbin, row 
logistic leftbin b4.aff_jw, cluster(state) 

tab2 urban leftbin, row
logistic leftbin i.urban, cluster(state) 

tab2 cens_reg leftbin, row
logistic leftbin b3.cens_reg, cluster(state) 

tab2 law_bcbin leftbin, row
logistic leftbin i.law_bcbin, cluster(state) 

tab2 svi_quar leftbin, row
logistic leftbin i.svi_quar, cluster(state) 

table leftbin, c(n pctpopu18 median pctpopu18 p25 pctpopu18 p75 pctpopu18)
logistic leftbin pctpopu18, cluster(state)

table leftbin, c(n pctaa mean pctaa median pctaa p25 pctaa p75 pctaa)
logistic leftbin pctaa, cluster(state)

table leftbin, c(n pcthisp mean pcthisp median pcthisp p25 pcthisp p75 pcthisp)
logistic leftbin pcthisp, cluster(state)

****odds of clinics leaving by state law
log using "/Users/apple/Desktop/NCSP/Contraception/Title X/Analysis/For Jungwon/log.log", text replace

**set state as random effect
capture encode state, gen(nstate)
d nstate state
xtset nstate

***univariate analysis: odds of clinic leaving by each characteristic
xtmelogit leftbin i.law_bcbin || nstate: , or
xtmelogit leftbin i.cens_reg || nstate: , or
xtmelogit leftbin i.aff_jw || nstate: , or
xtmelogit leftbin i.urban || nstate: , or
xtmelogit leftbin i.sdi_pct || nstate: , or
xtmelogit leftbin pctaa_bi || nstate: , or
xtmelogit leftbin pcthisp_bi || nstate: , or
xtmelogit leftbin popu18_30 || nstate: , or
xtmelogit leftbin i.politics || nstate: , or
xtmelogit leftbin i.svi_quar || nstate: , or

***examine if pctaa, pcthisp, pctnoinsurance, and median age have increasing/decreasing trends of the outcome.
cd "/Users/apple/Desktop/NCSP/Contraception/Title X/Analysis/For Jungwon"

/*RESULTS: 
Unadjusted univariate (p<0.2 ***): 
law_bcbin 3.38 p=0.129***
cens_reg:*** 
- midwest (ref NE): 0.09, CI 0.01-0.78
- south (ref NE): 0.02, CI 0.002-0.12
- West (ref NE): 0.25, CI 0.03-2.01
affiliation: ***
- pp (ref: FQHC) 368.1, p<0.001 ***
- other (ref: FQHC) 1.0, p=0.995
urban OR 1.52, p<0.001 ***
sdi pct (ref 1st):***
- 2nd: 0.77 p=0.18
-3rd: 0.81, p=0.27
-4th 0.7, p=0.059 
pctaa OR 0.99, p=0.002 ***
pcthisp OR 0.99, p<0.001 ***
noins OR 1.00 p=0.029***
medage OR 1.0 p=0.63
politics 
-dem (ref: rep) 15.6, OR 3.9-63.5
- split (ref: rep), 27.3, OR 0.07-0.45
*/


*** multivariate analysis with p<0.2 incl politics
xtmelogit leftbin i.law_bcbin i.aff_jw i.urban i.svi_quar  || nstate: , or
xtmelogit leftbin i.law_bcbin i.aff_jw i.urban i.svi_quar i.cens_reg if statedrop!=1 || nstate: , or

*** multivariate analysis with all vars
xtmelogit leftbin i.law_bcbin b4.aff_jw i.urban b3.cens_reg i.svi_quar pctaa pcthisp pctpopu18 || nstate: , or
xtmelogit leftbin i.law_bcbin b4.aff_jw i.urban b3.cens_reg i.svi_quar pctaa pcthisp pctpopu18 if statedrop!=1 || nstate: , or

***multivariate with only p<0. & law_bcbin incl politics 
xtmelogit leftbin i.law_bcbin i.cens_reg i.aff_jw i.urban i.politics || nstate: , or
xtmelogit leftbin i.law_bcbin i.cens_reg i.aff_jw i.urban i.politics if statedrop!=1 || nstate: , or

***multivariate with only p<0.02 & law_bcbin no politics 
xtmelogit leftbin i.law_bcbin i.aff_jw i.urban || nstate: , or
xtmelogit leftbin i.law_bcbin i.aff_jw i.urban if statedrop!=1 || nstate: , or

log close

/*~~~~~~~~~~~~~~~~~~~~Tables~~~~~~~~~~~~~~~~~~*/

cd "/Users/apple/Desktop/NCSP/Contraception/Title X/Analysis/"
table1, by(nyear) ///
		vars(pcc cat \ fqhcsum cat \ pp cat \ other cat \ urban cat \ rural cat \ cens_reg cat \ law_bcbin cat \ sdi_pct cat \ sdi conts \ pctaa conts \ pcthisp conts \ medage conts) ///
		one test missing format(%2.1f) ///
		saving(titlextable1, replace) 
		
cd "/Users/apple/Desktop/NCSP/Contraception/Title X/Analysis/"
table1, by(nyear) ///
		vars(cens_ne bin \ cens_west bin \ cens_south bin \ cens_mw bin ) ///
		one test missing format(%2.1f)
		
cd "/Users/apple/Desktop/NCSP/Contraception/Title X/Analysis/"
table1, by(leftbin) ///
		vars(fqhcsum cat \ pp cat \ pcc cat \ rucc_2013 cat \ rural cat \ law_bcbin cat \ cens_div cat \ cens_reg cat \ law_bcbin cat) ///
		one test miss format(%2.1f) 

/*~~~~~~~~~~~~~~~~~~~~Tables~~~~~~~~~~~~~~~~~~~*/

tab2 nyear aff, miss 

codebook state
table state, c(n year)

tab nyear, miss 
tab year, miss
tab year contexp
tab contexp left
tab contexp join

tab2 law_bc law_bcbin, miss
tab2 nyear law_bcbin, miss all
tab2 leftbin law_bc, miss
tab2 leftbin law_bcbin, miss

table1, by(leftbin) ///
		vars(aff_jw cat \ ///
		rural cat \ ///
		urban cat \ ///
		cens_reg cat \ ///
		law_bcbin cat \ ///
		sdi_pct cat \ ///
		svi_quar cat \ ///
		popu18 contn \ ///
		pctaa contn \ ///
		pcthisp contn) one test format(%2.1f) ///
		saving(titlexanalysis, sheet(left, replace)) 

tab aff year, row chi2

tab2 state year if law_bcbin==1
tab2 state year if law_bcbin!=1

/*~~~~~~~~~~~~~~~~~~~~Compare ORs~~~~~~~~~~~~~~~~~~~*/
log using "/Users/apple/Desktop/NCSP/Contraception/Title X/Analysis/Isabella/relativerisk_219.doc", replace text
cs fqhc nyear2, or
cs school nyear2, or
cs ph nyear2, or
cs homeless nyear2, or
cs np nyear2, or
cs hos nyear2, or
cs justice nyear2, or
cs pp nyear2, or
cs ss nyear2, or
tab aff nyear, chi2 column
log close

/*~~~~~~~~~~~~~~~~~~~~Output~~~~~~~~~~~~~~~~~~~*/
	
cd "/Users/apple/Desktop/NCSP/Contraception/Title X/Analysis/Isabella"  
asdoc tab aff year, nokey row replace save(summarystats.doc)
asdoc tab aff left, nokey row append
asdoc tab aff join, nokey row append
asdoc tab state left, nokey row append
asdoc tab state join, nokey row append

asdoc ranksum fqhc, by(left), replace save(ranksum.doc)
asdoc ranksum fqhc, by(join), append 
asdoc ranksum justice, by(left), append
asdoc ranksum justice, by(join), append
asdoc ranksum school, by(left), append
asdoc ranksum school, by(join), append
asdoc ranksum ph, by(left), append
asdoc ranksum ph, by(join), append
asdoc ranksum hos, by(left), append
asdoc ranksum hos, by(join), append
asdoc ranksum np, by(left), append
asdoc ranksum np, by(join), append
asdoc ranksum homeless, by(left), append
asdoc ranksum homeless, by(join), append

table1, by(left) ///
		vars(fqhc cat  \ justice cat \ ph cat \ np cat \ hos cat \ homeless cat \ school cat) ///
		one test format(%2.1f) ///
		saving(titlexanalysis, sheet(left, replace)) 
		
table1, by(join) ///
		vars(fqhc cat \ justice cat \ ph cat \ np cat \ hos cat \ homeless cat \ school cat) ///
		one test format(%2.1f) ///
		saving(titlexanalysis, sheet(join, replace)) 

table1, by(year) ///
		vars(fqhc cat \ justice cat \ ph cat \ np cat \ hos cat \ homeless cat \ school cat) ///
		one test format(%2.1f) ///
		saving(titlexanalysis, sheet(all, replace)) 	
		

cd "/Users/apple/Desktop/NCSP/Contraception/Title X/Analysis/"
table1, by(year) ///
		vars(state cat) one test ///
saving(state.xls)
		
save "titlexanalysis.dta", replace

/*~~~~~~~~~~~~~~~~~~~~Outsheet for Vicky~~~~~~~~~~~~~~~~~~*/
cd "/Users/apple/Desktop/NCSP/Contraception/Title X/Output"  
outsheet id_match id_2018o id_2020o name address city state zipcode ///
phone parent affiliation category using titleXdatabaseforGIS.csv, comma replace

/*~~~~~~~~~~~~~~~~~~~~Identify clinical vs administrative changes ~~~~~~~~~~~~~~~~~~
codebook newSS*
codebook newSR*
codebook lostSS
codebook combine

g clinic=0
replace clinic=2 if id_match !=. 
replace clinic=1 if lostSS==1 | newSS==1
replace clinic=1 if lostSRwoSS==1 | newSRwooldSS==1
***drop if clinic==0

label define labelc 2 "match" 1 "servicesite or isolated SR" 0 "SR with affiliated clinics"
label values clinic labelc 

gen year=.
replace year=2 if id_2020!=.
replace year=0 if id_2018!=. 
replace year=1 if id_match!=.

**label drop labely
label define labely 2 "Joined in 2020" 0 "Left after 2018" 1 "Stayed in Program"
label values year labely 
tab year, miss

gen leavedrop=.
replace leavedrop=1 if year==0
replace leavedrop=2 if year==2


gen left=.
replace left=1 if year==0
replace left=0 if year==1

gen join=.
replace join=1 if year==2
replace join=0 if year==1

/*~~~~~~~~~~~~~~~~~~~~summarize data~~~~~~~~~~~~~~~~~*/
table state year if clinic !=0
table affiliation year if clinic !=0

table state year, row
table affiliation year, row


table1, by(left) ///
		vars(fqhc cat \ justice cat \ ph cat \ np cat \ hos cat \ homeless cat \ school cat) ///
		one test format(%2.1f) ///
		saving(titlexanalysis, sheet(left, replace)) 


table1, by(join) vars(fqhc cat \ justice cat \ ph cat \ np cat \ hos cat \ homeless cat \ school cat) ///
		one test format(%2.1f) ///
		saving(titlexanalysis, sheet(join, replace)) 
		

table1, by(year) vars(fqhc cat \ justice cat \ ph cat \ np cat \ hos cat \ homeless cat \ school cat) ///
		one test format(%2.1f) ///
		saving(titlexanalysis, sheet(all, replace)) 
		
table1, by(year) vars(state cat) ///
		one test format(%2.1f) ///
		saving(titlexanalysis, sheet(state, replace))
		
/*~~~~~~~~~~~~~~~~~~~~percent total by aff~~~~~~~~~~~~~~~~~~*/
bysort affiliation: gen aff_n=_N
list year affiliation aff_n in 1/10 
list year affiliation aff_n in 1000/1010

bysort affiliation left: gen affleft_n=_N if left==1
replace affleft_n=affleft_n[_n-1] if affleft_n==. & affiliation==affiliation[_n-1]
replace affleft_n=affleft_n[_n+1] if affleft_n==. & affiliation==affiliation[_n+1]

list year affiliation affleft_n in 1400/1490

bysort affiliation join: gen affjoin_n=_N if join==1
replace affjoin_n=affjoin_n[_n-1] if affjoin_n==. & affiliation==affiliation[_n-1]
replace affjoin_n=affjoin_n[_n+1] if affjoin_n==. & affiliation==affiliation[_n+1]
list year affiliation affjoin_n in 20/500
list year affiliation affjoin_n in 1600/1800

cd "/Users/apple/Desktop/NCSP/Contraception/Title X/Code"  
save "titlexanalysis.dta", replace

ttest left=join if affiliation=="fqhc"*/

/*~~~~~~~~~~~~~~~~~~~~percent total by state~~~~~~~~~~~~~~~~~~*/
bysort state: gen state_n=_N
list year state state_n in 1/10 
list year state state_n in 1000/1010

bysort state left: gen left_n=_N if left==1
replace left_n=left_n[_n-1] if left_n==. & state==state[_n-1]
replace left_n=left_n[_n+1] if left_n==. & state==state[_n+1]
replace left_n=left_n[_n+10] if left_n==. & state==state[_n+10]
replace left_n=left_n[_n+20] if left_n==. & state==state[_n+20]
replace left_n=left_n[_n+15] if left_n==. & state==state[_n+15]
replace left_n=0 if state=="dc" | state=="as" | state=="fm" | state=="gu" ///
		| state=="mh" | state=="mp" 
list year state state_n left_n in 1/100 
list year state state_n left_n in 1400/1490

bysort state join: gen join_n=_N if join==1
replace join_n=join_n[_n-1] if join_n==. & state==state[_n+1]
replace join_n=join_n[_n+1] if join_n==. & state==state[_n+1]
replace join_n=join_n[_n+10] if join_n==. & state==state[_n+10]
replace join_n=join_n[_n+20] if join_n==. & state==state[_n+20]
replace join_n=join_n[_n-15] if join_n==. & state==state[_n-15]
replace join_n=0 if state=="ak" | state=="al" | state=="ar" | state=="as" ///
		| state=="fm" | state=="ks" | state=="mn" | state=="me" | state=="hi" ///
		| state=="ne" | state=="nh" | state=="ny" | state=="or" | state=="ut" ///
		| state=="vi" | state=="vt" | state=="wa" | state=="wy" | state=="mp" ///
		| state=="sc" | state=="pr"
list year state state_n left_n join_n in 20/500
list year state state_n join_n in 1600/1800

save "titlexanalysis.dta", replace
use "titlexanalysis.dta"


/*~~~~~~~~~~~~~~~~~~~~collapse state~~~~~~~~~~~~~~~~~~*/
keep if left_n!=. & join_n!=.

quietly bysort state:  gen dup = cond(_N==1,0,_n) 
drop if dup>1
keep state left_n join_n state_n
codebook state

gen left_percent=left_n/(state_n-join_n)*100
replace left_percent=0 if left_percent==.
gen join_percent=join_n/(state_n-left_n)*100
replace join_percent=0 if join_percent==.

gen net_percent=join_percent-left_percent

save "databy.dta", replace
clear

/*~~~~~~~~~~~~~~~~~~~~clean birthrate~~~~~~~~~~~~~~~~~~*/
import excel "/Users/apple/Desktop/NCSP/Contraception/Title X/CDC info/birthrate.xls", firstrow case(lower)
replace state=lower(state)
drop url
rename a year
drop if year!=2018
cd "/Users/apple/Desktop/NCSP/Contraception/Title X/Output"  
save "birthrate.dta"

/*~~~~~~~~~~~~~~~~~~~~join birthrate~~~~~~~~~~~~~~~~~~*/
use "databystate.dta"
merge m:1 state using "birthrate.dta"
drop if _merge==1
drop _merge
rename rate birthrate

tabstat birthrate, stat(mean sd median p75)
gen brbin=0
replace brbin=1 if birthrate>21.6

/*~~~~~~~~~~~~~~~~~~~~binary left/loss~~~~~~~~~~~~~~~~~~*/
gen majleft=0
replace majleft=1 if left_percent>50

gen majjoin=0
replace majjoin=1 if join_percent>50

/*~~~~~~~~~~~~~~~~~~~~regress~~~~~~~~~~~~~~~~~~*/
regress birthrate majleft
regress birthrate majjoin

logistic majleft brbin
logistic majjoin brbin


/*~~~~~~~~~~~~~~~~~~~~percent total by aff~~~~~~~~~~~~~~~~~~*/
generate census_region=.
	***census tract 1
	replace census_region=1 if (state=="ct")
	replace census_region=1 if (state=="me")
	replace census_region=1 if (state=="ma")
	replace census_region=1 if (state=="nh")
	replace census_region=1 if (state=="nj")
	replace census_region=1 if (state=="ny")
	replace census_region=1 if (state=="pa")
	replace census_region=1 if (state=="ri")
	replace census_region=1 if (state=="vt")
	***census tract 2
	replace census_region=2 if (state=="il")
	replace census_region=2 if (program_state=="Indiana")
	replace census_region=2 if (program_state=="Iowa")
	replace census_region=2 if (program_state=="Kansas")
	replace census_region=2 if (program_state=="Michigan")
	replace census_region=2 if (program_state=="Minnesota")
	replace census_region=2 if (program_state=="Missouri")
	replace census_region=2 if (program_state=="Nebraska")
	replace census_region=2 if (program_state=="North Dakota")
	replace census_region=2 if (program_state=="Ohio")
	replace census_region=2 if (program_state=="South Dakota")
	replace census_region=2 if (program_state=="Wisconsin")	
	***census tract 3
	replace census_region=3 if (program_state=="Alabama")
	replace census_region=3 if (program_state=="Arkansas")
	replace census_region=3 if (program_state=="Delaware")
	replace census_region=3 if (program_state=="Florida")
	replace census_region=3 if (program_state=="Georgia")
	replace census_region=3 if (program_state=="Kentucky")
	replace census_region=3 if (program_state=="Louisiana")
	replace census_region=3 if (program_state=="Maryland")
	replace census_region=3 if (program_state=="Mississippi")
	replace census_region=3 if (program_state=="North Carolina")
	replace census_region=3 if (program_state=="Oklahoma")
	replace census_region=3 if (program_state=="South Carolina")
	replace census_region=3 if (program_state=="Tennessee")
	replace census_region=3 if (program_state=="Texas")
	replace census_region=3 if (program_state=="Virginia")
	replace census_region=3 if (program_state=="Washington DC")
	replace census_region=3 if (program_state=="West Virginia")
	***census tract 4
	replace census_region=4 if (program_state=="Alaska")
	replace census_region=4 if (program_state=="Arizona")
	replace census_region=4 if (program_state=="California")
	replace census_region=4 if (program_state=="Colorado")
	replace census_region=4 if (program_state=="Hawaii")
	replace census_region=4 if (program_state=="Idaho")
	replace census_region=4 if (program_state=="Montana")
	replace census_region=4 if (program_state=="Nevada")
	replace census_region=4 if (program_state=="New Mexico")		
	replace census_region=4 if (program_state=="Oregon")
	replace census_region=4 if (program_state=="Utah")
	replace census_region=4 if (program_state=="Washington")
	replace census_region=4 if (program_state=="Wyoming")		

/*
"Alabama"        3
"Alaska"         4
"Arizona"        4
"Arkansas"       3
"California"     4
"Colorado"       4
"Connecticut"    1
"Delaware"       3
"Florida"        3
"Georgia"        3
"Hawaii"         4
"Idaho"          4
"Illinois"       2
"Indiana"        2
"Iowa"           2
"Kansas"         2
"Kentucky"       3
"Louisiana"      3
"Maine"          1
"Maryland"       3
"Massachusetts"  1
"Michigan"       2
"Minnesota"      2
"Mississippi"    3
"Missouri"       2
"Montana"        4
"Nebraska"       2
"Nevada"         4
"New Hampshire"  1
"New Jersey"     1
"New Mexico"     4
"New York"       1
"North Carolina" 3
"North Dakota"   2
"Ohio"           2
"Oklahoma"       3
"Oregon"         4
"Pennsylvania"   1
"Rhode Island"   1
"South Carolina" 3
"South Dakota"   2
"Tennessee"      3
"Texas"          3
"Utah"           4
"Vermont"        1
"Virginia"       3
"Washington"     4
"Washington DC"  3
"West Virginia"  3
"Wisconsin"      2
"Wyoming"        4
end
*/
label values census_region census_region
label def census_region 1 "Northeast", modify
label def census_region 2 "Midwest", modify
label def census_region 3 "South", modify
label def census_region 4 "West", modify

tab census_region, miss

/***odds of leaving by clinic characteristics
cd "/Users/apple/Desktop/NCSP/Contraception/Title X/Analysis/"
logistic leftbin fqhcsum pp urban b2.cens_reg, cluster(state)
outreg2 using "regressiontable.xls", replace excel title("without minor consent clustered by state")

***odds of leaving
logistic leftbin i.law_bcbin fqhcsum pp urban b2.cens_reg, cluster(state)
outreg2 using "regressiontable.xls", append excel title("with minor consent")
logistic leftbin i.law_bcbin , cluster(state)
outreg2 using "regressiontable.xls", append excel title("with minor consent")

***odds of leaving: sensitivity analyses
logistic leftbin i.law_bcbin fqhcsum pp urban b2.cens_reg if statedrop!=1, cluster(state)
outreg2 using "regressiontable.xls", append excel title("with 100% state drop")
logistic joinbin i.law_bcbin if statedrop!=1
logistic nyear i.law_bcbin if statedrop!=1

***odds of leaving: fixed effects
capture encode state, gen(nstate)
d nstate state
xtset nstate
xtologit leftbin i.law_bcbin fqhcsum pp urban if statedrop!=1, or
outreg2 using "regressiontable.xls", append excel title("fixed effect")
xtologit leftbin i.law_bcbin if statedrop!=1, or
outreg2 using "regressiontable.xls", append excel title("fixed effect")*/

/*WITH PP without random effects
***odds of leaving by clinic characteristics
cd "/Users/apple/Desktop/NCSP/Contraception/Title X/Analysis/"
logistic leftbin fqhcsum pp other urban sdi_pct medage pctaa pcthisp noins, cluster(state)

***check for individual factor effects
logistic leftbin fqhcsum
logistic leftbin pp
logistic leftbin other
logistic leftbin urban
logistic leftbin i.cens_reg
logistic leftbin i.sdi_pct
logistic leftbin medage
logistic leftbin pctaa
logistic leftbin pcthisp
logistic leftbin noins

***p<0.02 for: urban, SDI 2/3, medage, pctaa, pcthisp, noins

***odds of leaving by state law logistic leftbin i.law_bcbin pp urban i.cens_reg i.sdi_pct medage noins pctaa pcthisp, cluster(state)
***include fqhcsum
logistic leftbin i.law_bcbin pp fqhcsum other urban i.cens_reg i.sdi_pct medage noins pctaa pcthisp, cluster(state)

***unadjusted
logistic leftbin i.law_bcbin, cluster(state) 
/*~~~~~~~~~~~~~~~~~~~~Create state politics category~~~~~~~~~~~~~~~~~~*/		
gen politics=.
replace politics=1 if state=="ak" | state=="al" | state=="ar" | state=="fl" | state=="id" | ///
					state=="in" | state=="ia" | state=="ks" | state=="ky" | state=="la" |  ///
					state=="ms" | state=="mo" | state=="mt" | state=="nc" | state=="nd" | ///
					state=="oh" | state=="ok" | state=="sc" |  state=="sd" |  state=="tn" | ///
					state=="tx" |  state=="ut" |  state=="wv" |  state=="wy" | state=="dc"
replace politics=2 if state=="az" | state=="ca" | state=="co" | state=="ct" | state=="de" | ///
					state=="ga" | state=="hi" | state=="il" | state=="md" | state=="ma" | ///
					state=="mi" | state=="mn" |  state=="nv" | state=="nh" | state=="nj" | ///
					state=="nm" | state=="ny" | state=="or" | state=="pa" | state=="ri" | ///
					state=="vt" | state=="va" | state=="wa" |  state=="wi"   
replace politics=3 if state=="me" | state=="ne" 
label define politics 1 rep 2 dem 3 split
label values politics politics


