#' Sku Plots
#'
#' @param oid org uuid
#' @param sid store uuid
#' @param b0 plot base layer
#' @param salesDT velocity dataset
#' @param url image url
#' @param sku product sku
#' @param outdir directory to store images locally (defaults to images/products)
#' @param p internal, plot base layer
#' @param labDT internal, contains plot labels
#' @param impact_day day to draw the impact lines on plot
#' @param internal used internally for testing
#'
#' @import data.table
#' @importFrom fs dir_create
#' @importFrom stringr str_glue
#' @importFrom rdscore dbGetVtDaily
#'
#' @name sku-plots
NULL


#' @describeIn sku-plots Get image of a sku with url, process and save locally. Used in plots
process_image <- function(url, sku, outdir = "images/products") {
  if (!requireNamespace("bslib", quietly = TRUE)) {
    stop("'magick' not available", call. = FALSE)
  }
  dir_path <- fs::dir_create("images/products", recurse = TRUE)
  img_path <- stringr::str_glue("{dir_path}/{sku}.jpeg")
  magick::image_read(url) |>
    magick::image_resize("200x200") |>
    magick::image_crop("185x185") |>
    magick::image_trim(20) |>
    magick::image_background("#FFF", flatten = TRUE) |>
    magick::image_convert(format = "jpeg") |>
    magick::image_write(path = img_path)
}


#' @describeIn sku-plots plot base layer
plot_base_layer <- function(salesDT) {
  p_theme <- function() {
    ggthemes::theme_hc() +
      ggplot2::theme(
        plot.title.position = "plot",
        axis.title = ggplot2::element_blank(),
        legend.position = "right",
        legend.direction = "vertical",
        legend.justification = c(1, 1)
      )
  }

  b0 <- ggplot2::ggplot(salesDT, ggplot2::aes(x = wts)) +
    ggplot2::geom_ribbon(ggplot2::aes(ymin = c_sales_actual, ymax = c_sales_est, fill = "opportunity"), alpha = .7) +
    ggplot2::geom_segment(ggplot2::aes(xend = wts, y = c_sales_actual, yend = c_sales_est), linetype = "dotted") +
    ggplot2::geom_point(ggplot2::aes(y = c_sales_est, color = "estimated"), shape = 18) +
    ggplot2::geom_line(ggplot2::aes(y = c_sales_est, color = "estimated")) +
    ggplot2::geom_point(ggplot2::aes(y = c_sales_actual, color = "actual", shape = !has_sales), size = 2) +
    ggplot2::scale_y_continuous(name = NULL, labels = scales::dollar_format(accuracy = 1)) +
    ggplot2::scale_x_continuous(name = NULL, labels = scales::percent_format(accuracy = 1)) +
    ggplot2::scale_color_manual(
      name = "Cumulative Sales",
      values = c("#e23a2c", "#638ffb"),
      labels = c("Actual", "Expected")
    ) +
    ggplot2::scale_fill_manual(
      name = "Stockout Impact",
      values = c("#69cf48"),
      labels = "Lost Sales Dollars"
    ) +
    ggplot2::scale_shape_manual(
      name = "Stock Disruption",
      values = c(16, 4),
      labels = c("No Stockout", "Has Stockout")
    ) +
    ggplot2::guides(
      color = ggplot2::guide_legend(order = 1),
      shape = ggplot2::guide_legend(order = 2),
      fill = ggplot2::guide_legend(order = 3)
    ) +
    p_theme() +
    ggplot2::labs(
      title = "<b>Cumulative Total Product Sales in Prior 90 Day Period</b><br>
    <span style= 'font-size:10pt;'>*With Stockouts (Actual) vs No Stockouts (Estimate)*</span>",
    caption = "*x-axis is % of period completed (i.e. 50% = 45 days of sales)*"
    ) +
    ggplot2::theme(
      plot.title = ggtext::element_textbox_simple(
        size = 13,
        lineheight = 1,
        padding = ggplot2::margin(5.5, 5.5, 5.5, 5.5),
        margin = ggplot2::margin(0, 0, 5.5, 0),
        fill = "cornsilk"
      ),

      plot.caption = ggtext::element_markdown(
        size = 10,
        lineheight = 1,
        hjust = 1,
        padding = ggplot2::margin(5.5, 5.5, 5.5, 5.5),
        margin = ggplot2::margin(0, 0, 5.5, 0),
        fill = "#cae1ff",
        color = "#3d4c57"
      ),
      plot.caption.position = "plot"
    )
  ##
  ## Add image if available
  ##
  img_path <- tryCatch({
    process_image(salesDT[1, image_url], salesDT[1, product_sku])
  }, error = function(c) {
    warning(str_glue("Unable to process image for sku {salesDT[1, product_sku]}"), call. = FALSE)
    return(NULL)
  })

  if (!is.null(img_path)) {
    b0 <- b0 +
      ggtext::geom_richtext(ggplot2::aes(x = 1, y = 0),
                    label = str_glue("<img src='{img_path}' width='125'/>"),
                    hjust = -.3,
                    vjust = 0,
                    color = NA) +
      ggplot2::coord_cartesian(xlim = c(0,1), clip = "off")
  }
  return(b0)
}


