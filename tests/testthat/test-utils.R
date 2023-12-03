# test_that("App Utils", {
#   expect_true(fs::dir_exists(get_app_dir()))
#   expect_true(is.list(get_app_colors()))
#
#   dirPaths <- create_session_dir()
#   expect_true(all(fs::dir_exists(dirPaths)))
#
#   ll <- default_ml_params()
#   expect_true(is.list(ll))
#   expect_true(is.list(scale_ml_params(ll)))
#   expect_true(is.list(unscale_ml_params(ll)))
#
#   fs::dir_delete("www")
#   fs::dir_delete("output")
# })
#
#

# get_app_dir()
# get_app_colors()
# create_session_dir()
# clean_session_dir()
# rec <- rdscore::restock_rec_ep(
#   oid = ,
#   sid = ,
#   sku = ,
#   ml_ltmi = ,
#   ml_npom = ,
#   ml_prim = ,
#   ml_secd = ,
#   ml_ppql = ,
#   ml_ppqh = ,
#   ml_pair_ttest = ,
#   ml_pooled_var = ,
#   ml_trend_conf = ,
#   ml_stock_conf = ,
#   ml_trend_pval = ,
#   ml_stock_pval = )
# results <- process_rec_ep(rec)
# ml_args <- default_ml_params()
# exec_ml_restock(oid, sid, sku_vec, ml_args)
# save_plot_data(results)
# create_dl_link(dlfile = "report.html")
# generate_report(org, store)
# save_plot_image(p0, p1, p2, p3, p4)
# build_scenario_data()
# save_ml_context(oid, sid, sku_data, ml_args)
# save_ml_results(results)

