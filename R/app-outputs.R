#' App Outputs
#'
#' Functions to generate and prepare outputs presented by the package app.
#'
#' @param .colors colors returned by get_app_colors()
#' @param pdata0 plot dataset
#' @param pdata1 plot dataset
#' @param pdata2 plot dataset
#' @param pdata3 plot dataset
#' @param pdata4 plot dataset
#' @param ptitle plot title
#' @param psubtitle plot subtitle
#' @param rec internal
#' @param oid see rdscore::restock_rec_ep
#' @param sid see rdscore::restock_rec_ep
#' @param sku see rdscore::restock_rec_ep
#' @param ml_trend_conf see rdscore::restock_rec_ep
#' @param ml_trend_pval see rdscore::restock_rec_ep
#' @param ml_stock_conf see rdscore::restock_rec_ep
#' @param ml_stock_pval see rdscore::restock_rec_ep
#' @param ml_pair_ttest see rdscore::restock_rec_ep
#' @param ml_pooled_var see rdscore::restock_rec_ep
#' @param ml_ltmi see rdscore::restock_rec_ep
#' @param ml_npom see rdscore::restock_rec_ep
#' @param ml_prim see rdscore::restock_rec_ep
#' @param ml_secd see rdscore::restock_rec_ep
#' @param ml_ppql see rdscore::restock_rec_ep
#' @param ml_ppqh see rdscore::restock_rec_ep
#'
#' @import ggplot2
#' @import ggtext
#' @import data.table
#' @importFrom scales percent
#' @importFrom stringr str_glue str_remove str_split_1 str_replace str_replace_all
#' @importFrom rdscore restock_rec_ep
#'
#' @name app-outputs
NULL


#' @describeIn app-outputs provides the base theme for plots
.plot_theme <- function(.colors) {

  ggplot2::theme(
    axis.title = ggplot2::element_blank(),
    plot.title = ggtext::element_textbox(
      lineheight = 1.5,
      family = "Sora"
    ),
    plot.title.position = "plot",
    axis.text.x = ggtext::element_markdown(
      size = 12,
      colour = .colors$fg,
      family = "Sora"
    ),
    axis.text.y = ggtext::element_markdown(
      size = 12,
      colour = .colors$fg,
      family = "Sora"
    ),
    panel.background = ggplot2::element_rect(
      fill = .colors$bg,
      color = .colors$bg
    ),
    plot.background = ggplot2::element_rect(
      fill = .colors$bg,
      color = .colors$bg,
      linewidth = 0
    ),
    panel.grid.minor.y = ggplot2::element_blank(),
    panel.border = ggplot2::element_blank(),
    strip.background = ggplot2::element_blank(),
    strip.text = ggtext::element_textbox(
      size = 12,
      color = .colors$fg,
      fill = .colors$bg,
      box.color = .colors$fg,
      halign = 0.5,
      linewidth = .5,
      linetype = 1,
      family = "Sora",
      r = ggplot2::unit(5, "pt"),
      width = ggplot2::unit(1, "npc"),
      padding = ggplot2::margin(2, 0, 1, 0),
      margin = ggplot2::margin(3, 3, 3, 3)
    ),
    text = ggplot2::element_text(family = "Sora")
  )
}


#' @describeIn app-outputs Style the plot title/subtitle
.plot_title_style <- function(ptitle, psubtitle, .colors) {
  ggplot2::labs(
    title = stringr::str_glue(
      "<span style= 'font-size:16pt; color:{.colors$fg};'><b>{ptitle}</b></span><br>
        <span style= 'font-size:13pt; color:{.colors$fg};'>*{psubtitle}*</span><br>"
    ))
}


#' @describeIn app-outputs Parse failed skus to delineate between failures and uncertain recs
.parse_fails <- function(rec) {
  failed_skus <- stringr::str_split_1(
    stringr::str_remove(
      rec$status_msg,
      "Recommendations failed for the following..."
    ), ", ?")
  return(failed_skus)
}


