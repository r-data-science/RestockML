#' Ui elements of MLTuning App
#'
#' @param width width
#' @param inline default TRUE
#' @param .colors hca colors
#'
#' @import shiny
#' @importFrom sass font_link
#' @importFrom bslib bs_theme
#' @importFrom datamods select_group_ui
#' @importFrom shinyWidgets panel statiCard noUiSliderInput wNumbFormat materialSwitch dropMenu actionBttn
#' @importFrom shinycssloaders withSpinner
#'
#' @name mltuning-ui
NULL


#' @describeIn mltuning-ui bootstrap theme for app
.ui_bootstrap_theme <- function() {
  sor <- sass::font_link("Sora", href = "https://fonts.googleapis.com/css2?family=Sora")
  lex <- sass::font_link("Lexend", href = "https://fonts.googleapis.com/css2?family=Lexend")
  bslib::bs_theme(
    version = 5,
    bg = "#041E39",
    fg = "#E0ECF9",
    primary = "#187dd4",
    secondary = "#ED9100",
    success = "#00A651",
    info = "#fff573",
    warning = "#7d3be8",
    danger = "#DB14BF",
    bootswatch = "materia",
    base_font = lex,
    heading_font = sor,
    code_font = lex
  )
}


#' @describeIn mltuning-ui statistics panel
.ui_selection_filters <- function(width = 12, inline = TRUE) {
  column(
    width = width,
    shinyWidgets::panel(
      status = "warning",
      heading = datamods::select_group_ui(
        id = "filters",
        params = list(
          org = list(
            inputId = "org",
            placeholder = "All Orgs",
            label = "Choose Org (Required)",
            multiple = FALSE,
            selectedValue = "medithrive"

          ),
          store = list(
            inputId = "store",
            placeholder = "All Stores",
            label = "Choose Store (Required)",
            multiple = FALSE
          ),
          category3 = list(
            inputId = "category3",
            placeholder = "All Categories",
            label = "Filter Categories (Optional)",
            multiple = TRUE
          ),
          brand_name = list(
            inputId = "brand_name",
            placeholder = "All Brands",
            label = "Filter Brands (Optional)",
            multiple = TRUE
          )
        ),
        vs_args = list(
          noOfDisplayValues = 2,
          hideClearButton = FALSE,
          search = FALSE
        ),
        btn_reset_label = NULL,
        inline = inline
      )
    )
  )
}


#' @describeIn mltuning-ui statistics panel
.ui_selection_stats <- function(width = 12, .colors) {
  column(
    width = width,
    fluidRow(
      column(
        width = 3,
        shinyWidgets::statiCard(
          value = NULL,
          subtitle = "Products in Selection",
          icon = icon("joint"),
          left = TRUE,
          background = "#73bffb",
          color = .colors$bg,
          duration = 0,
          animate = FALSE,
          id = "stat_skus"
        )
      ),
      column(
        width = 3,
        shinyWidgets::statiCard(
          value = NULL,
          subtitle = "Brands in Selection",
          icon = icon("cannabis"),
          left = TRUE,
          background = "#73bffb",
          color = .colors$bg,
          duration = 0,
          animate = FALSE,
          id = "stat_brands"
        )
      ),
      column(
        width = 3,
        shinyWidgets::statiCard(
          value = NULL,
          subtitle = "90-day Total Sales",
          icon = icon("magnifying-glass-dollar"),
          left = TRUE,
          background = "#73bffb",
          color = .colors$bg,
          animate = FALSE,
          id = "stat_sales"
        )
      ),
      column(
        width = 3,
        shinyWidgets::statiCard(
          value = NULL,
          subtitle = "90-Day Total Units Sold",
          icon = icon("boxes"),
          left = TRUE,
          background = "#73bffb",
          color = .colors$bg,
          animate = FALSE,
          id = "stat_units"
        )
      )
    )
  )
}


