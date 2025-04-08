test_that("test ebv_create_taxonomy no lsid", {
  #test ebv_create_taxonomy without lsid ----

  #basic paths
  root <- system.file(file.path("extdata/testdata"), package="ebvcube")
  json <- file.path(root, '5.json')
  taxonomy <- file.path(root, 'id5_entities.csv')
  file <- tempfile(fileext='.nc')

  #spatial info
  extent <- c(-180, 180, -90, 90)
  res <- c(0.25, 0.25)
  fillvalue <- -127
  prec <- 'float'
  epsg <- 4326
  sep <- ','

  #create empty file
  expect_silent(ebv_create_taxonomy(jsonpath = json,
                     outputpath = file,
                     taxonomy = taxonomy,
                     taxonomy_key = FALSE,
                     epsg = epsg,
                     extent = extent,
                     timesteps = '2020-12-31',
                     fillvalue = fillvalue,
                     prec = prec,
                     sep = sep,
                     force_4D = TRUE,
                     overwrite = TRUE,
                     verbose = FALSE))

  #test the elements of the taxonomy
  hdf <- rhdf5::H5Fopen(file)

  #taxonomy_table
  taxonomy_table.id <- rhdf5::H5Dopen(hdf, 'entity_taxonomy_table')
  expect_equal(trimws(paste0(taxonomy_table.id[1,1,], collapse = '')), "Hipposideros curtus")
  expect_equal(trimws(paste0(taxonomy_table.id[2,1,], collapse = '')), "Hipposideridae")
  expect_equal(trimws(paste0(taxonomy_table.id[3,1,], collapse = '')), "Chiroptera")
  rhdf5::H5Dclose(taxonomy_table.id)

  #no lsid created
  expect_equal(rhdf5::H5Lexists(hdf, 'entity_taxonomy_key'), FALSE)

  #taxon level names
  taxonomy_levels.id <- rhdf5::H5Dopen(hdf, 'entity_taxonomy_levels')
  expect_equal(trimws(paste0(taxonomy_levels.id[1,], collapse = '')), "binomial")
  expect_equal(trimws(paste0(taxonomy_levels.id[2,], collapse = '')), "family")
  expect_equal(trimws(paste0(taxonomy_levels.id[3,], collapse = '')), "order")
  expect_equal(rhdf5::H5Aexists(taxonomy_levels.id, 'rhdf5-NA.OK'), FALSE)
  rhdf5::H5Dclose(taxonomy_levels.id)

  rhdf5::H5Fclose(hdf)

  #test ebv_properties taxonomy
  taxonomy_table <- ebv_properties(file, verbose = FALSE)@general$taxonomy
  expect_equal(names(taxonomy_table), c("binomial", "family", "order"))
  expect_equal(unlist(taxonomy_table[1,1]), "Hipposideros curtus")
  expect_equal(unlist(taxonomy_table[1,2]), "Hipposideridae")
  expect_equal(unlist(taxonomy_table[1,3]), "Chiroptera")
  taxonomy_key <- ebv_properties(file, verbose = FALSE)@general$taxonomy_key
  expect_equal(taxonomy_key, NA)

  #remove file
  file.remove(file)


})


