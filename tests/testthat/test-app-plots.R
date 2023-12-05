library(vdiffr)
library(ggplot2)

test_that("Testing Plot Functions", {
  th <- suppressWarnings(.plot_theme()) # May warn if font not found on sys
  expect_true(ggplot2::is.theme(th))

  expect_snapshot(.plot_title_style("My Title", "My Subtitle"))

  p0 <- .plot_diagnostic_0(readRDS("data/pdata0.Rds"))
  expect_doppelganger("diagnostic plot 0", p0)

  p1 <- .plot_diagnostic_1(readRDS("data/pdata1.Rds"))
  expect_doppelganger("diagnostic plot 1", p1)

  p2 <- .plot_diagnostic_2(readRDS("data/pdata2.Rds"))
  expect_doppelganger("diagnostic plot 2", p2)

  p3 <- .plot_diagnostic_3(readRDS("data/pdata3.Rds"))
  expect_doppelganger("diagnostic plot 3", p3)

  p4 <- .plot_diagnostic_4(readRDS("data/pdata4.Rds"))
  expect_doppelganger("diagnostic plot 4", p4)
})


