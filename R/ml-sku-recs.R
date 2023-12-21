#' Functions for Recommendations API
#'
#' Arguments to the endpoint function \code{restock_rec_ep} that are of the form ml_* are
#' advanced use modeling parameters. If not provided, the default tuning values will be used
#'
#' @param oid org uuid
#' @param sid store uuid
#' @param sku one or more skus to generate recommendations for
#' @param velocityDT output of \code{build_velocity_daily}
#' @param ml_stock output of \code{model_supply_risk}
#' @param ml_trend output of \code{model_sales_trend}
#' @param sku_price output of \code{classify_by_price}
#' @param sku_term output of \code{classify_by_term}
#' @param sku_share output of \code{classify_by_orders}
#'
#' @import data.table
#'
#' @name ml-sku-recs
NULL


#' @param ml_conf Model threshold - confidence level
#' @param ml_pval Model threshold - p value
#' @param ml_ltmi Model threshold - long-term menu item
#' @param ml_npom Model threshold - new product on menu
#' @param ml_prim Model threshold - primary product
#' @param ml_secd Model threshold - secondary product
#' @param ml_ppql Model threshold - product price quantile low
#' @param ml_ppqh Model threshold - product price quantile high
#' @param fail_on_error if FALSE (default) response status will be 200/201/207 while status_code object in return value will be 400
#' @param recs_only default FALSE. If true drop all objects except the rec results before returning
#' @param to_json default FALSE Encode return object as JSON before returning
#' @param auto_unbox Only used if to_json is TRUE. see ?jsonlite::toJSON
#' @param na Only used if to_json is TRUE. see ?jsonlite::toJSON
#' @param pretty Only used if to_json is TRUE. see ?jsonlite::toJSON
#' @param ... additional parameters to pass to jsonlite::toJSON
#' @param ml_trend_conf When provided, will override the args applied to all models
#' @param ml_stock_conf When provided, will override the args applied to all models
#' @param ml_trend_pval When provided, will override the args applied to all models
#' @param ml_stock_pval When provided, will override the args applied to all models
#' @param ml_pair_ttest Whether to pair the ttests. Default is FALSE
#' @param ml_pooled_var whether to pool the variance default is TRUE
#'
#' @importFrom lubridate now
#' @importFrom stringr str_replace_na
#' @importFrom jsonlite toJSON
#' @importFrom rpgconn dbc dbd
#'
#' @describeIn ml-sku-recs this is an insights api endpoint exposed to archx that wraps all the steps
#' performed to generate recommendations into a single call and uses default threshold parameters
#' for the models used to create those recs
#' @export
restock_rec_ep <- function(oid, sid, sku,
                           ml_conf = .9,
                           ml_pval = .05,
                           ml_ltmi = 182,
                           ml_npom = 14,
                           ml_prim = .45,
                           ml_secd = .25,
                           ml_ppql = .2,
                           ml_ppqh = .8,
                           ml_pair_ttest = FALSE,
                           ml_pooled_var = FALSE,
                           ml_trend_conf = ml_conf,
                           ml_stock_conf = ml_conf,
                           ml_trend_pval = ml_pval,
                           ml_stock_pval = ml_pval,
                           fail_on_error = FALSE,
                           recs_only = FALSE,
                           to_json = FALSE,
                           auto_unbox = TRUE,
                           na = "string",
                           pretty = FALSE, ...) {

  ## Open connection
  cn <- rpgconn::dbc(db = "integrated")
  on.exit(rpgconn::dbd(cn))

  OUT <- tryCatch({

    ###
    ### Get External Data Needed
    ###
    skuSalesDT <- dbGetTransacts90(oid, sid, sku, cn)

    ## check for skus with low or no pop data
    no_data_skus <- skuSalesDT[, .N, keyby = product_sku][sku][
      which(N < 10 | is.na(N)),
      product_sku]

    if (length(no_data_skus) > 0) {

      ## If there are no skus remaining after taking out the ones with low data, then error
      if (nrow(skuSalesDT[!no_data_skus, on = "product_sku"]) == 0)
        stop("Not enough sales data for given org/store and sku(s)", call. = FALSE)

      ## if there are skus remaining to process and fail_on_error is true then generate error
      if (fail_on_error) {
        sku_txt <- stringr::str_flatten_comma(no_data_skus)
        stop("The following sku(s) dont have enough sales data...", sku_txt, call. = FALSE)
      }
    }

    ## Get the skus with data and get external data needed to process recs for these skus
    skus_with_data <- skuSalesDT[, .N, product_sku][N >= 10, product_sku]
    prodHistDT <- dbGetProductHist(oid, sid, sku, cn)[(skus_with_data), on = "product_sku"]
    catPriceDT <- dbGetCatPricePts(oid, sid, cn)

    ###
    ### Build Internal Data Needed
    ###
    velocityDT <- build_velocity_daily(skuSalesDT)

    ## If there are no velocityDT rows, stop the code
    if (nrow(velocityDT) == 0)
      stop("No velocity data produced for the given org/store and sku(s)", call. = FALSE)

    ###
    ### Model Sales Trend and Supply Risk
    ###
    # gather the arguments needed for the modeling functions
    m_args <- list(velocityDT = velocityDT,
                   thresh_conf = NULL,
                   thresh_pval = NULL,
                   paired_test = ml_pair_ttest,
                   pool_var = ml_pooled_var)

    ## If the more granular confidence and pvalues are provided, use those, else fall back
    ## to the default args and apply them to both models
    ##
    ## First do sales trend
    ##
    if (!is.null(ml_trend_conf)) {
      m_args$thresh_conf <- ml_trend_conf
    } else {
      m_args$thresh_conf <- ml_conf
    }
    if (!is.null(ml_trend_pval)) {
      m_args$thresh_pval <- ml_trend_pval
    } else {
      m_args$thresh_pval <- ml_pval
    }

    ## Run sales model
    ml_trend <- do.call(model_sales_trend, m_args)

    ## Next do supply risk
    ##
    if (!is.null(ml_stock_conf)) {
      m_args$thresh_conf <- ml_stock_conf
    } else {
      m_args$thresh_conf <- ml_conf
    }
    if (!is.null(ml_stock_pval)) {
      m_args$thresh_pval <- ml_stock_pval
    } else {
      m_args$thresh_pval <- ml_pval
    }

    ## Run stock model
    ml_stock <- do.call(model_supply_risk, m_args)

    ## Classify Products based on Time, Order Stats, and Price Point
    ##
    sku_term  <- classify_by_term(
      prodHistDT,
      thresh_long = ml_ltmi,
      thresh_new = ml_npom
    )
    sku_share <- classify_by_orders(
      velocityDT,
      thresh_primary = ml_prim,
      thresh_second = ml_secd
    )
    sku_price <- classify_by_price(
      velocityDT,
      catPriceDT,
      thresh_low = ml_ppql,
      thresh_high = ml_ppqh
    )

    ## Extract Classifications, Stats, and Text Associated with Recs
    ##
    flags <- extract_rec_flags(ml_stock, ml_trend, sku_price, sku_term, sku_share)
    htext <- extract_help_text(ml_stock, ml_trend, sku_price, sku_term, sku_share)
    metad <- extract_meta_data(ml_stock, ml_trend, sku_price, sku_term, sku_share)


    ## Assign Recommendation for each Product
    ##
    precs <- assign_product_recs(flags)

    precs[is.na(is_recommended), restock := "unsure"]
    precs[(is_recommended), restock := "yes"]
    precs[!(is_recommended), restock := "no"]


    ## Check whether all skus were processed
    failed_skus <- sku[which(precs[(sku)][, is.na(restock)])]

    if (length(failed_skus) > 0) {
      code <- 207
      msg <- paste0(
        "Recommendations failed for the following...",
        stringr::str_flatten_comma(failed_skus)
      )
    } else {
      code <- 200
      msg <- "All Skus Processed Ok"
    }

    if (fail_on_error && code > 200)
      stop(msg, call. = FALSE)

    ## Form Body of API Request on Success
    ##
    list(
      results = precs[unique(c(precs$product_sku, failed_skus)), on = "product_sku"],
      meta = list("flags" = flags, "stats" = metad, "descr" = htext),
      created_utc = lubridate::now("UTC"),
      status_code = code,
      status_msg = msg
    )

  }, error = function(c) {

    if (fail_on_error)
      stop(c$message, call. = FALSE)

    ## Form Body of API Request on Error
    ##
    list(
      results = data.table(product_sku = sku, is_recommended = NA, restock = NA_character_),
      meta = list("flags" = NA, "stats" = NA, "descr" = NA),
      created_utc = lubridate::now("UTC"),
      status_code = 400,
      status_msg = c$message
    )

  })

  ## Process output based on given args
  if (recs_only)
    OUT <- OUT$results[]
  if (to_json)
    OUT <- jsonlite::toJSON(OUT, auto_unbox = auto_unbox, pretty = pretty, na = na, ...)
  return(OUT)
}


