# Changing & manipulating geographies


## Alternatives to the choropleth

``` r
library(ggplot2)
library(sf) 
```

    Warning: package 'sf' was built under R version 4.5.3

    Linking to GEOS 3.14.1, GDAL 3.12.1, PROJ 9.7.1; sf_use_s2() is TRUE

``` r
library(terra)
```

    Warning: package 'terra' was built under R version 4.5.3

    terra 1.9.50

``` r
tracts_sf <- tigris::tracts(state = "MD", cb = TRUE) |>
    dplyr::select(tract = GEOID, county = NAMELSADCO)
```

    Retrieving data for the year 2025

``` r
counties_sf <- tigris::counties(state = 'MD', cb = TRUE) |>
    dplyr::select(county = NAMELSAD)
```

    Retrieving data for the year 2025

We’re going to do some experiments. Start with basic choropleths. Use
either the ACS data or CDC data so you can try the same techniques for
both counties and tracts.

``` r
#need to join acs data to counties and tracts

#counties
acs_data<- justviz::acs|>
  dplyr::filter(level == "county")

acs_counties <- counties_sf |>
  dplyr::inner_join(acs_data, by = c("county" = "name"))

ggplot()+
  geom_sf(data =acs_counties,aes(fill=diversity_idx))
```

![](alt_geos_files/figure-commonmark/basic-choro-1.png)

``` r
ggplot()+
  geom_sf(data =acs_counties,aes(fill=black))
```

![](alt_geos_files/figure-commonmark/basic-choro-2.png)

``` r
ggplot()+
  geom_sf(data =acs_counties,aes(fill=median_hh_income))
```

![](alt_geos_files/figure-commonmark/basic-choro-3.png)

``` r
ggplot()+
  geom_sf(data =acs_counties,aes(fill=homeownership))
```

![](alt_geos_files/figure-commonmark/basic-choro-4.png)

``` r
#tracts
acs_data2<- justviz::acs|>
  dplyr::filter(level == "tract")

acs_tracts <- tracts_sf |>
  dplyr::inner_join(acs_data2, by = c("tract" = "name"))

ggplot()+
  geom_sf(data =acs_tracts,aes(fill=diversity_idx))
```

![](alt_geos_files/figure-commonmark/basic-choro-5.png)

``` r
ggplot()+
  geom_sf(data =acs_tracts,aes(fill=black))
```

![](alt_geos_files/figure-commonmark/basic-choro-6.png)

``` r
ggplot()+
  geom_sf(data =acs_tracts,aes(fill=median_hh_income))
```

![](alt_geos_files/figure-commonmark/basic-choro-7.png)

``` r
ggplot()+
  geom_sf(data =acs_tracts,aes(fill=homeownership))
```

![](alt_geos_files/figure-commonmark/basic-choro-8.png)

``` r
justviz::acs
```

    # A tibble: 1,486 × 41
       level  county name   total_pop ages00_17 ages18_34 ages35_64 ages65plus white
       <fct>  <chr>  <chr>      <dbl>     <dbl>     <dbl>     <dbl>      <dbl> <dbl>
     1 us     <NA>   Unite… 334922499      0.22      0.23      0.38       0.17  0.57
     2 state  <NA>   Maryl…   6206011      0.22      0.22      0.39       0.17  0.47
     3 county <NA>   Alleg…     67452      0.18      0.24      0.37       0.21  0.86
     4 county <NA>   Anne …    598166      0.22      0.22      0.4        0.16  0.62
     5 county <NA>   Balti…    850796      0.22      0.22      0.38       0.18  0.51
     6 county <NA>   Balti…    573243      0.21      0.27      0.37       0.15  0.26
     7 county <NA>   Calve…     94313      0.23      0.19      0.41       0.16  0.74
     8 county <NA>   Carol…     33669      0.24      0.2       0.39       0.17  0.73
     9 county <NA>   Carro…    175321      0.22      0.19      0.41       0.18  0.84
    10 county <NA>   Cecil…    104960      0.22      0.2       0.4        0.17  0.8 
    # ℹ 1,476 more rows
    # ℹ 32 more variables: black <dbl>, latino <dbl>, asian <dbl>,
    #   other_race <dbl>, diversity_idx <dbl>, foreign_born <dbl>, total_hh <dbl>,
    #   homeownership <dbl>, total_cost_burden <dbl>,
    #   total_severe_cost_burden <dbl>, owner_cost_burden <dbl>,
    #   owner_severe_cost_burden <dbl>, renter_cost_burden <dbl>,
    #   renter_severe_cost_burden <dbl>, no_vehicle_hh <dbl>, …

