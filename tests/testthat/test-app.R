library(shinytest2)
library(stringr)
library(data.table)
library(DBI)
library(rpgconn)


# Testing Functions -------------------------------------------------------


get_db_params <- function(oid, sid) {
  cn <- rpgconn::dbc(db = "hcaconfig")
  on.exit(rpgconn::dbd(cn))

  params <- data.table::as.data.table(DBI::dbGetQuery(
    cn,
    stringr::str_glue(
      "SELECT *
      FROM restock_ml_params
      WHERE oid = '{oid}'
      AND sid = '{sid}'"
    )
  ))
  params
}

clear_db_params <- function(oid, sid) {
  cn <- rpgconn::dbc(db = "hcaconfig")
  on.exit(rpgconn::dbd(cn))
  DBI::dbExecute(
    cn,
    stringr::str_glue(
      "DELETE FROM restock_ml_params
    WHERE oid = '{oid}' AND sid = '{sid}'"
    )
  )
}

compare_report <- function(old, new) {
  old_lines <- readLines(old)
  new_lines <- readLines(new)

  ## Remove any dates and image hashes
  pats <- c('h4 class\\=\\"date\\"', 'meta name\\=\\"date\\"', 'data\\:image')

  # Use either new or old lines to get drop index
  drop_index <- unlist(lapply(pats, function(x) {
    stringr::str_which(old_lines, x)
  }))

  stringr::str_equal(
    stringr::str_flatten(old_lines[-1 * drop_index]),
    stringr::str_flatten(new_lines[-1 * drop_index])
  )
}



# Globals for Testing -----------------------------------------------------


org <- "ORG001"
store <- "AA001"
cat3 <- "Edibles"
oid <- "044d7564-db32-4100-b960-f225c6879280"
sid <- "ecfb2baa-c5de-46f4-bb3a-96f62a819e3e"
slider_trend <- c(15, 60)



# Test Prep ---------------------------------------------------------------


clear_db_params(oid, sid)


# Start Tests -------------------------------------------------------------


