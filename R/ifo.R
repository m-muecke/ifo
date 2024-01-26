# TODO: better name for function, make it english
ifo_gsk <- function(links) {
  links <- ifo_links()
  tf <- tempfile(fileext = ".xlsx")
  on.exit(unlink(tf))
  utils::download.file(links[["gsk"]], destfile = tf, quiet = TRUE)
  df <- readxl::read_xlsx(tf, sheet = 1L, skip = 7L)
}

#' Return ifo export expectations
#'
#' @description
#' Long time-series of the ifo Export Expectations for manufacturing
#'
#' @references <https://www.ifo.de/en/ifo-time-series>
#' @family ifo time series
#' @export
ifo_export <- function() {
  links <- ifo_links()
  res <- ifo_download(links[["export"]], \(tf) {
    readxl::read_xlsx(tf,
      skip = 10L,
      col_names = c("yearmonth", "value"),
      col_types = c("date", "numeric")
    )
  })
  res$yearmonth <- as.Date(res$yearmonth)
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
ifo_empl <- function() {
  links <- ifo_links()
  res <- ifo_download(links[["empl"]], \(tf) {
    readxl::read_xlsx(tf,
      skip = 9L,
      col_names = c("yearmonth", "value", "manufacturing", "construction", "trade", "service_sector"),
      col_types = c("date", "numeric", "numeric", "numeric", "numeric", "numeric")
    )
  })
  res$yearmonth <- as.Date(res$yearmonth)
  res
}

#' Return ifo business climate for eastern Germany
#'
#' @description
#' Long time-series of the Business Climate for Eastern Germany and its two
#' components, the business situation and the expectations.
#'
#' @inherit ifo_export references
#' @family ifo time series
#' @export
ifo_ostd <- function() {
  links <- ifo_links()
  res <- ifo_download(links[["ostd"]], \(tf) {
    readxl::read_xlsx(tf,
      skip = 8L,
      col_names = c("yearmonth", "business_climate", "business_situation", "business_expecation"),
      col_types = c("text", "numeric", "numeric", "numeric")
    )
  })
  res$yearmonth <- as.Date(paste0("01/", res$yearmonth), format = "%d/%m/%Y")
  res
}

#' Return ifo business climate for Saxony
#'
#' @description
#' Long time-series of the Business Climate for Saxony and its two components,
#' the business situation and the expectations.
#'
#' @inherit ifo_export references
#' @family ifo time series
#' @export
ifo_ku_sachsen <- function() {
  links <- ifo_links()
  res <- ifo_download(links[["ku_sachsen"]], \(tf) {
    readxl::read_xlsx(tf,
      skip = 8L,
      col_names = c("yearmonth", "business_climate", "business_situation", "business_expecation"),
      col_types = c("text", "numeric", "numeric", "numeric")
    )
  })
  res$yearmonth <- as.Date(paste0("01/", res$yearmonth), format = "%d/%m/%Y")
  res
}

ifo_download <- function(url, fn) {
  tf <- tempfile(fileext = ".xlsx")
  on.exit(unlink(tf))
  utils::download.file(url, destfile = tf, quiet = TRUE)
  fn(tf)
}

ifo_links <- function() {
  # TODO: might be more robust to create names based on link
  url <- "https://www.ifo.de/en/ifo-time-series"
  links <- read_html(url) |>
    html_element(".link-list") |>
    html_elements("a") |>
    html_attr("href")
  links <- paste0("https://www.ifo.de", links)
  stats::setNames(links, c("gsk", "export", "empl", "ostd", "ku_sachsen"))
}