test_that("test ebv_create_taxonomy with lsid", {
  #test ebv_create_taxonomy with lsid ----

  #basic paths
  root <- system.file(file.path("extdata/testdata"), package="ebvcube")
  json <- file.path(root, '5_single_date.json')
  taxonomy <- file.path(root, 'id5_taxid.csv')
  file <- tempfile(fileext='.nc')

  #spatial info
  extent <- c(-180, 180, -90, 90)
  res <- c(0.25, 0.25)
  fillvalue <- -127
  prec <- 'float'
  epsg <- 4326
  sep <- ','

  #create empty file
  expect_silent(ebv_create_taxonomy(jsonpath = json,
                                    outputpath = file,
                                    taxonomy = taxonomy,
                                    taxonomy_key = TRUE,
                                    epsg = epsg,
                                    extent = extent,
                                    fillvalue = fillvalue,
                                    prec = prec,
                                    sep = sep,
                                    force_4D = TRUE,
                                    overwrite = TRUE,
                                    verbose = FALSE))

  #test the elements of the taxonomy
  hdf <- rhdf5::H5Fopen(file)

  #taxonomy_table
  taxonomy_table.id <- rhdf5::H5Dopen(hdf, 'entity_taxonomy_table')
  expect_equal(trimws(paste0(taxonomy_table.id[1,2,], collapse = '')), "Microcebus rufus")
  expect_equal(trimws(paste0(taxonomy_table.id[2,2,], collapse = '')), "Cheirogaleidae")
  expect_equal(trimws(paste0(taxonomy_table.id[3,2,], collapse = '')), "Primates")
  rhdf5::H5Dclose(taxonomy_table.id)

  #check taxonomy_key created
  expect_equal(rhdf5::H5Lexists(hdf, 'entity_taxonomy_key'), TRUE)
  taxonomy_key.id <- rhdf5::H5Dopen(hdf, 'entity_taxonomy_key')
  expect_equal(trimws(paste0(taxonomy_key.id[1,], collapse = '')), "10125")
  expect_equal(rhdf5::H5Aexists(taxonomy_key.id, 'rhdf5-NA.OK'), FALSE)
  expect_equal(ebv_i_read_att(taxonomy_key.id, 'long_name'), 'usageKey')
  rhdf5::H5Dclose(taxonomy_key.id)

  #taxon level names
  taxonomy_levels.id <- rhdf5::H5Dopen(hdf, 'entity_taxonomy_levels')
  expect_equal(trimws(paste0(taxonomy_levels.id[1,], collapse = '')), "scientificName")
  expect_equal(trimws(paste0(taxonomy_levels.id[2,], collapse = '')), "family")
  expect_equal(trimws(paste0(taxonomy_levels.id[3,], collapse = '')), "order")
  expect_equal(rhdf5::H5Aexists(taxonomy_levels.id, 'rhdf5-NA.OK'), FALSE)
  rhdf5::H5Dclose(taxonomy_levels.id)

  #test ebv_i_p
  did_list <- rhdf5::H5Dopen(hdf, 'entity_taxonomy_table')
  did_list_data <- rhdf5::H5Dread(did_list)
  rhdf5::H5Dclose(did_list)
  values <- c("Hipposideridae", "Cheirogaleidae", "Echimyidae", "Procyonidae", "Rhinolophidae", "Phyllostomidae",
              "Vespertilionidae","Rhinolophidae",   "Phyllostomidae",  "Muridae",
              "Pteropodidae",     "Echimyidae",      "Phalangeridae",   "Soricidae",       "Cricetidae",
              "Soricidae", "Ctenomyidae",     "Phyllostomidae",  "Emballonuridae",  "Callitrichidae",
              "Cricetidae",      "Geomyidae",       "Molossidae",      "Dipodidae",       "Bovidae",
              "Molossidae",      "Tarsiidae",       "Macropodidae",    "Cercopithecidae", "Muridae")
  expect_equal(apply(did_list_data[2, , ], 1, ebv_i_p),values)
  rhdf5::H5Fclose(hdf)

  #test ebv_properties taxonomy
  taxonomy_table <- ebv_properties(file, verbose = FALSE)@general$taxonomy
  expect_equal(names(taxonomy_table), c("scientificName", "family", "order"))
  expect_equal(unlist(taxonomy_table[1,1]), "Hipposideros curtus")
  expect_equal(unlist(taxonomy_table[1,2]), "Hipposideridae")
  expect_equal(unlist(taxonomy_table[1,3]), "Chiroptera")
  taxonomy_key <- ebv_properties(file, verbose = FALSE)@general$taxonomy_key
  expect_equal(taxonomy_key[1:3], c('10125', '13324', '18296'))

  #remove file
  file.remove(file)


})