#' @describeIn app-outputs diagnostic plot
plot_diagnostic_0 <- function(pdata0, .colors) {
  rdstools::log_inf("...Creating plot 0")

  ptitle <- "Count by Recommendation"
  psubtitle <- paste0("Total Recommendations Generated: ", pdata0[, sum(N)])
  p0 <- ggplot2::ggplot(pdata0) +
    ggplot2::geom_bar(
      ggplot2::aes(restock, N, fill = restock),
      stat = "identity",
      show.legend = FALSE,
      color = .colors$bg
    ) +
    ggplot2::scale_fill_manual(values = c(
      .colors$success,
      .colors$danger,
      .colors$warning,
      .colors$info
    )) +
    ggtext::geom_richtext(
      ggplot2::aes(restock, N, label = label),
      label.colour = .colors$fg,
      size = 6,
      family = "Sora",
      position = ggplot2::position_stack(0.9),
      text.colour = .colors$bg,
      vjust = 0
    ) +
    .plot_title_style(ptitle, psubtitle, .colors) +
    .plot_theme(.colors) +
    ggplot2::scale_x_discrete(
      breaks = c("yes", "no", "unsure", "failed"),
      labels = c(
        "<span style= 'font-size:12pt;'>**Restock IS Recommended**</span><br>
                 <span style= 'font-size:10pt;'>(*With Confidence*)</span>",
        "<span style= 'font-size:12pt;'>**Restock NOT Recommended**</span><br>
                 <span style= 'font-size:10pt;'>(*With Confidence*)</span>",
        "<span style= 'font-size:12pt;'>**Unsure Recommendation**</span><br>
                 <span style= 'font-size:10pt;'>(*No Confidence*)</span>",
        "<span style= 'font-size:12pt;'>**No Recommendation**</span><br>
                 <span style= 'font-size:10pt;'>(*Failed to Generate*)</span>"
      ),
      expand = c(.15, .1, .15, .1)
    ) +
    ggplot2::scale_y_sqrt(expand = c(0, 0)) +
    ggplot2::theme(panel.grid.major.x = ggplot2::element_blank())
  p0
}


#' @describeIn app-outputs diagnostic plot
plot_diagnostic_1 <- function(pdata1, .colors) {
  rdstools::log_inf("...Creating plot 1")

  ptitle <- "Proportion of Recommendation"
  psubtitle <- "By Product Category"
  p1 <- ggplot2::ggplot(pdata1) +
    ggplot2::geom_bar(
      ggplot2::aes(category3, fill = restock),
      stat = "count",
      position = "fill"
    ) +
    .plot_title_style(ptitle, psubtitle, .colors) +
    .plot_theme(.colors) +
    ggplot2::scale_y_continuous(
      labels = scales::percent_format(),
      expand = c(0, 0)
    ) +
    ggplot2::scale_fill_manual(
      breaks = c("yes", "no", "unsure"),
      labels = c("Is Recommended", "Is Not Recommended", "Uncertain Recommendation"),
      values = c(.colors$success, .colors$danger, .colors$warning)
    ) +
    ggplot2::theme(
      legend.position = c(.85, 1.05),
      legend.direction = "horizontal",
      legend.title = ggplot2::element_blank(),
      legend.justification = c(.7, .01),
      legend.key = ggplot2::element_rect(color = NA),
      legend.text = ggplot2::element_text(size = 12, color = .colors$fg),
      legend.background = ggplot2::element_rect(color = NA, fill = NA),
      panel.grid.major.x = ggplot2::element_blank(),
      panel.grid.major.y = ggplot2::element_line(color = .colors$fg, linewidth = .5, linetype = "dotted"),
      axis.ticks.length = ggplot2::unit(0, "cm"),
      axis.text.x = ggplot2::element_blank()
    ) +
    ggplot2::facet_grid(
      . ~ category3,
      switch = "x",
      space = "free",
      scales = "free"
    )
  p1
}


