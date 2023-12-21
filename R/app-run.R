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
#' @param args Values to update model parameters on UI
#'
#' @import shiny
#' @import waiter
#' @importFrom shinyWidgets updateStatiCard updateMaterialSwitch updateNoUiSliderInput show_alert radioGroupButtons sendSweetAlert
#' @importFrom shiny runApp shinyOptions
#' @importFrom rdstools log_suc
#' @importFrom fs file_exists path
#' @importFrom datamods select_group_server
#'
#' @name app-run
NULL


#' @describeIn app-run returns app object for subsequent execution
#' @export
appExplorePRM <- function(...) {
  shiny::shinyApp(
    ui = app_ui(),
    server = app_server(),
    onStart = create_session_dir,
    options = list(...)
  )
}


#' @describeIn app-run UI function for app
app_ui <- function() {
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
app_server <- function() {

  function(input, output, session) {

    # log helpers
    log_i <- function(msg, ...) {
      env <- parent.frame(1)
      msg <- stringr::str_glue(msg, .envir = env)
      rdstools::log_inf(msg, ...)
    }
    log_s <- function(msg, ...) {
      env <- parent.frame(1)
      msg <- stringr::str_glue(msg, .envir = env)
      rdstools::log_suc(msg, ...)
    }

    w <- new_waiter()

    onStop(clear_session_dir, session)


    appdata <- tryCatch({
      db_app_index_anon()
    }, error = function(c) {
      warning("Error getting appdata:\n", c$message, call. = FALSE)
      empty_appdata[]
    })


    ## Data filtered by the user contains org/store products
    r_index <- select_group_server(
      id = "filters",
      data_r = appdata,
      vars_r = c("org", "store", "category3", "brand_name", "product_sku")
    )

    ## Update the Stats Cards on filtered index
    observe({
      update_stat_cards(r_index(), session)
      log_s("+++ app event @-> filter update")
    })

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

    exportTestValues(
      oid = r_oid(),
      sid = r_sid()
    )

    ## On click, reset, load, or save tuning parameters
    observeEvent(input$btn_reset, {
      log_i("+++ user action @-> reset ml params")

      default_ml_params() |>
        update_model_params()
    })

    observeEvent(input$btn_load, {
      log_i("+++ user action @-> load from db")

      db_load_params(r_oid(), r_sid()) |>
        update_model_params()

      shinyWidgets::show_alert(
        session = session,
        title = "Success !!",
        text = "Parameters Loaded",
        type = "success",
        closeOnClickOutside = TRUE,
        showCloseButton = TRUE
      )
    })

    observeEvent(input$btn_save, {
      log_i("+++ user action @-> write to db")

      n <- db_save_params(r_oid(), r_sid(), r_ml_args())

      show_alert(
        session = session,
        title = "Success !!",
        text = "Parameters Saved",
        type = "success",
        closeOnClickOutside = TRUE,
        showCloseButton = TRUE
      )
    })

    ## On click, run model
    r_ml_out <- eventReactive(input$btn_run, {
      log_i("+++ user action @-> run model")
      run_model(
        w = w,
        oid = r_oid(),
        sid = r_sid(),
        index = as.data.table(r_index()),
        ml_args = r_ml_args()
      )
    })

    ## Render Plots
    output$plot_0 <- renderPlot(r_ml_out()$outputs$plots[[1]], res = 85)
    output$plot_1 <- renderPlot(r_ml_out()$outputs$plots[[2]], res = 85)
    output$plot_2 <- renderPlot(r_ml_out()$outputs$plots[[3]], res = 85)
    output$plot_3 <- renderPlot(r_ml_out()$outputs$plots[[4]], res = 85)
    output$plot_4 <- renderPlot(r_ml_out()$outputs$plots[[5]], res = 85)

    exportTestValues(
      plot_0 = r_ml_out()$outputs$plots[[1]],
      plot_1 = r_ml_out()$outputs$plots[[2]],
      plot_2 = r_ml_out()$outputs$plots[[3]],
      plot_3 = r_ml_out()$outputs$plots[[4]],
      plot_4 = r_ml_out()$outputs$plots[[5]],
      plot_0_data = r_ml_out()$outputs$results[[1]],
      plot_1_data = r_ml_out()$outputs$results[[2]],
      plot_2_data = r_ml_out()$outputs$results[[3]],
      plot_3_data = r_ml_out()$outputs$results[[4]],
      plot_4_data = r_ml_out()$outputs$results[[5]]
    )

    # On click, generate report
    observeEvent(input$btn_post, {
      log_i("+++ user action @-> create report")

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
    output$btn_dl <- shiny::downloadHandler(
      filename = function() {
        log_i("+++ user action @-> confirmed download")
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


#' @describeIn app-run create a new waiter object
new_waiter <- function(session = getDefaultReactiveDomain()) {
  waiter::Waiter$new(
    html = waiter_html("Initializing..."),
    color = get_app_colors()$bg
  )
}


#' @describeIn app-run get html for waiter progress page
waiter_html <- function(msg) {
  shiny::tagList(waiter::spin_pulsar(), shiny::br(), msg)
}


#' @describeIn app-run update stats on filter
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


#' @describeIn app-run update ui sliders containing model params
update_model_params <- function(args, session = getDefaultReactiveDomain()) {
  if (shiny::isRunning()) {
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



#' @describeIn app-run function that's executed on user action to run model
run_model <- function(w, oid, sid, index, ml_args, session = getDefaultReactiveDomain()) {
  .show_w <- function() if (isRunning()) w$show()
  .update_w <- function(msg) if (isRunning()) w$update(html = waiter_html(msg))
  .hide_w <- function() if (isRunning()) w$hide()

  .show_w()
  skus <- as.data.table(index)[
    org_uuid == oid & store_uuid == sid,
    product_sku]

  .update_w("...Building Model Context")
  context <- build_ml_context(oid, sid, index, ml_args)

  .update_w("...Building Model Recs...")
  recs <- build_ml_recs(oid, sid, skus, ml_args)

  .update_w("...Building Plot Datasets...")
  results <- build_plot_data(recs)

  .update_w("...Building Report Scenario...")
  scenario <- build_ml_scenario(results, context)

  .update_w("...Building Plot Outputs...")
  plots <- build_plot_objects(results)

  if (is_testing() & !shiny::isRunning()) {
    cat("\n\n\n...Unit Test Detected...\n\n\n")
  } else {
    .update_w("...Saving Report Images...")
    plots_path <- save_plot_objects(plots)

    .update_w("...Saving Report Data...")
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
      rdstools::log_inf("__! Test Mode Detected !___")

      .update_w("...Saving Model Context...")
      ml_out$paths$context_path <- save_ml_context(context)

      .update_w("...Saving Model Recs...")
      ml_out$paths$recs_path <- save_ml_recs(recs)

      .update_w("...Saving Plot Datasets...")
      ml_out$paths$results_path <- save_plot_data(results)
    }
    .hide_w()
    ml_out
  }

}


