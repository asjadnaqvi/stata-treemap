{smcl}
{* 10Apr2024}{...}
{hi:help treemap}{...}
{right:{browse "https://github.com/asjadnaqvi/stata-treemap":treemap v1.53 (GitHub)}}

{hline}


{title:treemap}: is a Stata package for plotting hierarchical data as a gridded {browse "https://en.wikipedia.org/wiki/Treemapping":tree map}. 

{p 4 4 2}
This program implements the {it:squarify} tiling algorithm ({browse "https://link.springer.com/chapter/10.1007/978-3-7091-6783-0_4":Bruls et. al. 2000}).
The algorithm attempts to optimize the aspect ratio of rectangles relative to the overall graph dimensions. 
Squarify is one of the most widely-used tiling method for treemaps. The Stata implementation is based on D3's {browse "https://observablehq.com/@d3/treemap":treemap}
and on the Python's {browse "https://github.com/laserson/squarify":squarify} algorithms.


{marker syntax}{title:Syntax}
{p 8 15 2}

{cmd:treemap} {it:numvar} {ifin}, {cmd:by}({it:variables (min=1 max=3})) 
		{cmd:[} {cmdab:xs:ize}({it:num}) {cmdab:ys:ize}({it:num}) {cmd:format}({it:str}) {cmd:share} {cmd:sformat}({it:str}) {cmd:palette}(it:str) {cmd:colorby}({it:name})
		  {cmd:pad}({it:list}) {cmdab:labs:ize}({it:list}) {cmdab:linew:idth}({it:list}) {cmdab:linec:olor}({it:list}) {cmd:fi}({it:list}) {cmd:labcond}({it:num})  
		  {cmdab:addt:itles} {cmdab:noval:ues} {cmdab:nolab:els} {cmdab:labs:ize}({it:num}) {cmd:titlegap}({it:num}) {cmdab:labg:ap}({it:str})
		  {cmdab:thresh:old}({it:num}) {cmd:fade}({it:num}) {cmd:labprop} {cmd:titleprop} {cmd:labscale}({it:num}) {cmd:colorprop}  
		  {cmd:title}({it:str}) {cmd:subtitle}({it:str}) {cmd:note}({it:str}) {cmd:scheme}({it:str}) {cmd:name}({it:str}) {cmd:saving}({it:str}) {cmd:]} 


{p 4 4 2}
The options are described as follows:

{synoptset 36 tabbed}{...}
{synopthdr}
{synoptline}

{p2coldent : {opt treemap} numvar}The command requires a {it:numeric variable} that contains the values.{p_end}

{p2coldent : {opt by(group vars)}}At least one {it:by()} string variable needs to be specified, and a maximum of three string variables are allowed. These also are used as labels.
The order is parent layer first followed by child layer or more aggregated layers should be specified first.{p_end}

{p2coldent : {opt xs:ize(num)}, {opt ys:ize(num)}}The width and height of the bounding box. Default values are {it:xsize(5) and ysize(3)}.
Note that changing the {opt xsize} and {opt ysize} will change the layout of the treemap.{p_end}

{p2coldent : {opt palette(str)}}Here one can use an named color scheme defined in the {stata help colorpalette:colorpalette} package. Default is {stata colorpalette tableau:{it:tableau}}.{p_end}

{p2coldent : {opt colorby(name)}}The option allows us to preserve the color order by alphabetical order of the {opt by()} variables rather than values. This is useful if multiple 
treemaps are drawn for the same data over time, and colors are likely to change across the same {opt by()} categories if their relative order changes.{p_end}

{p2coldent : {opt share}}Show percentage shares.{p_end}

{p2coldent : {opt addt:itles}}Add titles to rectangles of higher layers. This adds the name and value in the top left corner of the boxes.{p_end}

{p2coldent : {opt noval:ues}}Do not add the values to the lowest-level rectangles. If the graph is too crowded, this option might help.{p_end}

{p2coldent : {opt nolab:els}}Do not add any labels. This gives just boxes without any numbers. This option overrides the above two options.{p_end}

{p2coldent : {ul:Fine tuning}}

{p2coldent : {opt thresh:old(num)}}The value below which categories are combined in a "Rest of ..." category. Default is {opt thresh(0)}.{p_end}

{p2coldent : {opt labcond(value)}}The minimum value for showing the value labels. For example, {opt labcond(20)} will only plot values greater than 20. If {opt noval} is specified
in combination with {opt percent} then the threshold will use the percentage values.{p_end}