#' @describeIn app-outputs diagnostic plot
plot_diagnostic_2 <- function(pdata2, .colors) {
  rdstools::log_inf("...Creating plot 2")

  ptitle <- "Proportion of Recommendation Flags"
  psubtitle <- "By Classification and Assignment"
  lab_na <- pdata2[value == "Flag Not Assigned", .SD[1], .(variable)]
  lab_a <- pdata2[value == "Flag Assigned", .SD[1], .(variable)]
  p2 <- ggplot2::ggplot(pdata2) +
    ggplot2::geom_bar(
      ggplot2::aes(fac_var, fill = value),
      stat = "count",
      position = "fill",
      width = .90,
      color = NA
    ) +
    ggplot2::scale_y_continuous(
      labels = scales::percent_format(accuracy = 1),
      expand = c(0, 0, 0, .01)
    ) +
    .plot_title_style(ptitle, psubtitle, .colors) +
    .plot_theme(.colors) +
    ggplot2::scale_x_discrete(expand = c(0, 0, 0, 0)) +
    ggplot2::scale_fill_manual(values = rev(c(.colors$secondary, .colors$warning))) +
    ggplot2::theme(
      panel.grid.major.y = ggplot2::element_blank(),
      legend.position = c(.8, 1.025),
      legend.direction = "horizontal",
      legend.title = ggplot2::element_blank(),
      legend.justification = c(.7, .01),
      legend.text = ggplot2::element_text(size = 12, color = .colors$fg),
      legend.background = ggplot2::element_rect(fill = NA),
      text = ggplot2::element_text(family = "Sora")
    ) +
    ggtext::geom_richtext(
      data = lab_na,
      ggplot2::aes(fac_var, (1 - pct) + (pct / 2), label = pctlab),
      fill = "#aa83e7",
      color = "#4d248f",
      position = ggplot2::position_dodge(0),
      size = 4,
      fontface = "bold",
      family = "Sora",
      vjust = .5,
      label.size = 0
    ) +
    ggtext::geom_richtext(
      data = lab_a,
      ggplot2::aes(fac_var, pct / 2, label = pctlab),
      fill = "#edb45a",
      color = "#794a00",
      position = ggplot2::position_dodge(0),
      size = 4,
      fontface = "bold",
      family = "Sora",
      vjust = .5,
      label.size = 0
    ) +
    ggplot2::coord_flip()
  p2
}


#' @describeIn app-outputs diagnostic plot
plot_diagnostic_3 <- function(pdata3, .colors) {
  rdstools::log_inf("...Creating plot 3")

  ptitle <- "Proportion of Recommendation"
  psubtitle <- "By Recommendation and Flag Assignments"
  p3 <- ggplot2::ggplot(pdata3[variable != "is_trending"]) +
    ggplot2::geom_bar(
      ggplot2::aes(value2, fill = restock, alpha = value2, color = value2),
      stat = "count",
      position = "fill"
    ) +
    ggplot2::scale_alpha_manual(values = c(1, .35), guide = "none") +
    ggplot2::scale_color_manual(values = c(.colors$fg, .colors$bg), guide = "none") +
    .plot_title_style(ptitle, psubtitle, .colors) +
    ggplot2::scale_y_continuous(
      labels = scales::percent_format(accuracy = 1),
      expand = c(0, 0)
    ) +
    ggplot2::scale_fill_manual(
      name = NULL,
      breaks = c("yes", "no"),
      values = c("#96dc7d", "#f187eb"),
      labels = c("IS Recommended", "NOT Recommended")
    ) +
    .plot_theme(.colors) +
    ggplot2::facet_grid(. ~ fac_var, scales = "free", space = "free") +
    ggplot2::theme(
      axis.text.x = ggtext::element_markdown(
        size = 12,
        color = .colors$fg,
        angle = 90,
        hjust = 1
      ),
      strip.text = ggtext::element_textbox(
        size = 12,
        color = .colors$fg,
        margin = ggplot2::margin(30, 5, 5, 5),
        fill = .colors$bg,
        box.color = .colors$fg,
        halign = 0.5,
        vjust = 0,
        lineheight = 1,
        linewidth = .2,
        linetype = 1,
        r = ggplot2::unit(5, "pt"),
        width = ggplot2::unit(1, "npc"),
        padding = ggplot2::margin(2, 1, 1, 1)
      ),
      legend.position = c(.89, 1.19),
      legend.direction = "horizontal",
      legend.title = ggplot2::element_blank(),
      legend.justification = "top",
      legend.key = ggplot2::element_rect(color = NA),
      legend.text = ggplot2::element_text(size = 12, color = .colors$fg),
      legend.background = ggplot2::element_rect(color = NA, fill = NA),
      panel.grid.major.x = ggplot2::element_blank(),
      panel.grid.major.y = ggplot2::element_line(
        color = .colors$fg,
        linewidth = .5,
        linetype = "dotted"
      ),
      axis.ticks.length = ggplot2::unit(0, "cm"),
      panel.spacing = ggplot2::unit(0, "cm"),
      strip.placement = "inside"
    )
  p3
}


