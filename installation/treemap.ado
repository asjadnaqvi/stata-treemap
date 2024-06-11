*! treemap v1.55 (10 Jun 2024)
*! Asjad Naqvi (asjadnaqvi@gmail.com)

* v1.55 (10 Jun 2024): wrap() for label wraps.
* v1.54	(20 Apr 2024): colorby() fixed. Now requires a variable name for the color order.
* v1.53	(10 Apr 2024): Critical bug fix which was messing up the drawings if a third layer was defined.
* v1.52	(20 Jan 2024): If by() variables had empty rows, the program was giving an error. These are now dropped by default.
* v1.51 (24 Oct 2023): further stabilized the sort for categories with same totals that was causing a crash.
* v1.5  (22 Jul 2023): saving() added. Option to specify both values and shares. performat() added. noval + share defaults labcond to percent values only.
* v1.42 (15 May 2023): Help file fix. Minor corrections.
* v1.41 (15 Feb 2023): "Rest of ..." fix.
* v1.4  (22 Jan 2023): added threshold option, order is now larger to smaller. percent renamed to share to align it with other hierarchy packages.
*					   labelgap default improved. fix a bug where was not respecting the boundary of the parent. colorprop fixed. 
*					    fade() option added to control color scales. fixed string checks. colorby(name) added. threshold added for collapsing datasets
* v1.3  (14 Dec 2022): fixed formatting of labels. Added percent option. Add labgap option.
* v1.21 (22 Nov 2022): fixed a bug where duplicate values were causing categories to be dropped.
* v1.2  (22 Sep 2022): Negative values check. Control over fill intensity.
* v1.1  (13 Sep 2022): Label, color, title scaling. More options for controls. More checks. Better defaults.
* v1.0  (08 Sep 2022): First release.

cap prog drop treemap

prog def treemap, sortpreserve

	version 15
	
	syntax varlist(numeric max=1) [if] [in], by(varlist min=1 max=3)	 ///   
		[ XSize(real 5) YSize(real 3) format(str) palette(string) ADDTitles NOVALues NOLABels  ]		///
		[ pad(numlist max=3) labprop labscale(real 0.3333) labcond(real 0) colorprop titlegap(real 0.1) titleprop LINEWidth(string) LINEColor(string) LABSize(string) ] /// // v1.1 options. labscale is undocumented labprop scaling
		[ fi(numlist max=3) ] 		///   			// v1.2 options
		[ LABGap(string) 	] 	   /// 				// v1.3	options
		[ Share SFORmat(str) THRESHold(numlist max=1 >=0) fade(real 10) percent ] ///	// v1.4, v1.5	options
		[ colorby(varname) sharevar(varname) wrap(numlist >=0 max=1) * ]
		
	marksample touse, strok

	// check for dependencies
	cap findfile carryforward.ado
	if _rc != 0 {
		qui ssc install carryforward, replace
	}	
	


