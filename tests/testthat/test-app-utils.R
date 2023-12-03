test_that("App Utils", {
  expect_true(fs::dir_exists(get_app_dir()))
  expect_true(is.list(get_app_colors()))

  dirPaths <- create_session_dir()
  expect_true(all(fs::dir_exists(dirPaths)))

  ll <- default_ml_params()
  expect_true(is.list(ll))
  expect_true(is.list(scale_ml_params(ll)))
  expect_true(is.list(unscale_ml_params(ll)))

  fs::dir_delete("www")
  fs::dir_delete("output")
})




