/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Title X: GIS
Author: Polina Krass krassp@email.chop.edu
Last updated: 1/18/22
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
clear
cd "/Users/apple/Desktop/NCSP/Contraception/Title X/GIS/Analysis/"
import excel using "TractData032621.xlsx", ///
  case(lower) first allstring 
 destring(pct*), replace
 destring(pop* mhhi pop* med* intersect* centroid* tot* pov* birth* civ* *ins* *predicted *15_19 geo_fips_txt), replace
 duplicates example geo_fips_txt
 list if geo_fips_txt==.
 drop if geo_fips_txt==.
 drop geo_fips_txt geo_fips
 rename geo_fips2 geo_fips_txt
save "censustracts.dta", replace

use "censustracts.dta"
merge m:1 geo_fips_txt using "updatedtracts.dta", update
drop geo_fips
rename _merge geofipsupdate
save "censustracts.dta", replace

*****************
* Conbine with new age data
*****************
merge 1:1 geo_fips_txt using "/Users/apple/Desktop/NCSP/Contraception/Title X/Analysis/ACS data dictionary/adolageupdate.dta"
drop if _merge==2
tab _merge
drop _merge

*****************
* Match with SVI
****************
merge 1:1 geo_fips_txt using "/Users/apple/Desktop/NCSP/Contraception/Title X/GIS/Analysis/svi.dta"
drop if _merge==2
tab _merge
drop _merge

xtile svi_quant=svi_pct, nq(4)

*****************
* Generate SDI
*****************
gen sdi=pctunemp+pctassistance+pov_lt100+pov100_149+pctlths+ ///
	pctfhhwchild+pctrent+pctmoved

egen sdi_pct=xtile(sdi), nq(4)
sum sdi, detail
sum sdi_pct, detail
//histogram sdi 
export excel geo_fips_txt st_abbrev fips svi svi_pct svi_quant sdi sdi_pct using "forhannah.xlsx", replace firstrow(var)
save "censustracts.dta", replace

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

tab2 st_abbr cens_reg
drop stfips

*****************
*Define variables*
*****************

gen fpdesert=0
	replace fpdesert=1 if centroid_30_all==0 //desert throughout
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

gen state=lower(st_abbrev)
tab state, miss
drop if state=="pr"

save "censustracts.dta", replace

*****************
* Generate Variables
*****************
***combine state abbreviation with corresponding state law
merge m:1 state using "/Users/apple/Desktop/NCSP/Contraception/Title X/Analysis/Minor consent/minorconsent" 
drop if _merge==1 & state=="pr"
list if _merge==2
drop if _merge==2
drop _merge

***add border state laws
merge m:1 geo_fips_txt using "/Users/apple/Desktop/NCSP/Contraception/Title X/Analysis/Minor consent/minorconsent2.dta"
tab2 law_bc _merge, miss
drop if _merge==2
drop _merge

***create lawbcbin
gen law_bcbin=.
 replace law_bcbin=1 if law_bc==1
 replace law_bcbin=0 if law_bc!=1
tab law_bcbin law_bc

gen law_bcbin2=. //minor consent vs confidentiality
 replace law_bcbin2=1 if law_bc==1 | law_bc==3
 replace law_bcbin2=0 if law_bc==2 | law_bc==4
tab law_bcbin2 law_bcbin


***create composite variables
gen consentpost=0
	replace consentpost=3 if law_bc_border==1 //30 mins from border state with access
	replace consentpost=2 if desert20==0 //not a desert 
	replace consentpost=1 if law_bc==1 //live in state w/access
label define acc 1 "state" 2 "titleX"  3 "border" 0 "no access"
label values consentpost acc
tab2 consentpost law_bc, miss
tab2 consentpost desert20, miss

gen consentpre=.
	replace consentpre=3 if law_bc_border==1
	replace consentpre=2 if desert18==0
	replace consentpre=1 if law_bc==1
	replace consentpre=0 if law_bc!=1 & law_bc_border!=1 & desert18==1 //minor consent deserts+no state within 30 mins
label values consentpre acc
tab consentpost consentpre
tab2 consentpre law_bc, miss
tab2 consentpre desert18, miss

***NOV UPDATE: create composite variables to assess if clinic within 30 mins of border or within state

