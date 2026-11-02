{smcl}
{* 02Nov2026}{...}
{hi:help treemap}{...}
{right:{browse "https://github.com/asjadnaqvi/stata-treemap":treemap v1.8 (GitHub)}}

{hline}


{title:treemap}: is a Stata package for plotting hierarchical data as a gridded {browse "https://en.wikipedia.org/wiki/Treemapping":tree map}. 

{p 4 4 2}
This program implements the {it:squarify} tiling algorithm ({browse "https://link.springer.com/chapter/10.1007/978-3-7091-6783-0_4":Bruls et. al. 2000}),
as well as simple {it:slice} and {it:dice} layouts. The squarify algorithm attempts to optimize the aspect ratio of rectangles relative to the overall graph dimensions.
The Stata implementation is inspired by D3's {browse "https://observablehq.com/@d3/treemap":treemap} and on the Python's {browse "https://github.com/laserson/squarify":squarify} algorithms.
Internally aggregated values and geometry retain double precision; display formats affect only how values are shown in labels.
One engine handles hierarchies with any number of levels.


{marker syntax}{title:Syntax}
{p 8 15 2}

{cmd:treemap} {it:numvar} {ifin} {weight}, {cmd:by}({it:variables (min=1)})
		{cmd:[} {cmdab:xs:ize}({it:num}) {cmdab:ys:ize}({it:num}) {cmd:format}({it:str}) {cmd:share|percent} {cmd:palette}(it:str) {cmd:colorby}({it:var})
		  {cmd:pad}({it:list}) {cmdab:labs:ize}({it:list}) {cmdab:linew:idth}({it:list}) {cmdab:linec:olor}({it:list}) {cmd:fi}({it:list}) {cmd:labcond}({it:num})  
		  {cmdab:noval:ues} {cmdab:nolab:els} {cmdab:labs:ize}({it:num}) {cmdab:labg:ap}({it:str}) {cmdab:not:itles} {cmd:titlegap}({it:num}) {cmdab:titlesty:les}({ul:b}old | {ul:i}talic)
		  {cmdab:thresh:old}({it:num}) {cmd:fade}({it:num}) {cmd:labprop} {cmd:titleprop} {cmd:labscale}({it:num}) {cmd:colorprop} {cmd:wrap}({it:numlist}) {cmdab:*} 
		  {cmd:method}({it:str}) {cmd:ratio}({it:num}) {cmdab:laba:ngle}({it:numlist}) {cmd:orient}({it:str}) {cmd:]} 

{marker options}{title:Options}

{synoptset 24 tabbed}{...}

{marker required}{dlgtab:Required}

{p2coldent : {opt treemap} numvar}The command requires a {it:numeric variable} that contains the values.{p_end}

{p2coldent : {opt by(group vars)}}At least one variable is required. Any number of variables can be specified; they define successive hierarchy levels and are also used as labels. Numeric variables are converted to strings.
Specify parent layers first, followed by their children.{p_end}

{marker display}{dlgtab:Display options}

{p2coldent : {opt xs:ize(num)}, {opt ys:ize(num)}}The width and height of the figure. Default values are {opt xsize(5)} and {opt ysize(3)}.
Note that changing {opt xsize()} and {opt ysize()} will also change the layout of the treemap.{p_end}

{p2coldent : {opt format(fmt)}}Format the values. The default option is {opt format(%12.2fc)} for actual data and {opt format(%4.2f)} if {opt share} or {opt percent} is specified.{p_end}

{p2coldent : {opt stat(str)}}Aggregate observations within complete hierarchy paths using {opt stat(sum)} (default) or {opt stat(mean)}. Parent values sum the resulting leaf aggregates.{p_end}

{p2coldent : {opt share}, {opt percent}}Show percent as a share of the overall total. Option {opt percent} can also be used as a substitute.{p_end}

{p2coldent : {opt thresh:old(num)}}After leaf aggregation, combine categories at or below this value in a "Rest of ..." category within each full parent path.
Only the deepest level is combined. Default is {opt thresh(0)}, which disables combining.{p_end}

{marker colors}{dlgtab:Colors and palette}

