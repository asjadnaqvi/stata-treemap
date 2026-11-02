*! treemap v1.8 (02 Nov 2026)
*! Asjad Naqvi (asjadnaqvi@gmail.com)

* v1.8 (02 Nov 2026): Use one arbitrary-depth engine for all hierarchies. Streamline layout and coordinate calculations.
* v1.71 (02 Nov 2026): Preserve double precision in aggregation and matrix-to-variable conversions.
* v1.7 (22 Feb 2026): Added method(), ratio(), labangle(), and orient().
* v1.62 (23 Sep 2025): Minor fixes.
* v1.61 (21 Oct 2024): Added stat() option.
* v1.6 (08 Oct 2024): wrap() list integration via graphfunctions. Weights allowed. titlestyle(bold italic).
* v1.55 (10 Jun 2024): wrap() for label wraps.
* v1.54 (20 Apr 2024): colorby() fixed. Requires a variable name for the color order.
* v1.53 (10 Apr 2024): Fixed drawings when a third layer was defined.
* v1.52 (20 Jan 2024): Empty by() rows dropped by default.
* v1.51 (24 Oct 2023): Stabilized sorting for categories with equal totals.
* v1.5 (22 Jul 2023): saving(), values and shares, performat(), noval + share defaults labcond to percent.
* v1.42 (15 May 2023): Help file fix. Minor corrections.
* v1.41 (15 Feb 2023): "Rest of ..." fix.
* v1.4 (22 Jan 2023): threshold(), descending order, share, fade(), colorby(), padding fixes.
* v1.3 (14 Dec 2022): Label formatting, percent, labgap().
* v1.21 (22 Nov 2022): Fixed dropping categories with duplicate values.
* v1.2 (22 Sep 2022): Negative values check and fill intensity.
* v1.1 (13 Sep 2022): Label, color, title scaling and additional controls.
* v1.0 (08 Sep 2022): First release.

