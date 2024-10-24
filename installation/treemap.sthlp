{smcl}
{* 09Oct2024}{...}
{hi:help treemap}{...}
{right:{browse "https://github.com/asjadnaqvi/stata-treemap":treemap v1.6 (GitHub)}}

{hline}


{title:treemap}: is a Stata package for plotting hierarchical data as a gridded {browse "https://en.wikipedia.org/wiki/Treemapping":tree map}. 

{p 4 4 2}
This program implements the {it:squarify} tiling algorithm ({browse "https://link.springer.com/chapter/10.1007/978-3-7091-6783-0_4":Bruls et. al. 2000}).
The algorithm attempts to optimize the aspect ratio of rectangles relative to the overall graph dimensions. 
Squarify is one of the most widely-used tiling method for treemaps. The Stata implementation is based on D3's {browse "https://observablehq.com/@d3/treemap":treemap}
and on the Python's {browse "https://github.com/laserson/squarify":squarify} algorithms.


{marker syntax}{title:Syntax}
{p 8 15 2}

{cmd:treemap} {it:numvar} {ifin} {weight}, {cmd:by}({it:variables (min=1 max=3})) 
		{cmd:[} {cmdab:xs:ize}({it:num}) {cmdab:ys:ize}({it:num}) {cmd:format}({it:str}) {cmd:share|percent} {cmd:palette}(it:str) {cmd:colorby}({it:var})
		  {cmd:pad}({it:list}) {cmdab:labs:ize}({it:list}) {cmdab:linew:idth}({it:list}) {cmdab:linec:olor}({it:list}) {cmd:fi}({it:list}) {cmd:labcond}({it:num})  
		  {cmdab:noval:ues} {cmdab:nolab:els} {cmdab:labs:ize}({it:num}) {cmdab:labg:ap}({it:str}) {cmdab:addt:itles} {cmd:titlegap}({it:num}) {cmdab:titlesty:les}({ul:b}old | {ul:i}talic)
		  {cmdab:thresh:old}({it:num}) {cmd:fade}({it:num}) {cmd:labprop} {cmd:titleprop} {cmd:labscale}({it:num}) {cmd:colorprop} {cmd:wrap}({it:numlist}) {cmdab:*} {cmd:]} 


{p 4 4 2}
The options are described as follows:

{synoptset 36 tabbed}{...}
{synopthdr}
{synoptline}

{p2coldent : {opt treemap} numvar}The command requires a {it:numeric variable} that contains the values.{p_end}

{p2coldent : {opt by(group vars)}}At least one {it:by()} string variable needs to be specified, and a maximum of three string variables are allowed. These also are used as labels.
The order is parent layer first followed by child layer or more aggregated layers should be specified first.{p_end}

{p2coldent : {opt xs:ize(num)}, {opt ys:ize(num)}}The width and height of the figure. Default values are {opt xsize(5)} and {opt ysize(3)}.
Note that changing {opt xsize()} and {opt ysize()} will also change the layout of the treemap.{p_end}

{p2coldent : {opt palette(str)}}Here one can use an named color scheme defined in the {stata help colorpalette:colorpalette} package. Default is {stata colorpalette tableau:{it:tableau}}.{p_end}

{p2coldent : {opt colorby(var)}}Here one can define a variable to control the sequence of the colors drawn. This is useful if box positions are changing across
different treemaps which might make them confusing to compare. The color order is defined by alpha or numeric sorting, so numeric variables are ideal
for maximum control.{p_end}

{p2coldent : {opt share}, {opt percent}}Show percent as a share of the overall total. Option {opt percent} can also be used as a substitute.{p_end}

{p2coldent : {opt addt:itles}}Add titles to rectangles of higher layers. This adds the name and value in the top left corner of the boxes.{p_end}

{p2coldent : {opt noval:ues}}Do not add the values to the lowest-level rectangles. If the graph is too crowded, this option might help.{p_end}

{p2coldent : {opt nolab:els}}Do not add any labels. This gives just boxes without any numbers. This option overrides the above two options.{p_end}

{p2coldent : {ul:Fine tuning}}

{p2coldent : {opt thresh:old(num)}}The value below which categories are combined in a "Rest of ..." category. Default is {opt thresh(0)}.{p_end}

{p2coldent : {opt labcond(value)}}The minimum value for showing the value labels. For example, {opt labcond(20)} will only plot values greater than 20. If {opt noval} is specified
in combination with {opt percent} then the threshold will use the percentage values.{p_end}

{p2coldent : {opt format(fmt)}}Format the values. The default option is {opt format(%12.0fc)} for actual data and {opt format(%5.2f)} if {opt share} or {opt percent} is specified.{p_end}

{p2coldent : {opt pad(numlist list)}}The padding of the boxes, which can be defined as a list. The default values are {opt pad(0.012 0.01 0.01)} for the three layers. A value of 0 
implies no padding.{p_end}

{p2coldent : {opt wrap(numlist)}}Wrap the labels after a number of characters. Users need to specify a list, e.g. {opt wrap(0 0 10)} will wrap the 3rd layer after 10 characters.
Word boundaries are respected.{p_end}

{p2coldent : {opt labs:ize(string list)}}The size of the labels. The default values are {opt labs(1.6 1.6 1.6)}. If only one value is specified, it will passed on to all the layers.{p_end}