#' @param pop sales transactions dataset used to build velocity data for modeling
#'
#' @describeIn ml-sku-recs function to build velocity data for modeling
#' @export
build_velocity_daily <- function(pop) {

  ## split by sku for processing, and log
  ll <- split(pop, by = "product_sku", keep.by = TRUE)

  ## Process each sku subset to build velocity metrics
  vtDailyDT <- rbindlist(lapply(ll, function(skuDT) {

    if (nrow(skuDT) < 11) {
      return(NULL)
    }
    setkey(skuDT, order_date)

    vtDT <- cbind(
      skuDT[1, .(org_uuid, store_uuid, product_sku, category3, brand_name)],
      setnafill(
        skuDT[.(seq.Date(min(order_date), max(order_date), by = 1)), .(
          units_sold = ceiling(sum(product_qty)),
          tot_sales = sum(item_subtotal),
          ave_disc_r = abs(sum(item_discount)) / sum(item_subtotal),
          ave_ticket = mean(order_tot),
          wts = .GRP/.NGRP
        ), .EACHI],
        fill = 0
      )
    )
    vtDT[
      vtDT[tot_sales == 0, which = TRUE],
      tot_sales_est := vtDT[units_sold > 0, mean(tot_sales, trim = .2)]
    ]
    vtDT[is.na(tot_sales_est), tot_sales_est := tot_sales]
    vtDT[, c_sales_est := cumsum(tot_sales_est)]
    vtDT[, c_sales_actual := cumsum(tot_sales)]
    vtDT[, has_sales := units_sold > 0]
    vtDT[]
  }))

  if (nrow(vtDailyDT) == 0)
    return(vtDailyDT)

  ## set key and column ordering
  keyCols <- c("org_uuid", "store_uuid", "product_sku", "order_date")
  setcolorder(vtDailyDT, keyCols)
  setkeyv(vtDailyDT, keyCols)

  ## Add created time, log, and return
  vtDailyDT[, created_utc := Sys.time()]
  vtDailyDT[]
}


