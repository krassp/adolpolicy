/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Title X: Updated censustract analysis 
Author: Polina Krass krassp@email.chop.edu
Last updated: 1/21/22
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
clear
cd "/Users/apple/Desktop/NCSP/Contraception/Title X/GIS/Analysis/"
import excel using "TractData032621.xlsx", ///
  case(lower) first allstring 
 destring(pct*), replace
 destring(pop* mhhi pop* med* intersect* centroid* tot* pov* birth* civ* *ins* *predicted *15_19 geo_fips_txt), replace
 destring(noins_u18 pubins), replace
 duplicates example geo_fips_txt
 list if geo_fips_txt==.
 drop if geo_fips_txt==.
 drop geo_fips_txt geo_fips
 rename geo_fips2 geo_fips_txt
save "censustracts.dta", replace

use "censustracts.dta"
merge m:1 geo_fips_txt using "updatedtracts.dta", update
drop geo_fips
replace objectid_1=objectid if objectid_1=="" & objectid!=""
drop objectid
rename _merge geofipsupdate

save "censustracts.dta", replace

*****************
* Conbine with new ACS variables
*****************

*age15_17
merge 1:1 geo_fips_txt using "/Users/apple/Desktop/NCSP/Contraception/Title X/Analysis/ACS data dictionary/adolageupdate.dta"
drop if _merge==2
tab _merge
drop _merge

list pop_u18 t10_17 t15_17 in 600/610

*u19onmedicaid
merge 1:1 geo_fips_txt using "/Users/apple/Desktop/NCSP/Contraception/Title X/GIS/Analysis/u19medicaid.dta"
drop if _merge==2
tab _merge
drop _merge

list geo_fips_txt st_abbr name totpop_2 totpop u19_medicaid pop_u18 in 500/510

gen check=1 if totpop_2>totpop //uninstitutionalized included in totalpop, not included in totpop_2
tab check
drop check

gen check=1 if totpop==totpop_2
drop check

gen check=1 if u19_medicaid>pop_u18
tab check
drop check

twoway scatter u19_medicaid pop_u18

*****************
*Check ACS variables*
*****************
drop if st_abbrev=="PR"

*check missing against pop totals
replace pctaa=. if totpop==0 
replace pcthisp=. if totpop==0 
replace pctpopu18=. if totpop==0 
replace birth_p12mo=. if totpop==0 
replace noins_u18=. if totpop==0
replace pubins=. if totpop==0

mdesc *pct* *pop* *p12*
sum pcthisp, d
sum pctpopu18, d
sum birth_p12mo, d 

*****************
*Match with SVI
****************
merge 1:1 geo_fips_txt using "/Users/apple/Desktop/NCSP/Contraception/Title X/GIS/Analysis/svi.dta"
drop if _merge==2
tab _merge
drop _merge

mdesc svi_pct totpop

xtile svi_quant=svi_pct, nq(4)
mdesc svi*

/*****************
* Generate SDI
*****************
gen sdi=pctunemp+pctassistance+pov_lt100+pov100_149+pctlths+ ///
	pctfhhwchild+pctrent+pctmoved

egen sdi_pct=xtile(sdi), nq(4)
sum sdi, detail
sum sdi_pct, detail
save "censustracts.dta", replace*/

*****************
*Census regions*
*****************
gen stfips=substr(geo_fips_txt,1,2)
list stfips stcnty st_abbr in 3000/3210
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

label define censreg 1 "NE" 2 "Mid-west" 3 "South" 4 "West" 
label values cens_reg censreg

tab2 st_abbr cens_reg, miss
drop stfips

*****************
* Parse FIPS code and merge with RUCC
*****************

gen stfips=substr(geo_fips_txt,1,2)
list geo_fips_txt stfips in 1/10

gen countyfips=substr(geo_fips_txt,1,5)
list geo_fips_txt stfips countyfips in 1/50

save "censustracts.dta", replace

merge m:1 countyfips using "/Users/apple/Desktop/NCSP/Contraception/Title X/Analysis/Minor consent/ruralurbancodes.dta"
drop if _merge==2
drop state st_abbr stcnty //state variables from merge
list geo_fips_txt if _merge==1 //these correspond to new counties since 2013, double checked all=9

