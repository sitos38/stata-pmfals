program define dupbyid
	args id
	preserve
		tempvar N
		bysort id: gen N = _N	// nombre de lignes avec mm id
		tab N
		keep if N>1	// sélection des lignes avec répétition de mm id
		local mylist ""
		foreach v of varlist _all {
			if "`v'"!= "`id'" {
				capture by id: assert `v'==`v'[1]
				if _rc!=0 {
					di as res "var non constante par `id': `v'"
					local Myles = "`mylist'" + "`v' "
				}
				else {
					di as text "var constante par `id': `v'"
				}
			}
		}
		di as res "variables non constante(s): `mylist'"
	restore
end