#' @describeIn sku-plots called by functions plot_(mid|end)_period
add_guide <- function(p, labDT, impact_day) {
  ax <- labDT[, wts]
  tot_impact <- labDT[, scales::dollar(c_sales_est - c_sales_actual, accuracy = 1)]
  p +
    ggplot2::geom_linerange(
      data = labDT,
      ggplot2::aes(xmin = 0, xmax = ax, y = c_sales_est)
    ) +
    ggplot2::geom_linerange(
      data = labDT,
      ggplot2::aes(xmin = 0, xmax = ax, y = c_sales_actual)
    ) +
    ggplot2::geom_linerange(
      data = labDT,
      ggplot2::aes(x = ax, ymin = 0, ymax = c_sales_est)
    ) +
    ggplot2::geom_segment(
      data = labDT,
      ggplot2::aes(x = 0, xend = 0, y = c_sales_actual, yend = c_sales_est),
      arrow = ggplot2::arrow(length = ggplot2::unit(0.15, "inches"), ends = "both", type = "closed"),
      arrow.fill = "#ffa412"
    ) +
    ggtext::geom_textbox(
      data = labDT[, lab_y_est := stringr::str_glue(
        "*y<sub>estimate</sub>= {scales::dollar(c_sales_est, accuracy = 1)}*",
        .envir = .SD
      )],
      ggplot2::aes(x = 0, y = c_sales_est + 1, label = lab_y_est),
      hjust = 0,
      vjust = -0.05,
      box.color = NA,
      fill = NA,
      width = NULL
    ) +
    ggtext::geom_textbox(
      data = labDT[, lab_y_act := stringr::str_glue(
        "*y<sub>actual</sub>= {scales::dollar(c_sales_actual, accuracy = 1)}*",
        .envir = .SD
      )],
      ggplot2::aes(x = 0, y = c_sales_actual, label = lab_y_act),
      hjust = 0,
      vjust = 1,
      box.color = NA,
      fill = NA,
      width = NULL
    ) +
    ggtext::geom_textbox(
      data = labDT[, lab_x := stringr::str_glue("*x = {impact_day}*")],
      ggplot2::aes(x = ax, y = 0, label = lab_x),
      hjust = 1,
      vjust = 0,
      box.color = NA,
      fill = NA,
      width = NULL
    ) +
    ggtext::geom_textbox(
      data = labDT,
      ggplot2::aes(x = 0, y = (c_sales_est + c_sales_actual) * .5),
      label = stringr::str_glue("<span><b>Difference</b>=
                     **<span style = 'color:#00a651;'>{tot_impact}</span></span>**<br>
                     (*y<sub>estimate</sub> - y<sub>actual</sub>*)"),
      hjust = -.05,
      box.color = "#ffa412",
      lineheight = 1,
      fill = "cornsilk"
    ) +
    ggplot2::theme(
      plot.title = ggtext::element_textbox_simple(
        size = 13,
        lineheight = 1,
        padding = ggplot2::margin(5.5, 5.5, 5.5, 5.5),
        margin = ggplot2::margin(0, 0, 5.5, 0),
        fill = "cornsilk"
      )
    )
}



#' @describeIn sku-plots plot with guides at day in period
plot_period_impact <- function(oid, sid, sku, impact_day, internal = FALSE) {

  if (internal) {
    salesDT <- salesDT[product_sku == sku]
  } else {
    salesDT <- rdscore::dbGetVtDaily(oid, sid, sku)
  }

  ## adjust impact day based on how many days in the period for product
  impact_day <- round((impact_day / 90) * salesDT[, .N], 0)

  ## If no sales velocity data, return an empty plot with a message
  if (nrow(salesDT) == 0) {
    p <- ggplot2::ggplot() +
      ggplot2::geom_line(ggplot2::aes(1:10, 1:10), color = "#acacac") +
      ggplot2::geom_line(ggplot2::aes(1:10, 10:1), color = "#acacac") +
      ggplot2::labs(
        title = "<b>No Data Found</b><br><br><span>This product did not have
      enough data to meet the confidence threshold we determined appropriate to show
      this insight. Most likely this product has limited or no sales data in the past 90 days.
      If you have any questions, or this is not expected, reach out on Slack or email
      and let me the org, store, and sku.",
      caption = NULL
      ) +
      ggplot2::theme(
        axis.text = ggplot2::element_blank(),
        axis.ticks = ggplot2::element_blank(),
        axis.line = ggplot2::element_blank(),
        axis.title = ggplot2::element_blank(),
        plot.title = ggtext::element_textbox_simple(
          lineheight = 1,
          padding = ggplot2::margin(5.5, 5.5, 5.5, 5.5),
          margin = ggplot2::margin(0, 0, 5.5, 0),
          fill = "#e99997"
        ),
        panel.ontop = FALSE
      )
    return(p)
  }

  ## get plot base layer
  b0 <- plot_base_layer(salesDT)


  ## calculate out of stock rate at day
  oos_rate <- salesDT[, 1 - cumsum(has_sales) / .I][impact_day]

  ## if product is either barely in stock or barely out of stock, return a plot without impact
  if (oos_rate > .80) {
    p <- b0 +
      ggplot2::labs(
        subtitle = stringr::str_glue(
          "<b>Warning</b><br><span style= 'font-face:bold;'>Product's out of stock rate is too
      high for useful prediction. Currently product **has been out of stock
      for {scales::percent(oos_rate, accuracy = 1)} of the last 90 days.**</span>"
        )
      ) +
      ggplot2::theme(
        plot.subtitle = ggtext::element_textbox_simple(
          size = 10,
          lineheight = 1,
          padding = ggplot2::margin(5.5, 5.5, 5.5, 5.5),
          margin = ggplot2::margin(0, 0, 5.5, 0),
          fill = "#e99997"
        )
      )
  } else if (oos_rate < .20) {
    p <- b0 +
      ggplot2::labs(
        subtitle = stringr::str_glue(
          "<b>Note</b><br><span style= 'font-face:bold;'>Product's out of stock rate is very
        low. This product has **only been out of stock for
        {scales::percent(oos_rate, accuracy = 1)} of the last 90 days. Maintain current rate
        for this product to yield optimal revenue.**</span>"
        )
      ) +
      ggplot2::theme(
        plot.subtitle = ggtext::element_textbox_simple(
          size = 10,
          lineheight = 1,
          padding = ggplot2::margin(5.5, 5.5, 5.5, 5.5),
          margin = ggplot2::margin(0, 0, 5.5, 0),
          fill = "#97dd7f"
        )
      )
  } else {

    ## else return a plot with the predicted impact
    labXX <- salesDT[impact_day, .(wts, c_sales_est, c_sales_actual)]

    tot_impact_XX <- labXX[, scales::dollar(c_sales_est - c_sales_actual, accuracy = 1)]
    pct_impact_XX <- labXX[, scales::percent(c_sales_actual / c_sales_est, accuracy = 1)]

    p <- add_guide(b0, labDT = labXX, impact_day) +
      ggplot2::labs(
        title = stringr::str_glue("<b>Impact of Stockouts on Total Product Sales</b><br>
    <span style = 'font-size:10pt'>
    Expecting **<span style = 'color:#00a651;'>+{tot_impact_XX}</span>**
    in additional revenue generated **by day {impact_day} without stockout events**<br>
    This means revenues for this product are **<span style = 'color:red;'>{pct_impact_XX}</span>**
    of the prediction **but for historical stockouts**</span>"
        ))
  }

  ## Save plot as rds object
  saveRDS(p, stringr::str_glue("p_{sku}_{impact_day}.rds"))

  ## save plot as high res image
  x <- ggplot2::ggsave(
    filename = stringr::str_glue("p_{sku}_{impact_day}.png"),
    plot = p,
    width = 3000,
    height = 2500,
    dpi = "print",
    units = "px",
    bg = NULL
  )
  print(x) ## path to image

  ## return the plot
  return(p)
}


#' @describeIn sku-plots plot with guides at halfway
plot_mid_period <- function(b0, salesDT) {

  lab50 <- salesDT[wts > .49 & wts < .51, .(
    wts = .5,
    c_sales_est = mean(c_sales_est),
    c_sales_actual = mean(c_sales_actual)
  )]

  tot_impact_50 <- lab50[, scales::dollar(c_sales_est - c_sales_actual, accuracy = 1)]
  pct_impact_50 <- lab50[, scales::percent(c_sales_actual / c_sales_est, accuracy = 1)]

  add_guide(p = b0, labDT = lab50, impact_day = 45) +
    ggplot2::labs(
      title = stringr::str_glue("<b>Impact of Stockouts on Total Product Sales</b><br>
    <span style = 'font-size:10pt'>
    Expecting **<span style = 'color:#00a651;'>+{tot_impact_50}</span>**
    in additional revenue generated by day 45 **without stockout events**<br>
    This means revenues for this product are **<span style = 'color:red;'>{pct_impact_50}</span>**
    of the prediction **but for historical stockouts**</span>"
      ))
}


#' @describeIn sku-plots plot with guides at period end
plot_end_period <- function(b0, salesDT) {

  lab100 <- salesDT[wts > .98 & wts < 1, .(
    wts = 1,
    c_sales_est = mean(c_sales_est),
    c_sales_actual = mean(c_sales_actual)
  )]

  tot_impact_100 <- lab100[, scales::dollar(c_sales_est - c_sales_actual, accuracy = 1)]
  pct_impact_100 <- lab100[, scales::percent(c_sales_actual / c_sales_est, accuracy = 1)]

  add_guide(p = b0, labDT = lab100, impact_day = 90) +
    ggplot2::labs(
      title = stringr::str_glue("<b>Impact of Stockouts on Total Product Sales</b><br>
    <span style = 'font-size:10pt'>
    Expecting **<span style = 'color:#00a651;'>+{tot_impact_100}</span>**
    in additional revenue generated by day 90 **without stockout events**<br>
    This means revenues for this product are **<span style = 'color:red;'>{pct_impact_100}</span>**
    of the prediction **but for historical stockouts**</span>"
      ))
}



