# basic tests for ebv_download ----
skip_if_portal_tests_unavailable <- function() {
  testthat::skip_on_ci()
  testthat::skip_if_offline()

  if (ebv_i_check_url("https://portal.geobon.org/api/v1/datasets")) {
    testthat::skip("EBV Data Portal API is not reachable")
  }
}

test_that("test ebv_download ID=numeric", {
  skip_if_portal_tests_unavailable()

  dir <- tempdir()
  data <- ebv_download(27, dir, verbose = FALSE)
  expect_true(basename(data) %in% list.files(dir))
  unlink(dir, recursive = TRUE)
})

test_that("test ebv_download ID=doi", {
  skip_if_portal_tests_unavailable()

  dir <- tempdir()
  data <- ebv_download("10.25829/f2rdp4", dir, verbose = FALSE)
  expect_true(basename(data) %in% list.files(dir))
  unlink(dir, recursive = TRUE)
})

test_that("test ebv_download ID=title 1", {
  skip_if_portal_tests_unavailable()

  dir <- tempdir()
  data <- ebv_download("Local bird diversity (cSAR/BES-SIM)", dir, verbose = FALSE)
  expect_true(basename(data) %in% list.files(dir))
  unlink(dir, recursive = TRUE)
})

test_that("test ebv_download ID=title 2", {
  skip_if_portal_tests_unavailable()

  dir <- tempdir()
  data <- ebv_download("Global trends in biodiversity (BES-SIM PREDICTS)", dir, verbose = FALSE)
  expect_true(basename(data) %in% list.files(dir))
  unlink(dir, recursive = TRUE)
})

test_that("test ebv_download DOIs in download overview table", {
  skip_if_portal_tests_unavailable()

  data <- ebv_download(verbose = FALSE)
  expect_equal(names(data), c("id", "title", "doi"))
  expect_equal(data[data$id == 7, "doi"], "10.25829/f2rdp4")
  expect_equal(data[data$id == 42, "doi"], "10.25829/tder31")
  expect_equal(data[data$id == 28, "doi"], "10.25829/bk5g87")
})