#' @describeIn mltuning-ui model diagnostic plot panel
.ui_model_plot_panel <- function(width = 12) {
  column(
    width = width,
    fluidRow(
      column(
        width = 6,
        shinyWidgets::panel(shinycssloaders::withSpinner(plotOutput("plot_0", width = "100%", height = "675px" )), footer = "Diagnostic 0")
      ),
      column(
        width = 6,
        shinyWidgets::panel(shinycssloaders::withSpinner(plotOutput("plot_1", width = "100%", height = "675px")), footer = "Diagnostic 1")
      )
    ),
    fluidRow(
      column(
        width = 5,
        shinyWidgets::panel(shinycssloaders::withSpinner(plotOutput("plot_2", width = "100%", height = "1500px")), footer = "Diagnostic 2")
      ),
      column(
        width = 7,
        shinyWidgets::panel(shinycssloaders::withSpinner(plotOutput("plot_4", width = "100%", height = "1500px")), footer = "Diagnostic 4")
      )
    ),
    fluidRow(
      column(
        width = 12,
        shinyWidgets::panel(shinycssloaders::withSpinner(plotOutput("plot_3", width = "100%", height = "800px")), footer = "Diagnostic 3")
      )
    )
  )
}


#' @describeIn mltuning-ui model inputs panel
.ui_model_inputs_panel <- function() {
  panel(
    column(
      width = 12,
      fluidRow(
        .slider_model_sales(width = "20%", inline = TRUE),
        .slider_model_stock(width = "20%", inline = TRUE),
        .slider_price_qrtls(width = "20%", inline = TRUE),
        .slider_product_cls(width = "20%", inline = TRUE),
        .slider_menu_period(width = "20%", inline = TRUE)
      )
    ),
    footer = fluidRow(

      column(width = 4, .toggle_model_ttest(width = "150px", inline = TRUE)),
      column(
        width = 2,
        offset = 3,
        shinyWidgets::actionBttn(
          inputId = "btn_run",
          color = "warning",
          label = "Run Model",
          size = "xs",
          style = "minimal",
          block = TRUE
        )
      ),
      column(
        width = 2,
        shinyWidgets::actionBttn(
          inputId = "btn_post",
          color = "warning",
          label = "Create Report",
          size = "xs",
          style = "minimal",
          block = TRUE
        )
      ),
      column(
        width = 1,
        shinyWidgets::dropMenu(
          shinyWidgets::actionBttn("btn_param_drop",
                     icon = icon("gear"),
                     color = "primary",
                     size = "xs",
                     style = "jelly",
                     block = TRUE),
          shinyWidgets::actionBttn("btn_save", label = "Save Params", size = "xs", style = "fill"),
          shinyWidgets::actionBttn("btn_load", label = "Load Stored", size = "xs", style = "fill"),
          shinyWidgets::actionBttn("btn_reset", label = "Reset to Default", size = "xs", style = "fill"),
          placement = "bottom-end",
          padding = 1,
          maxWidth = "600px"
        )
      )
    )
  )
}


#' @describeIn mltuning-ui slider
.slider_model_sales <- function(width = "100%", inline = FALSE) {
  shinyWidgets::noUiSliderInput(
    inputId = "sli_trend_pval_conf",
    label = HTML("<b><i>Sales Trend</i></b><br><i>Conf-Level & P-Value</i>"),
    min = 0,
    max = 100,
    direction = "rtl",
    step = 1,
    padding = 0,
    margin = 40,
    value = c(5, 85),
    range = list(
      "min" = list(0),
      "30%" = list(5, 1),
      "70%" = list(85, 5),
      "max" = list(100, 5)
    ),
    color = c("#a98bfb"),
    connect = c(FALSE, TRUE, FALSE),
    format = shinyWidgets::wNumbFormat(decimals = 0, suffix = "%"),
    tooltips = TRUE,
    behaviour = c("tap", "drag"),
    orientation = "horizontal",
    height = "22px",
    width = width,
    inline = inline
  )
}


