# File: tests/testthat/test-inst-apps.R
library(shinytest2)


test_that("MLTuning App Test", {
  appdir <- system.file(package = "hcadsapps", "apps/mltuning")
  test_app(appdir, check_setup = FALSE)
})


