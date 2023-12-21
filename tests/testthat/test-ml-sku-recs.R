library(data.table)

## Parameters for the tests below
oid <- "bfcadfb1-34df-40c1-acf6-1be6ba20de0f"
sid <- "bf726b02-333a-448a-b800-e90f80a955be"
sku <- "SHT19898"
ml_conf <- .9
ml_pval <- .05
ml_ltmi <- 182
ml_npom <- 14
ml_prim <- .45
ml_secd <- .25
ml_ppql <- .2
ml_ppqh <- .8


test_that("Testing Rec Modeling End-point Function", {
  rec <- restock_rec_ep(oid, sid, sku)

  expect_true(is.list(rec))

  cnams <- c("results", "meta", "created_utc", "status_code", "status_msg")
  expect_named(rec, cnams)

  cnams <- c("product_sku", "is_recommended", "restock")
  expect_named(rec$results, cnams)

  cnams <- c("flags", "stats", "descr")
  expect_named(rec$meta, cnams)
})


test_that("End-to-End Recommendations Test", {
  skuSalesDT <- dbGetTransacts90(oid, sid, sku)
  expect_true(nrow(skuSalesDT) > 0)

  catPriceDT <- dbGetCatPricePts(oid, sid)
  expect_true(nrow(catPriceDT) > 0)

  prodHistDT <- dbGetProductHist(oid, sid, sku)
  expect_true(nrow(prodHistDT) > 0)

  ## Input data for the tests below
  velocityDT <- build_velocity_daily(skuSalesDT)

  nams <- c("org_uuid", "store_uuid", "product_sku", "order_date",
            "category3", "brand_name", "units_sold", "tot_sales",
            "ave_disc_r", "ave_ticket", "wts", "tot_sales_est",
            "c_sales_est", "c_sales_actual", "has_sales",
            "created_utc")
  expect_named(velocityDT, nams)

  ##
  ## Model Sales Trend and Supply Risk
  ##
  ml_trend <- model_sales_trend(
    velocityDT,
    thresh_conf = ml_conf,
    thresh_pval = ml_pval
  )
  expect_true(is.data.table(ml_trend))
  expect_true(nrow(ml_trend) == 1)


  ml_stock <- model_supply_risk(
    velocityDT,
    thresh_conf = ml_conf,
    thresh_pval = ml_pval
  )
  expect_true(is.data.table(ml_stock))
  expect_true(nrow(ml_stock) == 1)


  ##
  ## Classify Products based on Time, Order Stats, and Price Point
  ##
  sku_term  <- classify_by_term(
    prodHistDT,
    thresh_long = ml_ltmi,
    thresh_new = ml_npom
  )
  expect_true(is.data.table(sku_term))
  expect_true(nrow(sku_term) == 1)

  sku_share <- classify_by_orders(
    velocityDT,
    thresh_primary = ml_prim,
    thresh_second = ml_secd
  )
  expect_true(is.data.table(sku_share))
  expect_true(nrow(sku_share) == 1)

  sku_price <- classify_by_price(
    velocityDT, catPriceDT,
    thresh_low = ml_ppql,
    thresh_high = ml_ppqh
  )
  expect_true(is.data.table(sku_price))
  expect_true(nrow(sku_price) == 1)


  ##
  ## Extract Classifications, Stats, and Text Associated with Recs
  ##
  flags <- extract_rec_flags(ml_stock, ml_trend, sku_price, sku_term, sku_share)
  htext <- extract_help_text(ml_stock, ml_trend, sku_price, sku_term, sku_share)
  metad <- extract_meta_data(ml_stock, ml_trend, sku_price, sku_term, sku_share)

  cnams <- c("product_sku", "is_long_term", "is_new_on_menu", "price_point", "is_primary",
             "is_secondary", "has_oos_risk", "is_trending", "trend_sign")
  expect_named(flags, cnams)
  expect_true(is.data.table(flags))
  expect_true(nrow(flags) == 1)

  cnams <- c("product_sku", "days_since_first", "menu_period_days", "category3",
             "cat_price_low", "cat_price_high", "tot_days", "tot_sales", "tot_units",
             "ave_unit_price", "std_unit_price", "price_point", "share_of_order",
             "pct_oos_days", "days_sold", "days_not_sold", "oos_periods", "ave_oos_period_days",
             "mean_past", "mean_recent", "stdev_pooled")
  expect_named(metad, cnams)
  expect_true(is.data.table(metad))
  expect_true(nrow(metad) == 1)

  cnams <- c("product_sku", "product_trait", "description")
  expect_named(htext, cnams)
  expect_true(is.data.table(htext))
  expect_true(nrow(htext) == 5)


  ## Assign Recommendation for each Product
  ##
  precs <- assign_product_recs(flags)
  cnams <- c("product_sku", "is_recommended")
  expect_named(precs, cnams)
  expect_true(is.data.table(precs))
  expect_true(nrow(precs) == 1)
})





test_that("Error Testing Recommendations", {

  ##
  ## Model Sales Trend and Supply Risk
  ##
  expect_error(model_sales_trend(
    velocityDT[0],
    thresh_conf = ml_conf,
    thresh_pval = ml_pval
  ), "Unable to model sales trend...")


  expect_error(model_supply_risk(
    velocityDT[0],
    thresh_conf = ml_conf,
    thresh_pval = ml_pval
  ), "Unable to model supply risk...")


  ##
  ## Classify Products based on Time, Order Stats, and Price Point
  ##
  expect_error(classify_by_term(
    prodHistDT[0],
    thresh_long = ml_ltmi,
    thresh_new = ml_npom
  ), "Unable to classify by time...")


  expect_error(classify_by_orders(
    velocityDT[0],
    thresh_primary = ml_prim,
    thresh_second = ml_secd
  ), "Unable to classify by orders...")

  expect_error(classify_by_price(
    velocityDT[0], catPriceDT,
    thresh_low = ml_ppql,
    thresh_high = ml_ppqh
  ), "Unable to classify by price...")
})

