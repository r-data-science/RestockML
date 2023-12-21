test_that("Testing App UI Function", {
  expect_s3_class(app_ui(), "shiny.tag.list")
})

test_that("Testing App Server Function", {
  expect_true(is.function(app_server()))
})

test_that("Testing appRestockML", {
  expect_s3_class(appRestockML(), "shiny.appobj")
  expect_true(is.shiny.appobj(shinyApp(app_ui(), app_server())))
})

test_that("Testing Waiter", {
  w <- new_waiter()
  expect_s3_class(w, "waiter")
  html <- waiter_html("hello")
  expect_s3_class(html, "shiny.tag.list")
})
#
test_that("Testing run_model", {
  w <- NULL
  oid <- "044d7564-db32-4100-b960-f225c6879280"
  sid <- "ecfb2baa-c5de-46f4-bb3a-96f62a819e3e"
  path <- test_path("_data/context.Rds")
  index <- readRDS(path)$products[[1]]
  ml_args <- default_ml_params()
  expect_no_error(run_model(w, oid, sid, index, ml_args))
})
