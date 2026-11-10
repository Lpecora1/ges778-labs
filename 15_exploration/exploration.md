# Helping readers explore


``` r
library(ggplot2) 
```

## Consumer spending

This is going to be a fairly open-ended lab (sorry!). The dataset you’ll
start out with is one we haven’t used before: `justviz::spending`, which
comes from the Census Bureau’s Consumer Expenditure Survey. It’s dense
and in a tricky format, so read the docs for it. Not only is there an
overview variable, `qtotal`, but also variables for 5 income quintiles.
The categories are also hierarchical. All of this gives us a lot to
explore and walk a reader through.

First do some light EDA, jotting down questions about the data as you
go. Start by getting to know the different categories. How many item
types are in each top-level category (`l2`)? How do any of these
categories fit into the total spending amount? What are the largest
spending categories, and are they the same across income quintiles?
(This will require some reshaping of the data.)

With data like this, filtering for whether a column is NA will be your
best friend, as will reshaping. For example, spending on all items:

``` r
all_spending_by_quint <- justviz::spending |>
    dplyr::filter(is.na(l2)) |>
    # pivot all columns that start with q
    tidyr::pivot_longer(dplyr::matches("^q"), names_to = "quintile", values_to = "value") |>
    dplyr::mutate(quintile = forcats::as_factor(quintile))

ggplot(all_spending_by_quint, aes(x = quintile, y = value)) +
    geom_col()
```

![](exploration_files/figure-commonmark/filter-all-1.png)

Average spending on food at home:

``` r
avg_food_at_home <- justviz::spending |>
    # l2 = food, l3 = food at home, specific food types come from l5 != NA
    dplyr::filter(l3 == "Food at home", !is.na(l5)) |>
        # order items by qtotal spending amount
        dplyr::mutate(item = forcats::fct_reorder(item, qtotal)) 

ggplot(avg_food_at_home, aes(x = qtotal, y = item)) +
    geom_col()
```

![](exploration_files/figure-commonmark/filter-l2-1.png)

Each quintile’s spending on different types of meat & eggs, where we’ll
show just subcategories of meat & eggs:

``` r
meat_types_by_quint <- justviz::spending |>
    # l4 = meats, l5 != NA
    dplyr::filter(l4 == "Meats, poultry, fish, and eggs", !is.na(l5)) |>
    # order items by qtotal spending amount
    dplyr::mutate(item = forcats::fct_reorder(item, qtotal)) |>
    # then reshape 
    tidyr::pivot_longer(dplyr::matches("^q"), names_to = "quintile", values_to = "value") |>
    dplyr::mutate(quintile = forcats::as_factor(quintile))

ggplot(meat_types_by_quint, aes(x = value, y = quintile, fill = item)) +
    geom_col(position = position_stack()) +
    scale_fill_brewer(palette = "Set2") +
    coord_cartesian(reverse = "y")
```

![](exploration_files/figure-commonmark/filter-l4-1.png)

Once you’ve done some EDA, find something to explore in more detail and
develop 1 or more charts that help your reader dig in. Jot down some
questions that you think someone might want to explore about this data
to guide you. Some techniques to try:

- small multiples, repeating the same chart
- facets to show different views of the data side by side or in a grid
- zooming in on a focus area
- multiple charts in a series

``` r
#EDA

justviz::spending
```

    # A tibble: 101 × 11
       item            l2    l3    l4    l5    qtotal    q1    q2    q3    q4     q5
       <fct>           <fct> <fct> <fct> <fct>  <dbl> <dbl> <dbl> <dbl> <dbl>  <dbl>
     1 Average annual… <NA>  <NA>  <NA>  <NA>   78535 35046 50054 66900 89972 150342
     2 Food            Food  <NA>  <NA>  <NA>   10169  5498  7400  9097 11845  16989
     3 Food at home    Food  Food… <NA>  <NA>    6224  3843  4952  5820  7162   9336
     4 Cereals and ba… Food  Food… Cere… <NA>     779   501   626   740   860   1166
     5 Cereals and ce… Food  Food… Cere… Cere…    240   156   191   223   270    359
     6 Bakery products Food  Food… Cere… Bake…    539   345   435   517   589    807
     7 Meats, poultry… Food  Food… Meat… <NA>    1414   889  1117  1342  1647   2074
     8 Beef            Food  Food… Meat… Beef     408   237   336   382   492    593
     9 Pork            Food  Food… Meat… Pork     260   180   234   241   285    357
    10 Other meats     Food  Food… Meat… Othe…    150    92   107   151   172    227
    # ℹ 91 more rows