***access post
gen consentpost2=0 //desert and not in state or border state
	replace consentpost2=3 if law_bc_border==1 & desert20==1 //30 mins from border state with access AND in a desert
	replace consentpost2=5 if law_bc==1 & desert20==1 //live in state w/access AND in a desert	
	replace consentpost2=1 if desert20==0 //not a desert 
label define mc2 0 "no access" ///
1 "FP within 30 mins" 2 "Border state AND not desert" 3 "Border state BUT desert" ///
4 "in state AND not desert " 5 "in state BUT desert"
label values consentpost2 mc2

***access pre
drop consentpre2
gen consentpre2=0 //desert and not in state or border state
	replace consentpre2=3 if law_bc_border==1 & desert18==1 //30 mins from border state with access AND in a desert
	replace consentpre2=5 if law_bc==1 & desert18==1 //live in state w/access AND in a desert	
	replace consentpre2=1 if desert18==0 //not a desert 
label values consentpre2 mc2

tab2 consentpost2 consentpost, miss
tab2 consentpost2 law_bc, miss
tab2 consentpost2 desert20, miss
tab2 consentpost desert20, miss


***state/border agnostic change
gen desertchange=.
	replace desertchange=1 if desert18==1 & desert20==0
	replace desertchange=2 if desert18==0 & desert20==1
	replace desertchange=3 if desert18==0 & desert20==0
	replace desertchange=4 if desert18==1 & desert20==1
label define desertstatus 1 "gained clinic" 2 "lost clinic" 3 "always had clinic" 4 "never had clinic"
label values desertchange desertstatus

tab2 desertchange desert18, miss
tab2 desertchange desert20, miss
tab2 desertchange lostconsent_cat, miss
	
***create binary variables
gen consentpostbin=.
	replace consentpostbin=1 if consentpost==1 | consentpost==2 | consentpost==3
	replace consentpostbin=0 if consentpost==0
label define mcbin 1 "minor has access" 0 "no access"
label values consentpostbin mcbin	
tab2 consentpost consentpostbin, miss

gen consentprebin=.
	replace consentprebin=1 if consentpre==1 | consentpre==2 | consentpre==3
	replace consentprebin=0 if consentpre==0
label values consentprebin mcbin	
tab2 consentpre consentprebin, miss

tab2 consentpostbin consentprebin, miss

***create composite variables
gen lostconsent=. //missing=tract never had access
	replace lostconsent=1 if consentprebin==1 & consentpostbin==0
	replace lostconsent=0 if consentprebin==1 & consentpostbin==1
label define lostbin 1 "tract lost access" 0 "tract maintained access"
label values lostconsent lostbin	
tab2 lostconsent consentprebin, miss
tab2 lostconsent consentpostbin, miss
tab2 lostconsent desert18
tab2 lostconsent desert20

gen lostconsent_cat=lostconsent
replace lostconsent_cat=2 if consentprebin==0 & consentpostbin==0
replace lostconsent_cat=3 if consentprebin==0 & consentpostbin==1
label define lostcat 1 "lost access" 0 "kept access" 2 "never had access" 3 "gained access" 
label values lostconsent_cat lostcat
tab lostconsent lostconsent_cat, miss
tab2 lostconsent_cat consentprebin, miss
tab2 lostconsent_cat consentpostbin, miss

***NOV UPDATE
tab2 lostconsent_cat desert18, miss
tab2 lostconsent_cat desert20, miss


gen yearcompare=.
	replace yearcompare=0 if consentprebin==0
	replace yearcompare=1 if consentpostbin==0
	label define yearcomlab 0 "no access in 2018" 1 "no access in 2020"
label values yearcompare yearcomlab	
tab2 yearcompare consentprebin, miss
tab2 yearcompare consentpostbin, miss
tab2 yearcompare lostconsent, miss


***composite for stratified analysis


***EXPORT FOR FIG1
export delimited geo_fips_txt st_abbrev centroid_30* lostconsent* ///
		using "/Users/apple/Desktop/NCSP/Contraception/Title X/Figures/fig1cloropleth.csv", replace
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
* Output
*****************
table consentprebin, c(n fpdesert sum t15_19 sum t15_17 sum t10_17) row f(%12.0g)
tab2 consentprebin fpdesert, row column
table consentpre, c(n fpdesert sum t15_19 sum t15_17) row column f(%12.0g)

