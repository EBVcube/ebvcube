# basic tests for ebv_read* ----
test_that("test ebv_read single timestep", {
  file <- system.file(file.path("extdata","martins_comcom_subset.nc"), package="ebvcube")
  data <- ebv_read(file, 'metric_1/ebv_cube', entity = 1, timestep = 1, verbose = FALSE, ignore_RAM = TRUE)
  value <- as.numeric(data[40,45])
  expect_equal(value, -0.003191974)
})

test_that("test ebv_read multiple timestep", {
  file <- system.file(file.path("extdata","martins_comcom_subset.nc"), package="ebvcube")
  data <- ebv_read(file, 'metric_1/ebv_cube', 1, 1:3, verbose = FALSE, ignore_RAM = TRUE)
  value <- as.numeric(data[40,45,3])
  expect_equal(value, 0.01546155)
})

test_that("test ebv_read preserves entity and timestep order", {
  file <- system.file(file.path("extdata","martins_comcom_subset.nc"), package="ebvcube")
  data <- ebv_read(file, 'metric_1/ebv_cube', entity = c(3, 1), timestep = c(2, 1),ignore_RAM = TRUE)
  # check expected number of layer obtains from the call
  value <-  as.numeric(data[40,45])
  expect_equal(terra::nlyr(data), 4)
  expect_equal(value, c(0.005361155, -0.003827269, 0.003687655, -0.003191974),
               tolerance = 1e-6)
})

test_that("test ebv_read preserves array dimensions and values", {
  file <- system.file("extdata", "martins_comcom_subset.nc", package = "ebvcube")
  data <- ebv_read(file, "metric_1/ebv_cube", entity = 1:3,timestep = c(2, 1),
                   type = "a", ignore_RAM = TRUE)
  dims <- unname(dim(data))
  value <- as.numeric(data[40, 45, , ])

  expect_equal(class(data), "array")
  expect_equal(dims, c(85, 90, 2, 3))
  expect_equal(value, c(0.0036876546, -0.0031919740,-0.0030650636, -0.0006285036,
                        0.0053611547, -0.0038272690),
               tolerance = 1e-6)
})

test_that("test ebv_read preserves delayed-array dimensions and values", {
  file <- system.file("extdata", "martins_comcom_subset.nc", package = "ebvcube")
  data <- ebv_read(file, "metric_1/ebv_cube", entity = c("all bird species", "forest bird species"),
                   timestep = 1:2, type = "da")
  dims <- unname(dim(data))
  value <- as.numeric(as.array(data[40, 45, , ]))

  expect_s4_class(data, "DelayedArray")
  expect_equal(dims, c(85, 90, 2, 2))
  expect_equal(value, c(-0.003827269, 0.005361155, -0.003191974, 0.003687655),
               tolerance = 1e-6)
})

test_that("test ebv_read keeps the single time dimension", {
  file <- system.file("extdata", "martins_comcom_subset.nc", package = "ebvcube")
  data <- ebv_read(file, "metric_1/ebv_cube", entity = c(3, 1), timestep = 2,
                   type = "a", ignore_RAM = TRUE)
  delayed <- ebv_read(file, "metric_1/ebv_cube", entity = c(3, 1),
                      timestep = 2, type = "da")

  expect_equal(unname(dim(data)), c(85, 90, 1, 2))
  expect_equal(unname(dim(delayed)), c(85, 90, 1, 2))
})

test_that("test ebv_read labels the selected layers correctly", {
  file <- system.file("extdata", "martins_comcom_subset.nc", package = "ebvcube")
  data <- ebv_read(file, "metric_1/ebv_cube", entity = 1:3,
                   timestep = c(2, 1), ignore_RAM = TRUE)

  expect_equal(names(data), c(
    "forest bird species - 1910-01-01", "forest bird species - 1900-01-01",
    "non-forest bird species - 1910-01-01", "non-forest bird species - 1900-01-01",
    "all bird species - 1910-01-01", "all bird species - 1900-01-01"
  ))
  expect_equal(as.character(terra::time(data)),
               c("1910-01-01", "1900-01-01", "1910-01-01", "1900-01-01", "1910-01-01","1900-01-01"))
})

test_that("test ebv_read ISO date + metric&scenario", {
  file <- system.file(file.path("extdata","martins_comcom_subset.nc"), package="ebvcube")
  data <- ebv_read(file, entity = 1, timestep = c("2000-01-01", "2010-01-01"),
                   metric= 2, verbose = FALSE, ignore_RAM = TRUE)
  value <- as.numeric(data[40,45])
  expect_equal(value, c(3.05687881, 3.60405803))
})

test_that("test ebv_read_bb single timestep", {
  file <- system.file(file.path("extdata","martins_comcom_subset.nc"), package="ebvcube")
  data <- ebv_read_bb(file, 'metric_1/ebv_cube', 1, 1, c(-20,0,-30, -20),
                      verbose = FALSE, ignore_RAM = TRUE)
  dims <- dim(data)
  expect_equal(dims, c(10,20,1))
})