capture program drop treemap
program define treemap, sortpreserve rclass
	version 15
	syntax varlist(numeric max=1) [if] [in] [aw fw pw iw/], by(varlist min=1) ///
		[ XSize(real 5) YSize(real 3) format(str) palette(string) NOTitles NOVALues NOLABels ] ///
		[ pad(numlist >=0) labprop titleprop labscale(real 0.3333) labcond(real 0) colorprop titlegap(real 0.1) ///
		  LINEWidth(string) LINEColor(string) LABSize(string) fi(numlist >=0 <=100) LABGap(string) ] ///
		[ share THRESHold(numlist max=1 >=0) fade(real 10) percent colorby(varname) sharevar(varname) * ] ///
		[ wrap(numlist >=0) TITLESTYle(string) stat(string) METHOD(string) RATio(real 1.618034) ///
		  LABAngle(numlist) ORIENT(string) ]

	if "`stat'" == "" local stat sum
	if !inlist("`stat'", "mean", "sum") {
		display as error "Valid options are {bf:stat(mean)} or {bf:stat(sum) [default]}."
		exit 198
	}
	if missing(`ratio') | `ratio' <= 0 {
		display as error "ratio() must be greater than 0."
		exit 198
	}
	if missing(`xsize', `ysize', `titlegap') | `xsize' <= 0 | `ysize' <= 0 | `titlegap' < 0 {
		display as error "xsize() and ysize() must be positive; titlegap() must be nonnegative."
		exit 198
	}
	if "`threshold'" == "" local threshold 0
	if "`method'" == "" local method squarify
	if "`orient'" == "" local orient br
	if "`pad'" == "" local pad 0.01
	if "`linewidth'" == "" local linewidth 0.03
	if "`linecolor'" == "" local linecolor black
	if "`labsize'" == "" local labsize 1.6
	if "`labangle'" == "" local labangle 0
	if "`wrap'" == "" local wrap 0
	if "`labgap'" == "" local labgap 0.2
	if "`format'" == "" {
		local format "%12.2fc"
		if "`share'`percent'" != "" local format "%4.2f"
	}
	local depth : word count `by'
	local firstby : word 1 of `by'
	tempname tm_params
	matrix `tm_params' = J(`depth', 3, .)
	foreach opt in method orient pad fi linewidth linecolor labsize labangle wrap titlestyle {
		local `opt'count : word count ``opt''
	}
	forvalues d = 1/`depth' {
		foreach opt in method orient pad linewidth linecolor labsize labangle wrap {
			local ix = min(`d', ``opt'count')
			local `opt'`d' : word `ix' of ``opt''
		}
		local md = lower("`method`d''")
		if !inlist("`md'", "squarify", "slice", "dice") {
			display as error "Valid options for method() are squarify, slice, or dice."
			exit 198
		}
		local od = lower("`orient`d''")
		if !inlist("`od'", "br", "bl", "tr", "tl", "bottomright", "bottomleft", "topright", "topleft") {
			display as error "Valid options for orient() are br, bl, tr, tl, bottomright, bottomleft, topright, or topleft."
			exit 198
		}
		local mf = cond("`md'" == "squarify", 1, cond("`md'" == "slice", 2, 3))
		local of = cond(inlist("`od'", "br", "bottomright"), 1, ///
			cond(inlist("`od'", "bl", "bottomleft"), 2, cond(inlist("`od'", "tr", "topright"), 3, 4)))
		matrix `tm_params'[`d', 1] = `pad`d''
		matrix `tm_params'[`d', 2] = `mf'
		matrix `tm_params'[`d', 3] = `of'
		local fi`d' 100
		if `depth' == 2 local fi`d' = cond(`d' == 1, 60, 90)
		if `depth' >= 3 local fi`d' = 50 + 50 * (`d' - 1) / (`depth' - 1)
		if `ficount' > 0 {
			local ix = min(`d', `ficount')
			local fi`d' : word `ix' of `fi'
		}
		if `titlestylecount' > 0 {
			local ix = min(`d', `titlestylecount')
			local style`d' : word `ix' of `titlestyle'
			if !inlist("`style`d''", "bold", "b", "italic", "i") {
				display as error "Valid options for titlestyle() are bold or italic."
				exit 198
			}
		}
	}
	local needwrap 0
	foreach wr of numlist `wrap' {
		if `wr' > 0 local needwrap 1
	}
	if `needwrap' {
		capture findfile labsplit.ado
		if _rc != 0 quietly ssc install graphfunctions, replace
	}

	marksample touse, strok
	preserve
	quietly {
		keep if `touse'
		summarize `varlist', meanonly
		if r(min) <= 0 noisily display as text "`varlist' contains zeros or negative values. These values have been dropped."
		drop if `varlist' <= 0 | missing(`varlist')
		tempvar inputvalue inputweight colororder
		generate double `inputvalue' = `varlist'
		if "`weight'" != "" {
			generate double `inputweight' = `exp'
			local myweight [`weight' = `inputweight']
			local weightvar `inputweight'
		}
		if "`colorby'" != "" {
			egen long `colororder' = group(`colorby')
		}
		else generate long `colororder' = 1
		local groups
		foreach v of local by {
			tempvar group
			capture confirm string variable `v'
			if !_rc generate `group' = `v'
			else {
				if "`: value label `v''" != "" decode `v', generate(`group')
				else generate `group' = string(`v')
				drop if missing(`v')
			}
			drop if `group' == ""
			local groups `groups' `group'
		}
		count
		if r(N) == 0 {
			noisily display as error "no positive, nonmissing observations with complete by() values"
			exit 2000
		}
		keep `inputvalue' `groups' `colororder' `weightvar'
		rename `inputvalue' __tm_input
		rename `colororder' __tm_colorby
		local by
		forvalues d = 1/`depth' {
			local v : word `d' of `groups'
			rename `v' __tm_group`d'
			local by `by' __tm_group`d'
		}
		collapse (`stat') __tm_input (min) __tm_colorby `myweight', by(`by')
		if `threshold' > 0 {
			if `depth' > 1 {
				local prev = `depth' - 1
				local rest `" "Rest of " + __tm_group`prev' "'
			}
			if `depth' == 1 {
				replace __tm_group1 = "Rest of `firstby'" if __tm_input <= `threshold'
			}
			else replace __tm_group`depth' = `rest' if __tm_input <= `threshold'
			collapse (`stat') __tm_input (min) __tm_colorby, by(`by')
		}

		local prefix
		forvalues d = 1/`depth' {
			local v __tm_group`d'
			local prefix `prefix' `v'
			egen long __tm_id`d' = group(`prefix')
			if `d' == 1 generate long __tm_parent`d' = 0
			else {
				local prev = `d' - 1
				generate long __tm_parent`d' = __tm_id`prev'
			}
			bysort `prefix': egen double __tm_value`d' = total(__tm_input)
			egen byte __tm_tag`d' = tag(`prefix')
			bysort `prefix': egen long __tm_color`d' = min(__tm_colorby)
			gsort __tm_parent`d' -__tm_value`d' `v'
			by __tm_parent`d': generate long __tm_order`d' = sum(__tm_tag`d')
		}

		tempfile tm_nodes
		tempname tm_post
		postfile `tm_post' long __depth __id __parent double __value ///
			long __order __colororder str2045 __tm_name using `tm_nodes', replace
		forvalues d = 1/`depth' {
			forvalues obs = 1/`=_N' {
				if __tm_tag`d'[`obs'] {
					post `tm_post' (`d') (__tm_id`d'[`obs']) (__tm_parent`d'[`obs']) ///
						(__tm_value`d'[`obs']) (__tm_order`d'[`obs']) ///
						(__tm_color`d'[`obs']) (__tm_group`d'[`obs'])
				}
			}
		}
		postclose `tm_post'
		use `tm_nodes', clear

		foreach v in x y depth node parent value weight pct cx cy tx ty root order colororder {
			generate double __tm_`v' = .
		}
		local nnode = _N
		local addtitleflag = ("`notitles'" == "" & "`nolabels'" == "")
		mata: treemap_layout_any(`xsize', `ysize', `addtitleflag', `titlegap', `ratio', "`tm_params'")
		drop in 1/`nnode'
		drop __depth __id __parent __value __order __colororder
		generate str2045 __tm_lab = ""
		if "`novalues'" != "" {
			if "`share'`percent'" != "" {
				replace __tm_lab = __tm_name + " (" + string(__tm_pct, "`format'") + "%)" ///
					if __tm_pct >= `labcond'
			}
			else replace __tm_lab = __tm_name if __tm_value >= `labcond'
		}
		else {
			if "`share'`percent'" != "" {
				replace __tm_lab = __tm_name + " (" + string(__tm_value, "`format'") + ", " + ///
					string(__tm_pct, "`format'") + "%)" if __tm_value >= `labcond'
			}
			else replace __tm_lab = __tm_name + " (" + string(__tm_value, "`format'") + ")" ///
				if __tm_value >= `labcond'
		}
		forvalues d = 1/`depth' {
			if `wrap`d'' > 0 {
				tempvar wrapped
				labsplit __tm_lab, wrap(`wrap`d'') gen(`wrapped')
				replace __tm_lab = `wrapped' if __tm_depth == `d'
				drop `wrapped'
			}
			if inlist("`style`d''", "bold", "b") ///
				replace __tm_lab = "{bf:" + __tm_lab + "}" if __tm_depth == `d' & __tm_lab != ""
			if inlist("`style`d''", "italic", "i") ///
				replace __tm_lab = "{it:" + __tm_lab + "}" if __tm_depth == `d' & __tm_lab != ""
		}

		generate long __tm_row = _n
		generate str80 __tm_color = ""
		levelsof __tm_node if __tm_depth == 1, local(roots)
		local nroot : word count `roots'
		if "`colorby'" != "" egen long __tm_colorrank = group(__tm_colororder) if __tm_depth == 1
		if "`palette'" == "" local palette tableau
		local poptions
		if strpos("`palette'", ",") {
			tokenize "`palette'", p(",")
			local palette `1'
			local poptions `3'
		}
		colorpalette `palette', n(`nroot') `poptions' nograph
		forvalues ord = 1/`nroot' {
			local rootcolor`ord' `"`r(p`ord')'"'
		}
		foreach node of local roots {
			local sortcolor __tm_order
			if "`colorby'" != "" local sortcolor __tm_colorrank
			summarize `sortcolor' if __tm_depth == 1 & __tm_node == `node', meanonly
			local ord = r(min)
			replace __tm_color = `"`rootcolor`ord''"' if __tm_root == `node'
		}
		if "`colorprop'" != "" & `depth' > 1 {
			levelsof __tm_parent if __tm_depth == `depth', local(parents)
			foreach par of local parents {
				levelsof __tm_node if __tm_depth == `depth' & __tm_parent == `par', local(children)
				local nchild : word count `children'
				summarize __tm_row if __tm_depth == `depth' & __tm_parent == `par', meanonly
				local parentcolor = __tm_color[r(min)]
				colorpalette `"`parentcolor'"' `"`parentcolor'%`fade'"', n(`nchild') `poptions' nograph
				forvalues ord = 1/`nchild' {
					local gradient`ord' `"`r(p`ord')'"'
				}
				foreach node of local children {
					summarize __tm_order if __tm_depth == `depth' & __tm_node == `node', meanonly
					local ord = r(min)
					replace __tm_color = `"`gradient`ord''"' if __tm_depth == `depth' & __tm_node == `node'
				}
			}
		}

		local plots
		local labels
		forvalues d = 1/`depth' {
			levelsof __tm_node if __tm_depth == `d', local(ids)
			foreach node of local ids {
				summarize __tm_row if __tm_depth == `d' & __tm_node == `node', meanonly
				local row = r(min)
				local clr = __tm_color[`row']
				local plots `"`plots' (area __tm_y __tm_x if __tm_depth == `d' & __tm_node == `node', nodropbase fi(`fi`d'') fc("`clr'") lw(`linewidth`d'') lc(`linecolor`d''))"'
				if "`nolabels'" == "" & (`d' == `depth' | "`notitles'" == "") {
					local size `labsize`d''
					if (`d' == `depth' & "`labprop'" != "") | (`d' < `depth' & "`titleprop'" != "") {
						local size = `labsize`d'' * __tm_weight[`row']^`labscale'
					}
					local x __tm_cx
					local y __tm_cy
					local pos 0
					if `d' < `depth' {
						local x __tm_tx
						local y __tm_ty
						local pos 4
					}
					local labels `"`labels' (scatter `y' `x' in `row', mc(none) mlab(__tm_lab) mlabpos(`pos') mlabsize(`size') mlabgap(`labgap') mlabangle(`labangle`d'') mlabc(black))"'
				}
			}
		}
		noisily twoway `plots' `labels', legend(off) xscale(off) yscale(off) ///
			xlabel(, nogrid) ylabel(, nogrid) xsize(`xsize') ysize(`ysize') `options'
		restore
	}
	return local version "1.8"
	return local date "20261102"
