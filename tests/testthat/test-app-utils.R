library(withr)

test_that("Utils - Create Session Dir and Generate Report", {

  # Get path & ensure it doesnt exist yet
  get_app_dir() |>
    as.character() |>
    expect_equal("rdsapps-session") |>
    fs::dir_exists() |>
    expect_false()

  # Create app session dir
  create_session_dir() |>
    expect_true()

  # Generate report in app dir and check
  x <- generate_report(file = "test-report.html")
  expect_true(fs::file_exists(x))
  expect_snapshot_file(x)
})


test_that("Utils - Dev/Test Helpers", {
  expect_no_error(is_ci())
  expect_true(is_testing())
})



test_that("Utils - Build and Save Plots & Datasets", {


  ##
  ## Build plot data and snapshot
  ##
  results <- test_path("data/recs.Rds") |>
    readRDS() |>
    build_plot_data()

  expect_snapshot(results)

  ##
  ## Save plot data and confirm
  ##
  odir <- save_plot_data(results)

  withr::with_dir(odir, {
    for (i in 1:4) {
      stringr::str_glue("pdata{i}.Rds") |>
        fs::file_exists() |>
        expect_true()
    }
  })

  ##
  ## Build plot objects and check
  ##
  plots <- build_plot_objects(results)
  for (i in seq_along(plots)) {
    expect_true(ggplot2::is.ggplot(plots[[i]]))
    # expect_doppelganger(p)
  }


  ##
  ## Save plot objects and check
  ##
  odir <- save_plot_objects(plots)
  expect_equal(odir, fs::path(get_app_dir(), "output/plots"))
  withr::with_dir(odir, {
    for (i in 1:4) {
      stringr::str_glue("diagnostic-{i}.png") |>
        fs::file_exists() |>
        expect_true()
    }
  })
})


test_that("Utils - Handling Model Params", {
  default_ml_params() |>
    unscale_ml_params() |>
    scale_ml_params() |>
    expect_identical(default_ml_params())
})


test_that("Utils - Build and Save ML Scenario", {
  results <- readRDS(test_path("data/results.Rds"))
  context <- readRDS(test_path("data/context.Rds"))
  ck_scenario <- readRDS(test_path("data/scenario.Rds"))
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
