library(bslib)
library(data.table)
library(datamods)
library(fs)
library(ggplot2)
library(ggtext)
library(scales)
library(shiny)
library(shinyWidgets)
library(shinycssloaders)
library(stringr)
library(rdscore)
library(rdsapps)
library(rdstools)
library(rpgconn)
library(waiter)


server_mltune <- function() {
  function(input, output, session) {
    .colors <- getMyColors()

    # create the waiter
    w <- Waiter$new(html = tagList(spin_pulsar(), br(), "Initializing..."), color = .colors$bg)

    index <- getMlTuningIndex()

    ## Register callback to delete output dir on session end
    if (getShinyOption("clean_outputs", default = FALSE)) {
      onStop(cleanOutDir, session = session)
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
      args <- getDefaultParams()
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
      n <- saveParams(r_org_uuid(), r_store_uuid(), r_args())
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
      args <- loadParams(req(r_org_uuid()), req(r_store_uuid()))
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
      saveContext(oid, sid, skus_data, ml_args)

      w$update(html = tagList(spin_pulsar(), br(), "Running recommendations model..."))
      results <- execMlRestock(oid, sid, skus, ml_args)

      w$update(html = tagList(spin_pulsar(), br(), "Running model diagnostics..."))
      if (getShinyOption("save_plotdata", TRUE))
        savePlotDatasets(results)

      p0 <- plotDiag0(pdata0 = results[[1]], .colors)
      p1 <- plotDiag1(pdata1 = results[[2]], .colors)
      p2 <- plotDiag2(pdata2 = results[[3]], .colors)
      p3 <- plotDiag3(pdata3 = results[[4]], .colors)
      p4 <- plotDiag4(pdata4 = results[[5]], .colors)

      w$update(html = tagList(spin_pulsar(), br(), "Finalizing output plots..."))
      saveGGPlots(p0, p1, p2, p3, p4)

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
      scenario <- buildScenario()

      if (!is.null(scenario)) {
        w$update(html = tagList(spin_pulsar(), br(), "Generating Report Document..."))

        # Get org and store name for the report
        res <- generateReport(scenario[1, org], scenario[1, store])

        ## get the link to the generated content
        report_link <- a("Download Report", href = res$url, target = "_blank")

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

ui_mltune <- function() {
  fluidPage(
    theme = getBSTheme(),
    useWaiter(),
    br(),
    getSelectionPanel(),

    panel(
      column(
        width = 12,
        getSlidersRow()
      ),
      footer = fluidRow(

        column(width = 4, getMlToggle()),
        column(
          width = 2,
          offset = 3,
          actionBttn(
            inputId = "btn_run",
            color = "warning",
            label = "Generate Results",
            size = "xs",
            style = "minimal",
            block = TRUE
          )
        ),
        column(
          width = 2,
          actionBttn(
            inputId = "btn_post",
            color = "warning",
            label = "Publish Scenario",
            size = "xs",
            style = "minimal",
            block = TRUE
          )
        ),
        column(
          width = 1,
          dropMenu(
            actionBttn("btn_param_drop",
                       icon = icon("gear"),
                       color = "primary",
                       size = "xs",
                       style = "jelly",
                       block = TRUE),
            actionBttn("btn_save", label = "Save Params", size = "xs", style = "fill"),
            actionBttn("btn_load", label = "Load Stored", size = "xs", style = "fill"),
            actionBttn("btn_reset", label = "Reset to Default", size = "xs", style = "fill"),
            placement = "bottom-end",
            padding = 1,
            maxWidth = "600px"
          )
        )
      )
    ),
    getMlPlotPanel()
  )
}

# Init output directory
createOutDir()

shinyApp(ui_mltune(), server_mltune())