test_that("{shinytest2} Testing App", {
  app <- AppDriver$new(
    app_dir = "app",
    name = "app",
    width = 2000,
    height = 1000,
    load_timeout = 35000,
    timeout = 25000
  )

  #===========================================================
  app$log_message("*****< Started App Driver >*****")

  #-------------
  app$log_message("<EXPECT> Initial Values on App Start")
  app$expect_values(input = TRUE)

  #-------------
  app$log_message("<EXPECT> Stats Values Before Filter")
  app$expect_text(selector = "#stat_skus.stati-value.shiny-bound-input")
  app$expect_text(selector = "#stat_brands.stati-value.shiny-bound-input")
  app$expect_text(selector = "#stat_sales.stati-value.shiny-bound-input")
  app$expect_text(selector = "#stat_units.stati-value.shiny-bound-input")


  #===========================================================
  app$log_message("*****< Selection Filtering >*****")
  app$set_inputs(`filters-org` = org)
  app$set_inputs(`filters-store` = store)
  app$set_inputs(`filters-category3` = cat3)

  #-------------
  app$log_message("<EXPECT> Org and Store UUIDs")
  expect_identical(app$get_value(export = "oid"), oid)
  expect_identical(app$get_value(export = "sid"), sid)

  #-------------
  app$log_message("<EXPECT> Stat Values After Filter")
  app$expect_text(selector = "#stat_skus.stati-value.shiny-bound-input")
  app$expect_text(selector = "#stat_brands.stati-value.shiny-bound-input")
  app$expect_text(selector = "#stat_sales.stati-value.shiny-bound-input")
  app$expect_text(selector = "#stat_units.stati-value.shiny-bound-input")


  #===========================================================
  app$log_message("*****< Saving Customized Params >*****")
  app$set_inputs(sli_trend_pval_conf = slider_trend, wait_ = FALSE)

  #-------------
  app$log_message("<ACTION> User Click {input$btn_save}")
  app$click("btn_save", wait_ = FALSE)
  app$wait_for_idle()

  #-------------
  app$log_message("<EXPECT> Checking Success Alert")
  msg <- app$get_text(selector = "#swal2-html-container.swal2-html-container")
  expect_equal(msg, "Parameters Saved")

  #-------------
  app$log_message("<EXPECT> Checking DB For Values")
  params <- get_db_params(oid, sid)
  expect_equal(params$ml_trend_conf, slider_trend[2] / 100)
  expect_equal(params$ml_trend_pval, slider_trend[1] / 100)


  #===========================================================
  app$log_message("*****< Reset Params to Default >*****")

  #-------------
  app$log_message("<ACTION> User Click {input$btn_reset}")
  app$click("btn_reset", wait_ = FALSE)
  app$wait_for_idle()
  app$expect_values(input = TRUE)


  #===========================================================
  app$log_message("*****< Loading Saved Params >*****")

  #-------------
  app$log_message("<ACTION> User Click {input$btn_load}")
  app$click("btn_load", wait_ = FALSE)
  app$wait_for_idle()

  #-------------
  app$log_message("<EXPECT> Checking Success Alert")
  msg <- app$get_text(selector = "#swal2-html-container.swal2-html-container")
  expect_equal(msg, "Parameters Loaded")

  #-------------
  app$log_message("<EXPECT> DB Values Loaded on App")
  app$expect_values(input = TRUE)


  #===========================================================
  app$log_message("*****< Run and Download Report >*****")

  #-------------
  app$log_message("<ACTION> User Click {input$btn_run}")
  app$click("btn_run", wait_ = FALSE)
  app$set_inputs(waiter_shown = TRUE,
                 allow_no_input_binding_ = TRUE,
                 priority_ = "event",
                 wait_ = FALSE)
  app$set_inputs(waiter_hidden = TRUE,
                 allow_no_input_binding_ = TRUE,
                 priority_ = "event",
                 wait_ = FALSE)
  app$wait_for_idle()

  #-------------
  app$log_message("<EVENT> Getting Plot Objects")
  plot_0 <- app$get_value(export = "plot_0")
  plot_1 <- app$get_value(export = "plot_1")
  plot_2 <- app$get_value(export = "plot_2")
  plot_3 <- app$get_value(export = "plot_3")
  plot_4 <- app$get_value(export = "plot_4")

  app$log_message("<EVENT> Getting Plot Data")
  plot_0_data <- app$get_value(export = "plot_0_data")
  plot_1_data <- app$get_value(export = "plot_1_data")
  plot_2_data <- app$get_value(export = "plot_2_data")
  plot_3_data <- app$get_value(export = "plot_3_data")
  plot_4_data <- app$get_value(export = "plot_4_data")

  #-------------
  app$log_message("<EXPECT> Checking Plot and Data")
  expect_equal(plot_0$data, plot_0_data)
  expect_equal(plot_1$data, plot_1_data)
  expect_equal(plot_2$data, plot_2_data)
  expect_equal(plot_3$data, plot_3_data)
  expect_equal(plot_4$data, plot_4_data)

  #-------------
  app$log_message("<ACTION> User Click {input$btn_post}")
  app$click("btn_post", wait_ = FALSE)
  app$wait_for_idle()
  app$set_inputs(dl_format = "html", wait_ = FALSE)

  #-------------
  app$log_message("<ACTION> User Click {input$btn_dl}")
  if (is_ci()) {
    app$log_message("!!----> CI Detected...Skipping")
  } else {
    app$log_message("<EXPECT> Checking File Download")
    app$expect_download("btn_dl", compare = compare_report)
  }

  #===========================================================
  app$log_message("*****< App Tests Complete >*****")
  app$stop()
})



# Cleanup -----------------------------------------------------------------

test_that("Clearing Database", {
  expect_equal(clear_db_params(oid, sid), 1)
})
