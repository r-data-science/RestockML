library(withr)


test_that("Utils - Handle Session Dir", {

  # Get session dir, check to ensure it does not exist yet
  get_app_dir() |>
    as.character() |>
    expect_equal("rdsapps-session") |>
    fs::dir_exists() |>
    expect_false()

  # Get app dir, check to ensure it does not exist yet
  create_session_dir() |>
    expect_true()

  fs::dir_exists("rdsapps-session") |>
    expect_true()
})



test_that("Utils - Generate Report", {
  # create_session_dir() |>
  #   expect_true()
  generate_report(file = "test-report.html") |>
    expect_snapshot_file()
})


test_that("Utils - Dev/Test Helpers", {
  is_ci() |>
    expect_no_error()
  is_testing() |>
    expect_true()
})



test_that("Utils - Build and Save Plots", {

  results <- lapply(fs::dir_ls("data", regexp = "pdata"), readRDS)
  plots <- build_plot_objects(results)
  for (p in plots)
    expect_true(ggplot2::is.ggplot(p))

  path_plots <- save_plot_objects(plots)
  expect_equal(path_plots, fs::path(get_app_dir(), "output/plots"))

  with_dir(path_plots, {
    for (i in 1:4) {
      stringr::str_glue("diagnostic-{i}.png") |>
        fs::file_exists() |>
        expect_true()
    }
  })
})


test_that("Utils - Handling Model Params", {
  ll <- default_ml_params()
  expect_snapshot(ll)

  x <- ll |>
    unscale_ml_params() |>
    scale_ml_params()

  expect_identical(x, default_ml_params())
})


test_that("Utils - Build and Save ML Scenario", {
  results <- readRDS("data/results.Rds")
  context <- readRDS("data/context.Rds")
  ck_scenario <- readRDS("data/scenario.Rds")

  build_ml_scenario(results, context) |>
    expect_identical(ck_scenario) |>
    save_ml_scenario() |>
    fs::file_exists() |>
    expect_true()
})

test_that("Utils - Build and Save ML Context", {
  oid <- ..testuuid$oid
  sid <- ..testuuid$sid


  x <- build_ml_context(
    oid = ..testuuid$oid,
    sid = ..testuuid$sid,
    index = iris,
    ml_args = default_ml_params()
  )
  x$run_utc <- NULL
  expect_snapshot(x)

  save_ml_context(x) |>
    fs::file_exists() |>
    expect_true()
})


test_that("Utils - Cleanup Test", {
  fs::dir_delete("rdsapps-session")
  clear_session_dir() |>
    expect_false()
})
