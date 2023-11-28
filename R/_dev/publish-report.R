#' @describeIn mltuning-utils Run and Publishing Functions
add_content_tag <- function(cid) {
  apiKey <- Sys.getenv("CONNECT_API_KEY")
  srvUrl <- Sys.getenv("CONNECT_SERVER")
  result <- httr::POST(
    stringr::str_glue("{srvUrl}__api__/v1/content/{cid}/tags"),
    body = '{"tag_id": "56"}', encode = "raw",
    httr::add_headers(Authorization = paste("Key", apiKey))
  )
  result
}


#' @describeIn mltuning-utils publish to rstudio connect
publish_report <- function() {

  # Configure rsconnect access
  app_name <- connectapi::create_random_name()

  rscUser <- Sys.getenv("CONNECT_API_USER")
  rscKey <- Sys.getenv("CONNECT_API_KEY")
  rscApi <- stringr::str_remove_all(Sys.getenv("CONNECT_SERVER"), "https://|/")
  rsconnect::connectApiUser(server = rscApi, apiKey = rscKey)

  PUB_OK <- rsconnect::deployDoc(
    "output/report.qmd",
    appName = app_name,
    appTitle = report_title,
    recordDir = "output/",
    quarto = TRUE,
    appVisibility = "private",
    envVars = c("HCA_DB_PWD", "CONNECT_API_KEY", "CONNECT_SERVER"),
    account = rscUser,
    server = rscApi,
    contentCategory = "document",
    launch.browser = function(url) saveRDS(url, "output/temp/report-url.rds")
  )

  if (PUB_OK) {
    ## if published, add content tags
    url <- readRDS("output/temp/report-url.rds")
    cid <- stringr::str_remove(stringr::str_remove(url, ".+(?<=app/content/)"), "/")
    add_content_tag(cid)
    out <- list(name = app_name, content_id = cid, url = url)

    rdstools::log_suc("Published to connect...name: {app_name}, cid: {cid}, url: {url}")
    return(out)
  }
  rdstools::log_err("Unable to publish report")
  return(NULL)
}
