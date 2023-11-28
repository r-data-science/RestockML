## code to prepare `mltuning-test-datasets` dataset goes here
index <- rdsapps:::get_index()
mltuning_test_index <- index[org %in% c("abidenapa", "apothecare")]

mltuning_test_results <- list(
  readRDS("inst/apps/mltuning/.plotdata/pdata0.rds"),
  readRDS("inst/apps/mltuning/.plotdata/pdata1.rds"),
  readRDS("inst/apps/mltuning/.plotdata/pdata2.rds"),
  readRDS("inst/apps/mltuning/.plotdata/pdata3.rds"),
  readRDS("inst/apps/mltuning/.plotdata/pdata4.rds")
)

get_velocity_data <- function(oid, sid, sku = NULL){
  rdscore::dbGetVtDaily(oid, sid, sku)
}
oid <- "a6cefdc6-0561-48ee-88cf-7e1e47420e41" # verano
sid <- "5a020014-ff77-49b0-a856-c7ce3fff4633" # eldorado

tmp <- get_velocity_data(oid, sid, NULL)
salesDT <- tmp[tmp[, .N, product_sku][order(-N)][1:5, .(product_sku)], on = "product_sku"]


usethis::use_data(salesDT, mltuning_test_results, mltuning_test_index, overwrite = TRUE, internal = TRUE)
