#' App Outputs
#'
#' Functions to generate and prepare outputs presented by the package app.
#'
#' @param pdata0 plot dataset
#' @param pdata1 plot dataset
#' @param pdata2 plot dataset
#' @param pdata3 plot dataset
#' @param pdata4 plot dataset
#' @param ptitle plot title
#' @param psubtitle plot subtitle
#'
#' @import ggplot2
#' @import ggtext
#' @import data.table
#' @importFrom stringr str_glue str_replace str_replace_all
#' @importFrom rdstools log_inf
#'
#' @name app-plots
NULL

#' @describeIn app-plots provides the base theme for plots
.plot_theme <- function() {
  .colors <- get_app_colors()
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


#' @describeIn app-plots Style the plot title/subtitle
.plot_title_style <- function(ptitle, psubtitle) {
  .colors <- get_app_colors()
  ggplot2::labs(
    title = stringr::str_glue(
      "<span style= 'font-size:16pt; color:{.colors$fg};'><b>{ptitle}</b></span><br>
        <span style= 'font-size:13pt; color:{.colors$fg};'>*{psubtitle}*</span><br>"
    ))
}


#' @describeIn app-plots diagnostic plot
.plot_diagnostic_0 <- function(pdata0) {
  rdstools::log_inf("...Creating Plot 0")
  .colors <- get_app_colors()
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
    .plot_title_style(ptitle, psubtitle) +
    .plot_theme() +
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


#' @describeIn app-plots diagnostic plot
.plot_diagnostic_1 <- function(pdata1) {
  rdstools::log_inf("...Creating Plot 1")
  .colors <- get_app_colors()
  ptitle <- "Proportion of Recommendation"
  psubtitle <- "By Product Category"
  p1 <- ggplot2::ggplot(pdata1) +
    ggplot2::geom_bar(
      ggplot2::aes(category3, fill = restock),
      stat = "count",
      position = "fill"
    ) +
    .plot_title_style(ptitle, psubtitle) +
    .plot_theme() +
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


#' @describeIn app-plots diagnostic plot
.plot_diagnostic_2 <- function(pdata2) {
  rdstools::log_inf("...Creating Plot 2")
  .colors <- get_app_colors()
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
    .plot_title_style(ptitle, psubtitle) +
    .plot_theme() +
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


#' @describeIn app-plots diagnostic plot
.plot_diagnostic_3 <- function(pdata3) {
  rdstools::log_inf("...Creating Plot 3")
  .colors <- get_app_colors()
  ptitle <- "Proportion of Recommendation"
  psubtitle <- "By Recommendation and Flag Assignments"
  p3 <- ggplot2::ggplot(pdata3) +
    ggplot2::geom_bar(
      ggplot2::aes(value2, fill = restock, alpha = value2, color = value2),
      stat = "count",
      position = "fill"
    ) +
    ggplot2::scale_alpha_manual(values = c(1, .35), guide = "none") +
    ggplot2::scale_color_manual(values = c(.colors$fg, .colors$bg), guide = "none") +
    .plot_title_style(ptitle, psubtitle) +
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
    .plot_theme() +
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


#' @describeIn app-plots diagnostic plot
.plot_diagnostic_4 <- function(pdata4) {
  rdstools::log_inf("...Creating Plot 4")
  .colors <- get_app_colors()
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
    .plot_theme() +
    .plot_title_style(ptitle, psubtitle) +
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



