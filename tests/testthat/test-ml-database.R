test_that("Testing model database query functions", {

  X <- "my_org"
  Y <- "my_store"
  cn <- dbc()
  qry <- "SELECT * FROM table WHERE oid = ?oid AND sid = ?sid"
  expect_true(class(interp(qry, cn, oid = SQL(X), sid = Y)) == "SQL")

  oid <- "bfcadfb1-34df-40c1-acf6-1be6ba20de0f"
  sid <- "063674ca-e1db-4df3-b261-99c8fd5cc122"
  sku <- "01005288"
  tmp <- dbGetTransacts90(oid, sid, sku)

  nams <- c("org_uuid", "store_uuid", "order_id", "order_item_id",
            "order_time_utc", "customer_id", "phone", "category3",
            "brand_name", "product_name", "product_sku",
            "product_qty", "item_subtotal", "item_discount",
            "item_list_price", "order_tot", "order_disc", "order_date")
  expect_named(tmp, nams)

  expect_true(nrow(dbGetProductHist(oid, sid)) > 1)
  expect_true(nrow(dbGetProductHist(oid, sid, sku)) == 1)
  expect_true(nrow(dbGetCatPricePts(oid, sid)) > 1)
})