#' @describeIn app-outputs diagnostic plot
plot_diagnostic_4 <- function(pdata4, .colors) {
  rdstools::log_inf("...Creating plot 4")

  pdata4[, lab := stringr::str_replace(lab, "12pt;", "16pt;")]
  pdata4[, lab := stringr::str_replace_all(lab, "10pt", "14pt")]

  ptitle <- "Proportion of Recommendation"
  psubtitle <- "By Recommendation Text and Category"

  p4 <- ggplot2::ggplot(pdata4[!is.na(lab)]) +
    ggplot2::geom_bar(ggplot2::aes(lab, fill = restock, alpha = restock),
                      stat = "count",
                      color = .colors$fg,
                      width = 0.8,
                      position = ggplot2::position_fill()) +
    ggplot2::facet_grid(. ~ category3, scales = "free", space = "free") +
    ggplot2::coord_flip() +
    .plot_theme(.colors) +
    .plot_title_style(ptitle, psubtitle, .colors) +
    ggplot2::scale_fill_manual(
      name = NULL,
      breaks = c("yes", "no"),
      values = c("#4e7e40", "#7928e3"),
      labels = c("IS Recommended", "NOT Recommended")
    ) +
    ggplot2::scale_alpha_manual(values = c(1, .6), guide = "none") +
    ggplot2::scale_y_continuous(
      breaks = c(0, .50, 1),
      labels = scales::percent_format(accuracy = 1),
      expand = c(.02, 0)
    ) +
    ggplot2::theme(
      legend.position = c(1, 1.05),
      legend.direction = "horizontal",
      legend.title = ggplot2::element_blank(),
      legend.justification = "right",
      legend.key = ggplot2::element_rect(color = NA),
      legend.text = ggplot2::element_text(size = 14, color = .colors$fg),
      legend.background = ggplot2::element_rect(color = NA, fill = NA),
      axis.text.y = ggtext::element_markdown(size = 12),
      axis.text.x = ggtext::element_markdown(size = 12),
      panel.grid.major.x = ggplot2::element_line(
        color = .colors$fg,
        linewidth = .5,
        linetype = "dotted"
      ),
      strip.text = ggtext::element_textbox(size = 14),
      panel.grid.minor.x = ggplot2::element_blank(),
      panel.grid.major.y = ggplot2::element_blank(),
      axis.ticks.length = ggplot2::unit(0, "cm"),
      text = ggplot2::element_text(family = "Sora")
    )
  p4
}


