test_that("run lintr", {
  expect_silent(lintr::lint_package(show_progress = FALSE))
})