``` r
spend<-justviz::spending


#entertainment

entertain <- justviz::spending |>
    # l2 = food, l3 = food at home, specific food types come from l5 != NA
    dplyr::filter(l2 == "Entertainment", !is.na(l3)) |>
        # order items by qtotal spending amount
        dplyr::mutate(item = forcats::fct_reorder(item, qtotal)) 

ggplot(entertain, aes(x = qtotal, y = item)) +
    geom_col()
```

![](exploration_files/figure-commonmark/unnamed-chunk-1-1.png)

``` r
#not sure about some of this repitition in item names


#healthcare - What is the biggest expense for health care? How does healtchare expense vary by quintile?

health <- justviz::spending |>
    dplyr::filter(l2 == "Healthcare", !is.na(l3)) |>
        dplyr::mutate(item = forcats::fct_reorder(item, qtotal)) 

ggplot(health, aes(x = qtotal, y = item)) +
    geom_col()
```

![](exploration_files/figure-commonmark/unnamed-chunk-1-2.png)

``` r
#crzy that health insurance is WAY more than everything else, I think I will explore this

health
```

    # A tibble: 4 × 11
      item             l2     l3    l4    l5    qtotal    q1    q2    q3    q4    q5
      <fct>            <fct>  <fct> <fct> <fct>  <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
    1 Health insurance Healt… Heal… <NA>  <NA>    4055  2153  3194  3842  4913  6160
    2 Medical services Healt… Medi… <NA>  <NA>    1252   661   848  1063  1384  2297
    3 Drugs            Healt… Drugs <NA>  <NA>     658   416   644   572   700   957
    4 Medical supplies Healt… Medi… <NA>  <NA>     233   215   140   200   251   359

``` r
health_by_quint <- justviz::spending |>
    dplyr::filter(l2 == "Healthcare", !is.na(l3)) |>
    dplyr::mutate(item = forcats::fct_reorder(item, qtotal)) |>
    tidyr::pivot_longer(dplyr::matches("^q"), names_to = "quintile", values_to = "value") |>
    dplyr::mutate(quintile = forcats::as_factor(quintile))

ggplot(health_by_quint, aes(x = value, y = quintile, fill = item)) +
    geom_col(position = position_stack()) +
    scale_fill_brewer(palette = "Set2") +
    coord_cartesian(reverse = "y")
```

![](exploration_files/figure-commonmark/unnamed-chunk-1-3.png)

``` r
#q5 spends more on everything, interesting how much more is spent on med services than other quintiles - more money = more access



# taking a look at breakdown not considering health insurance
health_by_quint_noIn <- justviz::spending |>
    dplyr::filter(l2 == "Healthcare", !is.na(l3)) |>
    dplyr::mutate(item = forcats::fct_reorder(item, qtotal)) |>
    tidyr::pivot_longer(dplyr::matches("^q"), names_to = "quintile", values_to = "value") |>
    dplyr::mutate(quintile = forcats::as_factor(quintile))|>
    dplyr::filter(item!="Health insurance")

ggplot(health_by_quint_noIn, aes(x = value, y = quintile, fill = item)) +
    geom_col(position = position_stack()) +
    scale_fill_brewer(palette = "Set2") +
    coord_cartesian(reverse = "y")
```

![](exploration_files/figure-commonmark/unnamed-chunk-1-4.png)