#' @describeIn ml-sku-recs helper function to load default model params
#' @export
default_model_params <- function() {
  list(
    ml_npom = 14,
    ml_ltmi = 182,
    ml_secd = .20,
    ml_prim = .45,
    ml_ppql = .20,
    ml_ppqh = .80,
    ml_pair_ttest = FALSE,
    ml_pooled_var = TRUE,
    ml_trend_pval = .05,
    ml_trend_conf = .85,
    ml_stock_pval = .05,
    ml_stock_conf = .85
  )
}


#' @param thresh_conf conf-level threshold for model
#' @param thresh_pval p-level threshold for model
#' @param pool_var whether to pool the variance in ttest. Default is TRUE
#' @param paired_test whether to run a paired ttest (default is FALSE)
#'
#' @importFrom stats t.test sd
#' @importFrom utils tail
#'
#' @describeIn ml-sku-recs Model sales trend
#' @export
model_sales_trend <- function(velocityDT,
                              thresh_conf = .9,
                              thresh_pval = .05,
                              pool_var = TRUE,
                              paired_test = FALSE) {

  OUT <- tryCatch({

    ## internal function to parse model object
    parse_model <- function(tm) {
      list(
        mean_past = as.numeric(tm$estimate[2]),
        mean_recent = as.numeric(tm$estimate[1]),
        stdev_pooled = tm$stderr,
        model_object = list(tm)
      )
    }

    ## internal function to run the model given the sku-level dataset
    run_model <- function(dt) {
      if (nrow(dt) < 10) {
        mll <- list(
          is_trending = FALSE,
          trend_sign = NA,
          trend_desc = "Not enough sales days to evaluate recent trends",
          mean_past = dt[, mean(gross)],
          mean_recent = dt[, mean(gross)],
          stdev_pooled = dt[, sd(gross)],
          model_object = NA,
          model_data = list(dt)
        )
      } else {
        t0 <- dt[!tail(dt), gross]
        t1 <- tail(dt)[, gross]
        tm <- stats::t.test(t1, t0,
                            alternative = "greater",
                            var.equal = pool_var,
                            paired = paired_test,
                            conf.level = thresh_conf)

        if (tm$p.value < thresh_pval) {
          ## if p value is significant and low
          mll <- c(list(
            is_trending = TRUE,
            trend_sign = "positive",
            trend_desc = "Recent sales are trending upward"
          ), parse_model(tm), list(model_data = list(dt)))
        } else if (tm$p.value > (1 - thresh_pval)) {
          ## if p value is above 90% it is actually signficant in the other direction
          mll <- c(list(
            is_trending = TRUE,
            trend_sign = "negative",
            trend_desc = "Recent sales are trending downward"
          ), parse_model(tm), list(model_data = list(dt)))
        } else {
          ## no trend found
          mll <- c(list(
            is_trending = FALSE,
            trend_sign = "none",
            trend_desc = "No statistically significant sales trend"
          ), parse_model(tm), list(model_data = list(dt)))
        }
      }
      as.data.table(c(list(product_sku = dt[1, product_sku]), mll))
    }

    ## model data -> summary of sales by sku and day
    mlDT <- velocityDT[tot_sales > 0, .(
      gross = sum(tot_sales)
    ), keyby = .(product_sku, order_date)][, day_num := 1:.N, product_sku]

    ## split data into tables by sku
    tmp <- split(mlDT, by = "product_sku", keep.by = TRUE)

    ## run the model, bind results, and return
    rbindlist(lapply(tmp, run_model))

  }, error = function(c) {

    msg <- paste0("Unable to model sales trend...\n\n", paste0(c$message, collapse = '\n'))
    stop(msg, call. = FALSE)

  })
  return(OUT)
}


