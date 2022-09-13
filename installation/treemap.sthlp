{smcl}
{* 13Sep2022}{...}
{hi:help treemap}{...}
{right:{browse "https://github.com/asjadnaqvi/stata-treemap":treemap v1.1 (GitHub)}}

{hline}


{title:treemap}: is a Stata package for plotting hierarchical data as a {browse "https://en.wikipedia.org/wiki/Treemapping":tree map}.
This program implements the {it:squarify} tiling algorithm (Bruls et. al. 2000). 
This algorithm is highly robust and aims to optimize the aspect ratio of rectangles relative to the overall graph dimensions. 

Squarify is currently the most widely-used tiling method for treemaps. 

The Stata implementation is based on D3's {browse "https://observablehq.com/@d3/treemap":treemap} and on the Python's {browse "https://github.com/laserson/squarify":squarify} algorithms.


{marker syntax}{title:Syntax}
{p 8 15 2}

{cmd:treemap} {it:numvar} {ifin}, {cmd:by}({it:variables (min=1, max=3})) 
		{cmd:[} {cmdab:xs:ize}({it:num}) {cmdab:ys:ize}({it:num}) {cmd:format}(str) {cmd:labcond}({it:num}) {cmd:pad}({it:list}) 
		  {cmdab:labs:ize}({it:list}) {cmdab:linew:idth}({it:list}) {cmdab:linec:olor}({it:list}) 
		  {cmdab:addt:itles} {cmdab:noval:ues} {cmdab:nolab:els} {cmdab:labs:ize}({it:num}) {cmd:titlegap}({it:num})
		  {cmd:labprop} {cmd:titleprop} {cmd:colorprop}  {cmd:labscale}({it:num}) {cmd:title}({it:str}) {cmd:subtitle}({it:str})
		  {cmd:note}({it:str}) {cmd:scheme}({it:str}) {cmd:name}({it:str}) {cmd:palette}(str) {cmd:]} 


{p 4 4 2}
The options are described as follows:

{synoptset 36 tabbed}{...}
{synopthdr}
{synoptline}

{p2coldent : {opt treemap} numvar}The command requires a {it:numeric variable} that contains the values.{p_end}

{p2coldent : {opt by(group vars)}}At least one {it:by()} string variable needs to be specified, and a maximum of three string variables are allowed. These also are used as labels.
The order is inner-most layer first and top-most layer last.{p_end}

{p2coldent : {opt xs:ize(num)}, {opt ys:ize(num)}}The width and height of the bounding box. Default values are {it:xsize(5) and ysize(3)}.
Note that changing the {opt xsize} and {opt ysize} will change the layout of the treemap.{p_end}

{p2coldent : {opt palette(name)}}Color name is any named scheme defined in the {stata help colorpalette:colorpalette} package. Default is {stata colorpalette tableau:{it:tableau}}.{p_end}

{p2coldent : {opt addt:itles}}Add titles to rectangles of higher layers. This adds the name and value in the top left corner of the boxes.{p_end}

{p2coldent : {opt noval:ues}}Do not add the values to the lowest-level rectangles. If the graph is too crowded, this option might help.{p_end}

{p2coldent : {opt nolab:els}}Do not add any labels. This gives just boxes without any numbers. This option overrides the above two options.{p_end}

{p2coldent : {ul:Fine tuning}}

{p2coldent : {opt labcond(value)}}The minimum value for showing the value labels. For example, {opt labcond(20)} will only plot values greater than 20.{p_end}

{p2coldent : {opt format(fmt)}}Format the values of the labels. The default option is {opt format(%9.0fc)}.{p_end}

{p2coldent : {opt pad(numlist max=3)}}The padding of the boxes, which can be defined as a list. 
The default values are {opt :pad(0.012 0.01 0.01)} for the three layers. A value of 0 implies no padding. 
If you change the {opt xsize} and {opt ysize} substantially, then you might also need to update the padding.{p_end}

{p2coldent : {opt labs:ize(string max=3)}}The size of the labels. The default values are {opt labs(1.6 1.6 1.6)}. If only one value is specified, it will passed on to all the layers.{p_end}

{p2coldent : {opt linew:idth(string max=3)}}The line width of the boxes. The default values are {opt linew(0.03 0.03 0.03)}. If only one value is specified, it will passed on to all the layers.{p_end}

{p2coldent : {opt linec:olor(string max=3)}}The line color of the boxes. The default values are {opt linec(black black black)}. If only one value is specified, it will passed on to all the layers.{p_end}

{p2coldent : {opt titlegap(num)}}Change the space between the title text and the boxes. Default value is {opt titlegap(0.1)}.{p_end}

{p2coldent : {opt titleprop}}Make the size of the box titles proportional to the area.{p_end}

{p2coldent : {opt labprop}}Make the size of the labels proportional to the area.{p_end}

{p2coldent : {opt colorprop}}Add color gradient to the box colors. The colors are interpolated from the default level color to white.{p_end}

{p2coldent : {opt labscale(num)}}This option changes how the labels are scaled. This is an advanced option and should be used cautiously. Default value is {opt labscale(0.3333)}.
The formula for scaling is {it:((height x width x area) / sum of values)^labscale}.{p_end}

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

See {browse "https://github.com/asjadnaqvi/treemap":GitHub} for a comprehensive set of examples. Basic use below:

- use "https://github.com/asjadnaqvi/stata-circlepack/blob/main/data/demo_r_pjangrp3_clean.dta?raw=true", clear

- {stata drop year}
- {stata keep NUTS_ID y_TOT}
- {stata drop if y_TOT==0}
- {stata keep if length(NUTS_ID)==5}

- {stata gen NUTS2 = substr(NUTS_ID, 1, 4)}
- {stata gen NUTS1 = substr(NUTS_ID, 1, 3)}
- {stata gen NUTS0 = substr(NUTS_ID, 1, 2)}
- {stata ren NUTS_ID NUTS3}

- {stata treemap y_TOT, by(NUTS0)}

- {stata treemap y_TOT, by(NUTS0) addtitles labsize(2) format(%15.0fc)}

- {stata treemap y_TOT if NUTS0=="AT", by(NUTS3 NUTS2) addtitles noval labsize(1.6) format(%15.0fc)}


{hline}

{title:Acknowledgements}



{title:Package details}

Version      : {bf:treemap} v1.1
This release : 13 Sep 2022
First release: 08 Sep 2022
Repository   : {browse "https://github.com/asjadnaqvi/treemap":GitHub}
Keywords     : Stata, graph, treemap, squarify
License      : {browse "https://opensource.org/licenses/MIT":MIT}

Author       : {browse "https://github.com/asjadnaqvi":Asjad Naqvi}
E-mail       : asjadnaqvi@gmail.com
Twitter      : {browse "https://twitter.com/AsjadNaqvi":@AsjadNaqvi}


{title:References}

{p 4 8 2}Bruls, M., Huizing, K., van Wijk Jarke J. (2000). {browse "https://link.springer.com/chapter/10.1007/978-3-7091-6783-0_4":Squarified Treemaps}. Data Visualization 2000, Eurographics.

{p 4 8 2}Bostock, M. (2022). {browse "https://observablehq.com/@d3/treemap":D3 Treemap}. {browse "https://observablehq.com/":Observable HQ}.

{p 4 8 2}Jann, B. (2018). {browse "https://www.stata-journal.com/article.html?article=gr0075":Color palettes for Stata graphics}. The Stata Journal 18(4): 765-785.

{p 4 8 2}Laserson, U. (2022). {browse "https://github.com/agatheblues/squarify":Python squarify}.