table consentpostbin, c(n fpdesert sum t15_19 sum t15_17 sum t10_17) row f(%12.0g)
tab2 consentpostbin fpdesert, row column
table consentpost, c(sum t15_19 sum t15_19) row f(%12.0g)

***figure2
*steps: copy as tables into excel; generate % without access; 
***create graph for all states where %access is not 100% for both timepoints; combine graphs
************
table state consentprebin, c(sum t15_17) row column
table state consentpostbin, c(sum t15_17) row column
	
***PCTILES
egen aa_pct=xtile(pctaa), nq(4)
egen hisp_pct=xtile(pcthisp), nq(4)
egen age_pct=xtile(pctpopu18), nq(4)
egen birthrate_pct=xtile(birth_p12mo), nq(4)

label define quartlab 1 "1-25th %ile" 2 "25-50 %ile" 3 "50-75 %ile" 4 "75-99 %ile" 
label values birthrate_pct quartlab
table birthrate_pct, c(mean birth_p12mo)

label values age_pct quartlab
table age_pct, c(mean pctpopu18)

label values aa_pct quartlab
table aa_pct, c(mean pctaa)

gen statedrop=.
	replace statedrop=1 if state=="hi" | state=="me" | state=="ny" | state=="or" | state=="vt" | state=="wa"
table state,c(mean statedrop)

*****************
*Regression Analysis
*****************
log using censustractregression.log, text replace

***univariate
cd  "/Users/apple/Desktop/NCSP/Contraception/Title X/Analysis/Minor consent"
logistic lostconsent i.birthrate_pct
outreg2 using "forestplot.xls" , replace excel eform cti(odds ratio) ci
logistic lostconsent i.age_pct
outreg2 using "forestplot.xls" , excel eform cti(odds ratio) ci
logistic lostconsent i.aa_pct
outreg2 using "forestplot.xls" , excel eform cti(odds ratio) ci
logistic lostconsent i.hisp_pct
outreg2 using "forestplot.xls" , excel eform cti(odds ratio) ci
logistic lostconsent rural
outreg2 using "forestplot.xls" , excel eform cti(odds ratio) ci
logistic lostconsent i.sdi_pct
outreg2 using "forestplot.xls" , excel eform cti(odds ratio) ci
logistic lostconsent i.cens_reg
outreg2 using "forestplot.xls" , excel eform cti(odds ratio) ci

***census tract info for supplemental table 1
table cens_reg lostconsent, c(n pctpopu18) row column

*multivariate model: clustering at census tract
logistic lostconsent i.sdi_pct pctaa pcthisp i.rural pctpopu18 birth_p12mo, cluster(geo_fips_txt)

***with state exclusion
logistic lostconsent i.sdi_pct i.aa_pct i.hisp_pct i.rural if statedrop!=1, cluster(geo_fips_txt)

***tests for collinearity
tabstat rural age_pct aa_pct hisp_pct sdi_pct, by(birthrate_pct)  stat(mean)
tabstat birthrate_pct age_pct aa_pct hisp_pct sdi_pct, by(rural)  stat(mean)
tabstat birthrate_pct rural age_pct aa_pct hisp_pct sdi_pct, by(aa_pct)  stat(mean)
tabstat birthrate_pct rural age_pct aa_pct hisp_pct sdi_pct, by(sdi_pct)  stat(mean)
log close
	
***supp table 1 	
*geography
tab2 rural lostconsent, miss
tab2 rural lostconsent, column
logistic lostconsent rural

tab2 cens_reg lostconsent, miss
tab2 cens_reg lostconsent, column
logistic lostconsent i.cens_reg

*SES
tab2 sdi_pct lostconsent, miss
tab2 sdi_pct lostconsent, column
logistic lostconsent i.sdi_pct

*pop characteristics
tab2 birthrate_pct lostconsent, miss
tab2 birthrate_pct lostconsent, column
logistic lostconsent i.birthrate_pct

tab2 age_pct lostconsent, miss
tab2 age_pct lostconsent, column
logistic lostconsent i.age_pct

tab2 aa_pct lostconsent, miss
tab2 aa_pct lostconsent, column
logistic lostconsent i.aa_pct

tab2 hisp_pct lostconsent, miss
tab2 hisp_pct lostconsent, column
logistic lostconsent i.hisp_pct
	