{p2coldent : {opt format(fmt)}}Format the values. The default option is {opt format(%12.0fc)}.{p_end}

{p2coldent : {opt sformat(fmt)}}Format the percentage shares. The default option is {opt sformat(%5.2f)}.{p_end}

{p2coldent : {opt pad(numlist max=3)}}The padding of the boxes, which can be defined as a list. The default values are {opt :pad(0.012 0.01 0.01)} for the three layers. A value of 0 
implies no padding. If you change the {opt xsize} and {opt ysize} substantially, then you might also need to update the padding.{p_end}

{p2coldent : {opt labs:ize(string max=3)}}The size of the labels. The default values are {opt labs(1.6 1.6 1.6)}. If only one value is specified, it will passed on to all the layers.{p_end}

{p2coldent : {opt linew:idth(string max=3)}}The line width of the boxes. The default values are {opt linew(0.03 0.03 0.03)}. If only one value is specified, it will passed on to all the layers.{p_end}

{p2coldent : {opt linec:olor(string max=3)}}The line color of the boxes. The default values are {opt linec(black black black)}. If only one value is specified, it will passed on to all the layers.{p_end}

{p2coldent : {opt fi(numlist max=3)}}The fill intensity of the layers in the other they are specified. The default values are {opt fi(50 75 100)}.{p_end}

{p2coldent : {opt titlegap(num)}}Change the space between the title text and the boxes. Default value is {opt titlegap(0.1)}.{p_end}

{p2coldent : {opt labgap(num)}}Change the space between the box text and the values. Default value is {opt labgap(0.6)}. This option might be use if {opt labelprop} is used which might make
some labels overlap with each other.{p_end}

{p2coldent : {opt titleprop}}Make the size of the box titles proportional to the area.{p_end}

{p2coldent : {opt labprop}}Make the size of the labels proportional to the area.{p_end}

{p2coldent : {opt colorprop}}Add color gradient to the box colors. The colors are interpolated from the assigned level color to a 10% value of the color.
This can be changed using the {opt fade()} described below.{p_end}

{p2coldent : {opt fade(num)}}Change the end color used for interpolation in the {opt colorprop}. Default value is {opt fade(10)} or 10% of the color.{p_end}

{p2coldent : {opt labscale(num)}}This option changes how the labels are scaled. This is an advanced option and should be used cautiously. Default value is {opt labscale(0.3333)}.
The formula for scaling is {it:((height x width x area) / sum of values)^labscale}.{p_end}

{p2coldent : {opt title(), subtitle(), note()}}These are standard twoway graph options.{p_end}

{p2coldent : {opt name(), saving()}}These are standard twoway graph options.{p_end}

{p2coldent : {opt scheme(string)}}Load the custom scheme. Above options can be used to fine tune individual elements.{p_end}

{synoptline}
{p2colreset}{...}


{title:Dependencies}

The {browse "http://repec.sowi.unibe.ch/stata/palettes/index.html":palette} package (Jann 2018, 2022) is required for {cmd:treemap}:

{stata ssc install palettes, replace}
{stata ssc install colrspace, replace}

Even if you have these installed, it is highly recommended to check for updates: {stata ado update, update}

{title:Examples}

See {browse "https://github.com/asjadnaqvi/treemap":GitHub} for a comprehensive set of examples.




{hline}

{title:Feedback}

Please submit bugs, errors, feature requests on {browse "https://github.com/asjadnaqvi/stata-treemap/issues":GitHub} by opening a new issue.

{title:Package details}

Version      : {bf:treemap} v1.53
This release : 10 Apr 2024
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

{p 4 8 2}Jann, B. (2022). {browse "https://ideas.repec.org/p/bss/wpaper/43.html":Color palettes for Stata graphics: an update}. University of Bern Social Sciences Working Papers No. 43. 

{p 4 8 2}Laserson, U. (2022). {browse "https://github.com/agatheblues/squarify":Python squarify}.


{title:Other visualization packages}

{psee}
    {helpb arcplot}, {helpb alluvial}, {helpb bimap}, {helpb bumparea}, {helpb bumpline}, {helpb circlebar}, {helpb circlepack}, {helpb clipgeo}, {helpb delaunay}, {helpb joyplot}, 
	{helpb marimekko}, {helpb sankey}, {helpb schemepack}, {helpb spider}, {helpb streamplot}, {helpb sunburst}, {helpb treecluster}, {helpb treemap}, {helpb waffle}