``` r
#q5 spends more medical services than all non-insurance expenditure in most lower quintiles

#how does spending vary by quintile and spedning category?

spend_types_by_quint <- justviz::spending |>
    dplyr::filter(l2 %in% c("Food","Housing", "Healthcare","Transportation"), is.na(l3)) |>
    dplyr::mutate(item = forcats::fct_reorder(item, qtotal)) |>
    tidyr::pivot_longer(dplyr::matches("^q"), names_to = "quintile", values_to = "value") |>
    dplyr::mutate(quintile = forcats::as_factor(quintile))


spend_types_by_quint
```

    # A tibble: 24 × 7
       item    l2      l3    l4    l5    quintile value
       <fct>   <fct>   <fct> <fct> <fct> <fct>    <dbl>
     1 Food    Food    <NA>  <NA>  <NA>  qtotal   10169
     2 Food    Food    <NA>  <NA>  <NA>  q1        5498
     3 Food    Food    <NA>  <NA>  <NA>  q2        7400
     4 Food    Food    <NA>  <NA>  <NA>  q3        9097
     5 Food    Food    <NA>  <NA>  <NA>  q4       11845
     6 Food    Food    <NA>  <NA>  <NA>  q5       16989
     7 Housing Housing <NA>  <NA>  <NA>  qtotal   26266
     8 Housing Housing <NA>  <NA>  <NA>  q1       14563
     9 Housing Housing <NA>  <NA>  <NA>  q2       19174
    10 Housing Housing <NA>  <NA>  <NA>  q3       24093
    # ℹ 14 more rows

``` r
ggplot(spend_types_by_quint, aes(x = value, y = quintile, fill = item)) +
    geom_col(position = position_stack()) +
    scale_fill_brewer(palette = "Set2") +
    coord_cartesian(reverse = "y")+
  facet_wrap(~ item)
```

![](exploration_files/figure-commonmark/unnamed-chunk-1-5.png)

``` r
#food,housing, healthcare,transportation
```

``` r
#charts


ggplot(health, aes(x = qtotal, y = item)) +
    geom_col()
```

![](exploration_files/figure-commonmark/unnamed-chunk-2-1.png)

``` r
ggplot(health_by_quint, aes(x = value, y = quintile, fill = item)) +
    geom_col(position = position_stack()) +
    scale_fill_brewer(palette = "Set3") +
    coord_cartesian(reverse = "y")
```

![](exploration_files/figure-commonmark/unnamed-chunk-2-2.png)

``` r
ggplot(health_by_quint_noIn, aes(x = value, y = quintile, fill = item)) +
    geom_col(position = position_stack()) +
    scale_fill_brewer(palette = "Set3") +
    coord_cartesian(reverse = "y")
```

![](exploration_files/figure-commonmark/unnamed-chunk-2-3.png)

``` r
ggplot(spend_types_by_quint, aes(x = value, y = quintile, fill = item)) +
    geom_col(position = position_stack()) +
    scale_fill_brewer(palette = "Set3") +
    coord_cartesian(reverse = "y")+
  facet_wrap(~ item)
```

![](exploration_files/figure-commonmark/unnamed-chunk-2-4.png)

## Revising a chart

Now that you’ve practiced creating explorations for your reader, do the
same with a chart of your own. If you’re not sick of your midterm data,
try one of the charts you made for your project; otherwise, revise a
chart from a previous lab. Start with overview data—averages, higher
geographies, larger groups—then zoom in in whatever way might be
appropriate for the data. Use facets and/or multiple charts to do this,
including different types of charts.

``` r
library(ggplot2)
library(sf)
```

    Linking to GEOS 3.13.1, GDAL 3.11.4, PROJ 9.7.0; sf_use_s2() is TRUE

``` r
Low_Wint_Run <- st_read(
  "../data/LowerWintersRun_StreamData_v3.shp")
```

    Reading layer `LowerWintersRun_StreamData_v3' from data source 
      `C:\Users\Leope\Documents\ges778-labs\data\LowerWintersRun_StreamData_v3.shp' 
      using driver `ESRI Shapefile'
    Simple feature collection with 832 features and 37 fields
    Geometry type: MULTILINESTRING
    Dimension:     XY
    Bounding box:  xmin: 1659562 ymin: 1995743 xmax: 1667206 ymax: 2007062
    Projected CRS: USA_Contiguous_Albers_Equal_Area_Conic_USGS_version

``` r
Low_Wint_Run_data <- Low_Wint_Run|>
  dplyr::select(ID, SinuosityI, PhysProv,Slope, strOrder, Avg_WD)

