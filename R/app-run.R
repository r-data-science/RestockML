#' Run App
#'
#' Functions to run the package shiny app
#'
#' @param ... additional args for runApp or options to pass to shinyApp
#' @param w waiter object from app
#' @param msg message for waiter progress
#' @param oid org uuid from app
#' @param sid store uuid from app
#' @param index table of filtered rows from app
#' @param ml_args list of ml args from app
#' @param session shiny session object
#' @param test.mode runApp in test mode. Default FALSE
#'
#' @import shiny
#' @import waiter
#' @importFrom shinyWidgets updateStatiCard updateMaterialSwitch updateNoUiSliderInput show_alert radioGroupButtons sendSweetAlert
#' @importFrom shiny runApp shinyOptions
#' @importFrom rdstools log_suc
#' @importFrom fs file_exists path
#' @importFrom datamods select_group_server
#' @importFrom testthat is_testing
#'
#' @name app-run
NULL

#' @describeIn app-run returns app object for subsequent execution
#' @export
runExplorePRM <- function(test.mode = FALSE, ...) {
  runApp(
    test.mode = test.mode,
    appDir = fs::path_package("rdsapps", "apps"),
    ...
  )
}

#' @describeIn app-run returns app object for subsequent execution
#' @export
appExplorePRM <- function(...) {
  shiny::shinyApp(
    ui = .app_ui(),
    server = .app_server(),
    onStart = create_session_dir,
    options = list(...)
  )
}


#' @describeIn app-run UI function for app
.app_ui <- function() {
  fluidPage(
    theme = .ui_bootstrap_theme(),
    useWaiter(),
    br(),
    panel(
      .ui_selection_filters(),
      .ui_selection_stats()
    ),
    .ui_model_inputs_panel(),
    .ui_model_plot_panel()
  )
}


#' @describeIn app-run server function for app
.app_server <- function() {
  function(input, output, session) {
    w <- new_waiter()

    ## Data filtered by the user contains org/store products
    r_index <- reactive_app_index(db_app_index_anon(), session)

    ## Update the Stats Cards on filtered index
    observe(update_stat_cards(r_index(), session))

    ## Get model input params and store as reactive object
    r_ml_args <- reactive(list(
      ml_trend_conf = input$sli_trend_pval_conf[2], ## model confidence
      ml_trend_pval = input$sli_trend_pval_conf[1], ## model pvalue
      ml_stock_conf = input$sli_stock_pval_conf[2], ## model confidence
      ml_stock_pval = input$sli_stock_pval_conf[1], ## model pvalue
      ml_pair_ttest = input$sw_pairttest,           ## Pair the ttest
      ml_pooled_var = input$sw_poolvar,             ## Pool the variance
      ml_ltmi = input$sli_npom_ltmi[2],             ## Long term product days
      ml_npom = input$sli_npom_ltmi[1],             ## New menu item days
      ml_prim = input$sli_secd_prim[2],             ## Primary product thresh
      ml_secd = input$sli_secd_prim[1],             ## Secondary product thresh
      ml_ppql = input$sli_ppql_ppqh[1],             ## price quantile low
      ml_ppqh = input$sli_ppql_ppqh[2]              ## price quantile high
    ))

    ## Save Org, Store, and Skus into reactive objects
    r_oid <- reactive({
      as.data.table(r_index())[org == req(input$`filters-org`), org_uuid[1]]
    })
    r_sid <- reactive({
      as.data.table(r_index())[store == req(input$`filters-store`), store_uuid[1]]
    })

    ## On click, reset, load, or save tuning parameters
    observeEvent(input$btn_reset, reset_model_inputs())
    observeEvent(input$btn_load, load_model_params(r_oid(), r_sid()))
    observeEvent(input$btn_save, save_model_params(r_oid(), r_sid(), r_ml_args()))

    ## On click, run model
    r_ml_out <- eventReactive(input$btn_run, run_model(
      w = w,
      oid = r_oid(),
      sid = r_sid(),
      index = as.data.table(r_index()),
      ml_args = r_ml_args()
    ))

    ## Render Plots
    output$plot_0 <- renderPlot(r_ml_out()$outputs$plots[[1]], res = 85)
    output$plot_1 <- renderPlot(r_ml_out()$outputs$plots[[2]], res = 85)
    output$plot_2 <- renderPlot(r_ml_out()$outputs$plots[[3]], res = 85)
    output$plot_3 <- renderPlot(r_ml_out()$outputs$plots[[4]], res = 85)
    output$plot_4 <- renderPlot(r_ml_out()$outputs$plots[[5]], res = 85)

    # On click, generate report
    observeEvent(input$btn_post, {
      shinyWidgets::sendSweetAlert(
          title = "Report Format",
          session = session,
          text = shiny::div(
            shinyWidgets::prettyRadioButtons(
              inputId = "dl_format",
              label = NULL,
              width = "100%",
              choices = c("html", "pdf", "word"),
              selected = "html",
              inline = TRUE,
              status = "danger",
              fill = TRUE
            ),
            shiny::downloadButton("btn_dl", "Generate")
          ),
          showCloseButton = FALSE,
          closeOnClickOutside = TRUE,
          width = 600,
          btn_labels = NA,
          html = TRUE
        )
      })

    # Download report.html on action
    output$btn_dl <- downloadHandler(
      filename = function() {
        paste0('my-report.', switch(
          input$dl_format,
          pdf = 'pdf',
          html = 'html',
          word = 'docx'
        ))
      },
      content = function(file) {
        w$show()
        w$update(html = waiter_html("Generating Report..."))
        report_path <- generate_report(file)
        file.copy(report_path, file)
        w$hide()
      }
    )
  }
}