#' @param thresh_conf conf-level threshold for model
#' @param thresh_pval p-level threshold for model
#' @param pool_var whether to pool the variance in ttest. Default is TRUE
#' @param paired_test whether to run a paired ttest (default is FALSE)
#'
#' @importFrom stats t.test
#'
#' @describeIn ml-sku-recs Model Supply Risk
#' @export
model_supply_risk <- function(velocityDT,
                              thresh_conf = .9,
                              thresh_pval = .05,
                              paired_test = FALSE,
                              pool_var = FALSE) {

  ## Internal function to evaluate the stockout risk by sku
  .eval_risk <- function(sdt) {

    ## Testing for Supply Risk
    ## 1. split the data into three time periods
    ## 2. compare predicted cumalative sales against acutal cumalative sales ensuring
    ##    prediction is statistically greater than actuals across all three periods
    ## 3. Next compare total sales when greater than 0 vs predicted total sales
    ##    without splitting time periods
    ##
    ## Note:
    ## With the cumulative sales ttest, we also require that confidence in
    ## in the comparison increases from one period test to the subsequent while
    ## for total sales, this is relaxed

    ## First do cumulative sales
    x1 <- sdt[wts < .33, c_sales_est]
    y1 <- sdt[wts < .33, c_sales_actual]

    x2 <- sdt[wts > .33 & wts < .66, c_sales_est]
    y2 <- sdt[wts > .33 & wts < .66, c_sales_actual]

    x3 <- sdt[wts > .66, c_sales_est]
    y3 <- sdt[wts > .66, c_sales_actual]

    ## set default NA to be returned if theres not enough data
    has_risk_a <- NA

    ## Check whether there's enough in each split, if so run tests
    if ( all(sapply(list(x1, x2, x3, y1, y2, y3), length) > 1) ) {
      p1 <- stats::t.test(x1, y1, alternative = "greater", paired = paired_test,
                          var.equal = pool_var, conf.level = thresh_conf)$p.value
      p2 <- stats::t.test(x2, y2, alternative = "greater", paired = paired_test,
                          var.equal = pool_var, conf.level = thresh_conf)$p.value
      p3 <- stats::t.test(x3, y3, alternative = "greater", paired = paired_test,
                          var.equal = pool_var, conf.level = thresh_conf)$p.value
      has_risk_a <- (p1 > p2) & (p2 > p3) & (p3 < thresh_pval)
    }

    ## Now do total sales
    x <- sdt[, tot_sales_est]
    y <- sdt[, tot_sales]

    ## set default NA to be returned if theres not enough data
    has_risk_b <- NA

    ## Check whether there's enough in each split, if so run tests
    if ( all(sapply(list(x, y), length) > 1) ) {
      p <- stats::t.test(x, y, alternative = "greater", paired = paired_test,
                         var.equal = pool_var, conf.level = thresh_conf)$p.value
      has_risk_b <- p < thresh_pval
    }
    has_risk <- has_risk_a & has_risk_b


    ## calculate average length of period (in days) with no sales
    oosDT <- cbind(
      data.table(
        product_sku = sdt[1, product_sku],
        has_oos_risk = has_risk,
        pct_oos_days = sdt[, 1 - sum(has_sales)/.N],
        days_sold = sdt[(has_sales), .N],
        days_not_sold = sdt[!(has_sales), .N]
      ),
      sdt[sdt[units_sold == 0, which = TRUE],
          difftime(order_date[.N], order_date[1], units = "days"),
          c_sales_actual][, .(
            oos_periods = .N,
            ave_oos_period_days = as.numeric(mean(V1))
          )],
      data.table(oos_data = list(sdt[, .(product_sku, order_date, units_sold, tot_sales)]))
    )
    return(oosDT)
  }
  OUT <- tryCatch({
    ## split data by sku
    tmp <- split(velocityDT, by = "product_sku", keep.by = TRUE)

    ## run model, bind results, and descriptive text
    OUT <- rbindlist(lapply(tmp, .eval_risk))

    OUT[(has_oos_risk),
        stock_risk_desc := "Based on historical data, product supply is highly volatile"]
    OUT[(!has_oos_risk),
        stock_risk_desc := "Based on historical data, product has limited to no supply risk"]
    OUT[]
  }, error = function(c) {
    msg <- paste0("Unable to model supply risk...\n\n", paste0(c$message, collapse = '\n'))
    stop(msg, call. = FALSE)
  })
  return(OUT[])
}


