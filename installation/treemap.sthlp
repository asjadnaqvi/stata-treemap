{smcl}
{* 08Sep2022}{...}
{hi:help treemap}{...}
{right:{browse "https://github.com/asjadnaqvi/stata-treemap":treemap v1.0 (GitHub)}}

{hline}


{title:treemap}: is a Stata package for plotting hierarchical data as a {browse "https://en.wikipedia.org/wiki/Treemapping":tree map}.
This program implements the {it:squarify} tiling algorithm (Bruls et. al. 2000). 
This algorithm is highly robust and aims to optimize the aspect ratio of rectangles relative to the overall graph dimensions. 

Squarify is currently the most widely-used tiling method for treemaps. 

The Stata implementation is based on D3's {browse "https://observablehq.com/@d3/treemap":treemap} and on the Python's {browse "https://github.com/laserson/squarify":squarify} algorithms.


{marker syntax}{title:Syntax}
{p 8 15 2}

{cmd:treemap} {it:numvar} {ifin}, {cmd:by}({it:variables (min=1, max=3})) 
		{cmd:[} {cmdab:wid:th}({it:num}) {cmdab:hei:ght}({it:num}) {cmd:pad}({it:num}) {cmd:format}(str) {cmd:palette}(string) {cmdab:addt:itles} {cmdab:noval:ues} {cmdab:nolab:els} {cmdab:labs:ize}({it:num}) 
		  {cmd:title}({it:str}) {cmd:subtitle}({it:str}) {cmd:note}({it:str}) {cmd:scheme}({it:str}) {cmd:name}({it:str}) {cmd:]}


{p 4 4 2}
The options are described as follows:

{synoptset 36 tabbed}{...}
{synopthdr}
{synoptline}

{p2coldent : {opt treemap numvar}}The command requires a {it:numeric variable} that contains the values.{p_end}

{p2coldent : {opt by(group vars)}}At least one {it:by()} string variable needs to be specified, and a maximum of three string variables are allowed. These also are used as labels.
The order is inner-most layer first and top-most layer last.{p_end}

{p2coldent : {opt wid:th(num)}}The width of the bounding box. Default value is {it:5}.{p_end}

{p2coldent : {opt hei:ght(num)}}The height of the bounding box. Default value is {it:3}.{p_end}

{p2coldent : {opt pad(num)}}The padding of the bounding box. Default value is {it:0.012}. This reduces the size of the boxes. A value of 0 implies no padding. 
If you change the {it:width} and {it:height} substantially, then you might also need to fix the padding.{p_end}

{p2coldent : {opt palette(string)}}Color name is any named scheme defined in the {stata help colorpalette:colorpalette} package. Default is {stata colorpalette tableau:{it:tableau}}.{p_end}

{p2coldent : {opt addt:itles}}Add titles to rectangles of higher layers. This adds the name and value in the top left corner of the boxes.{p_end}

{p2coldent : {opt noval:ues}}Do not add the values to the lowest-level rectangles. If the graph is too crowded, this option might help.{p_end}

{p2coldent : {opt nolab:els}}Do not add anylabels. This gives just boxes without any numbers. This option overrides the above two options.{p_end}

{p2coldent : {opt labs:ize(string)}}The size of the labels. The default value is {it:2.2}.{p_end}

{p2coldent : {opt format()}}Format the values of the labels. The default is {it:%9.0fc}.{p_end}

{p2coldent : {opt title, subtitle, note}}These are standard twoway graph options.{p_end}

{p2coldent : {opt scheme(string)}}Load the custom scheme. Above options can be used to fine tune individual elements.{p_end}

{synoptline}
{p2colreset}{...}


{title:Dependencies}

The {browse "http://repec.sowi.unibe.ch/stata/palettes/index.html":palette} package (Jann 2018) is required for {cmd:streamplot}:

{stata ssc install palettes, replace}
{stata ssc install colrspace, replace}

Even if you have these installed, it is highly recommended to check for updates: {stata ado update, update}

{title:Examples}

{ul:{it:Set up the data}}

use "D:\Programs\Dropbox\Dropbox\STATA - MEDIUM\Webinar - Stata UK Maps 2\GIS\demo_r_pjangrp3_clean.dta", clear

drop year
keep NUTS_ID y_TOT

drop if y_TOT==0

keep if length(NUTS_ID)==5

gen NUTS2 = substr(NUTS_ID, 1, 4)
gen NUTS1 = substr(NUTS_ID, 1, 3)
gen NUTS0 = substr(NUTS_ID, 1, 2)

ren NUTS_ID NUTS3

- {stata treemap y_TOT, by(NUTS0)}

- {stata treemap y_TOT, by(NUTS0) addtitles labsize(2) format(%15.0fc)}

- {stata treemap y_TOT if NUTS0=="AT", by(NUTS3 NUTS2) addtitles noval labsize(1.6) format(%15.0fc)}


{hline}

{title:Acknowledgements}



{title:Package details}

Version      : {bf:treemap} v1.0
This release : 08 Sep 2022
First release: 08 Sep 2022
Repository   : {browse "https://github.com/asjadnaqvi/treemap":GitHub}
Keywords     : Stata, graph, stream plot
License      : {browse "https://opensource.org/licenses/MIT":MIT}

Author       : {browse "https://github.com/asjadnaqvi":Asjad Naqvi}
E-mail       : asjadnaqvi@gmail.com
Twitter      : {browse "https://twitter.com/AsjadNaqvi":@AsjadNaqvi}


{title:References}

{p 4 8 2}Bruls, M., Huizing, K., van Wijk Jarke J. (2000). {browse "https://link.springer.com/chapter/10.1007/978-3-7091-6783-0_4":Squarified Treemaps}. Data Visualization 2000, Eurographics.

{p 4 8 2}Bostock, M. {browse "https://observablehq.com/@d3/treemap":D3 Treemap}. {browse "https://observablehq.com/":Observable HQ}.

{p 4 8 2}Jann, B. (2018). {browse "https://www.stata-journal.com/article.html?article=gr0075":Color palettes for Stata graphics}. The Stata Journal 18(4): 765-785.

{p 4 8 2}Laserson, U. {browse "https://github.com/agatheblues/squarify":Python squarify}.
