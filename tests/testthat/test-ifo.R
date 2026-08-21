test_that("ifo_url() returns expected result", {
  local_mocked_bindings(
    read_html = \(x) rvest::read_html(test_path("fixtures", "ifo-time-series.html"))
  )
  expected <- "https://www.ifo.de/sites/default/files/secure/timeseries/gsk-e-202505.xlsx" # nolint
  expect_identical(ifo_url("germany"), expected)
  expect_identical(ifo_url("sectors"), expected)
  types <- c(
    "germany",
    "sectors",
    "eastern",
    "saxony",
    "export",
    "employment",
    "export_climate",
    "import_climate",
    "world",
    "euro"
  )
  lapply(types, \(type) expect_length(ifo_url(type), 1L))
})

test_that("parse_yearmonth() parses monthly labels", {
  expect_identical(
    parse_yearmonth(c("01/2005", "07/2005", "12/2005")),
    as.Date(c("2005-01-01", "2005-07-01", "2005-12-01"))
  )
})

test_that("parse_yearmonth() parses quarterly labels", {
  expect_identical(
    parse_yearmonth(c("01/1990", "02/1990", "03/1990", "04/1990"), quarterly = TRUE),
    as.Date(c("1990-01-01", "1990-04-01", "1990-07-01", "1990-10-01"))
  )
})

test_that("parse_yearmonth() truncates dates to the start of the month", {
  expect_identical(
    parse_yearmonth(as.POSIXct(c("2005-01-15", "2005-02-28"), tz = "UTC")),
    as.Date(c("2005-01-01", "2005-02-01"))
  )
})

test_that("parse_yearmonth() returns NA for rows without a date", {
  labels <- c(NA, "01/1990", "Source: ifo Institute")
  expect_identical(parse_yearmonth(labels), as.Date(c(NA, "1990-01-01", NA)))
  expect_identical(parse_yearmonth(labels, quarterly = TRUE), as.Date(c(NA, "1990-01-01", NA)))
})
