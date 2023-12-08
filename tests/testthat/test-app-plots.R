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
    path <- fs::path(getwd(), stringr::str_glue("test_data/pdata{i}.Rds"))
    pdata <- readRDS(path)
    pobj <- get(paste0(".plot_diagnostic_", i))(pdata)
    expect_s3_class(pobj, "gg")
  }
})


