#' Product Recommendations Model Tuning
#'
#' @param SAVE_PLOTDATA Default is FALSE. Whether to keep plot input datasets generated during app session. Useful for plot development.
#' @param CLEAN_OUTPUTS Default is False. Whether to delete the session output directory. Useful for debuging
#'
#' @import shiny
#' @import waiter
#' @importFrom shinyWidgets updateStatiCard updateMaterialSwitch updateNoUiSliderInput show_alert
#' @importFrom shiny runApp shinyOptions
#' @importFrom rdstools log_suc
#' @importFrom fs file_exists path
#' @importFrom datamods select_group_server
#'
#' @name run-app
NULL

#' @describeIn run-app run Recommendations Model Tuning App
#' @export
runExplorePRM <- function(SAVE_PLOTDATA = FALSE, CLEAN_OUTPUTS = TRUE) {
  create_session_dir() # Init output directory

  ## Set options for this app launch
  shiny::shinyOptions(
    save_plotdata = SAVE_PLOTDATA,
    clean_outputs = CLEAN_OUTPUTS
  )

  ## Set options for this app launch
  on.exit(shiny::shinyOptions(
    save_plotdata = NULL,
    clean_outputs = NULL,
    appDir = NULL
  ))

  rdstools::log_inf("...Launching App")

  writeLines(
    text = "shiny::shinyApp(rdsapps:::ui_prm(), rdsapps:::server_prm())",
    fs::path(get_app_dir(), "app.R")
  )
  # app <- shinyApp(ui_prm(), server_prm())
  shiny::runApp(appDir = get_app_dir(), display.mode = "normal")
}