***update new counties since 2013
destring(rucc_2013), replace
replace rucc_2013=9 if _merge==1
drop _merge

***gen rural
gen rural=.
	replace rural=1 if rucc_2013>3 & rucc_2013<10
	replace rural=0 if rucc_2013==1 | rucc_2013==2 | rucc_2013==3
tab rural, miss

***gen urban
gen urban=.
	replace urban=0 if rucc_2013>3 & rucc_2013<10
	replace urban=1 if rucc_2013==1 | rucc_2013==2 | rucc_2013==3
tab2 rural urban, miss

*****************
*Generate ACS percentiles*
*****************
egen aa_pct=xtile(pctaa), nq(4)
egen hisp_pct=xtile(pcthisp), nq(4)
egen age_pct=xtile(pctpopu18), nq(4)
egen birthrate_pct=xtile(birth_p12mo), nq(4)
egen noins_pct=xtile(noins_u18), nq(4)
egen pubins_pct=xtile(pubins), nq(4)


label define quartlab 1 "1-25th %ile" 2 "25-50 %ile" 3 "50-75 %ile" 4 "75-99 %ile" 
label values birthrate_pct quartlab
table birthrate_pct, c(mean birth_p12mo)

label values age_pct quartlab
table age_pct, c(mean pctpopu18)

label values aa_pct quartlab
table aa_pct, c(mean pctaa)

label values hisp_pct quartlab
table hisp_pct, c(mean pcthisp)

label values noins_pct quartlab
table noins_pct, c(mean noins_u18)

label values pubins_pct quartlab
table pubins_pct, c(mean pubins)


***calculate number u18
gen propu18=pctpopu18*0.01
gen u18num=propu18*totpop //populationu18 INCLUDING INSTITUTIONALIZED
gen prop15_17=t15_17/u18num //population15to17
gen medicaid15_17=u19_medicaid*prop15_17

table pubins_pct, c(sum u18num sum totpop sum t15_17 sum pubins sum medicaid15_17) format(%12.0gc)
table pubins_pct, c(mean prop15_17 mean propu18 mean percent_pubcov6to18 mean pubins) format(%12.0gc)

*****************
* Generate state minor confidentiality variable
*****************
***combine state abbreviation with corresponding state law
gen state=lower(st_abbrev)
merge m:1 state using "/Users/apple/Desktop/NCSP/Contraception/Title X/Analysis/Minor consent/minorconsent" 
drop if _merge==1 & state=="pr"
list object* if _merge==2
drop _merge

/*law_bc coding: 
1. Universal minor consent + confidentiality; 
2. Consent only for specific groups of minors (eg mature)
3. Consent allowed but confidentiality not protected
4. no policy in place 
*/

***create lawbcbin
gen law_bcbin=. //minor confidentiality
 replace law_bcbin=1 if law_bc==1
 replace law_bcbin=0 if law_bc!=1
tab law_bcbin law_bc

** sensitivity: broader def of minor consent
gen law_bcbin2=. //minor consent vs confidentiality
 replace law_bcbin2=1 if law_bc==1 | law_bc==3 //consent allowed
 replace law_bcbin2=0 if law_bc==2 | law_bc==4 //consent not allowed
tab law_bcbin2 law_bc

*****************
*Define outcome variables*
*****************

gen fpdesert=0
	replace fpdesert=1 if centroid_30_all==0 //no access ("FP desert") in both 2021 and 2020
	replace fpdesert=. if centroid_30_all==.
tab fpdesert, miss

gen desert18=0
	replace desert18=1 if centroid_30_2018==0 //desert in 2018
	replace desert18=. if centroid_30_2018==.
tab desert18, miss

gen desert20=0
	replace desert20=1 if centroid_30_2020==0 //desert in 2020
	replace desert20=. if centroid_30_2020==.
tab desert20, miss

tab desert18 desert20

save "censustracts.dta", replace

***create composite variables - updated 11/16 to REMOVE border state access
gen accesspost=.
	replace accesspost=0 if law_bc!=1 & desert20==1
	replace accesspost=1 if law_bc==1 //live in state w/access
	replace accesspost=2 if desert20==0 //not a desert 