quietly {	
preserve	
	keep if `touse'
	if "`threshold'"=="" local threshold = 0
	
	qui summ `varlist', meanonly
	if r(min) <= 0 noi di in yellow "`varlist' contains zeros or negative values. These values have been dropped."
	drop if `varlist' <= 0
	
	local length : word count `by'
	
	// do the string check
	foreach v of local by {
		if substr("`: type `v''",1,3) != "str" {
			if "`: value label `v' '" != "" { 	// has value label
				decode `v', gen(`v'_temp)
				drop `v'
				ren `v'_temp `v'
			}
			else {								// has no value label
				gen `v'_temp = string(`v')
				drop `v'
				ren `v'_temp `v'
			}
		}
	}	
	

	if `length' == 1 {
		local var0 `by'
		
		drop if `var0' == ""
		
		if "`threshold'"!="" {
			replace `var0' = "Rest of `var0'" if `varlist' <= `threshold'
		}
		
		collapse (sum) `varlist', by(`var0') 
		
		gen double var0_v = `varlist'
		gsort -var0_v `var0'  // stabilize the sort

	}
	
	

	if `length' == 2 {
		tokenize `by'
		local var0 `1'
		local var1 `2'
		
		drop if `var0' == ""
		drop if `var1' == ""
		
		collapse (sum) `varlist', by(`var0' `var1') 
		
		if "`threshold'"!="" {
			levelsof `var0', local(lvls)
			foreach x of local lvls {
				replace `var1' = "Rest of `x'" if `varlist' <= `threshold' & `var0'=="`x'"
			}
		}
		
		collapse (sum) `varlist', by(`var0' `var1') 
		
		bysort `var0': egen var0_v = sum(`varlist')
		gen double var1_v = `varlist'
		
		gsort -var0_v `var0' -var1_v `var1'
	}	
	
	
	
	if `length' == 3 {
		tokenize `by'
		local var0 `1'
		local var1 `2'
		local var2 `3'
		
		drop if `var0' == ""
		drop if `var1' == ""		
		drop if `var2' == ""
		
		if "`threshold'"!="" {
			levelsof `var1', local(lvls)
			foreach x of local lvls {
				replace `var2' = "Rest of `x'" if `varlist' <= `threshold' & `var1'=="`x'"
			}
		}
		
		collapse (sum) `varlist', by(`var0' `var1' `var2')
		
		bysort `var0': egen var0_v = sum(`varlist')
		bysort `var0' `var1': egen var1_v = sum(`varlist')
		gen double var2_v = `varlist'
		
		gsort -var0_v `var0' -var1_v `var1' -var2_v `var2'
	}
	
	
	
	gen id = _n		

	egen var0_t = tag(`var0')
	gen  double var0_o = sum(`var0' != `var0'[_n-1]) 
	
	if "`colorby'" != "" {
		egen var0_c = group(`colorby') // namewise color ordering	
	}
	else {
		gen  var0_c = var0_o
	}
	
		
	if `length' > 1 {
		cap drop var1_t
		egen var1_t = tag(`var0' `var1')
		gsort `var0' -var1_t -var1_v 
		cap drop var1_o
		bysort `var0': gen var1_o = _n if var1_t==1
		sort id
		carryforward var1_o, replace
	}
	

	if `length' > 2 {	
		sort `var0' `var1' id 
		by `var0' `var1': gen var2_o = _n
		gen var2_t = 1	
	}

	sort id

	// set up the base values
	
	if "`pad'" != "" {
		tokenize `pad'
		local plen : word count `pad'
			local pad0 = `1'
			local pad1 = `1'
			local pad2 = `1'

			if `plen' > 1 {
				local pad1 = `2' 
				local pad2 = `2'
			}
			
			if `plen' > 2 {
				local pad1 = `2' 
				local pad2 = `3' 
			}
	}
	else {
		local pad0 0.01
		local pad1 0.01
		local pad2 0.01
	}
	
	if "`linewidth'" != "" {
		tokenize `linewidth'
		local lwlen : word count `linewidth'
		
		local lw0 `1'
		local lw1 `1'
		local lw2 `1'

		if `lwlen' > 1 {
			local lw1 `2'
			local lw2 `2'
		}
			
		if `lwlen' > 2 {
			local lw1 `2'
			local lw2 `3'
		}
	}
	else {
		local lw0 0.03
		local lw1 0.03
		local lw2 0.03
	}
	
	if "`linecolor'" != "" {
		tokenize `linecolor'
		local lclen : word count `linecolor'
		
		local lc0 `1'
		local lc1 `1'
		local lc2 `1'

		if `lclen' > 1 {
			local lc1 `2'
			local lc2 `2'
		}
			
		if `lclen' > 2 {
			local lc1 `2'
			local lc2 `3'
		}
	}
	else {
		local lc0 black
		local lc1 black
		local lc2 black
	}

	if "`labsize'" != "" {
		tokenize `labsize'
		local lslen : word count `labsize'
		
		local ls0 `1'
		local ls1 `1'
		local ls2 `1'

		if `lslen' > 1 {
			local ls1 `2'
			local ls2 `2'
		}
			
		if `lslen' > 2 {
			local ls1 `2'
			local ls2 `3'
		}
	}
	else {
		local ls0 1.6
		local ls1 1.6
		local ls2 1.6
	}	
	
	
	if "`fi'" != "" {
		tokenize `fi'
		local filen : word count `fi'
		
		local fi0 `1'
		local fi1 `1'
		local fi2 `1'

		if `filen' > 1 {
			local fi1 `2'
			local fi2 `2'
		}
			
		if `filen' > 2 {
			local fi1 `2'
			local fi2 `3'
		}
	}
	else {
		local fi0 100
		
		if `length' == 2 {
			local fi0 = 60
			local fi1 = 90
		}	
		
		if `length' == 3 {
			local fi0 = 50
			local fi1 = 75
			local fi2 = 100
		}	
	}		
	

	
	
	local ratio = (1 + sqrt(5)) / 2
	
	mata: xmin = 0; xmax = `xsize'; ymin = 0; ymax = `ysize'; dy = ymax - ymin; dx = xmax - xmin; myratio = `ratio'

	
	*** define format options
	if "`format'"  == "" local format  %12.0fc  // values
	if "`sformat'" == "" local sformat %5.1f    // percentages

	if "`percent'" != "" local share pewpew
	
	**************
	**  layer0  **
    **************
	
	
	mata: data = select(st_data(., ("var0_v")), st_data(., "var0_t=1"))
	mata: datasum = sum(data[.,1])
	mata: pad0b = `pad0'; pad0t = `pad0'; pad0l = `pad0'; pad0r = `pad0'
	
	mata: normlist = normdata(data, dx, dy); b0 = squarify(normlist, xmin, ymin, dx, dy, myratio), normlist; c0 = getcoords2(data, b0, pad0b, pad0t, pad0l, pad0r, datasum)
	mata: st_matrix("c0", c0)

	local varlist 
	
	mat colnames c0 = "_l0_x" "_l0_y" "_l0_id" "_l0_val" "_l0_xmid" "_l0_ymid" "_l0_xmax" "_l0_ymax" "_l0_wgt" "_l0_pct"
	
	svmat c0, n(col)

	gen _l0_lab1 = ""

	levelsof var0_o, local(lvls)
	local item0 = `r(r)'
	foreach i of local lvls {
	
		summ id if var0_o==`i' & var0_t==1, meanonly
		replace  _l0_lab1 = `var0'[r(mean)] in `i'	
	}	
	

		gen  _l0_lab0 = ""
		gen  _l0_lab2 = ""
		
		if "`novalues'"=="" & "`share'"=="" {
			replace  _l0_lab0 = "{it:" + _l0_lab1 + " (" + string(_l0_val, "`format'") + ")}" in 1/`item0' if _l0_val >= `labcond'  
			replace  _l0_lab2 = string(_l0_val, "`format'") in 1/`item0'  if _l0_val >= `labcond' 
		}
		
		
		if "`novalues'"=="" & "`share'"!="" {
			replace  _l0_lab0 = "{it:" + _l0_lab1 + " (" + string(_l0_val, "`format'") + ", " + string(_l0_pct, "`sformat'") + "%)}" in 1/`item0' if _l0_val >= `labcond'
			replace  _l0_lab2 = string(_l0_val, "`format'") + " (" + string(_l0_pct, "`sformat'") + "%)" in 1/`item0'  if _l0_val >= `labcond' 
		}
		
		if "`novalues'"!="" & "`share'"!="" {
			replace  _l0_lab0 = "{it:" + _l0_lab1 + " (" + string(_l0_pct, "`sformat'") + "%)}" in 1/`item0' if _l0_pct >= `labcond'  
			replace  _l0_lab2 = string(_l0_pct, "`sformat'") + "%"  in 1/`item0'  if _l0_pct >= `labcond' 
		}
		
		
		if "`novalues'"!="" & "`share'"=="" {
			replace  _l0_lab0 = "{it:" + _l0_lab1 + "}" if _l0_val >= `labcond'  
		}	
		
	
		// wrap
		if "`wrap'" != "" {
			
			// layer 0
			gen _length0 = length(_l0_lab0) if _l0_lab0!= ""
			summ _length0, meanonly		
			local _wraprounds0 = floor(`r(max)' / `wrap')
			
			forval i = 1 / `_wraprounds0' {
				local wraptag = `wrap' * `i'
				replace _l0_lab0 = substr(_l0_lab0, 1, `wraptag') + "`=char(10)'" + substr(_l0_lab0, `=`wraptag' + 1', .) if _length0 > `wraptag' & _length0!=. 
			}
			
			// layer 1
			gen _length1 = length(_l0_lab1) if _l0_lab1!= ""
			summ _length1, meanonly		
			local _wraprounds1 = floor(`r(max)' / `wrap')
			
			forval i = 1 / `_wraprounds0' {
				local wraptag = `wrap' * `i'
				replace _l0_lab1 = substr(_l0_lab1, 1, `wraptag') + "`=char(10)'" + substr(_l0_lab1, `=`wraptag' + 1', .) if _length1 > `wraptag' & _length1!=. 
			}
			
			// layer 2
			gen _length2 = length(_l0_lab2) if _l0_lab2!= ""
			summ _length2, meanonly		
			local _wraprounds2 = floor(`r(max)' / `wrap')
			
			forval i = 1 / `_wraprounds2' {
				local wraptag = `wrap' * `i'
				replace _l0_lab2 = substr(_l0_lab2, 1, `wraptag') + "`=char(10)'" + substr(_l0_lab2, `=`wraptag' + 1', .) if _length2 > `wraptag' & _length2!=. 
			}
			
			drop _length*
		}	
	
		
	**************
	**  layer1  **
    **************	

	if `length' > 1 {
		
		if "`addtitles'" != "" mata b0[.,4] = b0[.,4] :- (`titlegap' :* (b0[.,4]  :> `titlegap' * 2.5))
		
		local l0
		local l1
		
		levelsof var0_o, local(l0)

		foreach z of local l0 {
				
				mata: mydata = select(st_data(., ("var1_v", "var0_o")), st_data(., "var1_t = 1"))
				mata: mydata = select(mydata, mydata[.,2] :== `z')		
				mata: pad1b = `pad1'; pad1t = `pad1'; pad1l = `pad1'; pad1r = `pad1'

				mata: b1_`z' = processchildren(`z', mydata[.,1], b0    , pad0b, pad0t, pad0l, pad0r, myratio)
				mata: c1_`z' = getcoords2(          mydata[.,1], b1_`z', pad1b, pad1t, pad1l, pad1r, datasum)
				mata: st_matrix("c1_`z'", c1_`z')

			mat colnames c1_`z' = "_l1_`z'_x" "_l1_`z'_y" "_l1_`z'_id" "_l1_`z'_val" "_l1_`z'_xmid" "_l1_`z'_ymid" "_l1_`z'_xmax" "_l1_`z'_ymax" "_l1_`z'_wgt" "_l1_`z'_pct"		
			svmat c1_`z', n(col)

			gen _l1_`z'_lab1  = ""
			levelsof var1_o if var0_o==`z', local(l1)
			local item1 = `r(r)'
			
			foreach i of local l1 {
				summ id if var0_o==`z' & var1_o==`i' &  var1_t==1 , meanonly
				replace  _l1_`z'_lab1 = `var1'[r(mean)] in `i'	
			}
			
			
			gen  _l1_`z'_lab0=""
			gen  _l1_`z'_lab2=""
			
			if "`novalues'"=="" & "`share'"=="" {
				replace  _l1_`z'_lab0 = "{it:" + _l1_`z'_lab1 + " (" + string(_l1_`z'_val, "`format'") + ")}" in 1/`item1' if _l1_`z'_val >= `labcond'  
				replace  _l1_`z'_lab2 = string(_l1_`z'_val, "`format'") in 1/`item1'  if _l1_`z'_val >= `labcond' 
			}
			
			
			if "`novalues'"=="" & "`share'"!="" {
				replace  _l1_`z'_lab0 = "{it:" + _l1_`z'_lab1 + " (" + string(_l1_`z'_val, "`format'") + ", " + string(_l1_`z'_pct, "`sformat'") + "%)}" in 1/`item1' if _l1_`z'_val >= `labcond'
				replace  _l1_`z'_lab2 = string(_l1_`z'_val, "`format'") + " (" + string(_l1_`z'_pct, "`sformat'") + "%)" in 1/`item1'  if _l1_`z'_val >= `labcond' 
			}
			
			if "`novalues'"!="" & "`share'"!="" {
				replace  _l1_`z'_lab0 = "{it:" + _l1_`z'_lab1 + " (" + string(_l1_`z'_pct, "`sformat'") + "%)}" in 1/`item1' if _l1_`z'_pct >= `labcond'  
				replace  _l1_`z'_lab2 = string(_l1_`z'_pct, "`sformat'") + "%" in 1/`item1'  if _l1_`z'_pct >= `labcond' 
			}

			if "`novalues'"!="" & "`share'"=="" {
				replace  _l1_`z'_lab0= "{it:" + _l1_`z'_lab1 + "}" if _l1_`z'_val >= `labcond'  
			}			
			
			
			// wrap
			if "`wrap'" != "" {
				
				// layer 0
				gen _length0 = length(_l1_`z'_lab0) if _l1_`z'_lab0!= ""
				summ _length0, meanonly		
				local _wraprounds0 = floor(`r(max)' / `wrap')
				
				forval i = 1 / `_wraprounds0' {
					local wraptag = `wrap' * `i'
					replace _l1_`z'_lab0 = substr(_l1_`z'_lab0, 1, `wraptag') + "`=char(10)'" + substr(_l1_`z'_lab0, `=`wraptag' + 1', .) if _length0 > `wraptag' & _length0!=. 
				}
				
				// layer 1
				gen _length1 = length(_l1_`z'_lab1) if _l1_`z'_lab1!= ""
				summ _length1, meanonly		
				local _wraprounds1 = floor(`r(max)' / `wrap')
				
				forval i = 1 / `_wraprounds0' {
					local wraptag = `wrap' * `i'
					replace _l1_`z'_lab1 = substr(_l1_`z'_lab1, 1, `wraptag') + "`=char(10)'" + substr(_l1_`z'_lab1, `=`wraptag' + 1', .) if _length1 > `wraptag' & _length1!=. 
				}
				
				// layer 2
				gen _length2 = length(_l1_`z'_lab2) if _l1_`z'_lab2!= ""
				summ _length2, meanonly		
				local _wraprounds2 = floor(`r(max)' / `wrap')
				
				forval i = 1 / `_wraprounds2' {
					local wraptag = `wrap' * `i'
					replace _l1_`z'_lab2 = substr(_l1_`z'_lab2, 1, `wraptag') + "`=char(10)'" + substr(_l1_`z'_lab2, `=`wraptag' + 1', .) if _length2 > `wraptag' & _length2!=. 
				}			
				
				drop _length*
			}

		}
		
	}
	
	
	**************
	**  layer2  **
    **************		
		
	if `length' > 2 {	
		
		local l0
		local l1
		local l2

		levelsof var0_o, local(l0)

		foreach z of local l0 {
			
			if "`addtitles'" != "" {
				
				mata b1_`z'[.,4] = b1_`z'[.,4] :- (`titlegap' :* (b1_`z'[.,4] :> `titlegap' * 2.5))
			}
			
			levelsof var1_o if var0_o==`z', local(l1)
			foreach y of local l1 {
				
					mata: mydata = select(st_data(., ("var2_v", "var0_o", "var1_o")), st_data(., "var2_t = 1"))
					mata: mydata = select(mydata, mydata[.,2] :== `z' :& mydata[.,3] :== `y')				
					mata: pad2b = `pad2'; pad2t = `pad2'; pad2l = `pad2'; pad2r = `pad2'
					mata: b2_`z'_`y' = processchildren(`y', mydata[.,1], b1_`z', pad2b, pad2t, pad2l, pad2r, myratio)
					mata: c2_`z'_`y' = getcoords2(mydata[.,1], b2_`z'_`y', pad2b, pad2t, pad2l, pad2r, datasum)
					mata: st_matrix("c2_`z'_`y'", c2_`z'_`y')		
				
				mat colnames c2_`z'_`y' = "_l2_`z'_`y'_x" "_l2_`z'_`y'_y" "_l2_`z'_`y'_id" "_l2_`z'_`y'_val" "_l2_`z'_`y'_xmid" "_l2_`z'_`y'_ymid" "_l2_`z'_`y'_xmax" "_l2_`z'_`y'_ymax" "_l2_`z'_`y'_wgt"  "_l2_`z'_`y'_pct"
				svmat c2_`z'_`y', n(col)
					
				// get the labels	
				gen  _l2_`z'_`y'_lab1 = ""
				levelsof var2_o if var0_o==`z' & var1_o==`y', local(l2)
				local item2 = `r(r)'
				foreach i of local l2 {
					summ id if var2_o==`i' & var1_o==`y' & var0_o==`z' & var2_t==1, meanonly
					replace  _l2_`z'_`y'_lab1 = `var2'[r(mean)] in `i'						
				}
				
				
				gen  _l2_`z'_`y'_lab0 = ""
				gen  _l2_`z'_`y'_lab2 = ""
				
				if "`novalues'"=="" & "`share'"=="" {
					replace  _l2_`z'_`y'_lab0 = "{it:" + _l2_`z'_`y'_lab1 + " (" + string(_l2_`z'_`y'_val, "`format'") + ")}" in 1/`item2' if _l2_`z'_`y'_val >= `labcond'  
					replace  _l2_`z'_`y'_lab2 = string(_l2_`z'_`y'_val, "`format'") in 1/`item2'  if _l2_`z'_`y'_val >= `labcond' 
				}
				
				
				if "`novalues'"=="" & "`share'"!="" {
					replace  _l2_`z'_`y'_lab0 = "{it:" + _l2_`z'_`y'_lab1 + " (" + string(_l2_`z'_`y'_val, "`format'") + " ," + string(_l2_`z'_`y'_pct, "`sformat'") + "%)}" in 1/`item2' if _l2_`z'_`y'_val >= `labcond'
					replace  _l2_`z'_`y'_lab2 = string(_l2_`z'_`y'_val, "`format'") + " (" + string(_l2_`z'_`y'_pct, "`sformat'") + "%)" in 1/`item2'  if _l2_`z'_`y'_val >= `labcond' 
				}
				
				if "`novalues'"!="" & "`share'"!="" {
					replace  _l2_`z'_`y'_lab0 = "{it:" + _l2_`z'_`y'_lab1 + " (" + string(_l2_`z'_`y'_val, "`sformat'") + "%)}" in 1/`item2' if _l2_`z'_`y'_pct >= `labcond'  
					replace  _l2_`z'_`y'_lab2 = string(_l2_`z'_`y'_pct, "`sformat'") + "%" in 1/`item2'  if _l2_`z'_`y'_pct >= `labcond' 
				}
				
				if "`novalues'"!="" & "`share'"=="" {
					replace  _l2_`z'_`y'_lab0 = "{it:" + _l2_`z'_`y'_lab1 + "}" in 1/`item2' if _l2_`z'_`y'_val >= `labcond' 
				}								
				
			
				// wrap
				if "`wrap'" != "" {
					
					// layer 0
					gen _length0 = length(_l2_`z'_`y'_lab0) if _l2_`z'_`y'_lab0 != ""
					summ _length0, meanonly		
					local _wraprounds0 = floor(`r(max)' / `wrap')
					
					forval i = 1 / `_wraprounds0' {
						local wraptag = `wrap' * `i'
						replace _l2_`z'_`y'_lab0  = substr(_l2_`z'_`y'_lab0, 1, `wraptag') + "`=char(10)'" + substr(_l2_`z'_`y'_lab0, `=`wraptag' + 1', .) if _length0 > `wraptag' & _length0!=. 
					}
					
					// layer 1
					gen _length1 = length(_l2_`z'_`y'_lab1) if _l2_`z'_`y'_lab1 != ""
					summ _length1, meanonly		
					local _wraprounds0 = floor(`r(max)' / `wrap')
					
					forval i = 1 / `_wraprounds0' {
						local wraptag = `wrap' * `i'
						replace _l2_`z'_`y'_lab1  = substr(_l2_`z'_`y'_lab1, 1, `wraptag') + "`=char(10)'" + substr(_l2_`z'_`y'_lab1, `=`wraptag' + 1', .) if _length1 > `wraptag' & _length1!=. 
					}					
					
					
					// layer 2
					gen _length2 = length(_l2_`z'_`y'_lab2) if _l2_`z'_`y'_lab2!= ""
					summ _length2, meanonly		
					local _wraprounds2 = floor(`r(max)' / `wrap')
					
					forval i = 1 / `_wraprounds2' {
						local wraptag = `wrap' * `i'
						replace _l2_`z'_`y'_lab2 = substr(_l2_`z'_`y'_lab2, 1, `wraptag') + "`=char(10)'" + substr(_l2_`z'_`y'_lab2, `=`wraptag' + 1', .) if _length2 > `wraptag' & _length2!=. 
					}		
					
					drop _length*
				}
				
			}
		}		
	}	
	

	
	**************
	//   draw   //
    **************	


	
	if "`palette'" == "" {
		local palette tableau
	}
	else {
		tokenize "`palette'", p(",")
		local palette  `1'
		local poptions `3'
	}
	
	if "`labgap'" == "" local labgap 0.2

	
	***************
	*** layer 0 ***
	***************
	
	levelsof var0_o
	local lvl0 = `r(r)'
	
		forval i = 1/`lvl0' {
			
			if "`titleprop'" != "" {
				local labt0 = max((`ls0' * _l0_wgt[`i']^`labscale'),0)
			}
			else {
				local labt0 = `ls0'
			}	
			
			if "`labprop'" != "" {
				local labs0 = (`ls0' * _l0_wgt[`i']^`labscale')
			}
			else {
				local labs0 = `ls0'
			}
			
						
			local clr0 `i'

			summ var0_c if var0_o==`i', meanonly
			local clr0 `r(mean)'

			
			colorpalette `palette', n(`lvl0') `poptions' nograph 
			
			local box0 `box0' (area _l0_y _l0_x if _l0_id==`i', nodropbase fi(`fi0') fc("`r(p`clr0')'") lw(`lw0') lc(`lc0'))  ||
			
			local lab0_box `lab0_box' (scatter _l0_ymax _l0_xmax in `i'  if _l0_val >= `labcond', mc(none) mlab(_l0_lab0) mlabpos(4) mlabsize(`labt0') mlabc(black) )
			
			local lab0 `lab0'         (scatter _l0_ymid _l0_xmid in `i'  if _l0_val >= `labcond', mc(none) mlab(_l0_lab1) mlabpos(0) mlabsize(`labs0') mlabc(black) ) || 
			
			if "`novalues'"=="" | "`share'"!="" local lab0 `lab0' (scatter _l0_ymid _l0_xmid in `i' if _l0_val > `labcond', mc(none) mlab(_l0_lab2) mlabpos(6) mlabsize(`labs0') mlabgap(`labgap') mlabc(black) ) ||
			
			***************
			*** layer 1 ***
			***************
			
			if `length' > 1 {
			
				qui levelsof var1_o if var0_o==`i'
				local lvl1 = r(r)
					
				forval j = 1/`lvl1' {

					if "`titleprop'" != "" {
						local labt1 = max((`ls1' * _l1_`i'_wgt[`j']^`labscale'),0)
					}
					else {
						local labt1 = `ls1'
					}				
							
					if "`labprop'" != "" {
						local labs1 = max((`ls1' * _l1_`i'_wgt[`j']^`labscale'),0)
					}
					else {
						local labs1 = `ls1'
					}
						
					colorpalette `palette', n(`lvl0') `poptions' nograph
					local clr `r(p`clr0')'
					
					if "`colorprop'" != "" & `length'==2 {			
						colorpalette "`r(p`clr0')'" "`r(p`clr0')'%`fade'", n(`lvl1') `poptions' nograph  
						local clr `r(p`j')'
					}

							
					local box1 `box1' (area _l1_`i'_y _l1_`i'_x if _l1_`i'_id==`j', nodropbase fi(`fi1') fc("`clr'") lw(`lw1') lc(`lc1'))  ||   
					
					local lab1_box `lab1_box' (scatter _l1_`i'_ymax _l1_`i'_xmax in `j' if _l1_`i'_val >= `labcond', mc(none) mlab(_l1_`i'_lab0) mlabpos(4) mlabsize(`labt1') mlabc(black) )
					
					local lab1 `lab1'         (scatter _l1_`i'_ymid _l1_`i'_xmid in `j' if _l1_`i'_val >= `labcond', mc(none) mlab(_l1_`i'_lab1) mlabpos(0) mlabsize(`labs1') mlabc(black) ) || 
							
					if "`novalues'"=="" | "`share'"!="" local lab1 `lab1' (scatter _l1_`i'_ymid _l1_`i'_xmid  in `j' if _l1_`i'_val >= `labcond', mc(none) mlab(_l1_`i'_lab2) mlabpos(6) mlabsize(`labs1') mlabgap(`labgap') mlabc(black) ) ||
					
					
					***************
					*** layer 2 ***
					***************
					
					if `length' > 2 {
				
						qui levelsof var2_o if var0_o==`i' & var1_o==`j'
						local lvl2 = r(r)
							
						forval k = 1/`lvl2' {
	
							if "`labprop'" != "" {
								local labs2 = max((`ls2' * _l2_`i'_`j'_wgt[`k']^`labscale'),0)
							}
							else {
								local labs2 = `ls2'
							}						
						
							colorpalette `palette', n(`lvl0') `poptions' nograph
							local clr `r(p`clr0')'
							
							if "`colorprop'" != "" {			
								colorpalette "`r(p`clr0')'" "`r(p`clr0')'%`fade'", n(`lvl2') `poptions' nograph 	
								local clr `r(p`k')'
							}								
							
							local box2 `box2' (area _l2_`i'_`j'_y _l2_`i'_`j'_x if _l2_`i'_`j'_id==`k', nodropbase fi(`fi2') fc("`clr'") lw(`lw2') lc(`lc2'))   ||
							
							local lab2 `lab2' (scatter _l2_`i'_`j'_ymid _l2_`i'_`j'_xmid in `k'  if _l2_`i'_`j'_val >= `labcond', mc(none) mlab(_l2_`i'_`j'_lab1) mlabpos(0) mlabsize(`labs2') mlabc(black) ) ||	
							
							if "`novalues'"=="" | "`share'"!="" local lab2 `lab2' (scatter _l2_`i'_`j'_ymid _l2_`i'_`j'_xmid in `k', mc(none) mlab(_l2_`i'_`j'_lab2) mlabpos(6) mlabsize(`labs2') mlabgap(`labgap') mlabc(black) ) ||			
						
						}
					}
				}
			}
		}


		if `length' == 3 {
			local mylab  `lab2'	
			if "`addtitles'" != "" local boxlab `lab1_box' || `lab0_box'
		} 
			else if `length' == 2 {
				local mylab  `lab1'
				if "`addtitles'" != "" local boxlab `lab0_box'
			}
				else {
					local mylab  `lab0'
					local boxlab
				}
		
		if "`nolabels'" != "" local mylab

		*** Final plot ***

		twoway ///
			`box0' ///
			`box1' ///
			`box2' ///
			`mylab' ///
			`boxlab' ///
				, ///
				legend(off)  ///
				xscale(off) yscale(off) ///
				xlabel(, nogrid) ylabel(, nogrid) ///
				xsize(`xsize') ysize(`ysize')	///
				`options'
		
	*/	
restore		
}		

// drop the Mata junk
mata mata drop data datasum dx dy myratio normlist xmax ymax xmin ymin pad* b* c* 
	

end


***************************
*** Mata sub-routines   ***
***************************



*********************
// 	  normdata     //  
*********************

cap mata mata drop normdata()

mata:
	real matrix normdata(data, dx, dy)
	{
		return (data :* (dx * dy) :/ sum(data))
	}
end


*********************
// 	  layoutrow    //  slice
*********************

cap mata mata drop layoutrow()

mata:
real matrix layoutrow(data, x, y, dx, dy)
	{
		area = sum(data)
		width = area / dy
		slices = J(rows(data), 4, .)  // x, y, dx, dy
		
		for (i=1; i<= rows(data); i++) {		
			slices[i, .] = (x, y, width, data[i] / width)	
			if (i > 1) slices[i, 2] = slices[i-1, 2] + data[i-1] / width
		}
		return (slices)
	}
end


*********************
// 	  layoutcol    //  
*********************

cap mata mata drop layoutcol()

mata:
real matrix layoutcol(data, x, y, dx, dy)
	{
		area = sum(data)
		height = area / dx
		slices = J(rows(data), 4, .)  // x, y, dx, dy
				
		for (i=1; i<= rows(data); i++) {
			slices[i, .] = (x , y, data[i] / height, height)
			if (i > 1) slices[i, 1] = slices[i-1, 1] +  data[i-1] / height			
		}
		return (slices)
	}
end



*********************
// 	    layout     //  
*********************

cap mata mata drop layout()

mata:
real matrix layout(data, x, y, dx, dy)
	{
		if (dx >= dy) {
			return (layoutrow(data, x, y, dx, dy))
		}
		else {
			return (layoutcol(data, x, y, dx, dy))
		}
	}
end


*************************
// 	  leftover row     //  
*************************

cap mata mata drop leftoverrow()

mata:
real matrix leftoverrow(data, x, y, dx, dy)
	{
		covered_area = sum(data)
		width        = covered_area / dy
		leftover_x   = x  + width
		leftover_y   = y
		leftover_dx  = dx - width
		leftover_dy  = dy
		return (leftover_x, leftover_y, leftover_dx, leftover_dy)
	}
end


*************************
// 	  leftover col     //  
*************************

cap mata mata drop leftovercol()

mata:
real matrix leftovercol(data, x, y, dx, dy)
	{
		covered_area = sum(data)
		height       = covered_area / dx
		leftover_x   = x
		leftover_y   = y  + height
		leftover_dx  = dx
		leftover_dy  = dy - height
		return (leftover_x, leftover_y, leftover_dx, leftover_dy)
	}

end

*************************
// 	    leftover       //  
*************************

cap mata mata drop leftover()

mata:
real matrix leftover(data, x, y, dx, dy)
	{
		if (dx >= dy) {
			return (leftoverrow(data, x, y, dx, dy))
		}
		else {
			return (leftovercol(data, x, y, dx, dy))
		}
	}
end



*************************
// 	  worst_ratio      //  
*************************

cap mata mata drop worst_ratio()

mata:
real scalar worst_ratio(data, x, y, dx, dy, rat)
	{
	sumval 	  = sum(data) 
	minval    = sumval
	maxval    = sumval
	temp      = layout(data, x, y, dx, dy)
	ratiolist = J(rows(temp), 1, .)
	
	for (i=1; i<= rows(data); i++) {
		ratiolist[i] = max((temp[i,3] :/ temp[i,4], temp[i,4] :/ temp[i,3])) 
		
		if (data[i] < minval) minval = data[i]
		if (data[i] > maxval) maxval = data[i]	
	}
	
	// alph = max(ratiolist) 
	// beta = sumval :* sumval :* alph
	// return (max((maxval / beta, beta / minval)))
	
	 return (max(ratiolist))
}
end



*************************
// 	    squarify       //  
*************************

cap mata mata drop squarify()

mata:
function squarify(data, x, y, dx, dy, myratio)
{
	if (rows(data) == 1) return (layout(data, x, y, dx, dy))

	leftover_x = .
  	leftover_y = .
	leftover_dx = .
	leftover_dy = .
	
	i = 1

	while ((i < rows(data)) & (worst_ratio(data[1 .. i], x, y, dx, dy, myratio) >= worst_ratio(data[1 .. i + 1], x, y, dx, dy, myratio))) i = i + 1	
		
	current 	= data[1   ..          i]
	remaining 	= data[i+1 .. rows(data)]

	leftover_x  = leftover(current, x, y, dx, dy)[1]
	leftover_y  = leftover(current, x, y, dx, dy)[2]
	leftover_dx = leftover(current, x, y, dx, dy)[3]
	leftover_dy = leftover(current, x, y, dx, dy)[4]
	 
	return (layout(current, x, y, dx, dy) \ squarify(remaining, leftover_x, leftover_y, leftover_dx, leftover_dy, myratio)) 
}	

end

*************************
// 	  processchildren  //  
*************************


cap mata mata drop processchildren()

mata:
	function processchildren(index, data, bounds, padb, padt, padl, padr, myratio) 
	{	
		xmin  = bounds[index,.][1] + padl
		ymin  = bounds[index,.][2] + padb 
		dx 	  = bounds[index,.][3] - padl - padr
		dy 	  = bounds[index,.][4] - padb - padt

		normlist = normdata(data, dx, dy)
		return (squarify(normlist, xmin, ymin, dx, dy, myratio), normlist)
	}
end



*************************
// 	    getcoords2     //   
*************************


cap mata mata drop getcoords2()

mata:
	real matrix getcoords2(data, b2, padb, padt, padl, padr, mysum) // data, bounds, padding
	{
	coords = J(5 * rows(b2), 10, .)  // rows = 4x coordinates + 1 empty, 8 cols = x,y,index, value, xmean, ymean, xmax, ymax, weight, percentage
	
		for (i=1; i<= rows(b2); i++) {	
			
			y = i * 5
			x = y - 4		
			tt = (b2[i,1] + padl, b2[i,2] + padb \ b2[i,1] + padl, b2[i,2] + b2[i,4] - padt \ b2[i,1] + b2[i,3] - padr, b2[i,2] + b2[i,4] - padt \ b2[i,1] + b2[i,3] - padr, b2[i,2] + padb \ ., .)		
				coords[x::y, 1..2] = tt   
				coords[x::y, 3] = J(5,1,i)
				coords[i, 4] = data[i]
				coords[i, 5] = mean(select(coords[.,1], coords[.,3] :== i))
				coords[i, 6] = mean(select(coords[.,2], coords[.,3] :== i))
				coords[i, 7] =  min(select(coords[.,1], coords[.,3] :== i)) 
				coords[i, 8] =  max(select(coords[.,2], coords[.,3] :== i))	
				coords[i, 9] = b2[i,5]
				coords[i,10] = (data[i] / mysum) * 100
		}

	return (coords)		
}
end



*******************
*******************
***		        ***
***		END     ***
***		        ***
*******************
*******************