#' @describeIn app-run function returns the reactive data needed on app startup
#' @export
reactive_app_index <- function(index, session = getDefaultReactiveDomain()) {
  if (shiny::isRunning()) {
    select_group_server(
      id = "filters",
      data_r = index,
      vars_r = c("org", "store", "category3", "brand_name", "product_sku")
    )
  } else {
    stop("Shiny app not running...", call. = FALSE)
  }
}


#' @describeIn app-run function that's executed on user action to run model
#' @export
run_model <- function(w, oid, sid, index, ml_args, session = getDefaultReactiveDomain()) {
  if (shiny::isRunning()) {
    # Check if the minimal required arguments are provided
    # Note the other args could never be null
    if (is.null(oid) | is.null(sid)) {
      show_alert(
        session = session,
        title = "Oops !!",
        text = "Select org and store to run model",
        type = "error",
        closeOnClickOutside = TRUE,
        showCloseButton = TRUE
      )
    } else {
      w$show()

      skus <- as.data.table(index)[
        org_uuid == oid & store_uuid == sid,
        product_sku]

      w$update(html = waiter_html("...Building Model Context"))
      context <- build_ml_context(oid, sid, index, ml_args)

      w$update(html = waiter_html("...Building Model Recs..."))
      recs <- build_ml_recs(oid, sid, skus, ml_args)

      w$update(html = waiter_html("...Building Plot Datasets..."))
      results <- build_plot_data(recs)

      w$update(html = waiter_html("...Building Report Scenario..."))
      scenario <- build_ml_scenario(results, context)

      w$update(html = waiter_html("...Building Plot Outputs..."))
      plots <- build_diag_plots(results)

      w$update(html = waiter_html("...Saving Report Images..."))
      plots_path <- save_diag_plots(plots)

      w$update(html = waiter_html("...Saving Report Data..."))
      scenario_path <- save_ml_scenario(scenario)

      ml_out <- list(
        inputs = list(
          oid = oid,
          sid = sid,
          skus = skus,
          index = index,
          ml_args = ml_args
        ),
        outputs = list(
          context = context,
          recs = recs,
          results = results,
          scenario = scenario,
          plots = plots
        ),
        paths = list(
          plots_path = plots_path,
          scenario_path = scenario_path
        )
      )

      # Save additional data if testmode is true
      if (getOption("shiny.testmode", FALSE)) {
        w$update(html = waiter_html("...Saving Model Context..."))
        ml_out$paths$context_path <- save_ml_context(context)

        w$update(html = waiter_html("...Saving Model Recs..."))
        ml_out$paths$recs_path <- save_ml_recs(recs)

        w$update(html = waiter_html("...Saving Plot Datasets..."))
        ml_out$paths$results_path <- save_plot_data(results)
      }
      w$hide()
      ml_out
    }
  } else {
    stop("Shiny app not running...", call. = FALSE)
  }
}


#' @describeIn app-run Reset inputs to default values
#' @export
reset_model_inputs <- function(session = getDefaultReactiveDomain()) {
  if (shiny::isRunning()) {
    args <- default_ml_params()
    updateMaterialSwitch(session = session,
                         inputId = "sw_poolvar",
                         value = args$ml_pooled_var)
    updateMaterialSwitch(session = session,
                         inputId = "sw_pairttest",
                         value = args$ml_pair_ttest)
    updateNoUiSliderInput(session = session,
                          inputId = "sli_trend_pval_conf",
                          value = list(args$ml_trend_pval, args$ml_trend_conf))
    updateNoUiSliderInput(session = session,
                          inputId = "sli_stock_pval_conf",
                          value = list(args$ml_stock_pval, args$ml_stock_conf))
    updateNoUiSliderInput(session = session,
                          inputId = "sli_ppql_ppqh",
                          value = list(args$ml_ppql, args$ml_ppqh))
    updateNoUiSliderInput(session = session,
                          inputId = "sli_secd_prim",
                          value = list(args$ml_secd, args$ml_prim))
    updateNoUiSliderInput(session = session,
                          inputId = "sli_npom_ltmi",
                          value = list(args$ml_npom, args$ml_ltmi))
  } else {
    stop("Shiny app not running...", call. = FALSE)
  }
}