{p2coldent : {opt linew:idth(string list)}}The line width of the boxes. The default values are {opt linew(0.03 0.03 0.03)}. If only one value is specified, it will passed on to all the layers.{p_end}

{p2coldent : {opt linec:olor(string list)}}The line color of the boxes. The default values are {opt linec(black black black)}. If only one value is specified, it will passed on to all the layers.{p_end}

{p2coldent : {opt fi(numlist list)}}The fill intensity of the layers in the order they are specified. The default values are {opt fi(50 75 100)}.{p_end}

{p2coldent : {opt titlegap(num)}}Change the space between the title text and the boxes. Default value is {opt titlegap(0.1)}.{p_end}

{p2coldent : {opt titlesty:le(str list)}}Define the style of the titles in a list. Options are {ul:b}old and {ul:i}talic. For example, {opt titlesty(b i)} will make the top
layer header bold and the second layer header italics.{p_end}

{p2coldent : {opt labgap(num)}}Change the space between the box text and the values. Default value is {opt labgap(0.6)}. This option might be useful if 
{opt labelprop} is causing some labels to overlap.{p_end}

{p2coldent : {opt titleprop}}Make the size of the box titles proportional to the area.{p_end}

{p2coldent : {opt labprop}}Make the size of the labels proportional to the area.{p_end}

{p2coldent : {opt colorprop}}Add color gradient to the box colors. The colors are interpolated from the assigned level color to a 10% value of the color.
This can be changed using the {opt fade()} described below.{p_end}

{p2coldent : {opt fade(num)}}Change the end color used for interpolation in the {opt colorprop}. Default value is {opt fade(10)} or 10% of the color.{p_end}

{p2coldent : {opt labscale(num)}}This option changes how the labels are scaled. This is an advanced option and should be used cautiously. Default value is {opt labscale(0.3333)}.
The formula for scaling is {it:((height x width x area) / sum of values)^labscale}.{p_end}


{p2coldent : {opt *}}All other standard twoway options not elsewhere specified.{p_end}

{synoptline}
{p2colreset}{...}


{title:Dependencies}

{stata ssc install palettes, replace}
{stata ssc install colrspace, replace}
{stata ssc install graphfunctions, replace}
{stata ssc install carryforward, replace}

{title:Examples}

See {browse "https://github.com/asjadnaqvi/treemap":GitHub} for examples.

{hline}

{title:Feedback}

Please submit bugs, errors, feature requests on {browse "https://github.com/asjadnaqvi/stata-treemap/issues":GitHub} by opening a new issue.

{title:Package details}

Version      : {bf:treemap} v1.6
This release : 09 Oct 2024
First release: 08 Sep 2022
Repository   : {browse "https://github.com/asjadnaqvi/treemap":GitHub}
Keywords     : Stata, graph, treemap, squarify
License      : {browse "https://opensource.org/licenses/MIT":MIT}

Author       : {browse "https://github.com/asjadnaqvi":Asjad Naqvi}
E-mail       : asjadnaqvi@gmail.com
Twitter      : {browse "https://twitter.com/AsjadNaqvi":@AsjadNaqvi}



{title:Citation guidelines}

Suggested citation guidlines for this package:

Naqvi, A. (2024). Stata package "treemap" version 1.6. Release date 09 October 2024. https://github.com/asjadnaqvi/stata-treemap.

@software{treemap,
   author = {Naqvi, Asjad},
   title = {Stata package ``treemap''},
   url = {https://github.com/asjadnaqvi/stata-treemap},
   version = {1.6},
   date = {2024-10-09}
}



{title:References}

{p 4 8 2}Bruls, M., Huizing, K., van Wijk Jarke J. (2000). {browse "https://link.springer.com/chapter/10.1007/978-3-7091-6783-0_4":Squarified Treemaps}. Data Visualization 2000, Eurographics.

{p 4 8 2}Bostock, M. (2022). {browse "https://observablehq.com/@d3/treemap":D3 Treemap}. {browse "https://observablehq.com/":Observable HQ}.

{p 4 8 2}Jann, B. (2018). {browse "https://www.stata-journal.com/article.html?article=gr0075":Color palettes for Stata graphics}. The Stata Journal 18(4): 765-785.

{p 4 8 2}Jann, B. (2022). {browse "https://ideas.repec.org/p/bss/wpaper/43.html":Color palettes for Stata graphics: an update}. University of Bern Social Sciences Working Papers No. 43. 

{p 4 8 2}Kantor D. (2016). "CARRYFORWARD: Stata module to carry forward previous observations," Statistical Software Components S444902, Boston College Department of Economics, revised 12 Feb 2016.

{p 4 8 2}Laserson, U. (2022). {browse "https://github.com/agatheblues/squarify":Python squarify}.


{title:Other visualization packages}

{psee}
    {helpb arcplot}, {helpb alluvial}, {helpb bimap}, {helpb bumparea}, {helpb bumpline}, {helpb circlebar}, {helpb circlepack}, {helpb clipgeo}, {helpb delaunay}, {helpb graphfunctions}, {helpb joyplot}, 
	{helpb marimekko}, {helpb polarspike}, {helpb sankey}, {helpb schemepack}, {helpb spider}, {helpb splinefit}, {helpb streamplot}, {helpb sunburst}, {helpb ternary}, {helpb treecluster}, {helpb treemap}, {helpb trimap}, {helpb waffle}

or visit {browse "https://github.com/asjadnaqvi":GitHub}.	