*****************
*OLD CODE
*****************	
/*
gen lostcon_nostate=lostconsent
	replace lostcon_nostate=. if statedrop==1
label values lostcon_nostate lostbin	

gen consentpost2=.
	replace consentpost2=2 if desert20==0 //not a desert
	replace consentpost2=1 if law_bc==1 | law_bc==3 //live in state w mc
	replace consentpost2=3 if law_bc_border==1 | law_bc_border==3 //30 mins from state w mc
	replace consentpost2=0 if law_bc!=1 & law_bc!=3 & law_bc_border!=1 & law_bc_border!=3 & desert20==1 //minor consent deserts+no state within 30 mins
label values consentpost2 mc
tab2 consentpost2 law_bc, miss
tab2 consentpost2 desert20, miss

gen consentpre2=.
	replace consentpre2=2 if desert18==0
	replace consentpre2=1 if law_bc==1 | law_bc==3 //live in state w mc
	replace consentpre2=3 if law_bc_border==1 | law_bc_border==3 //30 mins from state w mc
	replace consentpre2=0 if law_bc!=1 & law_bc!=3 & law_bc_border!=1 & law_bc_border!=3 & desert18==1 //minor consent deserts+no state within 30 mins
label values consentpre2 mc
tab consentpost2 consentpre2
tab2 consentpre2 law_bc, miss
tab2 consentpre2 desert18, miss

gen consentpostbin2=.
	replace consentpostbin2=1 if consentpost2==1 | consentpost2==2 | consentpost2==3
	replace consentpostbin2=0 if consentpost2==0
label values consentpostbin2 mcbin	
tab2 consentpost2 consentpostbin2, miss

gen consentprebin2=.
	replace consentprebin2=1 if consentpre2==1 | consentpre2==2 | consentpre2==3
	replace consentprebin2=0 if consentpre2==0
label values consentprebin2 mcbin	
tab2 consentpre2 consentprebin2, miss

tab2 consentpostbin2 consentprebin2

gen lostconsent2=. //missing=tract never had access
	replace lostconsent2=1 if consentprebin2==1 & consentpostbin2==0
	replace lostconsent2=0 if consentprebin2==1 & consentpostbin2==1
label values lostconsent2 lostbin	
tab2 lostconsent2 consentprebin2, miss
tab2 lostconsent2 consentpostbin2, miss

gen yearcompare2=.
	replace yearcompare2=0 if consentprebin2==0
	replace yearcompare2=1 if consentpostbin2==0
label values yearcompare2 yearcomlab	
tab2 yearcompare2 consentprebin2, miss
tab2 yearcompare2 consentpostbin2, miss
tab2 yearcompare2 lostconsent2, miss
*/
/*
gen consentpost2=0 //all minor consent sensitivity analysis
	replace consentpost2=3 if law_bc_border==1 | law_bc_border==3 //consent allowed in border state
	replace consentpost2=2 if desert20==0 //not a desert
	replace consentpost2=1 if law_bc==1 | law_bc==3 //live in state w consent
label values consentpost2 mc
tab2 consentpost2 law_bc, miss
tab2 consentpost2 desert20, miss
tab2 consentpost consentpost2, miss

gen consentpre2=0 
	replace consentpre2=3 if law_bc_border==1 
	replace consentpre2=3 if law_bc_border==3 & state_30access!="ME"
	replace consentpre2=2 if desert18==0
	replace consentpre2=1 if law_bc==1 
	replace consentpre2=1 if law_bc==3 & st_abbrev!="ME"
label values consentpre2 mc
tab consentpre2, miss
tab2 consentpre2 law_bc if state=="me", miss
tab2 consentpre2 desert18, miss
tab2 consentpre2 consentpre, miss

sens analysis w/consent not confidentiality 
gen consentpostbin2=.
	replace consentpostbin2=1 if consentpost2==1 | consentpost2==2 | consentpost2==3
	replace consentpostbin2=0 if consentpost2==0
label values consentpostbin2 mcbin	
tab2 consentpost2 consentpostbin2, miss

gen consentprebin2=.
	replace consentprebin2=1 if consentpre2==1 | consentpre2==2 | consentpre2==3
	replace consentprebin2=0 if consentpre2==0
label values consentprebin2 mcbin	
tab2 consentpre2 consentprebin2, miss

tab2 consentprebin2 consentpostbin2, miss row column
	
***majority vs % race/ethnciity

***Majority white/black
gen maj_aa=1 if pctaa>=50 & pctaa!=.
replace maj_aa=0 if pctaa<50
replace maj_aa=. if pctaa==.
table maj_aa, c(mean pctaa n pctaa) miss

gen maj_hi=1 if pcthisp>=50 & pctaa!=.
replace maj_hi=0 if pcthisp<50
replace maj_hi=. if pcthisp==.
table maj_hi, c(mean pcthisp n pcthisp) miss

gen maj_wh=1 if pctwht>=50 & pctwht!=.
replace maj_wh=0 if pctwht<50
replace maj_wh=. if pctwht==.
table maj_wh, c(mean pctwht n pctwht) miss

*regression
logistic lostconsent i.maj_wh
table  maj_wh lostconsent, c(n pctwht) row column
logistic lostconsent i.maj_hi
table  maj_hi lostconsent, c(n pcthisp) row column
logistic lostconsent i.maj_aa
table  maj_aa lostconsent, c(n pctaa) row column
		

***above/below avg pop growth
*birthrate
gen mean_br=1 if birthrate_pct>2 & birthrate_pct!=. 
replace mean_br=0 if birthrate_pct<3 
tab2 mean_br birthrate_pct, miss
table  mean_br lostconsent, c(n birth_p12mo) row column
logistic lostconsent i.mean_br


*age
gen mean_age=1 if age_pct>2 & age_pct!=. 
replace mean_age=0 if age_pct<3 
tab2 mean_age age_pct, miss
table  mean_age lostconsent, c(n pctpopu18) row column


Additional detail for fig 2

gen consentpretotal=.
	replace consentpretotal=0 if consentpre==0. //no consent
	replace consentpretotal=1 if desert18==0 & law_bc!=1 & law_bc_border!=1 //consent only bc of title X
	replace consentpretotal=2 if desert18==1 & law_bc!=1 & law_bc_border==1 //consent only bc of border access
	replace consentpretotal=3 if desert18==1 & law_bc==1 & law_bc_border!=1 //consent only bc of state access
	replace consentpretotal=4 if desert18==1 & law_bc==1 & law_bc_border==1 //state and border access
	replace consentpretotal=5 if desert18==0 & law_bc==1 & law_bc_border!=1 //state and title x access
	replace consentpretotal=6 if desert18==0 & law_bc!=1 & law_bc_border==1 //border and title x access
	replace consentpretotal=7 if desert18==0 & law_bc==1 & law_bc_border==1 //state, border and title x access
label values consentpretotal contotal
tab2 consentpretotal consentpre, miss
tab consentpre
tab consentpretotal, miss

gen consenttotal=.
	replace consenttotal=0 if consentpost==0. //no consent
	replace consenttotal=1 if desert20==0 & law_bc!=1 & law_bc_border!=1 //consent only bc of title X
	replace consenttotal=2 if desert20==1 & law_bc!=1 & law_bc_border==1 //consent only bc of border access
	replace consenttotal=3 if desert20==1 & law_bc==1 & law_bc_border!=1 //consent only bc of state access
	replace consenttotal=4 if desert20==1 & law_bc==1 & law_bc_border==1 //state and border access
	replace consenttotal=5 if desert20==0 & law_bc==1 & law_bc_border!=1 //state and title x access
	replace consenttotal=6 if desert20==0 & law_bc!=1 & law_bc_border==1 //border and title x access
	replace consenttotal=7 if desert20==0 & law_bc==1 & law_bc_border==1 //state, border and title x access
label define contotal 0 "no access" 1 "access only via title x" 2 "access only via border" ///
3 "access only via state" 4 "access via state and border" 5 "access via state and title x" ///
6 "access via border and title x" 7 "access via state, border and title x"
label values consenttotal contotal
tab2 consenttotal consentpost, miss
tab consentpost
tab consenttotal, miss*/

/*gen lostconsent2=. //missing=tract never had access
	replace lostconsent2=1 if consentprebin2==1 & consentpostbin2==0
	replace lostconsent2=0 if consentprebin2==1 & consentpostbin2==1
label values lostconsent2 lostbin	
tab2 lostconsent2 consentprebin2, miss
tab2 lostconsent2 consentpostbin2, miss*/
