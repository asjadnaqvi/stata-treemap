![StataMin](https://img.shields.io/badge/stata-2015-blue) ![issues](https://img.shields.io/github/issues/asjadnaqvi/stata-treemap) ![license](https://img.shields.io/github/license/asjadnaqvi/stata-treemap) ![Stars](https://img.shields.io/github/stars/asjadnaqvi/stata-treemap) ![version](https://img.shields.io/github/v/release/asjadnaqvi/stata-treemap) ![release](https://img.shields.io/github/release-date/asjadnaqvi/stata-treemap)


# treemap v1.1


This package provides the ability to draw treemaps Stata.

It is based on D3's [treemap](https://observablehq.com/@d3/treemap) and Python's [squarify](https://github.com/laserson/squarify) algorithms.


## Installation

The package can be installed via SSC or GitHub. The GitHub version, *might* be more recent due to bug fixes, feature updates etc, and *may* contain syntax improvements and changes in *default* values. See version numbers below. Eventually the GitHub version is published on SSC.

The SSC version (**v1.0**):

```
ssc intall treemap, replace
```

Or it can be installed from GitHub (**v1.1**):

```
net install treemap, from("https://raw.githubusercontent.com/asjadnaqvi/stata-treemap/main/installation/") replace
```


The `palettes` package is required to run this command:

```
ssc install palettes, replace
ssc install colrspace, replace
```

Even if you have the package installed, make sure that it is updated `ado update, update`.

If you want to make a clean figure, then it is advisable to load a clean scheme. These are several available and I personally use the following:

```
ssc install schemepack, replace
set scheme white_tableau  
```

You can also push the scheme directly into the graph using the `scheme(schemename)` option. See the help file for details or the example below.

I also prefer narrow fonts in figures with long labels. You can change this as follows:

```
graph set window fontface "Arial Narrow"
```


## Syntax

The syntax for v1.0 is as follows:

```
treemap numvar [if] [in], by(variables (min=1, max=3)) 
                [ xsize(num) ysize(num) format(str) labcond(num) pad(list) 
                  labsize(list) linewidth(list) linecolor(list) 
                  addtitles novalues nolabels labsize(num) titlegap(num)
                  labprop titleprop colorprop  labscale(num) title(str) subtitle(str)
                  note(str) scheme(str) name(str) palette(str) ] 
```

See the help file `help treemap` for details.

The most basic use is as follows:

```
treemap numvar, by(variable(s))
```


where `numvar` is a numeric variable, and `by()` is upto three string variables, ordered by finer to higher aggregation units. The algorithm changes the layout based on the `width()` and `height()` defintions. See examples below.



## Examples

Set up the data:

```
clear
set scheme white_tableau
graph set window fontface "Arial Narrow"

use "https://github.com/asjadnaqvi/stata-treemap/blob/main/data/demo_r_pjangrp3_clean.dta?raw=true", clear

drop year
keep NUTS_ID y_TOT
drop if y_TOT==0

keep if length(NUTS_ID)==5

gen NUTS2 = substr(NUTS_ID, 1, 4)
gen NUTS1 = substr(NUTS_ID, 1, 3)
gen NUTS0 = substr(NUTS_ID, 1, 2)

ren NUTS_ID NUTS3
```



```
treemap y_TOT, by(NUTS0) labsize(2.5) format(%15.0fc) title("Population of European countries")
```

<img src="/figures/treemap1.png" height="500">


```
treemap y_TOT, by(NUTS0) labsize(2.5) title("Population of European countries") noval
```

<img src="/figures/treemap2.png" height="500">


```
treemap y_TOT, by(NUTS0) labsize(2) title("Population of European countries") noval xsize(4) ysize(4)
```

<img src="/figures/treemap3.png" height="500">


```
treemap y_TOT, by(NUTS0) labsize(4) title("Population of European countries") noval xsize(5) ysize(2)
```

<img src="/figures/treemap4.png" height="400">


```
treemap y_TOT, by(NUTS0) labsize(5) title("Population of European countries") noval xsize(6) ysize(1)
```

<img src="/figures/treemap5.png" height="100">

```
treemap y_TOT, by(NUTS1 NUTS0) labsize(2) format(%15.0fc)
```

<img src="/figures/treemap6.png" height="500">

```
treemap y_TOT if NUTS0=="AT", by(NUTS3 NUTS2) addtitles noval labsize(2) format(%15.0fc) title("Population of Austria at NUTS2 and NUTS3 level")
```

<img src="/figures/treemap7.png" height="500">

```
treemap y_TOT if NUTS0=="NL", by(NUTS3 NUTS2) addtitles labsize(2) format(%15.0fc) title("Population of Netherlands at NUTS2 and NUTS3 level")
```

<img src="/figures/treemap8.png" height="500">


```
treemap y_TOT if NUTS0=="NL", by(NUTS3 NUTS2) addtitles labsize(1.3) format(%15.0fc) ///
	title("Population of Netherlands at NUTS2 and NUTS3 level") palette(CET L07, reverse) wid(3) hei(3)
```

<img src="/figures/treemap9.png" height="600">

```
treemap y_TOT if NUTS0=="NL", by(NUTS3 NUTS2) addtitles labsize(1.3) format(%15.0fc) title("Population of Netherlands at NUTS2 and NUTS3 level") palette(CET L07, reverse) xsize(3) ysize(3)
```

<img src="/figures/treemap10.png" height="600">

```
treemap y_TOT if NUTS0=="NL", by(NUTS3 NUTS2) addtitles noval labsize(1.3) format(%15.0fc) title("Population of Netherlands at NUTS2 and NUTS3 level") palette(CET L10) xsize(3) ysize(3)
```

<img src="/figures/treemap11.png" height="600">

```
treemap y_TOT if NUTS0=="NO", by(NUTS3 NUTS2) addtitles labsize(2) format(%15.0fc) title("Population of Norway at NUTS2 and NUTS3 level") palette(CET L17) xsize(3) ysize(3) 
```

<img src="/figures/treemap12.png" height="600">

```
treemap y_TOT if NUTS0=="NO", by(NUTS3) addtitles labsize(2) format(%15.0fc) title("Population of Norway at NUTS3 level") palette(CET L19) xsize(5) ysize(3) scheme(neon)
```

<img src="/figures/treemap13.png" height="600">

### v1.1 updates


```
treemap y_TOT, by(NUTS1 NUTS0) addtitles format(%15.0fc) title("Population of European countries")
```

<img src="/figures/treemap14.png" height="500">

```
treemap y_TOT, by(NUTS1 NUTS0) addtitles format(%15.0fc) title("Population of European countries") labprop linew(0.02 0.1) linec(red blue)
```

<img src="/figures/treemap15.png" height="500">

```
treemap y_TOT, by(NUTS1 NUTS0) addtitles format(%15.0fc) title("Population of European countries") labprop linew(none 0.1) linec(red black) labs(2)
```

<img src="/figures/treemap16.png" height="500">

```
treemap y_TOT, by(NUTS1 NUTS0) addtitles labsize(1.6 2.5) format(%15.0fc) title("Population of European countries") labprop colorprop titleprop pad(0.008) 
```

<img src="/figures/treemap17.png" height="500">

```
treemap y_TOT, by(NUTS2 NUTS1 NUTS0) format(%15.0fc) title("Population of European countries") nolab
```

<img src="/figures/treemap18.png" height="500">

```
treemap y_TOT, by(NUTS2 NUTS1 NUTS0) format(%15.0fc) title("Population of European countries") nolab pad(0.015 0.015 0.01)
```

<img src="/figures/treemap19.png" height="500">

```
treemap y_TOT, by(NUTS0) labsize(2.5) format(%15.0fc) title("Population of European countries") labprop labcond(5000000) 
```

<img src="/figures/treemap20.png" height="500">

```
treemap y_TOT, by(NUTS1 NUTS0) labsize(2.2) format(%15.0fc) title("Population of European countries") labprop colorprop titleprop labcond(2000000) addtitles
```

<img src="/figures/treemap21.png" height="500">

```
treemap y_TOT, by(NUTS2 NUTS0) labsize(2.2) format(%15.0fc) title("Population of European countries") labprop colorprop titleprop labcond(2000000) addtitles
```

<img src="/figures/treemap22.png" height="500">

```
treemap y_TOT, by(NUTS2 NUTS1 NUTS0) linew(none 0.1 none) linec(white black white) labsize(1.0 0.8 0.6) format(%15.0fc) title("Population of European countries") pad(0.015 0.015 0.01) titlegap(0.09) labprop labcond(2000000) addtitles xsize(5) ysize(4)
```

<img src="/figures/treemap23.png" height="600">

```
treemap y_TOT, by(NUTS2 NUTS1 NUTS0) linew(none 0.1 none) linec(white black white) labsize(1.0 1.2 1.8) format(%15.0fc) title("Population of European countries") pad(0.015 0.015 0.01) titlegap(0.09) labprop colorprop titleprop labcond(2000000) addtitles xsize(5) ysize(4)
```

<img src="/figures/treemap24.png" height="600">

## Feedback

Please open an [issue](https://github.com/asjadnaqvi/stata-treemap/issues) to report errors, feature enhancements, and/or other requests. 


## Versions

**v1.1 (13 September 2022)**
- Major update to the package
- Scaling options added for labels, titles, and colors
- Better checking for thresholds in how boxes are drawn
- Several bug fixes and clean ups to the code.

**v1.0 (08 September 2022)**
- First release





