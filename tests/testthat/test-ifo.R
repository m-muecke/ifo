test_that("ifo_url() returns expected result", {
  local_mocked_bindings(
    read_html = \(x) rvest::read_html(test_path("fixtures", "ifo-time-series.html"))
  )
  expected <- "https://www.ifo.de/sites/default/files/secure/timeseries/gsk-e-202404.xlsx" # nolint
  expect_identical(ifo_url("germany"), expected)
  expect_identical(ifo_url("sectors"), expected)
  types <- c("germany", "sectors", "eastern", "saxony", "export", "employment", "export_climate", "import_climate") # nolint
  lapply(types, \(type) expect_length(ifo_url(type), 1L))
})