{p2coldent : {opt palette(str)}}Here one can use an named color scheme defined in the {stata help colorpalette:colorpalette} package. Default is {stata colorpalette tableau:{it:tableau}}.{p_end}

{p2coldent : {opt colorby(var)}}Here one can define a variable to control the sequence of the colors drawn. This is useful if box positions are changing across
different treemaps which might make them confusing to compare. The color order is defined by alpha or numeric sorting, so numeric variables are ideal
for maximum control.{p_end}

{p2coldent : {opt colorprop}}Add a color gradient among deepest-level siblings. Descendants inherit their top-level color.
The colors are interpolated from the assigned color to a 10% value of the color.
This can be changed using the {opt fade()} described below.{p_end}

{p2coldent : {opt fade(num)}}Change the end color used for interpolation in the {opt colorprop}. Default value is {opt fade(10)} or 10% of the color.{p_end}

{p2coldent : {opt fi(numlist list)}}The fill intensity by layer. One layer defaults to {opt fi(100)} and two layers to {opt fi(60 90)}.
Three layers default to {opt fi(50 75 100)}; for deeper hierarchies the values interpolate from 50 for the first layer to 100 for the last. If fewer values than levels are supplied, the last value is reused.{p_end}

{marker labels}{dlgtab:Labels and text}

{p2coldent : {opt not:itles}}Suppress titles on higher-layer rectangles, leaving lowest-level labels unchanged.
By default, parent titles show the name and value in the top left corner of their boxes. This replaces the former {cmd:addtitles} option.{p_end}

{p2coldent : {opt noval:ues}}Do not add the values to rectangle labels or parent titles. If the graph is too crowded, this option might help.{p_end}

{p2coldent : {opt nolab:els}}Do not add any labels. This gives just boxes without any numbers. This option overrides the above two options.{p_end}

{p2coldent : {opt labcond(value)}}The minimum value for showing the value labels. For example, {opt labcond(20)} will only plot values greater than 20. If {opt noval} is specified
in combination with {opt percent} then the threshold will use the percentage values.{p_end}

{p2coldent : {opt labs:ize(str list)}}The size of the labels by layer. The default is {opt labs(1.6)}. If fewer values than levels are supplied, the last value is reused.{p_end}

{p2coldent : {opt wrap(numlist)}}Wrap the labels after a number of characters by layer. If fewer values than levels are supplied, the last value is reused.
Word boundaries are respected.{p_end}

{p2coldent : {opt labgap(num)}}Change the space between the box text and the values. Default value is {opt labgap(0.2)}. This option might be useful if
{opt labprop} is causing some labels to overlap.{p_end}

{p2coldent : {opt laba:ngle(numlist)}}Specify label rotation angle(s) in degrees by layer. If fewer values than layers are supplied, the last value is reused. Default is {opt labangle(0)} for all layers.
For example, {opt labangle(0 45 90)} rotates the first three levels by 0, 45, and 90 degrees.{p_end}

{p2coldent : {opt labprop}}Make the size of the labels proportional to the area.{p_end}

{p2coldent : {opt labscale(num)}}This option changes how the labels are scaled. This is an advanced option and should be used cautiously. Default value is {opt labscale(0.3333)}.
The formula for scaling is {it:((height x width x area) / sum of values)^labscale}.{p_end}

{marker titles}{dlgtab:Title options}

{p2coldent : {opt titlegap(num)}}Change the space between the title text and the boxes. Default value is {opt titlegap(0.1)}.{p_end}

{p2coldent : {opt titlesty:le(str list)}}Define title and label styles by layer. Options are {ul:b}old and {ul:i}talic. If fewer values than levels are supplied, the last style is reused.{p_end}

{p2coldent : {opt titleprop}}Make the size of the box titles proportional to the area.{p_end}

{marker layout}{dlgtab:Layout and spacing}

{p2coldent : {opt pad(numlist list)}}The padding of the boxes, which can be defined by layer. If fewer values than layers are supplied, the last value is reused. The default padding is {opt pad(0.01)}. A value of 0 implies no padding.
For each cell, effective padding is the minimum of the requested padding, one quarter of its width, and one quarter of its height.
Small cells therefore remain drawable without reducing padding elsewhere. Child layouts use the parent's effective padding.{p_end}

