test_that("App Function", {
  expect_true(shiny::is.shiny.appobj(appExplorePRM()))
  fs::dir_delete("output")
  fs::dir_delete("www")
})

test_that("App Run", {

  # Ensure current working dir is as expected
  expect_equal(fs::path_file(getwd()), "testthat")

  # Create a temp folder
  fs::dir_create("temp")

  # Run app in temp folder.. this will change working directory to ./temp
  x <- runExplorePRM(WORK_DIR = "temp", launch.browser = FALSE)

  # Ensure working directory was set to temp
  expect_equal(fs::path_file(getwd()), "temp")

  # Check for file app.R in working directory
  expect_true(fs::file_exists(x))

  # Reset working directory back to original
  setwd("../")

  # delete temp
  fs::dir_delete("temp")
})

