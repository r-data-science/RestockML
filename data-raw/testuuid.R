## code to prepare `DATASET` dataset goes here

..testuuid <- as.list(uuid::UUIDgenerate(n = 2)) |>
  setNames(c("oid", "sid"))

usethis::use_data(..testuuid, internal = TRUE, overwrite = TRUE)