#' @describeIn app-outputs Run recommendations then Build plot datasets and generate plots
ds_sku_recs_pdata <- function(oid, sid, sku,
                              ml_trend_conf = 0.85,
                              ml_trend_pval = 0.05,
                              ml_stock_conf = 0.85,
                              ml_stock_pval = 0.05,
                              ml_pair_ttest = FALSE,
                              ml_pooled_var = TRUE,
                              ml_ltmi = 182,
                              ml_npom = 14,
                              ml_prim = 0.45,
                              ml_secd = 0.2,
                              ml_ppql = 0.2,
                              ml_ppqh = 0.8) {

  # Get recommendations
  rec <- rdscore::restock_rec_ep(
    oid = oid,
    sid = sid,
    sku = sku,
    ml_trend_conf = ml_trend_conf,
    ml_trend_pval = ml_trend_pval,
    ml_stock_conf = ml_stock_conf,
    ml_stock_pval = ml_stock_pval,
    ml_pair_ttest = ml_pair_ttest,
    ml_pooled_var = ml_pooled_var,
    ml_ltmi = ml_ltmi,
    ml_npom = ml_npom,
    ml_prim = ml_prim,
    ml_secd = ml_secd,
    ml_ppql = ml_ppql,
    ml_ppqh = ml_ppqh
  )


  ## Label failed skus in results table
  rec$results[(.parse_fails(rec)), restock := "failed", on = "product_sku"]

  ## Set as factor columns
  levs <- c("yes", "no", "unsure", "failed")
  rec$results[, restock := factor(restock, levs)]

  ## Save labels for later
  labs <- c("Restock Is<br>Recommended",
            "Restock Not<br>Recommended",
            "Uncertain<br>Recommendation",
            "Failed to Get<br>Recommendation")
  label_table <- data.table(
    level = levs,
    label = labs
  )

  ## Set category factors
  rec$meta$stats[, category3 := factor(
    category3,
    levels = c(
      "FLOWER", "PREROLLS","VAPES", "EDIBLES", "EXTRACTS", "DRINKS",
      "TABLETS_CAPSULES", "TOPICALS", "TINCTURES", "ACCESSORIES", "OTHER"
    ),
    labels = c(
      "Flower", "Prerolls", "Vapes", "Edibles", "Extracts", "Drinks",
      "Tablets", "Topicals", "Tinctures", "Accessories", "Other"
    )
  )]

  ## Get plot datasets
  pdata0 <- rec$results[, .N, restock]
  pdata0[, label := scales::percent(N / sum(N), accuracy = 1)]
  pdata0[, restock := factor(restock, levels = c("yes", "no", "unsure", "failed"))]

  pdata1 <- rec$results[
    rec$meta$stats[, .(product_sku, category3)],
    on = "product_sku"][, !"is_recommended"]
  pdata1[, restock := factor(restock, levels = c("yes", "no", "unsure"))]

  # Proportion by Flag
  rec$meta$flags[, has_sales_growth := trend_sign == "positive"]
  rec$meta$flags[, has_sales_decline := trend_sign == "negative"]
  rec$meta$flags[, is_price_high := price_point == "high"]
  rec$meta$flags[, is_price_low := price_point == "low"]
  rec$meta$flags[, price_point := NULL]
  rec$meta$flags[, trend_sign := NULL]

  pdata2 <- data.table::melt(rec$meta$flags, id.vars = "product_sku", variable.factor = FALSE)[!is.na(value)]
  labs <- pdata2[, .N, .(variable, value)][, perc := N / sum(N), variable][]
  labs[, pctlab := scales::percent(perc, accuracy = 1)]

  setkey(pdata2, variable, value)
  setkey(labs, variable, value)
  pdata2[labs, c("pct", "pctlab") := .(perc, pctlab)]

  pdata2[variable == "has_oos_risk",
         fac_var := "<span style= 'font-size:12pt;'>**Stockout Risk**</span><br>
         <span style= 'font-size:10pt;'>*Supply has<br>risk of Stockout*</span>"]
  pdata2[variable == "has_sales_decline",
         fac_var := "<span style= 'font-size:12pt;'>**Sales Decline**</span><br>
         <span style= 'font-size:10pt;'>*Sales Trend<br>is Negative*</span>"]
  pdata2[variable == "has_sales_growth",
         fac_var := "<span style= 'font-size:12pt;'>**Sales Growth**</span><br>
         <span style= 'font-size:10pt;'>*Sales Trend<br>is Positive*</span>"]
  pdata2[variable == "is_long_term",
         fac_var := "<span style= 'font-size:12pt;'>**Menu Classic**</span><br>
         <span style= 'font-size:10pt;'>*Long-Term<br>Menu Item*</span>"]
  pdata2[variable == "is_new_on_menu",
         fac_var := "<span style= 'font-size:12pt;'>**New Product**</span><br>
         <span style= 'font-size:10pt;'>*Recent Addition<br>on Menu*</span>"]
  pdata2[variable == "is_price_high",
         fac_var := "<span style= 'font-size:12pt;'>**Top Shelf**</span><br>
         <span style= 'font-size:10pt;'>*High Price<br>Relative to Category*</span>"]
  pdata2[variable == "is_price_low",
         fac_var := "<span style= 'font-size:12pt;'>**Bottom Shelf**</span><br>
         <span style= 'font-size:10pt;'>*Low Price<br>Relative to Category*</span>"]
  pdata2[variable == "is_primary",
         fac_var := "<span style= 'font-size:12pt;'>**Primary Product**</span><br>
         <span style= 'font-size:10pt;'>*Drives Majority<br>of Order Sales*</span>"]
  pdata2[variable == "is_secondary",
         fac_var := "<span style= 'font-size:12pt;'>**Secondary Item**</span><br>
         <span style= 'font-size:10pt;'>*Product is an<br>Addon Item*</span>"]
  pdata2[variable == "is_trending",
         fac_var := "<span style= 'font-size:12pt;'>**Trending Sales**</span><br>
         <span style= 'font-size:10pt;'>*Recent Sales<br>shows Trend*</span>"]


  ## Set factor order by flag frequency
  levs <- pdata2[value == FALSE, .SD[1], .(variable, value)][order(-pct), fac_var]
  pdata2[, fac_var := factor(fac_var, levels = levs)]

  ## Set factor orders for flag assignment
  pdata2[, value := factor(
    x = value,
    levels = c(FALSE, TRUE),
    labels = c("Flag Not Assigned", "Flag Assigned")
  )]

  setkey(pdata1, product_sku)
  setkey(pdata2, product_sku)
  pdata3 <- pdata1[pdata2][!is.na(value) & restock != "unsure"]

  pdata3[value == "Flag Assigned", value2 := "Assigned"]
  pdata3[value == "Flag Not Assigned", value2 := "Not Assigned"]

  # Rec Breakdown by category
  #
  setkey(rec$meta$descr, product_sku)

  pdata4 <- rec$meta$descr[
    pdata3[, unique(.SD), .SDcols = c("product_sku", "restock", "category3")]
  ][!is.na(description)]

  pdata4[description == "No statistically significant sales trend",
         lab := "<span style= 'font-size:12pt;'>**No Sales Trend**</span><br>
                <span style= 'font-size:10pt;'>*No statistically<br>significant sales trend*</span>"]

  pdata4[description == "Based on historical data, product has limited to no supply risk",
         lab := "<span style= 'font-size:12pt;'>**Supply Not Risky**</span><br>
                <span style= 'font-size:10pt;'>*Product has limited<br>to no supply risk*</span>"]

  pdata4[description == "Price point is low relative to others in category",
         lab := "<span style= 'font-size:12pt;'>**Bottom Shelf**</span><br>
                <span style= 'font-size:10pt;'>*Low Priced Item*</span>"]

  pdata4[description == "Product is neither a primary or secondary item",
         lab := "<span style= 'font-size:12pt;'>**Ave Order Item**</span><br>
                <span style= 'font-size:10pt;'>*Products are neither<br>primary or secondary*</span>"]

  pdata4[description == "Product is a long-term menu item (first sold +6 months prior)",
         lab := "<span style= 'font-size:12pt;'>**Menu Classic**</span><br>
                <span style= 'font-size:10pt;'>*Long-term<br>menu items*</span>"]

  pdata4[description == "Based on historical data, product supply is highly volatile",
         lab := "<span style= 'font-size:12pt;'>**Supply Risky**</span><br>
                <span style= 'font-size:10pt;'>*Supply has risk<br>of stockouts*</span>"]

  pdata4[description == "Price point is within the average of others in category",
         lab := "<span style= 'font-size:12pt;'>**Mid-Shelf**</span><br>
                <span style= 'font-size:10pt;'>*Products are priced<br>within category range*</span>"]

  pdata4[description == "Price point is high relative to others in category",
         lab := "<span style= 'font-size:12pt;'>**Top Shelf**</span><br>
                <span style= 'font-size:10pt;'>*Products are priced<br>high relative to category*</span>"]

  pdata4[description == "Recent sales are trending upward",
         lab := "<span style= 'font-size:12pt;'>**Sales Growth**</span><br>
                <span style= 'font-size:10pt;'>*Sales are<br>trending up*</span>"]

  pdata4[description == "Recent sales are trending downward",
         lab := "<span style= 'font-size:12pt;'>**Sales Decline**</span><br>
                <span style= 'font-size:10pt;'>*Sales are<br>trending down*</span>"]

  pdata4[description == "This product drives less than 25% of the order total when purchased",
         lab := "<span style= 'font-size:12pt;'>**Secondary Item**</span><br>
                <span style= 'font-size:10pt;'>*Products are added<br>on to orders*</span>"]

  pdata4[description == "Product isn't a new menu offering, nor is it a long-term menu item",
         lab := "<span style= 'font-size:12pt;'>**Average History**</span><br>
                <span style= 'font-size:10pt;'>*Product not new<br>nor a menu classic*</span>"]

  pdata4[description == "Not enough sales days to evaluate recent trends",
         lab := "<span style= 'font-size:12pt;'>**Not enough data**</span><br>
                <span style= 'font-size:10pt;'>*Unable to model<br>sales trend*</span>"]

  pdata4[description == "This product drives the majority of sales per order when purchased",
         lab := "<span style= 'font-size:12pt;'>**Primary Product**</span><br>
                <span style= 'font-size:10pt;'>*Product drives the<br>majority of sales<br>per order*</span>"]


  list(
    pdata0 = pdata0,
    pdata1 = pdata1,
    pdata2 = pdata2,
    pdata3 = pdata3,
    pdata4 = pdata4,
    data = list(rec = rec)
  )
}