#' @describeIn app-run create a new waiter object
#' @export
new_waiter <- function(session = getDefaultReactiveDomain()) {
  if (shiny::isRunning()) {
    .colors <- get_app_colors()
    Waiter$new(
      html = waiter_html("Initializing..."),
      color = .colors$bg
    )
  } else {
    stop("Shiny app not running...", call. = FALSE)
  }
}


#' @describeIn app-run get html for waiter progress page
#' @export
waiter_html <- function(msg, session = getDefaultReactiveDomain()) {
  if (shiny::isRunning()) {
    shiny::tagList(waiter::spin_pulsar(), shiny::br(), msg)
  } else {
    stop("Shiny app not running...", call. = FALSE)
  }
}


#' @describeIn app-run update stats cards when selections change and data gets filtered
#' @export
update_stat_cards <- function(index, session = getDefaultReactiveDomain()) {
  if (shiny::isRunning()) {
    updateStatiCard(
      session = session,
      id = "stat_skus",
      value = scales::comma(as.integer(nrow(index))),
      duration = 100
    )
    updateStatiCard(
      session = session,
      id = "stat_brands",
      value = scales::comma(as.integer(length(unique(index$brand_name)))),
      duration = 100
    )
    updateStatiCard(
      session = session,
      id = "stat_sales",
      value = scales::dollar(as.integer(sum(index$tot_sales))),
      duration = 100
    )
    updateStatiCard(
      session = session,
      id = "stat_units",
      value = scales::comma(as.integer(sum(index$units_sold))),
      duration = 100
    )
  } else {
    stop("Shiny app not running...", call. = FALSE)
  }
}


#' @describeIn app-run update model inputs using values retrieved from database
#' @export
load_model_params <- function(oid, sid, session = getDefaultReactiveDomain()) {
  if (shiny::isRunning()) {

    # Check if the minimal required arguments are provided
    # Note the other args could never be null
    if (is.null(oid) | is.null(sid)) {
      show_alert(
        session = session,
        title = "Oops !!",
        text = "Select org and store to load any saved parameters",
        type = "error",
        closeOnClickOutside = TRUE,
        showCloseButton = TRUE
      )
    } else {
      args <- db_load_params(oid, sid)
      updateMaterialSwitch(session = session,
                           inputId = "sw_poolvar",
                           value = args$ml_pooled_var)
      updateMaterialSwitch(session = session,
                           inputId = "sw_pairttest",
                           value = args$ml_pair_ttest)
      updateNoUiSliderInput(session = session,
                            inputId = "sli_trend_pval_conf",
                            value = list(args$ml_trend_pval, args$ml_trend_conf))
      updateNoUiSliderInput(session = session,
                            inputId = "sli_stock_pval_conf",
                            value = list(args$ml_stock_pval, args$ml_stock_conf))
      updateNoUiSliderInput(session = session,
                            inputId = "sli_ppql_ppqh",
                            value = list(args$ml_ppql, args$ml_ppqh))
      updateNoUiSliderInput(session = session,
                            inputId = "sli_secd_prim",
                            value = list(args$ml_secd, args$ml_prim))
      updateNoUiSliderInput(session = session,
                            inputId = "sli_npom_ltmi",
                            value = list(args$ml_npom, args$ml_ltmi))

      shinyWidgets::show_alert(
        session = session,
        title = "Success !!",
        text = "Loaded parameters",
        type = "success",
        closeOnClickOutside = TRUE,
        showCloseButton = TRUE
      )
    }
  } else {
    stop("Shiny app not running...", call. = FALSE)
  }
}


#' @describeIn app-run save model inputs to database on user action
#' @export
save_model_params <- function(oid, sid, ml_args, session = getDefaultReactiveDomain()) {
  if (shiny::isRunning()) {

    if (is.null(oid) || is.null(sid)) {
      show_alert(
        session = session,
        title = "Oops !!",
        text = "Select Org and Store to save model parameters",
        type = "error",
        closeOnClickOutside = TRUE,
        showCloseButton = TRUE
      )
    } else {
      n <- db_save_params(oid, sid, ml_args)
      if (n == 1) {
        show_alert(
          session = session,
          title = "Success !!",
          text = "Parameters saved",
          type = "success",
          closeOnClickOutside = TRUE,
          showCloseButton = TRUE
        )
      } else {
        show_alert(
          session = session,
          title = "Error !!",
          text = "Failed to save parameters",
          type = "error",
          closeOnClickOutside = TRUE,
          showCloseButton = TRUE
        )
      }
    }

  } else {
    stop("Shiny app not running...", call. = FALSE)
  }
}