#' @describeIn run-app server function for app
server_prm <- function() {
  function(input, output, session) {

    .colors <- get_app_colors()

    # create the waiter
    w <- Waiter$new(html = tagList(spin_pulsar(), br(), "Initializing..."), color = .colors$bg)

    index <- get_app_index()

    ## Register callback to delete output dir on session end
    if (getShinyOption("clean_outputs", default = FALSE)) {
      onStop(clean_session_dir, session = session)
    }

    ## This dataset is reactively filtered by the user and contains SKUs to run recs
    rec_args <- select_group_server(
      id = "filters",
      data_r = index,
      vars_r = c("org", "store", "category3", "brand_name", "product_sku")
    )

    ## Get model input parameters and store as reactive object
    r_args <- reactive({
      list(
        ml_trend_conf = input$sli_trend_pval_conf[2], ## model confidence
        ml_trend_pval = input$sli_trend_pval_conf[1], ## model pvalue
        ml_stock_conf = input$sli_stock_pval_conf[2], ## model confidence
        ml_stock_pval = input$sli_stock_pval_conf[1], ## model pvalue
        ml_pair_ttest = input$sw_pairttest,           ## Pair the ttest
        ml_pooled_var = input$sw_poolvar,             ## Pool the variance
        ml_ltmi = input$sli_npom_ltmi[2],             ## Long term product days
        ml_npom = input$sli_npom_ltmi[1],             ## New menu item days
        ml_prim = input$sli_secd_prim[2],             ## Primary product threshold
        ml_secd = input$sli_secd_prim[1],             ## Secondary product threshold
        ml_ppql = input$sli_ppql_ppqh[1],             ## product price quantile low
        ml_ppqh = input$sli_ppql_ppqh[2]              ## product price quantile high
      )
    })

    ## Update the Stats Cards on new filtering of dataset
    observe({
      updateStatiCard(
        id = "stat_skus",
        value = scales::comma(as.integer(nrow(rec_args()))),
        duration = 100
      )
      updateStatiCard(
        id = "stat_brands",
        value = scales::comma(as.integer(length(unique(rec_args()$brand_name)))),
        duration = 100
      )
      updateStatiCard(
        id = "stat_sales",
        value = scales::dollar(as.integer(sum(rec_args()$tot_sales))),
        duration = 100
      )
      updateStatiCard(
        id = "stat_units",
        value = scales::comma(as.integer(sum(rec_args()$units_sold))),
        duration = 100
      )
    })

    ## Save Org, Store, and Skus into reactive objects
    r_org_uuid <- reactive({
      as.data.table(rec_args())[org == req(input$`filters-org`), org_uuid[1]]
    })
    r_store_uuid <- reactive({
      as.data.table(rec_args())[store == req(input$`filters-store`), store_uuid[1]]
    })
    r_skus <- reactive({
      as.data.table(rec_args())[org_uuid == r_org_uuid() & store_uuid == r_store_uuid(), product_sku]
    })



    ## On click, resent tuning parameters to default values
    observeEvent(input$btn_reset, {
      args <- default_ml_params()

      updateMaterialSwitch(session, "sw_poolvar", value = args$ml_pooled_var)
      updateMaterialSwitch(session, "sw_pairttest", value = args$ml_pair_ttest)
      updateNoUiSliderInput(session, "sli_trend_pval_conf", value = list(args$ml_trend_pval, args$ml_trend_conf))
      updateNoUiSliderInput(session, "sli_stock_pval_conf", value = list(args$ml_stock_pval, args$ml_stock_conf))
      updateNoUiSliderInput(session, "sli_ppql_ppqh", value = list(args$ml_ppql, args$ml_ppqh))
      updateNoUiSliderInput(session, "sli_secd_prim", value = list(args$ml_secd, args$ml_prim))
      updateNoUiSliderInput(session, "sli_npom_ltmi", value = list(args$ml_npom, args$ml_ltmi))
    })

    ## Save Params on Actions
    observeEvent(input$btn_save, {
      n <- save_ml_params(r_org_uuid(), r_store_uuid(), r_args())
      if (n == 1) {
        show_alert(
          title = "Success !!",
          text = "Parameters saved",
          type = "success",
          closeOnClickOutside = TRUE,
          showCloseButton = TRUE
        )
      } else {
        show_alert(
          title = "Error !!",
          text = "Failed to save parameters",
          type = "error",
          closeOnClickOutside = TRUE,
          showCloseButton = TRUE
        )
      }
    })

    ## Load previously stored params on action and update input elements
    observeEvent(input$btn_load, {
      args <- load_ml_params(req(r_org_uuid()), req(r_store_uuid()))

      updateMaterialSwitch(session, "sw_poolvar", value = args$ml_pooled_var)
      updateMaterialSwitch(session, "sw_pairttest", value = args$ml_pair_ttest)
      updateNoUiSliderInput(session, "sli_trend_pval_conf", value = list(args$ml_trend_pval, args$ml_trend_conf))
      updateNoUiSliderInput(session, "sli_stock_pval_conf", value = list(args$ml_stock_pval, args$ml_stock_conf))
      updateNoUiSliderInput(session, "sli_ppql_ppqh", value = list(args$ml_ppql, args$ml_ppqh))
      updateNoUiSliderInput(session, "sli_secd_prim", value = list(args$ml_secd, args$ml_prim))
      updateNoUiSliderInput(session, "sli_npom_ltmi", value = list(args$ml_npom, args$ml_ltmi))

      show_alert(
        title = "Success !!",
        text = "Loaded parameters",
        type = "success",
        closeOnClickOutside = TRUE,
        showCloseButton = TRUE
      )
    })


    ## Run all on action
    r_plots <- eventReactive(input$btn_run, {
      oid <- req(r_org_uuid())
      sid <- req(r_store_uuid())
      skus <- r_skus()
      skus_data <- req(as.data.table(rec_args()))
      ml_args <- req(r_args())

      w$show()

      w$update(html = tagList(spin_pulsar(), br(), "Saving model context..."))
      save_ml_context(oid, sid, skus_data, ml_args)

      w$update(html = tagList(spin_pulsar(), br(), "Running recommendations model..."))
      results <- exec_ml_restock(oid, sid, skus, ml_args)

      w$update(html = tagList(spin_pulsar(), br(), "Running model diagnostics..."))
      if (getShinyOption("save_plotdata", TRUE))
        save_plot_data(results)

      p0 <- plot_diagnostic_0(pdata0 = results[[1]], .colors)
      p1 <- plot_diagnostic_1(pdata1 = results[[2]], .colors)
      p2 <- plot_diagnostic_2(pdata2 = results[[3]], .colors)
      p3 <- plot_diagnostic_3(pdata3 = results[[4]], .colors)
      p4 <- plot_diagnostic_4(pdata4 = results[[5]], .colors)

      w$update(html = tagList(spin_pulsar(), br(), "Finalizing output plots..."))
      save_ggplots(p0, p1, p2, p3, p4)

      w$hide()
      list(p0, p1, p2, p3, p4)
    })

    ## Render Plots
    output$plot_0 <- renderPlot(r_plots()[[1]], res = 85)
    output$plot_1 <- renderPlot(r_plots()[[2]], res = 85)
    output$plot_2 <- renderPlot(r_plots()[[3]], res = 85)
    output$plot_3 <- renderPlot(r_plots()[[4]], res = 85)
    output$plot_4 <- renderPlot(r_plots()[[5]], res = 85)

    # Publish results on action
    observeEvent(input$btn_post, {
      w$show()
      w$update(html = tagList(spin_pulsar(), br(), "Gathering Model Outputs..."))

      ## This will read from the temp outputs and construct the data needed to population report
      scenario <- build_scenario_data()

      if (!is.null(scenario)) {
        w$update(html = tagList(spin_pulsar(), br(), "Generating Report Document..."))

        # Get org and store name for the report
        report_path <- generate_report(scenario[1, org], scenario[1, store])

        ## get the link to the generated content
        report_link <- a("Download Report", href = report_path, download=NA, target = "_blank")

        ## Hide waiter and show success alert containing link
        w$hide()
        show_alert("Document Ready!", report_link, type = "success", html = TRUE)
      } else {

        w$hide()

        show_alert(
          title = "Oops !!",
          text = "Unable to Generate Report. No Results Found...",
          type = "error",
          closeOnClickOutside = TRUE,
          showCloseButton = TRUE
        )
      }
    })
  }
}


#' @describeIn run-app UI function for app
ui_prm <- function() {
  fluidPage(
    theme = .ui_bootstrap_theme(),
    useWaiter(),
    br(),
    panel(
      .ui_selection_filters(width = 12),
      .ui_selection_stats(width = 12, get_app_colors())
    ),
    .ui_model_inputs_panel(),
    .ui_model_plot_panel(width = 12)
  )
}