test_that("test ebv_read_bb multiple timesteps", {
  file <- system.file(file.path("extdata","martins_comcom_subset.nc"), package="ebvcube")
  data <- ebv_read_bb(file, 'metric_1/ebv_cube', 1, 1:3, c(-10,0,-10, 0),
                      verbose = FALSE, ignore_RAM = TRUE)
  dims <- dim(data)
  expect_equal(dims, c(10,10,3))
})

test_that("test ebv_read_bb ISO date + metric&scenario", {
  file <- system.file(file.path("extdata","martins_comcom_subset.nc"), package="ebvcube")
  data <- ebv_read_bb(file, entity = 1, timestep = c("1950-01-01", "1960-01-01"),
                      bb=c(-20,0,-30, -20), metric = 2, verbose = FALSE, ignore_RAM = TRUE)
  dims <- dim(data)
  expect_equal(dims, c(10,20,2))
})

test_that("test ebv_read_bb reads multiple named entities and timesteps", {
  file <- system.file("extdata", "martins_comcom_subset.nc", package = "ebvcube")
  data <- ebv_read_bb(file, "metric_1/ebv_cube",entity = c("all bird species", "forest bird species"),
    timestep = c(2, 1), bb = c(8, 16, 0, 12),ignore_RAM = TRUE, verbose = FALSE)
  dims <- dim(data)
  value <-  as.numeric(data[6,4])
  expect_equal(dims, c(12, 8, 4))
  expect_equal(value, c(0.3952941, 0.1692434, 0.3292517, 0.1410922),
              tolerance = 1e-6)
})

test_that("test ebv_read_bb preserves layer labels and extent", {
  file <- system.file("extdata", "martins_comcom_subset.nc", package = "ebvcube")
  data <- ebv_read_bb(file, "metric_1/ebv_cube", entity = c(2, 1),
                      timestep = c(2, 1), bb = c(8, 16, 0, 12),
                      ignore_RAM = TRUE, verbose = FALSE)
  extent <- as.numeric(unname(terra::ext(data)[1:4]))

  expect_equal(extent, c(8, 16, 0, 12))
  expect_equal(names(data), c(
    "non-forest bird species - 1910-01-01", "non-forest bird species - 1900-01-01",
    "forest bird species - 1910-01-01", "forest bird species - 1900-01-01"
  ))
  expect_equal(as.character(terra::time(data)),
               c("1910-01-01", "1900-01-01", "1910-01-01", "1900-01-01"))
})

test_that("test ebv_read_bb preserves the saved layers", {
  file <- system.file("extdata", "martins_comcom_subset.nc", package = "ebvcube")
  out <- file.path(withr::local_tempdir(), "entities.tif")
  data <- ebv_read_bb(file, "metric_1/ebv_cube", entity = c(3, 1),timestep = c(2, 1),
                      bb = c(8, 16, 0, 12), ignore_RAM = TRUE, verbose = FALSE)
  path <- ebv_read_bb(file, "metric_1/ebv_cube", entity = c(3, 1), timestep = c(2, 1),
                      bb = c(8, 16, 0, 12), outputpath = out, ignore_RAM = TRUE, verbose = FALSE)
  saved <- terra::rast(path)
  value <- terra::values(saved, mat = FALSE)
  expected <- terra::values(data, mat = FALSE)

  expect_true(terra::compareGeom(saved, data, stopOnError = FALSE))
  expect_equal(names(saved), names(data))
  expect_equal(terra::time(saved), terra::time(data))
  expect_equal(value, expected, tolerance = 1e-6)
})

test_that("test ebv_read_shp single timestep", {
  shp <- system.file(file.path('extdata','cameroon.shp'), package="ebvcube")
  file <- system.file(file.path("extdata","martins_comcom_subset.nc"), package="ebvcube")
  data <- ebv_read_shp(file, 'metric_1/ebv_cube', entity=1, shp = shp,
                       timestep = 3, verbose = FALSE, ignore_RAM = TRUE)
  dims <- dim(data)
  value <- as.numeric(data[5,5])
  expect_equal(dims, c(12,9,1))
  expect_equal(value, 0.79184753)
})

test_that("test ebv_read_shp multiple timesteps", {
  shp <- system.file(file.path('extdata','cameroon.shp'), package="ebvcube")
  file <- system.file(file.path("extdata","martins_comcom_subset.nc"), package="ebvcube")
  data <- ebv_read_shp(file, 'metric_1/ebv_cube', entity='forest bird species',
                       shp = shp, timestep = 1:3, verbose = FALSE, ignore_RAM = TRUE)
  dims <- dim(data)
  value <- as.numeric(data[5,5,1])
  expect_equal(dims, c(12,9,3))
  expect_equal(value, 0.188491091)
})

test_that("test ebv_read_shp ISO date + metric&scenario", {
  shp <- system.file(file.path('extdata','cameroon.shp'), package="ebvcube")
  file <- system.file(file.path("extdata","martins_comcom_subset.nc"), package="ebvcube")
  data <- ebv_read_shp(file, entity = 1, timestep = c("2000-01-01", "2010-01-01"),
                   metric= 2, shp = shp, verbose = FALSE, ignore_RAM = TRUE)
  dims <- dim(data)
  value <- as.numeric(data[5,5,1])
  expect_equal(dims, c(12,9,2))
  expect_equal(value, 14.0923309)
})


