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

test_that("ifo_url() finds the renamed employment workbook", {
  html <- paste0(
    '<div class="paragraph--linkliste">',
    '<a href="/sites/default/files/secure/timeseries/ifo-beschbaro-e-202608.xlsx" ',
    'title="ifo Employment Barometer for Germany (August 2026)"></a>',
    "</div>"
  )
  local_mocked_bindings(read_html = \(x) rvest::read_html(charToRaw(html)))

  expected <- paste0(
    "https://www.ifo.de/sites/default/files/secure/timeseries/",
    "ifo-beschbaro-e-202608.xlsx"
  )
  expect_identical(ifo_url("employment"), expected)
})

test_that("ifo_url() finds the vintage workbooks", {
  files <- c(
    germany = "Germany",
    industry = "Industry_and_Trade",
    manufacturing = "Manufacturing",
    services = "Services",
    trade = "Trade",
    wholesale = "Wholesale_Trade",
    retail = "Retail_Trade",
    construction = "Construction"
  )
  links <- sprintf(
    '<a href="/sites/default/files/facts/vintage/%s-ifo-vintage.xlsx" title="%s"></a>',
    files,
    gsub("_", " ", files)
  )
  html <- sprintf('<div class="paragraph--linkliste">%s</div>', paste(links, collapse = ""))
  local_mocked_bindings(read_html = \(x) rvest::read_html(charToRaw(html)))

  for (type in names(files)) {
    expected <- sprintf(
      "https://www.ifo.de/sites/default/files/facts/vintage/%s-ifo-vintage.xlsx",
      files[[type]]
    )
    expect_identical(ifo_url(paste0("vintage_", type)), expected)
  }
})

test_that("ifo_file() downloads the workbook for a type", {
  local_mocked_bindings(ifo_url = \(type) paste0("https://example.org/", type, ".xlsx"))
  local_mocked_bindings(
    curl_download = \(url, destfile, ...) writeLines(url, destfile),
    .package = "curl"
  )

  path <- ifo_file("export")
  on.exit(unlink(path))
  expect_match(path, "\\.xlsx$")
  expect_identical(readLines(path), "https://example.org/export.xlsx")
})

test_that("ifo_expectation() drops rows without observations", {
  tab <- data.table(
    yearmonth = as.Date(c("2025-01-01", "2025-02-01", "2025-03-01")),
    x = c(1, 2, NA),
    y = c(1, NA, NA)
  )
  local_mocked_bindings(ifo_download = \(...) copy(tab))

  expect_identical(ifo_expectation("export"), setDF(tab[1:2]))
})

test_that("ifo_vintage() returns one observation per month and vintage", {
  sheet <- \(scale) {
    data.frame(
      Date = c("January 2005", "February 2005", "March 2005"),
      v2005m02 = scale * c(1, 2, NA),
      v2005m03 = scale * c(1.5, 2, 3)
    )
  }
  sheets <- list(Climate = sheet(1), Situation = sheet(10), Expectations = sheet(100))
  local_mocked_bindings(ifo_file = \(type) tempfile())
  local_mocked_bindings(read_xlsx = \(path, sheet, ...) sheets[[sheet]], .package = "readxl")

  tab <- ifo_vintage("germany")
  expect_named(tab, c("yearmonth", "vintage", "indicator", "series", "value"))
  expect_identical(nrow(tab), 15L)
  expect_identical(unique(tab$series), "index")
  expect_identical(unique(tab$indicator), c("climate", "situation", "expectation"))
  expect_identical(
    tab[tab$indicator == "climate", ],
    data.frame(
      yearmonth = as.Date(c("2005-01-01", "2005-01-01", "2005-02-01", "2005-02-01", "2005-03-01")),
      vintage = as.Date(c("2005-02-01", "2005-03-01", "2005-02-01", "2005-03-01", "2005-03-01")),
      indicator = "climate",
      series = "index",
      value = c(1, 1.5, 2, 2, 3),
      row.names = c(1L, 4L, 7L, 10L, 13L)
    )
  )

  expect_identical(unique(ifo_vintage("manufacturing")$series), "balance")
})

test_that("parse_monthname() parses month names", {
  expect_identical(
    parse_monthname(c("January 2005", "December 2025")),
    as.Date(c("2005-01-01", "2025-12-01"))
  )
  expect_identical(parse_monthname("Januar 2005"), as.Date(NA))
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
