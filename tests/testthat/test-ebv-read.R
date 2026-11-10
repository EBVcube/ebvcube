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

test_that("test ebv_read multi-entity raster layer order", {
  file <- system.file(file.path("extdata","martins_comcom_subset.nc"), package="ebvcube")
  stack <- ebv_read(file, 'metric_1/ebv_cube', entity = c(3, 1), timestep = c(2, 1),ignore_RAM = TRUE)
  expect_equal(terra::nlyr(stack), 4)
  expect_identical(names(stack), c(
    "all bird species | 1910-01-01",
    "all bird species | 1900-01-01",
    "forest bird species | 1910-01-01",
    "forest bird species | 1900-01-01"
  ))
  expect_identical(
    as.character(terra::time(stack)),
    c("1910-01-01", "1900-01-01", "1910-01-01", "1900-01-01")
  )
  entity3_time2 <- ebv_read(file, 'metric_1/ebv_cube',
                            entity = 3, timestep = 2, ignore_RAM = TRUE)
  entity3_time1 <- ebv_read(file, 'metric_1/ebv_cube',
                            entity = 3, timestep = 1, ignore_RAM = TRUE)
  entity1_time2 <- ebv_read(file, 'metric_1/ebv_cube',
                            entity = 1, timestep = 2, ignore_RAM = TRUE)
  entity1_time1 <- ebv_read(file, 'metric_1/ebv_cube',
                            entity = 1, timestep = 1, ignore_RAM = TRUE)

  expect_equal(terra::values(stack[[1]], mat = FALSE),
               terra::values(entity3_time2, mat = FALSE))
  expect_equal(terra::values(stack[[2]], mat = FALSE),
               terra::values(entity3_time1, mat = FALSE))
  expect_equal(terra::values(stack[[3]], mat = FALSE),
               terra::values(entity1_time2, mat = FALSE))
  expect_equal(terra::values(stack[[4]], mat = FALSE),
               terra::values(entity1_time1, mat = FALSE))
})

test_that("test ebv_read multi-entity arrays with one timestep", {
  file <- system.file(file.path("extdata","martins_comcom_subset.nc"), package="ebvcube")
  prop <- ebv_properties(file, 'metric_1/ebv_cube', verbose = FALSE)

  expected_dims <- c(prop@spatial$dimensions[1:2], 1L, 2L)

  in_memory <- ebv_read(file, 'metric_1/ebv_cube', entity = c(3, 1), timestep = 2,
                        type = "a", ignore_RAM = TRUE)
  delayed <- ebv_read(file, 'metric_1/ebv_cube', entity = c(3, 1), timestep = 2,
                      type = "da", ignore_RAM = TRUE)

  expect_equal(unname(dim(in_memory)), expected_dims)
  expect_equal(unname(dim(delayed)), expected_dims)
  expect_equal(as.array(delayed), in_memory)
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