#' @param catPriceDT output of \code{dbGetCatPricePts}
#' @param thresh_low percentile threshold for determining low price
#' @param thresh_high percentile threshold for determining high price
#'
#' @importFrom stats quantile
#'
#' @describeIn ml-sku-recs benchmark against category prices
#' @export
classify_by_price <- function(velocityDT,
                              catPriceDT,
                              thresh_low = .2,
                              thresh_high = .8) {
  tryCatch({
    cpDT <- catPriceDT[, as.list(quantile(item_list_price, c(thresh_low, thresh_high))), category3]
    setnames(cpDT, c("category3", "cat_price_low", "cat_price_high"))

    cpDT[, cat_price_low := as.integer(cat_price_low)]
    cpDT[, cat_price_high := as.integer(cat_price_high)]

    vsumm <- velocityDT[units_sold > 0, .(
      tot_days = sum(has_sales),
      tot_sales = sum(tot_sales),
      tot_units = sum(units_sold),
      ave_unit_price = mean(tot_sales / units_sold),
      std_unit_price = sd(tot_sales / units_sold)
    ), .(product_sku, category3)]

    if (nrow(vsumm) == 0) {
      stop("No velocity metrics for given skus", call. = FALSE)
    }

    sku_price <- cpDT[vsumm, on = "category3"]
    setcolorder(sku_price, c("product_sku", "category3"))

    sku_price[ave_unit_price < cat_price_low, price_point := "low"]
    sku_price[ave_unit_price > cat_price_high, price_point := "high"]
    sku_price[is.na(price_point), price_point := "mid"]
    sku_price[, price_point := factor(price_point, levels = c("low", "mid", "high"))]

    sku_price[price_point == "low",
              price_point_desc := "Price point is low relative to others in category"]
    sku_price[price_point == "high",
              price_point_desc := "Price point is high relative to others in category"]
    sku_price[price_point == "mid",
              price_point_desc := "Price point is within the average of others in category"]
    sku_price[]

  }, error = function(c) {
    msg <- paste0("Unable to classify by price...\n\n", paste0(c$message, collapse = '\n'))
    stop(msg, call. = FALSE)
  })
}