Now try some of the adjustments from the notes: get centroids and make
bubble maps; try cartograms; scale opacity by some useful population
measure. Do the techniques that work for the state’s 24 counties work as
well for all 1,464 tracts? What about for tracts within just one or two
counties—at what point do things get too cluttered?

``` r
# draw county boundaries, then draw points at their centroids

#bubbles
county_cents <- sf::st_centroid(acs_counties)
```

    Warning: st_centroid assumes attributes are constant over geometries

``` r
ggplot(acs_counties) +
    # layer for boundaries
    geom_sf(color = "gray20", linewidth = 0.2) +
    # layer for bubbles
    geom_sf(
        aes(size = median_hh_income),
        data = county_cents,
        alpha = 0.8,
        color="red"
    ) +
    # make sure to scale by area, not radius
    scale_size_area(
        max_size = 10
    ) +
    labs(
        title = "Median Household Income by MD County"
    ) +
    coord_sf(ndiscr = 0)
```

![](alt_geos_files/figure-commonmark/unnamed-chunk-1-1.png)

``` r
ggplot(acs_counties) +
    # layer for boundaries
    geom_sf(color = "gray20", linewidth = 0.2) +
    # layer for bubbles
    geom_sf(
        aes(size = diversity_idx),
        data = county_cents,
        alpha = 0.8,
        color="red"
    ) +
    # make sure to scale by area, not radius
    scale_size_area(
        max_size = 10
    ) +
    labs(
        title = "Diversity Index by MD County"
    ) +
    coord_sf(ndiscr = 0)
```

![](alt_geos_files/figure-commonmark/unnamed-chunk-1-2.png)

``` r
tract_cents <- sf::st_centroid(acs_tracts)
```

    Warning: st_centroid assumes attributes are constant over geometries

``` r
ggplot(acs_tracts) +
    # layer for boundaries
    geom_sf(color = "gray20", linewidth = 0.2) +
    # layer for bubbles
    geom_sf(
        aes(size = diversity_idx),
        data = tract_cents,
        alpha = 0.8,
        color="red"
    ) +
    # make sure to scale by area, not radius
    scale_size_area(
        max_size = 10
    ) +
    labs(
        title = "Diversity Index by MD Tract"
    ) +
    coord_sf(ndiscr = 0)
```

![](alt_geos_files/figure-commonmark/unnamed-chunk-1-3.png)

``` r
#way to crowded


#cartogram
acs_counties |>
    sf::st_transform(3857) |>
    cartogram::cartogram_cont(weight = "total_pop") |>
    ggplot() +
    geom_sf(aes(fill = foreign_born)) +
    scale_fill_fermenter(palette = "RdPu", direction = 1) +
    labs(
        title = "% Foreign Born Population in MD Counties",
        subtitle = "Shapes sized by total population"
    ) +
    coord_sf(ndiscr = 0)
```

![](alt_geos_files/figure-commonmark/unnamed-chunk-1-4.png)

``` r
acs_tracts |>
    sf::st_transform(3857) |>
    cartogram::cartogram_cont(weight = "total_pop") |>
    ggplot() +
    geom_sf(aes(fill = foreign_born)) +
    scale_fill_fermenter(palette = "RdPu", direction = 1) +
    labs(
        title = "% Foreign Born Population in MD Tracts",
        subtitle = "Shapes sized by total population"
    ) +
    coord_sf(ndiscr = 0)
```

![](alt_geos_files/figure-commonmark/unnamed-chunk-1-5.png)

## Simplifying points

Obtain some point data in one of 3 ways:

- Use one of the point datasets from `justviz` (either `vacants_sf` or
  `art_sf`)