label define acc 1 "state access only" 2 "titleX" 0 "no access"
label values accesspost acc
tab2 accesspost law_bc, miss
tab2 accesspost desert20, miss

gen accesspostbin=.
	replace accesspostbin=1 if accesspost==1 | accesspost==2 //access=1 if permissive law or NOT a desert
	replace accesspostbin=0 if accesspost==0
label define accbin 1 "access (st or titX)" 0 "no access"
label values accesspostbin accbin
tab2 accesspost accesspostbin, miss

gen accesspre=.
	replace accesspre=0 if law_bc!=1 & desert18==1 //minor consent deserts+no state within 30 mins
	replace accesspre=1 if law_bc==1
	replace accesspre=2 if desert18==0
label values accesspre acc
tab2 accesspre accesspost, miss
tab2 accesspre law_bc, miss
tab2 accesspre desert18, miss

gen accessprebin=.
	replace accessprebin=1 if accesspre==1 | accesspre==2 //access=1 if permissive law or NOT a desert
	replace accessprebin=0 if accesspre==0
label values accessprebin accbin
tab2 accesspre accessprebin, miss

tab2 accessprebin accesspostbin, row
tab2 accesspre accesspost, column

***state law agnostic change variable - for sensitivity/double check
gen desertchange=.
	replace desertchange=1 if desert18==1 & desert20==0
	replace desertchange=2 if desert18==0 & desert20==1
	replace desertchange=3 if desert18==0 & desert20==0
	replace desertchange=4 if desert18==1 & desert20==1
label define desertstatus 1 "gained clinic" 2 "lost clinic" 3 "always had clinic" 4 "never had clinic"
label values desertchange desertstatus

tab2 desertchange desert18, miss
tab2 desertchange desert20, miss

***create outcome variable: lost access
gen lostaccess_cat=. 
	replace lostaccess_cat=0 if accessprebin==1 & accessprebin==1 //access both years
	replace lostaccess_cat=1 if accessprebin==1 & accesspostbin==0 //lost access
	replace lostaccess_cat=2 if accessprebin==0 & accesspostbin==1 //gained access
	replace lostaccess_cat=3 if accessprebin==0 & accesspostbin==0 //never had
label define lost 0 "kept access" 1 "lost access" 2 "gained access" 3 "no access"
label values lostaccess lost	
tab2 lostaccess_cat accessprebin, miss
tab2 lostaccess_cat accesspostbin, miss
tab2 lostaccess_cat desertchange, miss

gen lostaccess_bin=. //missing=tract never had access OR tract gained access
replace lostaccess_bin=1 if lostaccess_cat==1
replace lostaccess_bin=0 if lostaccess_cat==0
label values lostaccess_bin lost
tab lostaccess_bin lostaccess_cat, miss
tab2 lostaccess_bin accessprebin, miss
tab2 lostaccess_bin accesspostbin, miss

*****************
* Output
*****************
***EXPORT FOR FIG1
export delimited geo_fips_txt st_abbrev centroid_30* lostaccess_cat* ///
		using "/Users/apple/Desktop/NCSP/Contraception/Title X/Figures/fig1cloropleth_Nov.csv", replace
		
***number of census tracts w/access & youth impacted
table accesspre, c(n desertchange sum t15_17) row f(%12.0g)
table accesspost, c(n desertchange sum t15_17) row f(%12.0g)

***subtract sum of 15-17 in "no access" row post-pre to get net change

*estimate of youth impacted w/ medicaid
table accesspre, c(n desertchange sum t15_17 sum medicaid15_17) row f(%12.0gc)
table accesspost, c(n desertchange sum t15_17 sum medicaid15_17) row f(%12.0gc)

***figure2
*steps: copy as tables into excel; generate % without access; 
***create graph for all states where %access is not 100% for both timepoints; combine graphs
************
table state accessprebin, c(sum t15_17) row column
table state accesspostbin, c(sum t15_17) row column
	
gen statedrop=. //sensitivity analysis: states where 100% of titleX clinics were dropped
	replace statedrop=1 if state=="hi" | state=="me" | state=="ny" | state=="or" | state=="vt" | state=="wa"
table state,c(mean statedrop)

*****************
*Regression Analysis
*****************
log using censustractregression.log, text replace

