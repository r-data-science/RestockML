library(shinytest2)

test_that("{shinytest2} recording: app ", {

  ## Test app location
  appd <- "test-app"

  ## Initiate new test app session
  app <- AppDriver$new(app_dir = appd,
                       name = "app",
                       height = 871,
                       width = 1562,
                       load_timeout = 100000)

  ## Select scenario for model execution
  app$set_inputs(`filters-org` = "abidenapa")
  app$set_inputs(`filters-store` = "main")
  app$set_inputs(`filters-category3` = "EDIBLES")

  ## Run model and expect output values
  app$click("btn_run", timeout_=100000)
  app$expect_values(output = TRUE)

  ## Expect these directories to have been created
  expect_true(all(fs::file_exists(c(
    fs::path(appd, "www"),
    fs::path(appd, "output", c(".plotdata", "temp", "plots"))
  ))))

  ## Test downloading the report after model execution
  app$click("btn_post")
  app$expect_download("report.html")

  ## Clean up test app directory
  fs::dir_ls(path = "test-app",
             type = "directory",
             recurse = FALSE) |>
    fs::dir_delete()

})
