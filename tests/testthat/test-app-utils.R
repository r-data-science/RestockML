library(withr)
library(testthat)

# local_test_context()

test_that("Utils - Dev/Test Helpers", {
  expect_no_error(is_ci())
  expect_true(is_testing())
})

test_that("Utils - Session Directory", {
  tempd <- local_tempdir("", tmpdir = ".")
  local_dir(tempd)
  on.exit(fs::dir_delete(fs::path_file(tempd)))
  appd <- get_app_dir()
  expect_false(fs::dir_exists(appd))
  expect_equal(as.character(appd), "rdsapps-session")
  expect_true(create_session_dir())
  expect_true(fs::dir_exists("rdsapps-session"))
})