***univariate
cd  "/Users/apple/Desktop/NCSP/Contraception/Title X/Analysis/Minor consent"
logistic lostaccess_bin i.birthrate_pct
outreg2 using "forestplot3.xls" , replace excel eform cti(odds ratio) ci
logistic lostaccess_bin i.age_pct
outreg2 using "forestplot3.xls" , excel eform cti(odds ratio) ci
logistic lostaccess_bin i.aa_pct
outreg2 using "forestplot3.xls" , excel eform cti(odds ratio) ci
logistic lostaccess_bin i.hisp_pct
outreg2 using "forestplot3.xls" , excel eform cti(odds ratio) ci
logistic lostaccess_bin rural
outreg2 using "forestplot3.xls" , excel eform cti(odds ratio) ci
logistic lostaccess_bin i.svi_quant
outreg2 using "forestplot3.xls" , excel eform cti(odds ratio) ci
logistic lostaccess_bin i.cens_reg
outreg2 using "forestplot3.xls" , excel eform cti(odds ratio) ci

***max/min for forestplot
table aa_pct, c(mean pctaa max pctaa min pctaa)
table hisp_pct, c(mean pcthisp max pcthisp min pcthisp)
table birthrate_pct, c(mean birth_p12mo max birth_p12mo min birth_p12mo)
table pubins_pct, c(mean pubins max pubins min pubins)
table pubins_pct, c(mean medicaid15_17 max medicaid15_17 min medicaid15_17)
table age_pct, c(mean pctpopu18 max pctpopu18 min pctpopu18)

***table 2 
tab lostaccess_cat
***census tract info for table 2
table cens_reg lostaccess_bin, c(n pctpopu18) row column

*geography
tab2 rural lostaccess_bin, miss column
tab2 rural lostaccess_bin, column
logistic lostaccess_bin rural

***sens_analysis
gen check=1 if accesspost==1 & desertchange==2
replace check=0 if check==. & desertchange!=.
table check, c(count rural sum rural) row column
tab2 check rural, miss row

tab2 cens_reg lostaccess_bin, miss column
tab2 cens_reg lostaccess_bin, column
logistic lostaccess_bin i.cens_reg

*SES
tab2 svi_quant lostaccess_bin, miss column
tab2 svi_quant lostaccess_bin, column
logistic lostaccess_bin i.svi_quant

*pop characteristics
tab2 birthrate_pct lostaccess_bin, miss column
tab2 birthrate_pct lostaccess_bin, column
table birthrate_pct, c(mean birth_p12mo min birth_p12mo max birth_p12mo)
logistic lostaccess_bin i.birthrate_pct

tab2 age_pct lostaccess_bin, miss column
tab2 age_pct lostaccess_bin, column
table age_pct, c(mean pctpopu18 min pctpopu18 max pctpopu18)

logistic lostconsent i.age_pct

tab2 aa_pct lostaccess_bin, miss column
tab2 aa_pct lostaccess_bin, column
logistic lostconsent i.aa_pct

tab2 hisp_pct lostaccess_bin, miss column
tab2 hisp_pct lostaccess_bin, column
table hisp_pct, c(mean pcthisp min pcthisp max pcthisp)
logistic lostconsent i.hisp_pct

tab2 law_bcbin lostaccess_bin, miss column
tab2 law_bcbin lostaccess_bin, column

*****************
* Sensitivity Analyses
*****************

***tests for collinearity
tabstat rural age_pct aa_pct hisp_pct sdi_pct, by(birthrate_pct)  stat(mean)
**collinearity btwn birthrate and age
tabstat birthrate_pct age_pct aa_pct hisp_pct sdi_pct, by(rural)  stat(mean)
**collinearity between AA/hisp and rural
tabstat birthrate_pct rural age_pct aa_pct hisp_pct sdi_pct, by(aa_pct)  stat(mean)
**collinearity between SDI, rural and pctAA
tabstat birthrate_pct rural age_pct aa_pct hisp_pct sdi_pct, by(sdi_pct)  stat(mean)
***collinearity between SDI, rural, pctAA and pctHisp

*multivariate model: clustering at census tract
logistic lostaccess_bin2 i.sdi_pct i.cens_reg i.birthrate_pct, cluster(geo_fips_txt)

