/* CCHS import and cleaning for 2009-2010 and later cycles.
Includes 2012 mental health component.
Does not include 2015 nutrition component.
File dependencies:
- data: CCHS_2009-2010_Annual.dta, CCHS_2010_Annual.dta,
		CCHS_2011-2012_Annual.dta, CCHS_2012_Mental-Health.dta,
		CCHS_2012_Annual.dta, CCHS_2013-2014_Annual.dta,
		CCHS_2014_Annual.dta, cchs_annual_2015_2016.dta 
	(downloadable on UBC Abacus Dataverse)
- subscripts: data-extract.do
*/

local dtafiles CCHS_2009-2010_Annual CCHS_2010_Annual ///
		CCHS_2011-2012_Annual CCHS_2012_Annual ///
		 CCHS_2013-2014_Annual CCHS_2014_Annual
*		cchs_annual_2015_2016*/

* 2012 mental health component requires special pre-treatment
* then gets appended to 2012 annual component
use CCHS_2012_Mental-Health.dta, clear
rename GEO_PRV GEOGPRV
keep GEOGPRV DHHGAGE-DHHGMS DHHGLVG GEN_01-GENDHDI INCGHH-SDCGRES SDCGLHM EDUDH04-WTS_M
drop GEN_04
rename GEN_02A2 swl
drop if (swl==.a | swl==.b | swl==.c | swl==.d)
rename DHHGAGE age_5yr
gen age_10yr = floor( (age_5yr+1)/2 )
save 2012mh.dta, replace		

* Every other cycle gets a standardize treatment		
foreach wave of local dtafiles {
	display "`wave'"
	use `wave'.dta, clear
	do data-extract.do
	if "`wave'" == "CCHS_2012_Annual" {
		append using 2012mh.dta, gen(component)
		label define component 0 "Annual" 1 "Mental Health"
		label values component component
	}
	save `wave'_pruned.dta, replace
}

* Merge cycles
use CCHS_2009-2010_Annual_pruned.dta, clear
append using "CCHS_2010_Annual_pruned.dta" "CCHS_2011-2012_Annual_pruned.dta" ///
	"CCHS_2012_Annual_pruned.dta" "CCHS_2013-2014_Annual_pruned.dta" ///
	"CCHS_2014_Annual_pruned.dta", gen(wave)


* Clean and label 
label define wave 0 "2009" 1 "2010" 2 "2011" 3 "2012" 4 "2013" 5 "2014"
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
