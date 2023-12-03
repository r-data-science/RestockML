test_that("App Database Interface", {
  cnams <- c("org", "store", "category3", "brand_name", "product_sku",
             "tot_sales", "units_sold", "org_uuid", "store_uuid")
  indx <- db_app_index_anon()
  expect_named(indx, cnams, ignore.order = TRUE)

  oid <- "bfcadfb1-34df-40c1-acf6-1be6ba20de0f"
  sid <- "bf726b02-333a-448a-b800-e90f80a955be"
  cnams <- c("oid", "sid", "ml_ltmi", "ml_npom", "ml_prim", "ml_secd",
             "ml_ppql", "ml_ppqh", "ml_trend_conf", "ml_stock_conf",
             "ml_trend_pval", "ml_stock_pval", "ml_pooled_var",
             "ml_pair_ttest")
  ll <- db_load_params(oid, sid)
  expect_named(ll, cnams, ignore.order = TRUE)

  oid <- ll$oid
  sid <- ll$sid
  ll$oid <- NULL
  ll$sid <- NULL
  expect_equal(db_save_params(oid, sid, ll), 1)
})
