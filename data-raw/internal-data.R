## code to prepare `DATASET` dataset goes here

devtools::load_all()


# test uuids --------------------------------------------------------------


..testuuid <- as.list(uuid::UUIDgenerate(n = 2)) |>
  setNames(c("oid", "sid"))




# empty-appdata -----------------------------------------------------------



empty_appdata <- db_app_index_anon()

usethis::use_data(..testuuid, empty_appdata, internal = TRUE, overwrite = TRUE)
