#' Return ifo business climate
#'
#' @description
#' Long time-series of the ifo Business Climate for Germany and its two and
#' its two components, the business situation, and the expectations for sectors.
#'
#' @references <https://www.ifo.de/en/ifo-time-series>
#' @family ifo time series
#' @export
ifo_climate <- function(x = c("germany", "eastern", "saxony")) {
  x <- match.arg(x, c("germany", "eastern", "saxony"))
  x <- if (x == "germany") "climate" else x
  url <- ifo_url(x)
  if (x == "climate") {
    col_names <- c(
      "yearmonth", "climate_index", "situation_index", "expecation_index",
      "climate_balance", "situation_balance", "expectation_balance",
      "uncertainty", "economic_expansion"
    )
    col_types <- c("text", rep("numeric", 8L))
  } else {
    col_names <- c("yearmonth", "climate", "situation", "expecation")
    col_types <- c("text", "numeric", "numeric", "numeric")
  }
  res <- ifo_download(
    url = url, skip = 8L, col_names = col_names, col_types = col_types
  )
  res$yearmonth <- as.Date(paste0("01/", res$yearmonth), format = "%d/%m/%Y")
  res
}

#' Return ifo export expectations
#'
#' @description
#' Long time-series of the ifo Export Expectations for manufacturing
#'
#' @inherit ifo_export references
#' @family ifo time series
#' @export
ifo_export <- function() {
  url <- ifo_url("export")
  res <- ifo_download(
    url = url,
    skip = 10L,
    col_names = c("yearmonth", "expecation"),
    col_types = c("date", "numeric")
  )
  res$yearmonth <- as.Date(format(res$yearmonth, "%Y-%m-01"))
  res
}

#' Return ifo employment expectations
#'
#' @description
#' Long time-series of the ifo Employment Barometer for Germany
#'
#' @inherit ifo_export references
#' @family ifo time series
#' @export
ifo_employment <- function() {
  url <- ifo_url("employment")
  col_names <- c(
    "yearmonth", "expecation", "manufacturing", "construction", "trade", "service_sector"
  )
  col_types <- c(
    "date", "numeric", "numeric", "numeric", "numeric", "numeric"
  )
  res <- ifo_download(
    url = url, skip = 9L, col_names = col_names, col_types = col_types
  )
  res$yearmonth <- as.Date(format(res$yearmonth, "%Y-%m-01"))
  res
}

ifo_download <- function(url, ...) {
  tf <- tempfile(fileext = ".xlsx")
  on.exit(unlink(tf), add = TRUE)
  utils::download.file(url, destfile = tf, quiet = TRUE)
  readxl::read_xlsx(tf, ...)
}

ifo_url <- function(x) {
  # TODO: might be more robust to create names based on link
  url <- "https://www.ifo.de/en/ifo-time-series"
  links <- read_html(url) |>
    html_element(".link-list") |>
    html_elements("a") |>
    html_attr("href")
  links <- paste0("https://www.ifo.de", links)
  names(links) <- c("climate", "export", "employment", "eastern", "saxony")
  links[[x]]
}
