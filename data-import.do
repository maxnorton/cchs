/* CCHS import and cleaning for 2009-2010 and later cycles.
Includes 2012 mental health component.
Does not include 2015 nutrition component.
File dependencies:
- data: CCHS_2009-2010_Annual.dta, CCHS_2010_Annual.dta,
		CCHS_2011-2012_Annual.dta, CCHS_2012_Mental-Health.dta,
		CCHS_2012_Annual.dta, CCHS_2013-2014_Annual.dta,
		CCHS_2014_Annual.dta, cchs_annual_2015_2016.dta 
	(downloadable on UBC Abacus Dataverse)
- subscripts: none anymore
*/

local dtafiles CCHS_2009-2010_Annual CCHS_2010_Annual ///
		CCHS_2011-2012_Annual CCHS_2012_Annual ///
		 CCHS_2013-2014_Annual CCHS_2014_Annual cchs_annual_2015_2016

* 2012 mental health component requires special pre-treatment
* then gets appended to 2012 annual component
use CCHS_2012_Mental-Health.dta, clear
rename GEO_PRV GEOGPRV
keep GEOGPRV DHHGAGE-DHHGMS DHHGLVG GEN_01-GENDHDI INCGHH-SDCGRES SDCGLHM ///
	EDUDH04-WTS_M SPS_01 SPS_10
drop GEN_04
rename GEN_02A2 swl
drop if (swl==.a | swl==.b | swl==.c | swl==.d)
rename DHHGAGE age_5yr
save 2012mh.dta, replace		

* Every other cycle gets a standardize treatment		
foreach wave of local dtafiles {
	use `wave'.dta, clear
	if "`wave'" == "cchs_annual_2015_2016" {
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
		rename sps_005 sps_01
		rename sps_050 sps_10


		* Prune
		keep geogprv dhh_sex dhhgms dhhdglvg dhhgage gen_07 gen_08 gen_09 gen_10  ///
			gendhdi gendmhi edudh04 sdcglhm sdcfimm sdcgres incghh incgper incdrca ///
			incdrpr sps_01 sps_10 wts_m

		* Build age groups
		gen age_5yr = 0 if dhhgage==1
		replace age_5yr=1 if (dhhgage==2 | dhhgage==3)
		replace age_5yr=dhhgage-2 if dhhgage>3
		gen age_10yr = floor( (age_5yr+1)/2 )
		gen agegrp = 2 if age_10yr > 4
		replace agegrp = 1 if age_10yr == 4
		replace agegrp = 0 if age_10yr < 4
		drop dhhgage 
	} 
	else {
		* Satisfaction with life: we're only interested in responders
		rename GEN_02A2 swl
		drop if (swl==.a | swl==.b | swl==.c | swl==.d)

		* Prune
		if "`wave'" == "CCHS_2009-2010_Annual" | "`wave'" == "CCHS_2010_Annual" {
			keep GEOGPRV DHHGAGE-DHHGMS DHHGLVG GEN_01-GENDMHI SDCGLHM-SDCGRES ///
				EDUDH04-EDUDR04 INCGHH-WTS_M 
		}
		else {
			keep GEOGPRV DHHGAGE-DHHGMS DHHGLVG GEN_01-GENDMHI SDCGLHM-SDCGRES ///
				EDUDH04-EDUDR04 INCGHH-WTS_M SPS_01 SPS_10
		}
		drop INCDRRS

		* Build age groups
		gen age_5yr = 0 if DHHGAGE==1
		replace age_5yr=1 if (DHHGAGE==2 | DHHGAGE==3)
		replace age_5yr=DHHGAGE-2 if DHHGAGE>3
		
		if "`wave'" == "CCHS_2012_Annual" {
			append using 2012mh.dta, gen(component)
			label define component 0 "Annual" 1 "Mental Health"
			label values component component
		}
		
		gen age_10yr = floor( (age_5yr+1)/2 )
		gen agegrp = 2 if age_10yr > 4
		replace agegrp = 1 if age_10yr == 4
		replace agegrp = 0 if age_10yr < 4
		drop DHHGAGE 
		
		rename *, lower

	}
	save `wave'_pruned.dta, replace
}

* Merge cycles
use CCHS_2009-2010_Annual_pruned.dta, clear
append using "CCHS_2010_Annual_pruned.dta" "CCHS_2011-2012_Annual_pruned.dta" ///
	"CCHS_2012_Annual_pruned.dta" "CCHS_2013-2014_Annual_pruned.dta" ///
	"CCHS_2014_Annual_pruned.dta" "cchs_annual_2015_2016_pruned.dta", gen(wave)


* Clean and label 
label define wave 0 "2009" 1 "2010" 2 "2011" 3 "2012" 4 "2013" 5 "2014" 6 "2015"
label values wave wave
replace component=0 if component==.

label define age_5yr 0 "12 to 14" 1 "15 to 19" 2 "20 to 24" 3 "25 to 29" 4 "30 to 34" 5 "35 to 39" 6 "40 to 44" 7 "45 to 49" 8 "50 to 54" 9 "55 to 59" 10 "60 to 64" 11 "65 to 69" 12 "70 to 74" 13 "75 to 79" 14 "80+"
label define age_10yr 0 "12 to 14" 1 "15 to 24" 2 "25 to 34" 3 "35 to 44" 4 "45 to 54" 5 "55 to 64" 6 "65 to 74" 7 "75+"
label define agegrp 0 "Young" 1 "Midlife" 2 "Old"
label values age_5yr age_5yr
label values age_10yr age_10yr
label values agegrp agegrp

* Save and remove tempfiles
compress
save cchs.dta, replace
foreach wave of local dtafiles {
	rm "`wave'_pruned.dta"
}
rm 2012mh.dta