end

capture mata mata drop normdata()
capture mata mata drop layoutrow()
capture mata mata drop layoutcol()
capture mata mata drop layout()
capture mata mata drop reorient()
capture mata mata drop worst_ratio()
capture mata mata drop squarify()
capture mata mata drop treemap_layout_any()

mata:
real matrix normdata(real colvector data, real scalar dx, real scalar dy)
{
	return(data :* (dx * dy) :/ sum(data))
}

real matrix layoutrow(real colvector data, real scalar x, real scalar y,
	real scalar dx, real scalar dy)
{
	real scalar width, i, offset
	real matrix slices
	width = sum(data) / dy
	slices = J(rows(data), 4, .)
	offset = y
	for (i = 1; i <= rows(data); i++) {
		slices[i, .] = (x, offset, width, data[i] / width)
		offset = offset + data[i] / width
	}
	return(slices)
}

real matrix layoutcol(real colvector data, real scalar x, real scalar y,
	real scalar dx, real scalar dy)
{
	real scalar height, i, offset
	real matrix slices
	height = sum(data) / dx
	slices = J(rows(data), 4, .)
	offset = x
	for (i = 1; i <= rows(data); i++) {
		slices[i, .] = (offset, y, data[i] / height, height)
		offset = offset + data[i] / height
	}
	return(slices)
}

