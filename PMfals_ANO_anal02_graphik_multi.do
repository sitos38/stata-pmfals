capture log close
log using Texte/Log/PMfals_ANO_anal02_graph, replace text

//  program:    PMfals_ANO_anal02_graph
//  task:       graphiques des distributions
//  project:    PM falsifiées CCMIR GIR sud-est
//  author:     jfb 20/04/2015


//=============================================
//  #0 program setup
version 13
clear all
set linesize 120
macro drop _all

local date = 	"20/04/2015"
local tag 		"\ANO_anal02_graph `date'"

//========================================================
//  #1 chargement fichier agrégé avec unicité patient-ATC
dir data/modif/pmfals_*
use data/modif/PMfals_ANO_data02_bigdose.dta, clear

*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
* ATTENTION voir graphiques avec 1 SEULE délivrances ou bien PLUSIEURS
*drop if maxdel==0
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//=====================================================
// préparation codes pour les graphiques

// par type d'unité de mesure
egen maxdq = max(dq), by(cdatc)
format maxdq %9.2f
lab var maxdq "DQ maxi par ATC"
note maxdq: création `tag'
tab maxdq

egen maxdq30 = max(dq30), by(cdatc)
format maxdq30 %9.2f
lab var maxdq30 "DQ30 maxi par ATC"
note maxdq30: création `tag'
tab maxdq30

egen maxdq30dur = max(dq30) if duree>0, by(cdatc)
format maxdq30dur %9.2f
lab var maxdq30dur "DQ30 maxi /ATC Kdelivr"
note maxdq30dur: création `tag'
tab maxdq30dur, miss

gen byte duree0 = duree==0
lab var duree0 "Nb délivrances"
lab def duree0 0 "au moins 2" 1 "une seule"
lab val duree0 duree0
tab duree0
tab duree0 selD, col nokey

// graphiques
// dose quotidienne maximum par code ATC
local mycaption = "GIR sud-est: remboursements du 01 janvier 2012 au 31 décembre 2014"
local mytitle   = "Doses quotidiennes moyennes par groupe ATC"
local mystitle  = "relatives à la durée estimée de traitement"

// DQ30
local i 1
local low = 0
tabstat maxdq30, by(cdatc) s(min max n) form(%9.2f)	// XXXXXXXXXXXXX VOIR MAX
foreach high in 0 1 9 20 40 250 1500 {
	if "`high'"!="`low'" { 
		#delimit ;
		count if nobs>10 & `low'<=maxdq30dur & maxdq30dur<`high';
		graph hbox dq30 if nobs>10 
			& `low'<=maxdq30dur & maxdq30dur<`high',
			over(lbCatc) missing 
			ytitle(dose quotidienne moyenne) 
			ylabel(, labsize(small) labcolor(gs10) format(%9.0g)) 
			title(`mytitle') 
			subtitle(`mystitle')
			caption(`mycaption'+ "N = "+r(N), size(small))
			note(`tag');
		graph export graphes/explo/boxplot_dq30_`i++'.wmf, replace;
		#delimit cr
	}
	local low = `high'
}

// dose quotidienne maximum par code ATC
local mycaption = "GIR sud-est: remboursements du 01 janvier 2012 au 31 décembre 2014"
local mytitle   = "Doses quotidiennes moyennes par groupe ATC"
local mystitle  = "(durée calculées entre 2 délivrances minimum par patient)"
// DQ
local i 1
local low = 0
tabstat maxdq, by(cdatc) s(min max n) form(%9.2f)
foreach high in 0 10 80 200 1000 3800 {
	if "`high'"!="`low'" { 
		#delimit ;
		graph hbox dq if nobs>10 
			& `low'<=maxdq & maxdq<`high',
			over(lbCatc) missing 
			ytitle(dose quotidienne moyenne) 
			ylabel(, labsize(small) labcolor(gs10) format(%9.0g)) 
			title(`mytitle') 
			subtitle(`mystitle')
			caption(`mycaption', size(small))
			note(`tag');
		graph export graphes/explo/boxplot_dq_`i++'.wmf, replace;
		#delimit cr
	}
	local low = `high'
}

		*di as res "saving graph boxplot_dq_`i'

view Texte/Log/PMfals_anal02_graph.log
exit
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

graph hbox dq30 if maxdq30dur<10, ///
	over(lbCatc, label(labcolor(gs2) labsize(small)) axis(lcolor(gs15))) ///
	title("My Title", size(small) color(blue)) ///
	yscale(lcolor(gs5)) ///
	yline(3, lpattern(longdash) lcolor(orange)) ///
	ylabel(, labsize(vsmall) labcolor(gs12)) ymtick(, labcolor(blue))

graph hbox dq30 if maxdq30dur<10, ///
	over(lbCatc, label(labcolor(magenta) labsize(small)) axis(lcolor(magenta))) ///
	ytitle(My Title, size(small) color(dknavy)) ///
	yscale(lcolor(blue)) yline(3, lpattern(longdash) lcolor(orange)) ///
	ylabel(, labsize(vsmall) labcolor(gs13)) ymtick(, labcolor(cyan))

graph hbox dq30 if nobs>10 & 20<=maxdq30dur & maxdq30dur<40, over(lbCatc) missing ///
	ytitle(dose quotidienne moyenne) 	///
	ylabel(, labsize(small) labcolor(gs10) format(%9.0g)) 	///
	title(titre) subtitle(ssTitre) caption(caption, size(small)) note(note)

local i 1
local low = 0
tabstat maxdq30, by(cdatc) s(min max n) form(%9.2f)	// XXXXXXXXXXXXX VOIR MAX

count if nobs>10 & 20<=maxdq30dur & maxdq30dur<40
local mycaption = "mycaption N = " & string(r(N))
di "`mycaption'"
#delimit ;
graph hbox dq30 if nobs>10 
	& 20<=maxdq30dur & maxdq30dur<40,
	over(lbCatc) missing 
	ytitle(dose quotidienne moyenne) 
	ylabel(, labsize(small) labcolor(gs10) format(%9.0g)) 
	title(mytitle) 
	subtitle(mystitle)
	caption("`mycaption'", size(small))
	note(tag);
#delimit cr
