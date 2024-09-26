
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ebvcube package

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/ebvcube)](https://CRAN.R-project.org/package=ebvcube)
[![R-CMD-check](https://github.com/LuiseQuoss/ebvcube/actions/workflows/R.yaml/badge.svg?branch=dev)](https://github.com/LuiseQuoss/ebvcube/actions/workflows/R.yaml)
[![codecov](https://codecov.io/gh/LuiseQuoss/ebvcube/graph/badge.svg?token=2TVFHRKBNJ)](https://app.codecov.io/gh/LuiseQuoss/ebvcube)
<!-- badges: end -->

This package can be used to easily access the data of the EBV netCDFs
which can be downloaded from the [EBV Data
Portal](https://portal.geobon.org/). It also provides some basic
visualization. Advanced users can build their own netCDFs following the
EBV structure.

## 1. Basis

The EBV netCDF structure is designed to hold Essential Biodiversity
Variables. This concept is further described
[here](https://geobon.org/ebvs/what-are-ebvs/). The files are based on
the [Network Common Data
Format](https://www.unidata.ucar.edu/software/netcdf/) (netCDF).
Additionally, it follows the [Climate and Forecast
Conventions](https://cfconventions.org/Data/cf-conventions/cf-conventions-1.8/cf-conventions.html)
(CF, version 1.8) and the [Attribute Convention for Data
Discovery](https://wiki.esipfed.org/Attribute_Convention_for_Data_Discovery_1-3)
(ACDD, version 1.3).

## 2. Data structure

The structure allows several datacubes per netCDF file. These cubes have
four dimensions: longitude, latitude, time and entity, whereby the last
dimension can, e.g., encompass different species or groups of species,
ecosystem types or other. The usage of hierarchical groups enables the
coexistence of multiple data cubes. All cubes share the same dimensions.
The first level (netCDF group) are scenarios, e.g., the modelling for
different Shared Socioeconomic Pathways (SSP) scenarios. The second
level (netCDF group) are metrics, e.g., the percentage of protected area
per pixel and its proportional loss over a certain time span per pixel.
All metrics are repeated per scenario, if any are present.

``` bash
├── scenario_1
│   └── metric_1
│       └── ebv_cube [lon, lat, time, entity]
└── scenario_2
    └── metric_2
        └── ebv_cube [lon, lat, time, entity]
```

Just keep in mind: All EBV netCDF always have a metric. But they may or
may not have a scenario. The resulting datacubes hold the data. These
datacubes are 4D.

## 2. Installation

You can install the ebvcube packages with:

``` r
#get the current version on CRAN
install.packages('ebvcube') 

#install the latest version from GitHub
devtools::install_github('https://github.com/LuiseQuoss/ebvcube/tree/dev')

#troubleshooting for BioConductor packages
#if one of the following packages is not loaded: rhdf5, DelayedArray, HDF5Array
install.packages("BiocManager")
BiocManager::install('rhdf5')
BiocManager::install('DelayedArray')
BiocManager::install('HDF5Array')
```

## 3. Working with the package - a quick intro

The example data set used in this README is a spatial subset (African
continent) of the [Local bird diversity
(cSAR/BES-SIM)](https://portal.geobon.org/ebv-detail?id=1) data set by
Ines Martins.

### 3.1 Take a very first look at the file

With the following two functions you get the metadata of a specific EBV
netCDF file. First we take a look at some basic metadata of that file.
The properties encompass much more information!

``` r
library(ebvcube)
#> Error in library(ebvcube): there is no package called 'ebvcube'

#set the path to the file
file <- system.file(file.path("extdata", "martins_comcom_subset.nc"), package="ebvcube")

#read the properties of the file
prop.file <- ebv_properties(file, verbose=FALSE)
#> Error in ebv_properties(file, verbose = FALSE): could not find function "ebv_properties"

#take a look at the general properties of the data set - there are more properties to discover!
prop.file@general[1:4]
#> Error: object 'prop.file' not found
slotNames(prop.file)
#> Error: object 'prop.file' not found
```

Now let’s get the paths to all possible datacubes. The resulting
data.frame includes the paths and also descriptions of the metric and/or
scenario and/or entity. The paths basically consist of the nested
structure of scenario, metric and the datacube.

``` r
datacubes <- ebv_datacubepaths(file, verbose=FALSE)
#> Error in ebv_datacubepaths(file, verbose = FALSE): could not find function "ebv_datacubepaths"
datacubes
#> Error: object 'datacubes' not found
```

In the next step we will get the properties of one specific datacube -
fyi: the result also holds the general file properties from above.

``` r
prop.dc <- ebv_properties(file, datacubes[1, 1], verbose=FALSE)
#> Error in ebv_properties(file, datacubes[1, 1], verbose = FALSE): could not find function "ebv_properties"
prop.dc@metric
#> Error: object 'prop.dc' not found
```

### 3.2 Plot the data to get a better impression

To discover the spatial distribution of the data, you can plot a map of
the datacube that we just looked at. It has 12 timesteps. Here we look
at the first one.

``` r
#plot the global map
dc <- datacubes[2, 1]
#> Error: object 'datacubes' not found
ebv_map(file, dc, entity=1, timestep = 1, classes = 9,
        verbose=FALSE, col_rev = TRUE)
#> Error in ebv_map(file, dc, entity = 1, timestep = 1, classes = 9, verbose = FALSE, : could not find function "ebv_map"
```

It’s nice to see the global distribution, but how is the change of that
datacube (non forest birds) over time? Let’s take a look at the average.
The function returns the values, catch them!

``` r
#get the averages and plot
averages <- ebv_trend(file, dc, entity=1, verbose=FALSE)
#> Error in ebv_trend(file, dc, entity = 1, verbose = FALSE): could not find function "ebv_trend"
averages
#> Error: object 'averages' not found
```

It would be cool to have that for other indicators as well? Check out
the different options for ‘method’.

### 3.3 Read the data from the files to start working

Before you actually load the data it may be nice to get an impression of
the value range and other basic measurements.

``` r
#info for whole dataset
measurements <- ebv_analyse(file, dc, entity=1, verbose=FALSE)
#> Error in ebv_analyse(file, dc, entity = 1, verbose = FALSE): could not find function "ebv_analyse"
#see the included measurements
names(measurements)
#> Error: object 'measurements' not found
#check out the mean and the number of pixels
measurements$mean
#> Error: object 'measurements' not found
measurements$n
#> Error: object 'measurements' not found

#info for a subset defined by a bounding box
#you can also define the subset by a Shapefile - check it out!
bb <- c(-26, 64, 30, 38)
measurements.bb <- ebv_analyse(file, dc, entity = 1, subset = bb, verbose=FALSE)
#> Error in ebv_analyse(file, dc, entity = 1, subset = bb, verbose = FALSE): could not find function "ebv_analyse"
#check out the mean of the subset
measurements.bb$mean
#> Error: object 'measurements.bb' not found
measurements.bb$n
#> Error: object 'measurements.bb' not found
```

To access the first three timesteps of the data you can use the
following:

``` r
#load whole data as array for two timesteps
data <- ebv_read(file, dc, entity = 1, timestep = 1:3, type = 'a')
#> Error in ebv_read(file, dc, entity = 1, timestep = 1:3, type = "a"): could not find function "ebv_read"
dim(data)
#> NULL
```

You can also get a spatial subset of the data by providing a Shapefile.

``` r
#load subset from shapefile (Cameroon)
shp <- system.file(file.path('extdata', 'cameroon.shp'), package="ebvcube")
data.shp <- ebv_read_shp(file, dc, entity=1, shp = shp, timestep = c(1, 2, 3), verbose=FALSE)
#> Error in ebv_read_shp(file, dc, entity = 1, shp = shp, timestep = c(1, : could not find function "ebv_read_shp"
dim(data.shp)
#> Error: object 'data.shp' not found
#very quick plot of the resulting raster plus the shapefile
borders <- terra::vect(shp)
#> Error: [vect] file does not exist:
ggplot2::ggplot() +
  tidyterra::geom_spatraster(data = data.shp[[1]]) +
  tidyterra::geom_spatvector(data = borders, fill = NA) +
  ggplot2::scale_fill_fermenter(na.value=NA, palette = 'YlGn', direction = 1) +
  ggplot2::theme_classic()
#> Error: object 'data.shp' not found
```

Imagine you have a very large dataset but only limited memory. The
package provides the possibility to load the data as a DelayedArray. The
ebv_write() function helps you to write that data back on disk properly.
Look into the manual to obtain more information.

### 3.4 Take a peek on the creation of an EBV netCDF

#### a. Create an empty EBV netCDF (with metadata)

First of all, you have to insert all the metadata in the [EBV Data
Portal](https://portal.geobon.org/home) and then use the resulting text
file (json format) to create an empty netCDF which complies to the EBV
netCDF structure, i.e., it has the correct structure mapped to your data
and holds the metadata. Additionally to that (json) text file, the
function needs a list of all entities the netCDF (see help page for
detailed information) will encompass and geospatial information such as
the coordinate reference system.

The example is based on the [Local bird diversity
(cSAR/BES-SIM)](https://portal.geobon.org/ebv-detail?id=1).

``` r
#paths
json <- system.file(file.path('extdata', 'metadata.json'), package="ebvcube")
newNc <- file.path(system.file(package="ebvcube"), 'extdata', 'test.nc')
entities <- c('forest bird species', 'non-forest bird species', 'all bird species')
#defining the fillvalue - optional
fv <- -3.4e+38
#create the netCDF
ebv_create(jsonpath = json, outputpath = newNc, entities = entities,
           epsg = 4326, extent = c(-180, 180, -90, 90), resolution = c(1, 1),
           fillvalue = fv, overwrite=TRUE, verbose=FALSE)
#> Error in ebv_create(jsonpath = json, outputpath = newNc, entities = entities, : could not find function "ebv_create"

#needless to say: check the properties of your newly created file to see if you get what you want
#especially the entity_names from the slot general should be checked to see if your csv was formatted the right way
print(ebv_properties(newNc, verbose=FALSE)@general$entity_names)
#> Error in ebv_properties(newNc, verbose = FALSE): could not find function "ebv_properties"

#check out the (still empty) datacubes that are available
dc.new <- ebv_datacubepaths(newNc, verbose=FALSE)
#> Error in ebv_datacubepaths(newNc, verbose = FALSE): could not find function "ebv_datacubepaths"
print(dc.new)
#> Error: object 'dc.new' not found
```

Hint: You can always take a look at your netCDF in
[Panoply](https://www.giss.nasa.gov/tools/panoply/) provided by NASA.
That’s very helpful to understand the structure.

#### b. Add your data to the EBV NetCDF

In the next step you can add your data to the netCDF from GeoTiff files
or in-memory objects (matrix/array). You need to indicate the
datacubepath the data belongs to. You can add your data timestep per
timestep, in slices or all at once. You can simply add more data to the
same datacube by changing the timestep definition.

``` r
#path to tif with data
root <- system.file(file.path('extdata'), package="ebvcube")
tifs <- c('entity1.tif', 'entity2.tif', 'entity3.tif')
tif_paths <- file.path(root, tifs)

#adding the data
entity <- 1
for (tif in tif_paths){
  ebv_add_data(filepath_nc = newNc, datacubepath=dc.new[1, 1], entity = entity,
              timestep=1:3, data = tif, band=1:3)
  entity <- entity + 1
}
#> Error in ebv_add_data(filepath_nc = newNc, datacubepath = dc.new[1, 1], : could not find function "ebv_add_data"
```

#### c. Add missing attributes to datacube

Ups! So you did a mistake and want to change the attribute?! No problem.
Just use the upcoming function to change it.

``` r
ebv_attribute(newNc, attribute_name='units', value='Percentage', levelpath=dc.new[1, 1])
#> Error in ebv_attribute(newNc, attribute_name = "units", value = "Percentage", : could not find function "ebv_attribute"
#check the properties one more time - perfect!
print(ebv_properties(newNc, dc.new[1, 1], verbose=FALSE)@ebv_cube$units)
#> Error in ebv_properties(newNc, dc.new[1, 1], verbose = FALSE): could not find function "ebv_properties"
```

In this case the levelpath corresponds to the datacube path. But you can
also alter attributes at the metric or scenario level. See the manual
for more info.

## 4. Cite package

``` r
citation('ebvcube')
#> Error in citation("ebvcube"): there is no package called 'ebvcube'
```

## List of all functions

| Functionality      | Function            | Description                                         |
|:-------------------|:--------------------|:----------------------------------------------------|
| Basic access       | ebv_datacubepaths   | Get all available data cubes in the netCDF          |
|                    | ebv_properties      | Get all the metadata of the netCDF                  |
|                    | ebv_download        | Download EBV netCDFs from the EBV Portal            |
| Data access        | ebv_read            | Read the data                                       |
|                    | ebv_read_bb         | Read a spatial subset given by a bounding box       |
|                    | ebv_read_shp        | Read a spatial subset given by a Shapefile          |
|                    | ebv_analyse         | Get basic measurements of the data                  |
|                    | ebv_write           | Write manipulated data back to disc                 |
| Data visualization | ebv_map             | Plot a map of the specified data slice              |
|                    | ebv_trend           | Plot the temporal trend                             |
|                    | ebv_taxonomy_app    | Shiny App to browse and plot your taxonomic netCDFs |
| Data creation      | ebv_create          | Create a new EBV netCDF                             |
|                    | ebv_create_taxonomy | Create a new EBV netCDF with taxonomy info          |
|                    | ebv_metadata        | Create the EBV metadata text file (JSON)            |
|                    | ebv_add_data        | Add data to the new netCDF                          |
|                    | ebv_attribute       | Change an attribute value                           |
