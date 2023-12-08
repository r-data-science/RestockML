test_that("Utils - Create Session Dir and Generate Report", {
  expect_true(create_session_dir())
  x <- generate_report(file = "test-report.html")
  expect_true(fs::file_exists(x))
})

test_that("Utils - Dev/Test Helpers", {
  expect_no_error(is_ci())
  expect_true(is_testing())
})



test_that("Utils - Build and Save Plots & Datasets", {
  path <- fs::path(getwd(), "_data/recs.Rds")
  recs <- readRDS(path)
  results <- expect_no_error(build_plot_data(recs))
  expect_no_error(save_plot_data(results))
  plots <- expect_no_error(build_plot_objects(results))
  expect_no_error(save_plot_objects(plots))
})


test_that("Utils - Handling Model Params", {
  default_ml_params() |>
    unscale_ml_params() |>
    scale_ml_params() |>
    expect_identical(default_ml_params())
})


test_that("Utils - Build and Save ML Scenario", {
  path_res <- fs::path(getwd(), "_data/results.Rds")
  path_ctx <- fs::path(getwd(), "_data/context.Rds")
  results <- readRDS(path_res)
  context <- readRDS(path_ctx)
  scenario <- expect_no_error(build_ml_scenario(results, context))
  expect_no_error(save_ml_scenario(scenario))
})


test_that("Utils - Build and Save ML Context", {
  x <- expect_no_error(build_ml_context(
    oid = ..testuuid$oid,
    sid = ..testuuid$sid,
    index = iris,
    ml_args = default_ml_params()
  ))
  expect_no_error(save_ml_context(x))
})


if (fs::dir_exists(get_app_dir())) {
  fs::dir_delete(get_app_dir())
}

if (fs::dir_exists(fs::path("_app", get_app_dir()))) {
  fs::dir_delete(fs::path("_app", get_app_dir()))
}

