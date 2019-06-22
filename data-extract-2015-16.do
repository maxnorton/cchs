* Satisfaction with life: we're only interested in responders
rename gen_010 swl
drop if (swl==.a | swl==.b | swl==.c | swl==.d)

* Backcode variables to prev cycle defns
rename geo_prv geogprv
replace geogprv=60 if geogprv==61 | geogprv==62

rename ehg2dvh3 edudh04
replace edudh04=4 if edudh04==3
 

* Rename to fit earlier waves, no recoding required
rename gen_020 gen_07
rename mac_010 gen_08
rename gen_025 gen_09
rename gen_030 gen_10
rename gendvhdi gendhdi 
rename gendvmhi gendmhi
rename sdcdglhm sdcglhm
rename sdcdvimm sdcfimm
rename sdcdgres sdcgres
rename incdghh incghh
rename incdgper incgper
rename incdvrca incdrca
rename incdvrpr incdrpr


* Prune
keep geogprv dhh_sex dhhgms dhhdglvg dhhgage gen_07 gen_08 gen_09 gen_10  ///
	gendhdi gendmhi edudh04 sdcglhm sdcfimm sdcgres incghh incgper incdrca ///
	incdrpr wts_m

* Build age groups
gen age_5yr = 0 if dhhgage==1
replace age_5yr=1 if (dhhgage==2 | dhhgage==3)
replace age_5yr=dhhgage-2 if dhhgage>3
gen age_10yr = floor( (age_5yr+1)/2 )
gen agegrp = 2 if age_10yr > 4
replace agegrp = 1 if age_10yr == 4
replace agegrp = 0 if age_10yr < 4
drop dhhgage 
