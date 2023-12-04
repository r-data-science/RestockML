library(shinytest2)

test_that("Initial Shiny values are consistent", {
  app <- AppDriver$new(
    app_dir = "app",
    name = "app",
    seed = 1000,
    height = 1200,
    width = 1900,
    timeout = 10000,
    load_timeout = 5000,
    screenshot_args = FALSE,
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

  app$expect_values(output = c(
    "stat_skus",
    "stat_brands",
    "stat_sales",
    "stat_units"
  ))

  app$set_inputs(sli_trend_pval_conf = c(15, 60))
  app$set_inputs(sli_stock_pval_conf = c(10, 80))
  app$set_inputs(sli_secd_prim = c(20, 50))
  app$set_inputs(sli_npom_ltmi = c(21, 150))

  app$click("btn_run")
  app$wait_for_idle(500)
  app$expect_values()

  #-----------------------------------------------------
  # Create report and expect download
  #
  app$click("btn_post")
  app$wait_for_idle(500)
  app$set_inputs(dl_format = "html", wait_ = FALSE)
  app$wait_for_idle(500)
  app$expect_download("btn_dl")

  #-----------------------------------------------------
  # Run Model with reset params and expect output
  #
  app$click("btn_reset")
  app$wait_for_idle()

  app$expect_values(input = c(
    "sli_trend_pval_conf",
    "sli_stock_pval_conf",
    "sli_ppql_ppqh",
    "sli_secd_prim",
    "sli_npom_ltmi"
  ))

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

  app$click("btn_save")
  app$wait_for_idle()

  app$click("btn_reset")
  app$wait_for_idle()

  app$click("btn_load")
  app$wait_for_idle()

  app$expect_values(input = c(
    "sli_trend_pval_conf",
    "sli_stock_pval_conf",
    "sli_ppql_ppqh",
    "sli_secd_prim",
    "sli_npom_ltmi"
  ))

  # app$click("btn_run")
  # app$expect_values()
})