real matrix layout(real colvector data, real scalar x, real scalar y,
	real scalar dx, real scalar dy)
{
	if (dx >= dy) return(layoutrow(data, x, y, dx, dy))
	return(layoutcol(data, x, y, dx, dy))
}

real matrix reorient(real matrix b, real scalar xmin, real scalar ymin,
	real scalar xmax, real scalar ymax, real scalar orientflag)
{
	if (orientflag == 2 | orientflag == 4) b[,1] = xmax :- (b[,1] :- xmin) :- b[,3]
	if (orientflag == 3 | orientflag == 4) b[,2] = ymax :- (b[,2] :- ymin) :- b[,4]
	return(b)
}

real scalar worst_ratio(real colvector data, real scalar dx, real scalar dy, real scalar rat)
{
	real scalar side, area, dxr, dyr
	dxr = dx
	dyr = dy
	if (dx >= dy) dxr = dx * rat
	else dyr = dy * rat
	side = min((dxr, dyr))
	area = sum(data)
	return(max((area^2 / (side^2 * min(data)), side^2 * max(data) / area^2)))
}

real matrix squarify(real colvector data, real scalar xinput, real scalar yinput,
	real scalar dxinput, real scalar dyinput, real scalar ratio)
{
	real matrix result, strip
	real colvector current
	real scalar first, last, n, score, candidate, area, x, y, dx, dy
	x = xinput
	y = yinput
	dx = dxinput
	dy = dyinput
	n = rows(data)
	result = J(n, 4, .)
	first = 1
	while (first <= n) {
		last = first
		score = worst_ratio(data[|first \ last|], dx, dy, ratio)
		while (last < n) {
			candidate = worst_ratio(data[|first \ last+1|], dx, dy, ratio)
			if (candidate > score) break
			score = candidate
			last++
		}
		current = data[|first \ last|]
		strip = layout(current, x, y, dx, dy)
		result[|first,1 \ last,4|] = strip
		area = sum(current)
		if (dx >= dy) {
			x = x + area / dy
			dx = dx - area / dy
		}
		else {
			y = y + area / dx
			dy = dy - area / dx
		}
		first = last + 1
	}
	return(result)
}

