library(shinytest2)

test_that("Initial Shiny values are consistent", {
  app <- AppDriver$new(
    app_dir = "app",
    shiny_args = list(
      test.mode = TRUE
    ),
    name = "app",
    seed = 1000,
    height = 1200,
    width = 1900,
    timeout = 10000,
    load_timeout = 15000,
    screenshot_args = FALSE,
    expect_values_screenshot_args = FALSE
  )

  #-----------------------------------------------------
  # Expect a consistent state on app start
  #
  app$expect_values()

  #-----------------------------------------------------
  # Check stats shown on the ui BEFORE filtering
  #
  x <- app$get_text(selector = "#stat_skus.stati-value.shiny-bound-input")
  expect_equal(x, "227,059")

  x <- app$get_text(selector = "#stat_brands.stati-value.shiny-bound-input")
  expect_equal(x, "10,434")

  x <- app$get_text(selector = "#stat_sales.stati-value.shiny-bound-input")
  expect_equal(x, "$308,222,837")

  x <- app$get_text(selector = "#stat_units.stati-value.shiny-bound-input")
  expect_equal(x, "13,393,465")

  #-----------------------------------------------------
  # Set primary selection inputs to filter sku data
  #
  app$set_inputs(`filters-org` = "ORG001")
  # app$wait_for_idle()

  app$set_inputs(`filters-store` = "AA001")
  # app$wait_for_idle()

  app$set_inputs(`filters-category3` = "Edibles")
  # app$wait_for_idle(3000)

  #-----------------------------------------------------
  # Check stats shown on the ui AFTER filtering
  #
  x <- app$get_text(selector = "#stat_skus.stati-value.shiny-bound-input")
  expect_equal(x, "15")

  x <- app$get_text(selector = "#stat_brands.stati-value.shiny-bound-input")
  expect_equal(x, "3")

  x <- app$get_text(selector = "#stat_sales.stati-value.shiny-bound-input")
  expect_equal(x, "$15,543")

  x <- app$get_text(selector = "#stat_units.stati-value.shiny-bound-input")
  expect_equal(x, "1,014")


  #-----------------------------------------------------
  # Set custom model parameters and run
  #
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
  # app$wait_for_idle()
  app$set_inputs(dl_format = "html", wait_ = FALSE)
  # app$wait_for_idle()
  app$expect_download("btn_dl")

  #-----------------------------------------------------
  # Run Model with reset params and expect output
  #
  app$click("btn_reset")
  # app$wait_for_idle()

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
  # app$wait_for_idle()

  app$click("btn_reset")
  # app$wait_for_idle()

  app$click("btn_load")
  # app$wait_for_idle()

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