- Download point data from OSM (look through the
  [wiki](https://wiki.openstreetmap.org/wiki/Map_features) for the
  feature type you want). Make sure it’s something that will return
  points, such as bus stops or benches. The wiki table has an icon for
  features that return nodes.
- Download point data from a local open data portal:
  - Baltimore city https://data.baltimorecity.gov
  - Maryland GIS https://data.imap.maryland.gov/

``` r
vacants<-justviz::vacants_sf
```

### Gridding

Create a grid over the relevant area (the state, a county, etc) using
`sf::st_make_grid`. Experiment with making a grid by the number of cells
vs cells of a certain size. Then join your points to the grid and
aggregate your points to the grid This might mean just taking the count
of points in each grid cell, or something like averaging an attribute,
depending on your data and what you want to do with it.

Map your gridded data. Pay attention to color palettes that work well.
If there are any other shapes you want to overlay, such as boundaries or
related features, add those as new layers. Try this a few times,
experimenting with different ways to structure the grid to see what
gives you the best balance between granularity and legibility. (You
could also try a hexagonal grid, or plot cells as points instead of
polygons.)

``` r
balt_to_grid <- counties_sf |>
    dplyr::filter(county == "Baltimore city") |>
    sf::st_geometry() |>
    sf::st_transform(2248)

# for each grid, transform back to 4269 & make an sf data frame
# filter for only cells that intersect with city
# then give unique ID to each cell to aggregate
# supply n to set number of cells in each direction
balt_grid_20x20 <- balt_to_grid |>
    sf::st_make_grid(n = 20) |>
    sf::st_as_sf() |>
    sf::st_filter(balt_to_grid) |>
    sf::st_transform(4269) |>
    tibble::rowid_to_column("id")

# supply cellsize to set length of cells
balt_grid_05_mi <- balt_to_grid |>
    sf::st_make_grid(cellsize = 5280 / 2) |>
    sf::st_as_sf() |>
    sf::st_filter(balt_to_grid) |>
    sf::st_transform(4269) |>
    tibble::rowid_to_column("id")

balt_grid_20x20 |>
    sf::st_join(justviz::vacants_sf) |>
    dplyr::group_by(id) |>
    dplyr::summarise(n_vacants = dplyr::n()) |>
    ggplot() +
    geom_sf(aes(fill = n_vacants), color = "gray20", linewidth = 0.1) +
    geom_sf(data = balt_to_grid, fill = NA, color = "black") +
    scale_fill_fermenter(palette = "RdPu", direction = 1) +
    coord_sf(ndiscr = 0) +
    labs(
        title = "Count of vacants, aggregated to 400-cell grid, Baltimore city"
    )
```

![](alt_geos_files/figure-commonmark/grids-1.png)

``` r
balt_to_grid <- counties_sf |>
    dplyr::filter(county == "Baltimore city") |>
    sf::st_geometry() |>
    sf::st_transform(2248)

# for each grid, transform back to 4269 & make an sf data frame
# filter for only cells that intersect with city
# then give unique ID to each cell to aggregate
# supply n to set number of cells in each direction
balt_grid_50x50 <- balt_to_grid |>
    sf::st_make_grid(n = 50) |>
    sf::st_as_sf() |>
    sf::st_filter(balt_to_grid) |>
    sf::st_transform(4269) |>
    tibble::rowid_to_column("id")

# supply cellsize to set length of cells
balt_grid_025_mi <- balt_to_grid |>
    sf::st_make_grid(cellsize = 5280 / 4) |>
    sf::st_as_sf() |>
    sf::st_filter(balt_to_grid) |>
    sf::st_transform(4269) |>
    tibble::rowid_to_column("id")

balt_grid_50x50 |>
    sf::st_join(justviz::vacants_sf) |>
    dplyr::group_by(id) |>
    dplyr::summarise(n_vacants = dplyr::n()) |>
    ggplot() +
    geom_sf(aes(fill = n_vacants), color = "gray20", linewidth = 0.1) +
    geom_sf(data = balt_to_grid, fill = NA, color = "black") +
    scale_fill_fermenter(palette = "RdPu", direction = 1) +
    coord_sf(ndiscr = 0) +
    labs(
        title = "Count of vacants, aggregated to 2500-cell grid, Baltimore city"
    )
```

![](alt_geos_files/figure-commonmark/grids-2.png)

### Densities

Now take the same points and map their density. You can try the easy
method (`geom_density_2d_filled` or its variants). Or, go ahead and use
the proper method outlined in the notes with `spatstat`, first
calculating a KDE, then converting it to a raster.

``` r
# naive way with geom_density_2d:
# extract matrix of point coordinates, drop geometry column
# expand matrix out into 2 proper columns
vacants_xy <- justviz::vacants_sf |>
    sf::st_transform(2248) |>
    dplyr::mutate(coords = sf::st_coordinates(geometry)) |>
    sf::st_drop_geometry() |>
    dplyr::mutate(x = coords[, "X"], y = coords[, "Y"])

ggplot(vacants_xy) +
    geom_density_2d_filled(aes(x = x, y = y)) +
    geom_sf(data = balt_to_grid, fill = NA, color = "black") +
    scale_fill_brewer(palette = "RdPu", direction = 1) +
    coord_sf(ndiscr = 0) +
    labs(title = "Density of vacants")
```

![](alt_geos_files/figure-commonmark/densities-1.png)