void treemap_layout_any(real scalar xsize, real scalar ysize,
	real scalar addtitles, real scalar titlegap, real scalar ratio, string scalar paramsname)
{
	real matrix nodes, params, bounds, out, b, corners, panel
	real colvector indices, roots, seq, values, ndata
	real scalar n, d, first, last, j, row, off, pad, dx, dy, xmin, ymin, parentrow, total
	real scalar method, orient, root, cellpad
	string colvector names, outnames

	nodes = st_data(., ("__depth", "__id", "__parent", "__value", "__order", "__colororder"))
	names = st_sdata(., "__tm_name")
	indices = order(nodes, (1, 3, 5))
	nodes = nodes[indices, .]
	names = names[indices]
	params = st_matrix(paramsname)
	n = rows(nodes)
	bounds = J(n, 6, .)
	roots = J(n, 1, .)
	out = J(5*n, 15, .)
	outnames = J(5*n, 1, "")
	// IDs are contiguous within each depth; this maps parent IDs directly to rows.
	panel = J(max(nodes[,1]), max(nodes[,2]), .)
	for (row = 1; row <= n; row++) panel[nodes[row,1], nodes[row,2]] = row
	total = sum(select(nodes[,4], nodes[,1] :== 1))

	first = 1
	while (first <= n) {
		d = nodes[first,1]
		last = first
		while (last < n) {
			if (nodes[last+1,1] != d | nodes[last+1,3] != nodes[first,3]) break
			last++
		}
		if (d == 1) {
			xmin = 0
			ymin = 0
			dx = xsize
			dy = ysize
		}
		else {
			parentrow = panel[d-1, nodes[first,3]]
			pad = bounds[parentrow,6]
			xmin = bounds[parentrow,1] + pad
			ymin = bounds[parentrow,2] + pad
			dx = bounds[parentrow,3] - 2*pad
			dy = bounds[parentrow,4] - 2*pad
			if (addtitles & bounds[parentrow,4] > titlegap*2.5) dy = dy - titlegap
		}
		pad = params[d,1]
		if (dx >= . | dy >= . | dx <= 0 | dy <= 0) {
			errprintf("insufficient space at hierarchy level %g; reduce pad() or titlegap(), or increase xsize()/ysize()\n", d)
			_error(198)
		}
		values = nodes[|first,4 \ last,4|]
		ndata = normdata(values, dx, dy)
		method = params[d,2]
		orient = params[d,3]
		if (method == 1) b = squarify(ndata, xmin, ymin, dx, dy, ratio)
		else if (method == 2) b = layoutrow(ndata, xmin, ymin, dx, dy)
		else b = layoutcol(ndata, xmin, ymin, dx, dy)
		b = reorient(b, xmin, ymin, xmin+dx, ymin+dy, orient), ndata
		for (row = first; row <= last; row++) {
			j = row - first + 1
			if (b[j,3] >= . | b[j,4] >= . | b[j,3] <= 0 | b[j,4] <= 0) {
				errprintf("nonpositive or missing rectangle size at hierarchy level %g\n", d)
				_error(198)
			}
			cellpad = min((pad, b[j,3]/4, b[j,4]/4))
			bounds[row,.] = (b[j,.], cellpad)
			if (d == 1) root = nodes[row,2]
			else root = roots[parentrow]
			roots[row] = root
			off = 5*(row-1)
			corners = (b[j,1]+cellpad, b[j,2]+cellpad \
				b[j,1]+cellpad, b[j,2]+b[j,4]-cellpad \
				b[j,1]+b[j,3]-cellpad, b[j,2]+b[j,4]-cellpad \
				b[j,1]+b[j,3]-cellpad, b[j,2]+cellpad \ ., .)
			out[|off+1,1 \ off+5,2|] = corners
			out[|off+1,3 \ off+5,8|] = J(5,1,1) *
				(d, nodes[row,2], nodes[row,3], nodes[row,4], b[j,5], 100*nodes[row,4]/total)
			out[off+1,9] = (corners[1,1] + corners[3,1])/2
			out[off+1,10] = (corners[1,2] + corners[3,2])/2
			out[off+1,11] = corners[1,1]
			out[off+1,12] = corners[3,2]
			out[|off+1,13 \ off+5,15|] = J(5,1,1) * (root, nodes[row,5], nodes[row,6])
			outnames[|off+1 \ off+5|] = J(5,1,names[row])
		}
		first = last + 1
	}
	st_addobs(5*n)
	seq = (n+1)::(6*n)
	st_store(seq, ("__tm_x", "__tm_y", "__tm_depth", "__tm_node", "__tm_parent",
		"__tm_value", "__tm_weight", "__tm_pct", "__tm_cx", "__tm_cy", "__tm_tx",
		"__tm_ty", "__tm_root", "__tm_order", "__tm_colororder"), out)
	st_sstore(seq, "__tm_name", outnames)
}
end
