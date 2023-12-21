# Unit Tests For File: <No corresponding {pkg}/R/*.R File>
#
# Locally Testing of Shiny Apps
# ---------------------------------------------------------

library(shinytest2)

test_that("Testing package app", {
  skip_if(RestockML:::is_ci(), "On CI") # Skip CI bc we have a dedicated workflow for apps
  test_path("_app") |>
    test_app(stop_on_failure = TRUE) |>
    expect_no_error()
})