StreamData <- Low_Wint_Run_data |>
  dplyr::filter(SinuosityI <= 200)

StreamData$strOrder<-as.factor(StreamData$strOrder)

#orignal chart
ggplot(StreamData,aes(x=Slope/100,y=SinuosityI))+
  geom_point(aes(colour=strOrder))+
  geom_smooth(colour="blue")+
  scale_colour_manual(values=rcartocolor::carto_pal(5,name ="SunsetDark"))+
  labs(y="Sinuosity Index",x="Slope",title = "Slope, Sinuosity, and Stream Order in the Lower Winters Run Watershed, MD", colour="Stream Order",caption = "Data generated from 2025 Chesapeake watershed hyper-resolution hydrography and 1m DEM in ArcGIS Pro",subtitle = "Channel Slope = stream elevation change over horizontal length
Stream Order = hierarchical position of stream segment in drainage network")+
  scale_x_continuous(labels = scales::label_percent())+
  theme_classic()+
  theme(plot.subtitle = element_text(size = 10),plot.title = element_text(size=14, legend.title=element_text(size=6),axis.title=element_text(size = 9)))
```

    Warning in element_text(size = 14, legend.title = element_text(size = 6), : `...` must be empty.
    ✖ Problematic arguments:
    • legend.title = element_text(size = 6)
    • axis.title = element_text(size = 9)

    `geom_smooth()` using method = 'loess' and formula = 'y ~ x'

![](exploration_files/figure-commonmark/unnamed-chunk-3-1.png)

``` r
#faceted chart
ggplot(StreamData, aes(x = Slope/100, y = SinuosityI)) +
  geom_point(alpha = 0.6) +
  geom_smooth() +
  facet_wrap(~ strOrder, scales="free_x")+
  labs(y="Sinuosity Index",x="Slope",title = "Slope, Sinuosity, and Stream Order in the Lower Winters Run Watershed, MD", colour="Stream Order",caption = "Data generated from 2025 Chesapeake watershed hyper-resolution hydrography and 1m DEM in ArcGIS Pro",subtitle = "Channel Slope = stream elevation change over horizontal length
Stream Order = hierarchical position of stream segment in drainage network")+
  scale_x_continuous(labels = scales::label_percent())+
  theme_classic()+
  theme(plot.subtitle = element_text(size = 10),plot.title = element_text(size=14, legend.title=element_text(size=6),axis.title=element_text(size = 9)))
```

    Warning in element_text(size = 14, legend.title = element_text(size = 6), : `...` must be empty.
    ✖ Problematic arguments:
    • legend.title = element_text(size = 6)
    • axis.title = element_text(size = 9)

    Ignoring unknown labels:
    • colour : "Stream Order"

    `geom_smooth()` using method = 'loess' and formula = 'y ~ x'

![](exploration_files/figure-commonmark/unnamed-chunk-3-2.png)

``` r
ggplot(StreamData,aes(x=SinuosityI))+
  geom_histogram()+
  facet_wrap(~ strOrder, scales="free_x")
```

    `stat_bin()` using `bins = 30`. Pick better value `binwidth`.

![](exploration_files/figure-commonmark/unnamed-chunk-3-3.png)

``` r
ggplot(StreamData,aes(x=SinuosityI))+
  geom_histogram()+
  facet_wrap(~ PhysProv, scales="free_x")
```

    `stat_bin()` using `bins = 30`. Pick better value `binwidth`.

![](exploration_files/figure-commonmark/unnamed-chunk-3-4.png)

``` r
ggplot(StreamData,aes(x=Slope))+
  geom_histogram()+
  facet_wrap(~ strOrder, scales="free_x")
```

    `stat_bin()` using `bins = 30`. Pick better value `binwidth`.

![](exploration_files/figure-commonmark/unnamed-chunk-3-5.png)

``` r
ggplot(StreamData,aes(x=Slope))+
  geom_histogram()+
  facet_wrap(~ strOrder~PhysProv, scales="free_x")
```

    `stat_bin()` using `bins = 30`. Pick better value `binwidth`.

![](exploration_files/figure-commonmark/unnamed-chunk-3-6.png)