#' @describeIn mltuning-ui slider
.slider_model_stock <- function(width = "100%", inline = FALSE) {
  shinyWidgets::noUiSliderInput(
    inputId = "sli_stock_pval_conf",
    label = HTML("<b><i>Supply Risk</i></b><br><i>Conf-Level & P-Value</i>"),
    min = 0,
    max = 100,
    direction = "rtl",
    step = 1,
    padding = 0,
    margin = 40,
    value = c(5, 85),
    range = list(
      "min" = list(0),
      "30%" = list(5, 1),
      "70%" = list(85, 5),
      "max" = list(100, 5)
    ),
    color = c("#a98bfb"),
    connect = c(FALSE, TRUE, FALSE),
    format = shinyWidgets::wNumbFormat(decimals = 0, suffix = "%"),
    tooltips = TRUE,
    behaviour = c("tap", "drag"),
    orientation = "horizontal",
    height = "22px",
    width = width,
    inline = inline
  )
}


#' @describeIn mltuning-ui slider
.slider_price_qrtls <- function(width = "100%", inline = FALSE) {
  shinyWidgets::noUiSliderInput(
    inputId = "sli_ppql_ppqh",
    label = HTML("<b><i>Price Quantiles</i></b><br><i>High vs Low</i>"),
    min = 0,
    max = 100,
    padding = 5,
    direction = "rtl",
    step = 1,
    margin = 30,
    value = c(20, 80),
    range = list(
      "min" = list(0),
      "30%" = list(20, 1),
      "70%" = list(80, 5),
      "max" = list(100, 5)
    ),
    color = c("#a98bfb"),
    connect = c(TRUE, FALSE, TRUE),
    format = shinyWidgets::wNumbFormat(decimals = 0, suffix = "th"),
    tooltips = TRUE,
    behaviour = c("tap", "drag"),
    orientation = "horizontal",
    height = "22px",
    width = width,
    inline = inline
  )
}


#' @describeIn mltuning-ui slider
.slider_product_cls <- function(width = "100%", inline = FALSE) {
  shinyWidgets::noUiSliderInput(
    inputId = "sli_secd_prim",
    label = HTML("<b><i>Primary vs Secondary</i></b><br><i>Share of Order</i>"),
    min = 0,
    max = 75,
    direction = "rtl",
    step = 1,
    padding = 5,
    margin = 20,
    value = c(20, 45),
    range = list(
      "min" = list(0),
      "30%" = list(20, 1),
      "70%" = list(45, 5),
      "max" = list(75, 5)
    ),
    color = c("#a98bfb"),
    connect = c(TRUE, FALSE, TRUE),
    format = shinyWidgets::wNumbFormat(decimals = 0, suffix = "%"),
    tooltips = TRUE,
    behaviour = c("tap", "drag"),
    orientation = "horizontal",
    height = "22px",
    width = width,
    inline = inline
  )
}


#' @describeIn mltuning-ui slider
.slider_menu_period <- function(width = "100%", inline = FALSE) {
  shinyWidgets::noUiSliderInput(
    inputId = "sli_npom_ltmi",
    label = HTML("<b><i>Classic vs New</i></b><br><i>Days on Menu</i>"),
    min = 0,
    max = 360,
    padding = 4,
    margin = 60,
    direction = "rtl",
    step = 1,
    range = list(
      "min" = list(0),
      "30%" = list(14, 1),
      "70%" = list(182, 10),
      "max" = list(360, 10)
    ),
    value = c(14, 182),
    color = c("#a98bfb"),
    connect = c(TRUE, FALSE, TRUE),
    format = shinyWidgets::wNumbFormat(decimals = 0, suffix = " days"),
    tooltips = TRUE,
    behaviour = c("tap", "drag"),
    orientation = "horizontal",
    height = "22px",
    width = width,
    inline = inline
  )
}


#' @describeIn mltuning-ui ml toggle
.toggle_model_ttest <- function(width = "150px", inline = TRUE) {
  fluidRow(
    shinyWidgets::materialSwitch(
      inputId = "sw_poolvar",
      label = "Pool Variance",
      width = width,
      right = TRUE,
      value = TRUE,
      inline = inline
    ),
    shinyWidgets::materialSwitch(
      inputId = "sw_pairttest",
      label = "Paired T-Test",
      width = width,
      right = TRUE,
      value = FALSE,
      inline = inline
    )
  )
}


