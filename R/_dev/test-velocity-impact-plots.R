library(ggplot2)
library(ggthemes)
library(ggtext)

test_that("plot functions work", {
  plots <- salesDT[!is.na(image_url)][, .(
    list(plot_base_layer(cbind(.SD, product_sku = .BY$product_sku)))
    ), product_sku]
  expect_true(plots[, all(sapply(V1, ggplot2::is.ggplot))])

  oid <- "a6cefdc6-0561-48ee-88cf-7e1e47420e41"
  sid <- "5a020014-ff77-49b0-a856-c7ce3fff4633"
  sku <- "01384628"
  impact_day <- 45

  res <- plot_period_impact(oid, sid, sku, impact_day, internal = TRUE)
  # fname <- capture.output(plot_period_impact(oid, sid, sku, impact_day, internal = TRUE))

  expect_true(ggplot2::is.ggplot(res))

  fs::dir_delete("images")
  sapply(fs::dir_ls(".", regexp = "^p_"), fs::file_delete)
})
