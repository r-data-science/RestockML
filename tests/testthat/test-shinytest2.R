library(shinytest2)


test_that("{shinytest2} Basic App Tests ", {
  testthat::skip_on_os(c("windows", "mac"))

  #-----------------------------------------------------
  # Initialize app and expect consistent state on start
  #
  app <- AppDriver$new(
    app_dir = ".",
    name = "app",
    height = 1200,
    width = 1900,
    timeout = 10000,
    variant = "linux-4.3",
    expect_values_screenshot_args = FALSE
  )
  app$expect_values()

  #-----------------------------------------------------
  # Set primary selection inputs and custom model inputs
  # and then Run and expect outputs
  #
  app$set_inputs(`filters-org` = "ORG001")
  app$wait_for_idle(500)

  app$set_inputs(`filters-store` = "AA001")
  app$wait_for_idle(500)

  app$set_inputs(`filters-category3` = "Edibles")
  app$wait_for_idle(500)

  app$set_inputs(sli_trend_pval_conf = c(15, 60))
  app$set_inputs(sli_stock_pval_conf = c(10, 80))
  app$set_inputs(sli_secd_prim = c(20, 50))
  app$set_inputs(sli_npom_ltmi = c(21, 150))

  app$click("btn_run")
  app$expect_values()

  #-----------------------------------------------------
  # Create report and expect download
  #
  app$click("btn_post")
  app$expect_download("report.html")

  #-----------------------------------------------------
  # Run Model with reset params and expect output
  #
  app$click("btn_reset")
  app$wait_for_idle(500)

  app$click("btn_run")
  app$expect_values()

  #-----------------------------------------------------
  # Save customer params, load from database, and run
  # model expecting outputs
  #
  app$set_inputs(sli_trend_pval_conf = c(8, 80))
  app$set_inputs(sli_stock_pval_conf = c(8, 80))
  app$set_inputs(sli_secd_prim = c(20, 40))
  app$set_inputs(sli_npom_ltmi = c(14, 120))

  app$click("btn_save", wait_=FALSE)
  app$wait_for_idle(5000)

  app$click("btn_reset")
  app$wait_for_idle(500)

  app$click("btn_load", wait_=FALSE)
  app$wait_for_idle(5000)

  app$click("btn_run")
  app$expect_values()

  #-----------------------------------------------------
  # Clean up test app directory
  #
  fs::dir_delete("output")
  fs::dir_delete("www")

})