#' @param prodHistDT output of \code{dbGetProductHist}
#' @param thresh_long threshold in days for determining if a product is a long-term menu item
#' @param thresh_new threshold in days for determining if a product is a new menu item
#'
#' @importFrom lubridate today
#'
#' @describeIn ml-sku-recs Establish whether sku is long term or new on the menu
#' @export
classify_by_term <- function(prodHistDT,
                             thresh_long = 182,
                             thresh_new = 14) {
  tryCatch({
    sku_term <- prodHistDT[, .(
      days_since_first = as.numeric(difftime(lubridate::today(), first_date, units = "days")),
      menu_period_days = as.numeric(difftime(last_date, first_date, units = "days"))
    ), keyby = .(product_sku)]

    sku_term[, is_long_term := menu_period_days > thresh_long]
    sku_term[, is_new_on_menu := menu_period_days < thresh_new]
    sku_term[(is_long_term),
             term_desc := "Product is a long-term menu item (first sold +6 months prior)"]
    sku_term[(is_new_on_menu),
             term_desc := "Product is new on the menu (sold within the prior 2 weeks)"]
    sku_term[!(is_long_term | is_new_on_menu),
             term_desc := "Product isn't a new menu offering, nor is it a long-term menu item"]

    if (nrow(sku_term) == 0) {
      stop("No history for given skus", call. = FALSE)
    }
    sku_term[]

  }, error = function(c) {
    msg <- paste0("Unable to classify by time...\n\n", paste0(c$message, collapse = '\n'))
    stop(msg, call. = FALSE)
  })
}


#' @param thresh_primary percent threshold for identifying primary products
#' @param thresh_second percent threshold for identifying secondary products
#'
#' @describeIn ml-sku-recs Establish whether a product is a primary, secondary, or neither
#' @export
classify_by_orders <- function(velocityDT,
                               thresh_primary = .45,
                               thresh_second = .25) {
  tryCatch({
    sku_share <- velocityDT[(has_sales), .(
      share_of_order = mean((tot_sales / units_sold) / ave_ticket)
    ), product_sku]

    if (nrow(sku_share) == 0)
      stop("No skus with sales to classify by orders", call. = FALSE)

    sku_share[, is_primary := share_of_order > thresh_primary]
    sku_share[, is_secondary := share_of_order < thresh_second]
    sku_share[(is_primary),
              share_desc := "This product drives the majority of sales per order when purchased"]
    sku_share[(is_secondary),
              share_desc := "This product drives less than 25% of the order total when purchased"]
    sku_share[!(is_secondary | is_primary),
              share_desc := "Product is neither a primary or secondary item"]
    sku_share[]

  }, error = function(c) {
    msg <- paste0("Unable to classify by orders...\n\n", paste0(c$message, collapse = '\n'))
    stop(msg, call. = FALSE)
  })
}


#' @describeIn ml-sku-recs Extract recommendation guidance
#' @export
extract_help_text <- function(ml_stock,
                              ml_trend,
                              sku_price,
                              sku_term,
                              sku_share) {
  tryCatch({
    helptext <- rbindlist(list(
      ml_stock[, .(product_sku, product_trait = "supply_risk", description = stock_risk_desc)],
      ml_trend[, .(product_sku, product_trait = "sales_trend", description = trend_desc)],
      sku_price[, .(product_sku, product_trait = "price_point", description = price_point_desc)],
      sku_term[, .(product_sku, product_trait = "menu_staple", description = term_desc)],
      sku_share[, .(product_sku, product_trait = "order_spend", description = share_desc)]
    ))
    setkey(helptext, product_sku)

    helptext[, product_trait := factor(
      product_trait,
      levels = c("sales_trend", "supply_risk", "price_point", "order_spend", "menu_staple")
    )]
    setkey(helptext, product_sku, product_trait)
    helptext[]

  }, error = function(c) {
    msg <- paste0("Unable to extract rec text..\n\n", paste0(c$message, collapse = '\n'))
    stop(msg, call. = FALSE)
  })
}


