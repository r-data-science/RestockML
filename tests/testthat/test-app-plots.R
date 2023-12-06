library(ggplot2)

test_that("Testing Plot Theme", {
  .plot_theme() |>
    ggplot2::is.theme() |>
    expect_true()
})


test_that("Testing Plot Title", {
  .plot_title_style("x", "y") |>
    expect_snapshot()
})


test_that("Testing Plot Functions", {
  for (i in 0:4) {
    stringr::str_glue("data/pdata{i}.Rds") |>
      readRDS() |>
      (function(x, i) get(paste0(".plot_diagnostic_", i))(x))(i) |>
      expect_s3_class("gg")
  }
})


