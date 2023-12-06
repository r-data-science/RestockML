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
  x <- generate_report(file = "test-report.html")
  fs::file_exists(x) |>
    expect_true()
  expect_snapshot_file(x)
})


test_that("Utils - Dev/Test Helpers", {
  is_ci() |>
    expect_no_error()
  is_testing() |>
    expect_true()
})



test_that("Utils - Build and Save Plots & Datasets", {


  ## Build plot data
  results <- readRDS("data/recs.Rds") |>
    build_plot_data()
  expect_snapshot(results)

  ## Save plot data
  pdata_path <- save_plot_data(results)

  withr::with_dir(pdata_path, {
    for (i in 1:4) {
      stringr::str_glue("pdata{i}.Rds") |>
        fs::file_exists() |>
        expect_true()
    }
  })

  ## Build plot objects
  plots <- build_plot_objects(results)

  for (p in plots)
    expect_true(ggplot2::is.ggplot(p))

  ## Save plot objects
  path_plots <- save_plot_objects(plots)
  expect_equal(path_plots, fs::path(get_app_dir(), "output/plots"))

  withr::with_dir(path_plots, {
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
