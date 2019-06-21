rename GEN_02A2 swl
drop if (swl==.a | swl==.b | swl==.c | swl==.d)
keep GEOGPRV DHHGAGE-DHHGMS DHHGLVG GEN_01-GENDMHI SDCGLHM-SDCGRES EDUDH04-EDUDR04 INCGHH-WTS_M LOP_015
gen age_5yr = 0 if DHHGAGE==1
replace age_5yr=1 if (DHHGAGE==2 | DHHGAGE==3)
replace age_5yr=DHHGAGE-2 if DHHGAGE>3
gen age_10yr = floor( (age_5yr+1)/2 )
gen agegrp = 2 if age_10yr > 4
replace agegrp = 1 if age_10yr == 4
replace agegrp = 0 if age_10yr < 4
drop DHHGAGE
rename LOP_015 employed
replace employed=0 if employed==2
