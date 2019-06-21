set more off

****2008-2009 excluded for now since it only samples ages 45+****
*2008-2009
*use CCHS_2008-2009_Annual.dta, clear
*rename GEN_02AA swl
*rename GEO_PRV GEOGPRV
*rename GEND08 GEN_08
*rename GEND09 GEN_09
*keep GEOGPRV DHHGAGE DHH_SEX DHHGMS DHHGLVG GEN_01 GEN_02 swl GEN_02B GEN_07 GEN_08 GEN_09 GEN_10 GENDHDI GENDMHI IN2GHH IN2GPER IN2DRCA IN2DRPR SDCGLHM SDCGLNG SDCGRES SDCFIMM EDUDH04 EDUDR04 WTS_M
*rename IN2GHH INCGHH
*rename IN2GPER INCGPER
*rename IN2DRCA INCDRCA
*rename IN2DRPR INCDRPR
*Geography, immigration, income vars differ in this wave, have combine as reasonable
*save wave08.dta, replace

*2009-2010
use CCHS_2009-2010_Annual.dta, clear
do cchs-clean.do
save wave09.dta, replace

*2010
use CCHS_2010_Annual.dta, clear
do cchs-clean.do
save wave10.dta, replace

*2011-2012
use CCHS_2011-2012_Annual.dta, clear
do cchs-clean.do
save wave11.dta, replace

*2012 Mental Health pre-cleaning
use CCHS_2012_Mental-Health.dta
rename GEO_PRV GEOGPRV
keep GEOGPRV DHHGAGE-DHHGMS DHHGLVG GEN_01-GENDHDI INCGHH-SDCGRES SDCGLHM EDUDH04-WTS_M
drop GEN_04
rename GEN_02A2 swl
drop if (swl==.a | swl==.b | swl==.c | swl==.d)
rename DHHGAGE age_5yr
gen age_10yr = floor( (age_5yr+1)/2 )
save wave12mh.dta, replace
*Does not include perceived mental health GENDMHI

*2012 Annual; append cleaned Mental Health
*Merges Annual and Mental Health components, from what I can tell these are entirely distinct samples.
use CCHS_2012_Annual.dta, clear
do cchs-clean.do
append using wave12mh.dta, gen(component)
label define component 0 "Annual" 1 "Mental Health"
label values component component
save wave12.dta, replace

*2013-2014
use CCHS_2013-2014_Annual.dta, clear
do cchs-clean.do
save wave13.dta, replace

*2014
use CCHS_2014_Annual.dta, clear
do cchs-clean.do
save wave14.dta, replace

*Merge
use wave09.dta
append using "wave10.dta" "wave11.dta" "wave12.dta" "wave13.dta" "wave14.dta", gen(wave)
label define wave 0 "2009" 1 "2010" 2 "2011" 3 "2012" 4 "2013" 5 "2014"
label values wave wave
replace component=0 if component==.
drop INCDRRS
label define age_5yr 0 "12 to 14" 1 "15 to 19" 2 "20 to 24" 3 "25 to 29" 4 "30 to 34" 5 "35 to 39" 6 "40 to 44" 7 "45 to 49" 8 "50 to 54" 9 "55 to 59" 10 "60 to 64" 11 "65 to 69" 12 "70 to 74" 13 "75 to 79" 14 "80+"
label define age_10yr 0 "12 to 14" 1 "15 to 24" 2 "25 to 34" 3 "35 to 44" 4 "45 to 54" 5 "55 to 64" 6 "65 to 74" 7 "75+"
label define agegrp 0 "Young" 1 "Midlife" 2 "Old"
label values age_5yr age_5yr
label values age_10yr age_10yr
label values agegrp agegrp
compress
save CCHS_combined.dta, replace
