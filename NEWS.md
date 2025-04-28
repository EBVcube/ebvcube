# ebvcube 0.5.0

## Major changes

-   ebv_create_taxonomy:
    -   renamed entity_list and entity_levels to entity_taxonomy_table and entity_taxonomy_levels (ebv_properties still reads the old naming for now)
    -   remove lsid and replace by taxonomy_key, add attribute to variable which refers to the name of the entity_taxonomy_key of the authority of the taxonomic backbone (long_name)
-   ebv_properties:
    -   read either from entity_list and entity_levels or entity_taxonomy_table and entity_taxonomy_levels
    -   read both: lsid and entity_taxonomy_key

## Bug fixes

-   set ignore_RAM to TRUE for the tests


# ebvcube 0.4.0

## Major changes

-   renamed metadata terms: 'ebv_spatial_scope' to 'ebv_geospatial_scope' and 'ebv_spatial_description' to 'ebv_geospatial_description'
-   ebv_create(\_taxonomy): add date_metadata_modified and date_modified
-   added new metadata terms: publisher_url, creator_url

## Minor changes

-   ebv_download: add doi (now available in API)
-   ebv_properties: add time_coverage_start and time_coverage_end + date_metadata_modified and date_modified
-   add new test-data, update tests regarding updated metadata terms and JSONs

## Bug fixes

-   ebv_create_taxonomy: remove rhdf5-Na.OK attribute from entity_list
-   DelayedArray errors on ubuntu dev

# ebvcube 0.3.3

## Bug fixes

-   update EBV Data Portal website URL

# ebvcube 0.3.2

## Bug fixes

-   add read-only flag to test-file (test-ebv_utils.R)

# ebvcube 0.3.1

## Bug fixes

-   correct old url in News.md

# ebvcube 0.3.0

## Major changes

-   new function: ebv_metadata
-   new helper functions: ebv_i_vector_intersect, ebv_i_contained, ebv_i_check_iso_res, ebv_i_check_iso_date
-   new Shiny App: ebv_taxonomy_app
-   add DOI to ebv_create(\_taxonomy) and ebv_properties
-   GitHub repo transfer to <https://github.com/EBVcube/ebvcube/>

## Minor changes

-   ebv_add_data: add argument 'raw' to ignore scale and offset values

## Bug fixes

-   ebv_download: corrected ID-missmatch when giving ID by title
-   ebv_map: fix color scales, fix bug 'length of breaks and labels differ', add scenario to subtitle
-   ebv_properties: ensure that metric or datacube argument is given

# ebvcube 0.2.3

## Bug fixes

-   edit test file for ebv_download: make sure the portal website is up
-   new helper function: ebv_i_check_url

# ebvcube 0.2.1

## Bug fixes

-   remove old url of codecov from badge

# ebvcube 0.2.0

## Major changes

-   all (affected) functions: define timestep(s) also as an ISO formatted date
-   add new arguments: define metric and scenario by name & index instead of the datacubepath
-   new function: ebv_create_taxonomy including new utils function ebv_i_char_variable
-   add taxonomy-info the ebv_properties
-   ebv_create(\_taxonomy): if one timestep but start and end date differ, apply end date

## Bug fixes

-   ebv_map: remove outdated stuff from guide_bins
-   ebv_write: DelayedArray 'name' variable was not defined

# ebvcube 0.1.7

## Major changes

-   ebv_download: download via DOI
-   ebv_create: lon and lat units changed (see below)
-   EBVcube format: geospatial units: 'degrees'/'meters' to 'degree'/'meter'
-   ebv_download: return path of netCDF file also if it is already downloaded

## Bug fixes

-   remove ebv_i_file_opened from the functions
-   ebv_read: read-access only

# ebvcube 0.1.6

## Major changes

-   ebv_resample: added more methods
-   ebv_create: lower compression to 5
-   ebv_download: return path
-   ebv_map: col_rev does not reverse the numbers in the legend

## Bug fixes

-   ebv_download: fix the internet check
-   ebv_add_data: array data error (transpose)
-   ebv_attribtue: change 'coordinate' to 'coordinates' (black-list attribute)

# ebvcube 0.1.4

## Major changes

-   ebv_properties: speed up for nc with many entities

## Bug fixes

-   ebv_datacubepaths: implement CRAN feedback - read-only flag was missing at one point

# ebvcube 0.1.3

## Major changes

-   ebv_trend: alter trend-plot (dashed-lines, subtitle)
-   ebv_map: correct the display of binary maps
-   ebv_create: implemented paleo and irregular dates netCDFs (terranova)
-   ebv_create: correct typo: coordinates instead of coordinate for entity coordinate
-   ebv_properties: remove backwards compatibility to old standard (before ACDD)
-   replaced h5ls by h5dump to make ebv_properties and ebv_datacubepaths faster
-   ebv_properties: rename 'timesteps_natural' to 'dates' (changes across functions)

## Bug fixes

-   ebv_create: contributor_name, content coverage type and domain corrected (comma + white space)
-   ebv_i_file_opened: solve error on MAC OS (CRAN)
-   ebv_i_eval_epsg: suppress warning by terra when assigning a crs (test error). [#23](https://github.com/EBVCube/ebvcube/issues/23) by Roger Bivand

# ebvcube 0.1.2

## Major changes

-   implement CRAN feedback (ebv_i_file_opened (lsof to fuser), examples and test (writing to user library))

## Bug fixes

-   ebv_create: keywords for spatial_scope
-   ebv_attribute: ebv_cube attributes connected to metric (changes over all scenarios)

# ebvcube 0.1.1

## Major changes

-   implement CRAN feedback (examples(dontrun))

## Bug fixes

# ebvcube 0.1.0

## Major changes

-   using ggplot2 for plots
-   using terra for geospatial operations (removing dependencies: gdalUtils, rgdal, raster and sp)

## Bug fixes

# ebvcube 0.0.1

First version of the package
