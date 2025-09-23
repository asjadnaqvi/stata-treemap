
![treemap-1](https://github.com/asjadnaqvi/stata-treemap/assets/38498046/9b282b3f-8647-4f8d-9ef9-fb7f6ceb8e9e)


![StataMin](https://img.shields.io/badge/stata-2015-blue) ![issues](https://img.shields.io/github/issues/asjadnaqvi/stata-treemap) ![license](https://img.shields.io/github/license/asjadnaqvi/stata-treemap) ![Stars](https://img.shields.io/github/stars/asjadnaqvi/stata-treemap) ![version](https://img.shields.io/github/v/release/asjadnaqvi/stata-treemap) ![release](https://img.shields.io/github/release-date/asjadnaqvi/stata-treemap)


---

[Installation](#Installation) | [Syntax](#Syntax) | [Examples](#Examples) | [Feedback](#Feedback) | [Change log](#Change-log)

---

# treemap v1.62
(23 Sep 2025)

This package provides the ability to draw treemaps Stata.

It is based on D3's [treemap](https://observablehq.com/@d3/treemap) and Python's [squarify](https://github.com/laserson/squarify) algorithms.


## Installation

The package can be installed via SSC or GitHub. The GitHub version, *might* be more recent due to bug fixes, feature updates etc, and *may* contain syntax improvements and changes in *default* values. See version numbers below. Eventually the GitHub version is published on SSC.

The SSC version (**v1.6**):

```stata
ssc install treemap, replace
```

Or it can be installed from GitHub (**v1.62**):

```stata
net install treemap, from("https://raw.githubusercontent.com/asjadnaqvi/stata-treemap/main/installation/") replace
```

The `palettes` package is required to run this command:

```stata
ssc install palettes, replace
ssc install colrspace, replace
```

Even if you have the package installed, make sure that it is updated `ado update, update`.

If you want to make a clean figure, then it is advisable to load a clean scheme. These are several available and I personally use the following:

```stata
ssc install schemepack, replace
set scheme white_tableau  
```

You can also push the scheme directly into the graph using the `scheme(schemename)` option. See the help file for details or the example below.

I also prefer narrow fonts in figures with long labels. You can change this as follows:

```stata
graph set window fontface "Arial Narrow"
```


## Syntax

The syntax for the latest version is as follows:

```stata
treemap numvar [if] [in] [weight], by(variables (min=1 max=3)) 
                [ xsize(num) ysize(num) format(str) share|percent palette(it:str) colorby(var)
                  pad(list) labsize(list) linewidth(list) linecolor(list) fi(list) labcond(num)  
                  novalues nolabels labsize(num) labgap(str) addtitles titlegap(num) titlestyles(bold|italic)
                  threshold(num) fade(num) labprop titleprop labscale(num) colorprop wrap(numlist) * ] 
```

See the help file `help treemap` for details.

The most basic use is as follows:

```
treemap numvar, by(variable(s))
```


where `numvar` is a numeric variable, and `by()` is upto three string variables, ordered by higher aggregated levels to finer units. The algorithm changes the layout based on `xsize()` and `ysize()`. See examples below.



## Citation guidelines
Software packages take countless hours of programming, testing, and bug fixing. If you use this package, then a citation would be highly appreciated. Suggested citations:


*in BibTeX*

```
@software{treemap,
   author = {Naqvi, Asjad},
   title = {Stata package ``treemap''},
   url = {https://github.com/asjadnaqvi/stata-treemap},
   version = {1.6},
   date = {2024-10-09}
}
```

*or simple text*

```
Naqvi, A. (2024). Stata package "treemap" version 1.6. Release date 09 October 2024. https://github.com/asjadnaqvi/stata-treemap.
```


*or see [SSC citation](https://ideas.repec.org/c/boc/bocode/s459123.html) (updated once a new version is submitted)*




## Examples

Set up the data:

```stata
clear
set scheme white_tableau
graph set window fontface "Arial Narrow"

use "https://github.com/asjadnaqvi/stata-treemap/blob/main/data/demo_r_pjangrp3_2024.dta?raw=true", clear

```



```
treemap pop, by(nuts0) labsize(2.5) title("Population of European countries")
```

<img src="/figures/treemap1.png" width="100%">


```
treemap pop, by(nuts0) labsize(2.5) title("Population of European countries") noval
```

<img src="/figures/treemap2.png" width="100%">


### Dimensions

`treemap` is sensitive to changes in overall figure dimension:

```
treemap pop, by(nuts0) labsize(2) title("Population of European countries") noval xsize(4) ysize(4)
```

<img src="/figures/treemap3.png" width="100%">


```
treemap pop, by(nuts0) labsize(4) title("Population of European countries") noval xsize(5) ysize(2)
```

<img src="/figures/treemap4.png" height="400">


```
treemap pop, by(nuts0) labsize(5) title("Population of European countries") noval xsize(6) ysize(1)
```

<img src="/figures/treemap5.png" height="100">

```
treemap pop, by(nuts0_id nuts1_id) labsize(2) format(%15.0fc)
```

<img src="/figures/treemap6.png" width="100%">

```
treemap pop if nuts0_id=="AT", by(nuts2 nuts3_id) addtitles noval labsize(2) ///
format(%15.0fc) title("Population of Austria at NUTS2 and NUTS3 level") 
```

<img src="/figures/treemap7.png" width="100%">

```
treemap pop if nuts0_id=="NL", by(nuts2 nuts3_id) addtitles labsize(2) ///
format(%15.0fc) title("Population of Netherlands at NUTS2 and NUTS3 level") 
```

<img src="/figures/treemap8.png" width="100%">


```
treemap pop if nuts0_id=="NL", by(nuts2_id nuts3_id ) addtitles labsize(1.3) format(%15.0fc) ///
title("Population of Netherlands at NUTS2 and NUTS3 level") palette(CET L07, reverse) xsize(3) ysize(3)
```

<img src="/figures/treemap9.png" width="100%">

```
treemap  pop if nuts0_id=="NL", by(nuts2_id nuts3_id)  addtitles noval labsize(1.3) ///
format(%15.0fc) title("Population of Netherlands at NUTS2 and NUTS3 level") palette(CET L10) xsize(3) ysize(3)
```

<img src="/figures/treemap10.png" width="100%">

```
treemap pop if nuts0_id=="NL", by(nuts1 nuts2 nuts3_id)  addtitles noval labsize(1.3) ///
format(%15.0fc) title("Population of Netherlands at NUTS1-NUTS3 level") palette(CET L10) xsize(3) ysize(3)
```

<img src="/figures/treemap11.png" width="100%">

```
treemap pop if nuts0_id=="NO", by(nuts2 nuts3_id)  addtitles labsize(2) format(%15.0fc) ///
title("Population of Norway at NUTS2 and NUTS3 level") palette(CET L20) xsize(3) ysize(3) 
```

<img src="/figures/treemap12.png" width="100%">

```
treemap pop if nuts0_id=="NO", by(nuts3_id) addtitles labsize(2) format(%15.0fc) ///
title("Population of Norway at NUTS3 level") palette(CET L19) xsize(5) ysize(3) scheme(neon)
```

<img src="/figures/treemap13.png" width="100%">


### v1.1 updates

```
treemap pop, by(nuts0 nuts1_id) addtitles format(%15.0fc) title("Population of European countries")
```

<img src="/figures/treemap14.png" width="100%">

```
treemap pop, by(nuts0 nuts1_id) addtitles format(%15.0fc) title("Population of European countries") ///
labprop linew(0.02 0.1) linec(red blue)
```

<img src="/figures/treemap15.png" width="100%">

```
treemap pop, by(nuts0 nuts1_id) addtitles format(%15.0fc) title("Population of European countries") ///
labprop linew(none 0.1) linec(red black) labs(2)
```

<img src="/figures/treemap16.png" width="100%">

```
treemap pop, by(nuts0 nuts1_id) addtitles labsize(1.6 2.5) format(%15.0fc) title("Population of European countries") ///
labprop colorprop titleprop pad(0.008) 
```

<img src="/figures/treemap17.png" width="100%">

```
treemap pop, by(nuts0 nuts1 nuts2  ) format(%15.0fc) title("Population of European countries") nolab
```

<img src="/figures/treemap18.png" width="100%">

```
treemap pop, by(nuts0 nuts1 nuts2) format(%15.0fc) title("Population of European countries") nolab pad(0.015 0.015 0.01)
```

<img src="/figures/treemap19.png" width="100%">

```
treemap pop, by(nuts0) labsize(2.5) format(%15.0fc) title("Population of European countries") labprop labcond(5000000) 
```

<img src="/figures/treemap20.png" width="100%">

```stata
treemap pop, by(nuts0 nuts1_id) labsize(2.2) format(%15.0fc) title("Population of European countries") ///
labprop colorprop titleprop labcond(2000000) addtitles
```

<img src="/figures/treemap21.png" width="100%">

```stata
treemap pop, by(nuts0 nuts2_id) labsize(2.2) format(%15.0fc) title("Population of European countries") ///
labprop colorprop titleprop labcond(2000000) addtitles
```

<img src="/figures/treemap22.png" width="100%">

```stata
treemap pop, by(nuts0 nuts1 nuts2_id) linew(none 0.1 none) linec(white black white) labsize(1.4 1.8 2.4) ///
format(%15.0fc) title("Population of European countries") pad(0.015 0.015 0.01) labprop titleprop palette(CET C6) addtitle noval
```

<img src="/figures/treemap23.png" width="100%">

```stata
treemap pop, by(nuts0 nuts1 nuts2_id) linew(none 0.1 none) linec(white black white) labsize(1.0 1.2 1.8) ///
format(%15.0fc) title("Population of European countries") pad(0.015 0.015 0.01) titlegap(0.09) ///
labprop colorprop titleprop labcond(2000000) addtitles xsize(5) ysize(4)
```

<img src="/figures/treemap24.png" width="100%">

### v1.2 updates

```
treemap pop if nuts0_id=="DE", by(nuts1 nuts2 nuts3_id) linew(none 0.1 none) linec(white black white) labsize(1.4 1.8 2.4) ///
 format(%15.0fc) title("Population of Germany") pad(0.015 0.015 0.01) labprop titleprop palette(CET C6) addtitle noval fi(100 50 20)
```

<img src="/figures/treemap25.png" width="100%">

### v1.3 updates

```
treemap pop if nuts0_id=="DK", by(nuts2 nuts3 ) addtitles labsize(2) ///
title("Population of Denmark at NUTS2 and NUTS3 level") subtitle("% of total") share
```

<img src="/figures/treemap26.png" width="100%">

```
treemap pop if nuts0_id=="DK", by(nuts2 nuts3 ) addtitles labsize(2) title("Population of Denmark at NUTS2 and NUTS3 level") ///
subtitle("% of total") share noval format(%3.1f) palette(CET C7) labgap(1)
```

<img src="/figures/treemap27.png" width="100%">

### v1.4 updates

```
treemap pop if nuts0_id=="ES", by(nuts1 nuts3_id) addtitles labsize(2) title("Population of Spain at NUTS1 and NUTS3 level")
```

<img src="/figures/treemap28.png" width="100%">

```
treemap pop if nuts0_id=="ES", by(nuts1 nuts3 ) addtitles labsize(2) title("Population of Spain at NUTS1 and NUTS3 level") ///
threshold(200000) labprop colorprop
```

<img src="/figures/treemap29.png" width="100%">

```
treemap pop if nuts0_id=="ES", by(nuts1 nuts3 ) addtitles labsize(2) title("Population of Spain at NUTS1 and NUTS3 level") ///
threshold(200000) labprop colorprop fade(40) 
```

<img src="/figures/treemap30.png" width="100%">


### v1.5 updates (new label options)

```
treemap pop if nuts0_id=="IT", by(nuts1 nuts2) addtitles labsize(2) labprop
```

<img src="/figures/treemap31_1.png" width="100%">

```
treemap pop if nuts0_id=="IT", by(nuts1 nuts2) addtitles labsize(2) share labprop
```

<img src="/figures/treemap31_2.png" width="100%">

```
treemap pop if nuts0_id=="IT", by(nuts1 nuts2) addtitles labsize(2) share labprop format(%15.2f)
```

<img src="/figures/treemap31_3.png" width="100%">

```
treemap pop if nuts0_id=="IT", by(nuts1 nuts2) addtitles labsize(2) share labprop noval format(%7.2f)
```

<img src="/figures/treemap31_4.png" width="100%">

```
treemap pop if nuts0_id=="IT", by(nuts1 nuts2) addtitles labsize(2) share labprop noval labcond(5) format(%7.2f)
```

<img src="/figures/treemap31_5.png" width="100%">

```
treemap pop if nuts0_id=="IT", by(nuts1 nuts2) addtitles labsize(2) noval
```

<img src="/figures/treemap31_6.png" width="100%">


### v1.6: better label wrapping and titletyles

```
treemap pop if nuts0_id=="FR", by(nuts1 nuts2) addtitles labsize(2) labprop titleprop
```

<img src="/figures/treemap32_1.png" width="100%">

```
treemap pop if nuts0_id=="FR", by(nuts1 nuts2) addtitles labsize(2) labprop titleprop wrap(0 10)
```

<img src="/figures/treemap32_2.png" width="100%">

```
treemap pop if nuts0_id=="FR", by(nuts1 nuts2 nuts3) addtitles labsize(1.8) labprop titleprop wrap(0 0 10)
```

<img src="/figures/treemap32_3.png" width="100%">

Let's get rid of the dashes and plot again:

```
replace nuts3 = subinstr(nuts3, "-", " ", .)

treemap pop if nuts0_id=="FR", by(nuts1 nuts2 nuts3) addtitles labsize(1.4 1.4 1.8) labprop titleprop wrap(0 0 12)
```

<img src="/figures/treemap32_4.png" width="100%">

```
treemap pop if nuts0_id=="FR", by(nuts1 nuts2 nuts3) addtitles labsize(1.4 1.4 1.8) labprop titleprop wrap(0 0 12) titlestyle(bold italic)
```

<img src="/figures/treemap32_5.png" width="100%">


## Feedback

Please open an [issue](https://github.com/asjadnaqvi/stata-treemap/issues) to report errors, feature enhancements, and/or other requests. 


## Change log

**v1.61 and 1.62 (23 Sep 2025)**
- Added `stat()` option which gives users control on how data should be collapse. Valid options are `stat(sum)` (default) and `stat(mean)`. Ideally data should be prepared before passing it onto `treemap`.
- Better management of internal variables to minimize conflicts.
- Minor bug fixes.

**v1.6 (09 Oct 2024)**
- `wrap()` now takes on a list of each layer and requires `labsplit` from the latest [graphfunctions](https://github.com/asjadnaqvi/stata-graphfunctions) package (requested by Marc Kaulisch).
- Added `titlestyle()` that takes on a list with options `italic` or `bold`.
- Weights are now allowed.
- `sformat()` removed. Now there is only `format()`.
- Major cleanup to remove a lot of redunduncies in the code.

**v1.55 (10 Jun 2024)**
- Added `wrap()` for label wrapping.
- Minor fixes.

**v1.54 (20 Apr 2024)**
- `colorby()` fixed. This option now requires a variable name that determines the color order (reported by Adam Okulicz-Kozaryn).
- Minor fixes.

**v1.53 (10 Apr 2024)**
- Fixed a critical bug where adding three layers was causing errors in the drawing of the second and third layers (reported by Aurelio Tobias).
- Some minor code cleanups.

**v1.52 (10 Jan 2024)** (unreleased internal version subsumed in v1.53)
- If `by()` variables had empty rows, the program was giving an error. These are now dropped by default.

**v1.51 (24 Oct 2023)**
- Further stabilized the sort. Categories with same totals were ending up in a random order (reported by Cesar Lopez). This has been fixed.
- Minor code cleanups.

**v1.5 (22 Jul 2023)**
- Added ability to plot both values and shares.
- `sformat()` option added to format shares.
- `saving()` option added.
- `labcond()` defaults to percentage shares if both `noval` and `share` are specified.
- Minor bug fixes.

**v1.41 (15 Feb 2023)**
- Fixed the "Rest of ..." bug.

**v1.4 (22 Jan 2023)**
- **IMPORTANT**: The order now need to be specified from highest tier to lowest tier. This reversal in categories is (a) just logical, and (b) aligns `treemap` with other hierarchy packages.
- **IMPORTANT**: the `percent` (from v1.3) has been renamed to `share` (v1.4). This is to align `treemap` with other hierarchy packages.
- Updated defaults in `labgap()` to improve the spacing.
- Fixed a bug where the children were not respecting the boundary of the parents.
- Added a `threshold()` option to collapse values below the defined threshold as one category. The collapsed category is renamed to "Rest of <parent>". If only one layer is specified, this category is renamed to "Other"
- `colorprop` now fades to 10% of category color. Previously this was a light shade of grey and didn't look as nice.
- A new `fade(val)` option added to change the fade value.
- Fixed issue with numeric variables with labels not properly showing up in the labels.
- Added the `colorby(name)` option to allow users to define colors by category names rather than the order defined by relative values. This option might be useful if comparing the same categories over time, especially if their ranking is changing.

**v1.3 (14 Dec 2022)**
- Fixed issue with the defaults in value formatting.
- Add `percent` option that shows percentage share of the total value rather than actual values.
- Added a `labgap()` option that allows the distance of the labels and the values in boxes to be adjusted.

**v1.21 (22 Nov 2022)**
- Removed error where duplicate values were causing categories to be dropped.
- Stablized the sort order to prevent random trees across different runs.
- Better variable precision and code cleanup.

**v1.2 (25 Sep 2022)**
- Fill intensity control added.
- Error checks for negative values.
- Minor code cleanups.

**v1.1 (13 Sep 2022)**
- Major update to the package
- Scaling options added for labels, titles, and colors
- Better checking for thresholds in how boxes are drawn
- Several bug fixes and clean ups to the code.

**v1.0 (08 Sep 2022)**
- First release.