#' @describeIn ml-sku-recs Join all results together and select columns needed for recommendation
#' @export
extract_rec_flags <- function(ml_stock,
                              ml_trend,
                              sku_price,
                              sku_term,
                              sku_share) {
  tryCatch({
    setkey(sku_price, product_sku)
    setkey(sku_term, product_sku)
    setkey(sku_share, product_sku)
    setkey(ml_stock, product_sku)
    setkey(ml_trend, product_sku)

    ## generated flags used in logic for recommendations
    flags <- sku_term[, .(product_sku, is_long_term, is_new_on_menu)][
      sku_price[, .(product_sku, price_point)]
    ][sku_share[, .(product_sku, is_primary, is_secondary)]][ml_trend[
      ml_stock, .(product_sku, has_oos_risk, is_trending, trend_sign)]]
    setkey(flags, product_sku)
    flags[]

  }, error = function(c) {
    msg <- paste0("Unable to extract classifications...\n\n", paste0(c$message, collapse = '\n'))
    stop(msg, call. = FALSE)
  })
}


#' @importFrom stringr str_subset
#'
#' @describeIn ml-sku-recs meta data used to generate flags
#' @export
extract_meta_data <- function(ml_stock,
                              ml_trend,
                              sku_price,
                              sku_term,
                              sku_share) {
  tryCatch({
    setkey(sku_price, product_sku)
    setkey(sku_term, product_sku)
    setkey(sku_share, product_sku)
    setkey(ml_stock, product_sku)
    setkey(ml_trend, product_sku)

    metad <- sku_term[sku_price[sku_share][ml_stock]][ml_trend]
    dropCols <- stringr::str_subset(names(metad), "^(is|has)_|(desc|data|object)$|trend_sign")
    metad[, (dropCols) := NULL]
    setkey(metad, product_sku)
    metad[]

  }, error = function(c) {
    msg <- paste0("Unable to extract rec meta data...\n\n", paste0(c$message, collapse = '\n'))
    stop(msg, call. = FALSE)
  })
}


#' @param flags return value of call to \code{extract_flags} in a prior rec step
#'
#' @describeIn ml-sku-recs assign recommendation of yes/no based on the flags associated with each sku
#' @export
assign_product_recs <- function(flags) {
  tryCatch({
    ##  Does product has sales trends in either direction? If negative, do not restock,
    ##  if positive restock recommend
    recs <- flags[, .(product_sku)]
    recs[flags[trend_sign == "positive", which = TRUE], is_recommended := TRUE]
    recs[flags[trend_sign == "negative", which = TRUE], is_recommended := FALSE]

    ## if it didnt get a recommendation based on trend, check if this is a new product.
    ## If so, to stay consistent with Buyers, we are assigning a default rec of yes
    indx <- flags[recs][is.na(is_recommended) & is_new_on_menu, which = TRUE]
    recs[indx, is_recommended := TRUE]

    ## if a product is a secondary item and has oos risk, do not recommend
    indx <- flags[recs[is.na(is_recommended), which = TRUE]][]

    recs[
      flags[indx, product_sku[which(is_secondary & has_oos_risk)]],
      is_recommended := FALSE]

    ## Of the remaining products w/o a rec, if it is a primary product or a long
    ## term menu item, then recommend
    recs[
      flags[recs[is.na(is_recommended) & (is_primary | is_long_term)], product_sku],
      is_recommended := TRUE]

    ## Of the remaining products w/o a rec, if there is oos risk, do not recommend
    recs[
      flags[recs[is.na(is_recommended) & has_oos_risk], product_sku],
      is_recommended := FALSE]

    recs[]

  }, error = function(c) {
    msg <- paste0("Unable to assign recommendations...\n\n", paste0(c$message, collapse = '\n'))
    stop(msg, call. = FALSE)
  })
}