***univariate with state exclusion
logistic lostaccess_bin i.birthrate_pct if statedrop!=1
logistic lostaccess_bin i.age_pct if statedrop!=1
logistic lostaccess_bin i.aa_pct if statedrop!=1
logistic lostaccess_bin i.hisp_pct if statedrop!=1
logistic lostaccess_bin rural if statedrop!=1 //not significant after statedrop
logistic lostaccess_bin i.sdi_pct if statedrop!=1
logistic lostaccess_bin i.cens_reg if statedrop!=1 //after statedrop West has significantly lower odds 

*MINOR CONSENT VS CONFIDENTIALITY
***composite variables with broader consent definition
gen accesspost2=.
	replace accesspost2=0 if law_bcbin2!=1 & desert20==1
	replace accesspost2=1 if law_bcbin2==1 //live in state w/access
	replace accesspost2=2 if desert20==0 //not a desert 
label define acc2 0 "no access" 1 "live in a state w/access" 2 "not a Tit X desert"
label values accesspost2 acc2
tab2 accesspost2 law_bcbin2, miss
tab2 accesspost2 desert20, miss

gen accesspostbin2=.
	replace accesspostbin2=1 if accesspost2==1 | accesspost2==2 //access=1 if permissive law or NOT a desert
	replace accesspostbin2=0 if accesspost2==0
label define accbin2 1 access 0 "no access"
label values accesspostbin2 accbin2
tab2 accesspost2 accesspostbin2, miss

gen accesspre2=.
	replace accesspre2=0 if state=="me". //maine - no access b4 2019
	replace accesspre2=0 if law_bcbin2!=1 & desert18==1 //minor consent deserts+no state within 30 mins
	replace accesspre2=1 if law_bcbin2==1 & state!="me" //permissive law & not in maine
	replace accesspre2=2 if desert18==0 //not a desert
label values accesspre2 acc2
tab2 accesspre2 accesspost2, miss
tab2 accesspre2 law_bcbin2, miss
tab2 accesspre2 desert18, miss

gen accessprebin2=.
	replace accessprebin2=1 if accesspre2==1 | accesspre2==2 //access=1 if permissive law or NOT a desert
	replace accessprebin2=0 if accesspre2==0
label values accessprebin2 accbin2
tab2 accesspre2 accessprebin2, miss

gen lostaccess_cat2=. 
	replace lostaccess_cat2=0 if accessprebin2==1 & accessprebin2==1 //access both years
	replace lostaccess_cat2=1 if accessprebin2==1 & accesspostbin2==0 //lost access
	replace lostaccess_cat2=2 if accessprebin2==0 & accesspostbin2==1 //gained access
	replace lostaccess_cat2=3 if accessprebin2==0 & accesspostbin2==0 //never had
label define lost2 0 "access both years" 1 "lost access" 2 "gained" 3 "never had"
label values lostaccess_cat2 lost2	
tab2 lostaccess_cat2 accessprebin2, miss
tab2 lostaccess_cat2 accesspostbin2, miss

gen lostaccess_bin2=. //missing=tract never had access OR tract gained access
replace lostaccess_bin2=1 if lostaccess_cat2==1
replace lostaccess_bin2=0 if lostaccess_cat2==0
label values lostaccess_bin2 lost2
tab lostaccess_bin2 lostaccess_cat2, miss
tab2 lostaccess_bin2 accessprebin2, miss
tab2 lostaccess_bin2 accesspostbin2, miss

***univariate with minor consent
log using minorconsent.log, text replace

tab lostaccess_bin2, miss

tab2  birthrate_pct lostaccess_bin2, miss column
tab2 birthrate_pct lostaccess_bin2 , column
logistic lostaccess_bin2 i.birthrate_pct 

tab2  age_pct lostaccess_bin2, miss column
tab2 age_pct lostaccess_bin2 , column
logistic lostaccess_bin2 i.age_pct 

tab2  aa_pct lostaccess_bin2, miss column
tab2 aa_pct lostaccess_bin2 , column
logistic lostaccess_bin2 i.aa_pct 

logistic lostaccess_bin2 i.hisp_pct 
logistic lostaccess_bin2 rural 
logistic lostaccess_bin2 i.svi_quant
logistic lostaccess_bin2 i.cens_reg  
log close
	

