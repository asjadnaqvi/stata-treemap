*! Treemap v1.0 beta
*! Asjad Naqvi (asjadnaqvi@gmail.com)
*
* 



cap prog drop treemap

prog def treemap, sortpreserve

	version 15
	
	syntax varlist(numeric max=1) [if] [in], by(varlist min=1 max=3)	 ///   
		[ WIDth(real 5) HEIght(real 3) pad(real 0.012) format(str) palette(string) ADDTitles NOVALues NOLABels cond(string) ]		///
		[ LABSize(real 2.2) title(passthru) subtitle(passthru) note(passthru) scheme(passthru) name(passthru) ]
		
	
	
	marksample touse, strok
	
	
qui {	
  preserve	
	keep if `touse'
	
	local length : word count `by'
	
	if `length' == 1 {
		local var0 `by'
		
		cap confirm string var `var0'
			if _rc!=0 {
				gen var0_temp = string(`var0')
				local var0 var0_temp
			}
		
		collapse (sum) `varlist', by(`var0') 
		
		gen var0_v = `varlist'
		gsort -var0_v
	}

	if `length' == 2 {
		tokenize `by'
		local var0 `2'
		local var1 `1'
		
		cap confirm string var `var0'
			if _rc!=0 {
				gen var0_temp = string(`var0')
				local var0 var0_temp
			}
			
		cap confirm string var `var1'
			if _rc!=0 {
				gen var1_temp = string(`var1')
				local var1 var1_temp
			}	
			
		
		collapse (sum) `varlist', by(`var0' `var1') 
		
		bysort `var0': egen var0_v = sum(`varlist')
		gen var1_v = `varlist'
		
		gsort -var0_v -var1_v
	}	
	
	if `length' == 3 {
		tokenize `by'
		local var0 `3'
		local var1 `2'
		local var2 `1'
		
		cap confirm string var `var0'
			if _rc!=0 {
				gen var0_temp = string(`var0')
				local var0 var0_temp
			}
			
		cap confirm string var `var1'
			if _rc!=0 {
				gen var1_temp = string(`var1')
				local var1 var1_temp
			}	
			
		cap confirm string var `var2'
			if _rc!=0 {
				gen var2_temp = string(`var2')
				local var2 var2_temp
			}		
			

		collapse (sum) `varlist', by(`var0' `var1' `var2')
		
		bysort `var0': egen var0_v = sum(`varlist')
		bysort `var1': egen var1_v = sum(`varlist')
		gen var2_v = `varlist'
		
		gsort -var0_v -var1_v -var2_v
	}
	

	gen id = _n		

	egen var0_t = tag(`var0')
	egen var0_o = group(var0_v) 
	levelsof var0_o
	replace var0_o = r(r) - var0_o + 1
	
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
		sort `var1' id 
		by `var1': gen var2_o = _n
		gen var2_t = 1	
	}

	sort id
	
	// set up the base values
	
	mata: xmin = 0; xmax = `width'; ymin = 0; ymax = `height'; dy = ymax - ymin; dx = xmax - xmin
	
	if "`format'" == "" local format %9.0fc
	
	**************
	**  layer0  **
    **************
	
	
	mata: data = select(st_data(., ("var0_v")), st_data(., "var0_t=1"))
	mata: padb = `pad'; padt = `pad'; padl = `pad'; padr = `pad'
	
	mata: normlist = normdata(data, dx, dy); b0 = squarify(normlist, xmin, ymin, dx, dy); c0 = getcoords2(data, b0, padb, padt, padl, padr)
	mata: st_matrix("c0", c0)
	
	cap drop _*
	local varlist 
	
	mat colnames c0 = "_l0_x" "_l0_y" "_l0_id" "_l0_val" "_l0_xmid" "_l0_ymid" "_l0_xmax" "_l0_ymax"
	
	mat li c0
	svmat c0, n(col)
	
	gen _l0_lab1  = ""

	levelsof var0_o, local(lvls)
	local item0 = `r(r)'
	foreach i of local lvls {
	
		summ id if var0_o==`i' & var0_t==1, meanonly
		replace  _l0_lab1 = `var0'[r(mean)] in `i'	
	}	
				
		gen  _l0_lab0 = "{it:" + _l0_lab1 + " (" + string(_l0_val, "`format'") + ")}"  in 1/`item0'
		gen  _l0_lab2 = string(_l0_val, "`format'") in 1/`item0'
		

		
	**************
	**  layer1  **
    **************	
	

	if `length' > 1 {
		
		if "`addtitles'" != "" mata b0[.,4] = b0[.,4] :- 0.1
		local pad = `pad' * 1.5
		
		local l0
		local l1
		
		levelsof var0_o, local(l0)

		foreach z of local l0 {
				
				mata: mydata = select(st_data(., ("var1_v", "var0_o")), st_data(., "var1_t = 1"))
				mata: mydata = select(mydata, mydata[.,2] :== `z')		
				mata: padb = `pad'; padt = `pad'; padl = `pad'; padr = `pad'

				mata: b1_`z' = processchildren(`z', mydata[.,1], b0, padb, padt, padl, padr)
				mata: c1_`z' = getcoords2(mydata[.,1], b1_`z', padb, padt, padl, padr)
				mata: st_matrix("c1_`z'", c1_`z')

			mat colnames c1_`z' = "_l1_`z'_x" "_l1_`z'_y" "_l1_`z'_id" "_l1_`z'_val" "_l1_`z'_xmid" "_l1_`z'_ymid" "_l1_`z'_xmax" "_l1_`z'_ymax"			
			svmat c1_`z', n(col)

			gen _l1_`z'_lab1  = ""
			levelsof var1_o if var0_o==`z', local(l1)
			local item1 = `r(r)'
			
			foreach i of local l1 {
				qui summ id if var1_o==`i' & var0_o==`z' & var1_t==1 , meanonly
				replace  _l1_`z'_lab1 = `var1'[r(mean)] in `i'	
			}
			
			gen  _l1_`z'_lab0 = "{it:" + _l1_`z'_lab1 + " (" + string(_l1_`z'_val, "`format'") + ")}"  in 1/`item1'
			gen  _l1_`z'_lab2 = string(_l1_`z'_val, "`format'") in 1/`item1'

		}
		
	}
	
		
	**************
	**  layer2  **
    **************		
		
	if `length' > 2 {	
		
		local pad = `pad' * 1.5
		
		local l0
		local l1
		local l2

		qui levelsof var0_o, local(l0)

		foreach z of local l0 {
			
			if "`addtitles'" != "" mata b1_`z'[.,4] = b1_`z'[.,4] :- 0.1
			
			qui levelsof var1_o if var0_o==`z', local(l1)
			foreach y of local l1 {
				
					mata: mydata = select(st_data(., ("var2_v", "var0_o", "var1_o")), st_data(., "var2_t = 1"))
					mata: mydata = select(mydata, mydata[.,2] :== `z' :& mydata[.,3] :== `y')				
					mata: padb = `pad'; padt = `pad'; padl = `pad'; padr = `pad'
					mata: b2_`z'_`y' = processchildren(`y', mydata[.,1], b1_`z', padb, padt, padl, padr)
					mata: c2_`z'_`y' = getcoords2(mydata[.,1], b2_`z'_`y', padb, padt, padl, padr)
					mata: st_matrix("c2_`z'_`y'", c2_`z'_`y')		
				

				mat colnames c2_`z'_`y' = "_l2_`z'_`y'_x" "_l2_`z'_`y'_y" "_l2_`z'_`y'_id" "_l2_`z'_`y'_val" "_l2_`z'_`y'_xmid" "_l2_`z'_`y'_ymid" "_l2_`z'_`y'_xmax" "_l2_`z'_`y'_ymax"
				svmat c2_`z'_`y', n(col)
					
				// get the labels	
				
				gen  _l2_`z'_`y'_lab1 = ""
				levelsof var2_o if var0_o==`z' & var1_o==`y', local(l2)
				local item2 = `r(r)'
				foreach i of local l2 {
		
					qui summ id if var2_o==`i' & var1_o==`y' & var0_o==`z' & var2_t==1 , meanonly
					replace  _l2_`z'_`y'_lab1 = `var2'[r(mean)] in `i'						
				}
				
				gen  _l2_`z'_`y'_lab0 = "{it:" + _l2_`z'_`y'_lab1 + " (" + string(_l2_`z'_`y'_val, "`format'") + ")}"  in 1/`item2'
				gen  _l2_`z'_`y'_lab2 = string(_l2_`z'_`y'_val, "`format'") in 1/`item2'
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
		local palette `1'
		local poptions `3'
	}
	
	local fi0 = 100
	
	if `length' == 2 {
		local fi0 = 60
		local fi1 = 90
	}	
	
	if `length' == 3 {
		local fi0 = 50
		local fi1 = 75
		local fi2 = 100
	}
	

	***************
	*** layer 0 ***
	***************
	
	levelsof var0_o
	local lvl0 = `r(r)'
	
		forval i = 1/`lvl0' {
			
			colorpalette `palette', n(`lvl0') `poptions' nograph 
			local box0 `box0' (area _l0_y _l0_x if _l0_id==`i', nodropbase fi(`fi0') fc("`r(p`i')'") lw(0.03) lc(black))  ||
			
			local lab0_box `lab0_box' (scatter _l0_ymax _l0_xmax in `i', mc(none) mlab(_l0_lab0) mlabpos(4) mlabsize(`labsize') mlabc(black) )
			
			local lab0 `lab0' (scatter _l0_ymid _l0_xmid in `i', mc(none) mlab(_l0_lab1) mlabpos(0) mlabsize(`labsize') mlabc(black) ) || 
			
			if "`novalues'" == "" local lab0 `lab0' (scatter _l0_ymid _l0_xmid in `i', mc(none) mlab(_l0_lab2) mlabpos(6) mlabsize(`labsize') mlabc(black) ) ||
			
			***************
			*** layer 1 ***
			***************
			
			if `length' > 1 {
			
				qui levelsof var1_o if var0_o==`i'
				local lvl1 = `r(r)'
					
				forval j = 1/`lvl1' {
						
					colorpalette `palette', n(`lvl0') `poptions' nograph 
					local box1 `box1' (area _l1_`i'_y _l1_`i'_x if _l1_`i'_id==`j', nodropbase fi(`fi1') fc("`r(p`i')'") lw(0.03) lc(black))  ||    //  lw(vthin) lc("`r(p`i')'"))
					
					local lab1_box `lab1_box' (scatter _l1_`i'_ymax _l1_`i'_xmax in `j', mc(none) mlab(_l1_`i'_lab0) mlabpos(4) mlabsize(`labsize') mlabc(black) )
					
					local lab1 `lab1' (scatter _l1_`i'_ymid _l1_`i'_xmid in `j', mc(none) mlab(_l1_`i'_lab1) mlabpos(0) mlabsize(`labsize') mlabc(black) ) || 
							
					if "`novalues'" == "" local lab1 `lab1' (scatter _l1_`i'_ymid _l1_`i'_xmid  in `j', mc(none) mlab(_l1_`i'_lab2) mlabpos(6) mlabsize(`labsize') mlabc(black) ) ||
					
					
					***************
					*** layer 2 ***
					***************
					
					if `length' > 2 {
				
						qui levelsof var2_o if var0_o==`i' & var1_o==`j'
						local lvl2 = `r(r)'
							
						forval k = 1/`lvl2' {
				
							colorpalette `palette', n(`lvl0') `poptions' nograph						
							local box2 `box2' (area _l2_`i'_`j'_y _l2_`i'_`j'_x if _l2_`i'_`j'_id==`k', nodropbase fi(`fi2') fc("`r(p`i')'") lw(0.03) lc(black))   ||
							
							local lab2 `lab2' (scatter _l2_`i'_`j'_ymid _l2_`i'_`j'_xmid in `k' , mc(none) mlab(_l2_`i'_`j'_lab1) mlabpos(0) mlabsize(`labsize') mlabc(black) ) ||	
							
							if "`novalues'" == "" local lab2 `lab2' (scatter _l2_`i'_`j'_ymid _l2_`i'_`j'_xmid in `k', mc(none) mlab(_l2_`i'_`j'_lab2) mlabpos(6) mlabsize(`labsize') mlabc(black) ) ||			
						
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
				xsize(`width') ysize(`height')	///
				`title' `subtitle' `note' `scheme'

restore		
}		

end


***************************
*** Mata sub-routines   ***
***************************


*********************
// 	  normdata     //  normalize list where sum of values equal 1
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
		width = covered_area / dy
		leftover_x = x + width
		leftover_y = y
		leftover_dx = dx - width
		leftover_dy = dy
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
		height = covered_area / dx
		leftover_x = x
		leftover_y = y + height
		leftover_dx = dx
		leftover_dy = dy - height
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
// 	  worst_ratio     //  
*************************

cap mata mata drop worst_ratio()

mata:
real scalar worst_ratio(data, x, y, dx, dy)
	{
	temp = layout(data, x, y, dx, dy)
	ratiolist = J(rows(temp), 1, .)
	
	for (i=1; i<= rows(data); i++) ratiolist[i] = max((temp[i,3] :/ temp[i,4], temp[i,4] :/ temp[i,3]))
	

	return (max(ratiolist))
}
end



*************************
// 	    squarify       //  
*************************

cap mata mata drop squarify()

mata:
function squarify(data, x, y, dx, dy)
{
	if (rows(data) == 1) return (layout(data, x, y, dx, dy))

	leftover_x = .
  	leftover_y = .
	leftover_dx = .
	leftover_dy = .
	
	i = 1

	while ((i < rows(data)) & (worst_ratio(data[1 .. i], x, y, dx, dy) >= worst_ratio(data[1 .. i + 1], x, y, dx, dy))) i = i + 1	
		
	current 	= data[1   ..          i]
	remaining 	= data[i+1 .. rows(data)]

	leftover_x  = leftover(current, x, y, dx, dy)[1]
	leftover_y  = leftover(current, x, y, dx, dy)[2]
	leftover_dx = leftover(current, x, y, dx, dy)[3]
	leftover_dy = leftover(current, x, y, dx, dy)[4]
	 
	return (layout(current, x, y, dx, dy) \ squarify(remaining, leftover_x, leftover_y, leftover_dx, leftover_dy)) 
}	

end


*************************
// 	  processchildren  //  
*************************


cap mata mata drop processchildren()

mata:
	function processchildren(index, data, bounds, padb, padt, padl, padr) 
	{	
		xmin  = bounds[index,.][1] + padl
		ymin  = bounds[index,.][2] + padb 
		dx 	  = bounds[index,.][3] - padl - padr
		dy 	  = bounds[index,.][4] - padb - padt

		normlist = normdata(data, dx, dy)
		return (squarify(normlist, xmin, ymin, dx, dy))
	}
end


*************************
// 	    getcoords      //   
*************************


cap mata mata drop getcoords()

mata:
	real matrix getcoords(b2, padb, padt, padl, padr)
	{
		coords = J(5, rows(b2) * 2, .)  
		
		for (i=1; i<= rows(b2); i++) {			
			b = i * 2
			a = b - 1
			coords[.,a..b] = (b2[i,1] + padl, b2[i,2] + padb \ b2[i,1] + padl, b2[i,2] + b2[i,4] - padt \ b2[i,1] + b2[i,3] - padr, b2[i,2] + b2[i,4] - padt \ b2[i,1] + b2[i,3] - padr, b2[i,2] + padb \ b2[i,1] + padl, b2[i,2] + padb)	
		}	

	return (coords)	
		
	}
end

*************************
// 	    getcoords2     //   
*************************


cap mata mata drop getcoords2()

mata:
	real matrix getcoords2(data, b2, padb, padt, padl, padr) // data, bounds, padding
	{
	coords = J(5 * rows(b2), 8, .)  // rows = 4x coordinates + 1 empty, 8 cols = x,y,index,value, xmean, ymean, xmax, ymax 
	
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