{p2coldent : {opt linew:idth(str list)}}The line width of the boxes by layer. The default is {opt linewidth(0.03)}. If fewer values than levels are supplied, the last width is reused.{p_end}

{p2coldent : {opt linec:olor(str list)}}The line color of the boxes by layer. The default is {opt linecolor(black)}. If fewer values than levels are supplied, the last color is reused.{p_end}

{p2coldent : {opt method(str)}}Specify the layout algorithm by layer. Options are {it:squarify} (default), {it:slice}, or {it:dice}. If fewer methods than layers are supplied, the last method is reused.
For example, {opt method(squarify slice dice)} uses those methods for the first three levels and dice for any deeper levels.{p_end}

{p2coldent : {opt ratio(num)}}Control the aspect ratio preference for the squarify algorithm. Default value is {opt ratio(1.618034)} (golden ratio).
Higher values favor wider rectangles. Only affects layers using squarify method.{p_end}

{p2coldent : {opt orient(str)}}Control box placement orientation by layer. Options are {it:br} (bottom-right, default), {it:bl} (bottom-left), {it:tr} (top-right), or {it:tl} (top-left).
If fewer orientations than levels are supplied, the last value is reused. For example, {opt orient(tl)} places largest boxes in top-left corner at every level.{p_end}

{marker twoway}{dlgtab:Twoway options}

{p2coldent : {opt *}}All other standard twoway options not elsewhere specified and not blocked by the program.{p_end}

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

Version      : {bf:treemap} v1.8
This release : 02 Nov 2026
First release: 08 Sep 2022
Repository   : {browse "https://github.com/asjadnaqvi/stata-treemap":GitHub}
Keywords     : Stata, graph, treemap, squarify
License      : {browse "https://opensource.org/licenses/MIT":MIT}

Author       : {browse "https://github.com/asjadnaqvi":Asjad Naqvi}
E-mail       : asjadnaqvi@gmail.com
Twitter      : {browse "https://twitter.com/AsjadNaqvi":@AsjadNaqvi}



{title:Citation guidelines}

See {browse "https://ideas.repec.org/c/boc/bocode/s459123.html"} for the official SSC citation. 
Please note that the GitHub version might be newer than the SSC version.



{title:References}

{p 4 8 2}Bruls, M., Huizing, K., van Wijk Jarke J. (2000). {browse "https://link.springer.com/chapter/10.1007/978-3-7091-6783-0_4":Squarified Treemaps}. Data Visualization 2000, Eurographics.

{p 4 8 2}Bostock, M. (2022). {browse "https://observablehq.com/@d3/treemap":D3 Treemap}. {browse "https://observablehq.com/":Observable HQ}.

{p 4 8 2}Jann, B. (2018). {browse "https://www.stata-journal.com/article.html?article=gr0075":Color palettes for Stata graphics}. The Stata Journal 18(4): 765-785.

{p 4 8 2}Jann, B. (2022). {browse "https://ideas.repec.org/p/bss/wpaper/43.html":Color palettes for Stata graphics: an update}. University of Bern Social Sciences Working Papers No. 43. 

{p 4 8 2}Kantor D. (2016). "CARRYFORWARD: Stata module to carry forward previous observations," Statistical Software Components S444902, Boston College Department of Economics, revised 12 Feb 2016.

{p 4 8 2}Laserson, U. (2022). {browse "https://github.com/agatheblues/squarify":Python squarify}.


{title:Other visualization packages}

{psee}
    {helpb arcplot}, {helpb alluvial}, {helpb bimap}, {helpb bumparea}, {helpb bumpline}, {helpb circlebar}, {helpb circlepack}, {helpb clipgeo}, {helpb delaunay}, {helpb graphfunctions},
	{helpb geoboundary}, {helpb geoflow}, {helpb joyplot}, {helpb marimekko}, {helpb polarspike}, {helpb sankey}, {helpb schemepack}, {helpb spider}, {helpb splinefit}, {helpb streamplot}, 
	{helpb sunburst}, {helpb ternary}, {helpb tidytuesday}, {helpb treecluster}, {helpb treemap}, {helpb trimap}, {helpb waffle}, {helpb vcontrol}

Visit {browse "https://github.com/asjadnaqvi":GitHub} for further details.	