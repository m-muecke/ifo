#' Return ifo business climate
#'
#' @description
#' Long time-series of the ifo Business Climate for Germany and its two and
#' its two components, the business situation, and the expectations for sectors.
#'
#' @param type `character(1)` one of `"climate"`, `"sectors"`,`"eastern"`,
#'   `"saxony"`. Default `"climate"`.
#' @references <https://www.ifo.de/en/ifo-time-series>
#' @family ifo time series
#' @export
#' @examples
#' \donttest{
#' ifo_climate()
#' }
ifo_climate <- function(type = c("climate", "sectors", "eastern", "saxony")) {
  type <- match.arg(type, c("climate", "sectors", "eastern", "saxony"))
  sheet <- 1L
  switch(type,
    climate = {
      col_names <- c(
        "yearmonth",
        "climate_index", "situation_index", "expectation_index",
        "climate_balance", "situation_balance", "expectation_balance",
        "uncertainty", "economic_expansion"
      )
      col_types <- c("text", rep("numeric", 8L))
    },
    sectors = {
      sheet <- 2L
      type <- "climate"
      col_types <- c("text", rep("numeric", 24L))
      col_names <- "yearmonth"
      component <- c("climate", "situation", "expectation")
      nms <- as.character(outer(
        paste(component, "industry", sep = "_"), c("balance", "index"), paste,
        sep = "_"
      ))
      col_names <- c(col_names, nms)
      nms <- as.character(outer(
        component,
        c("manufacturing", "services", "trade", "wholesale", "retail", "construction"),
        paste,
        sep = "_"
      ))
      nms <- paste0(nms, "_balance")
      col_names <- c(col_names, nms)
    },
    {
      col_names <- c("yearmonth", "climate", "situation", "expecation")
      col_types <- c("text", rep("numeric", 3L))
    }
  )
  res <- ifo_download(
    type = type,
    sheet = sheet,
    skip = 8L,
    col_names = col_names,
    col_types = col_types
  )
  res$yearmonth <- as.Date(paste0("01/", res$yearmonth), format = "%d/%m/%Y") # nolint
  res
}

#' Return ifo export expectations
#'
#' @description
#' Long time-series of the ifo Export Expectations for manufacturing.
#'
#' @inherit ifo_export references
#' @family ifo time series
#' @export
#' @examples
#' \donttest{
#' ifo_export()
#' }
ifo_export <- function() {
  res <- ifo_download(
    type = "export",
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
#' Long time-series of the ifo Employment Barometer for Germany.
#'
#' @inherit ifo_export references
#' @family ifo time series
#' @export
#' @examples
#' \donttest{
#' ifo_employment()
#' }
ifo_employment <- function() {
  col_names <- c(
    "yearmonth", "expecation", "manufacturing", "construction", "trade",
    "service_sector"
  )
  col_types <- c("date", rep("numeric", 5L))
  res <- ifo_download(
    type = "employment", skip = 9L, col_names = col_names, col_types = col_types
  )
  res$yearmonth <- as.Date(format(res$yearmonth, "%Y-%m-01"))
  res
}

ifo_download <- function(type, ...) {
  url <- ifo_url(type)
  tf <- tempfile(fileext = ".xlsx")
  on.exit(unlink(tf), add = TRUE)
  utils::download.file(url, destfile = tf, quiet = TRUE)
  readxl::read_xlsx(tf, ...)
}

ifo_url <- function(type) {
  pattern <- switch(type,
    climate = "gsk",
    eastern = "ostd",
    saxony = "sachsen",
    export = "export",
    employment = "empl"
  )
  urls <- read_html("https://www.ifo.de/en/ifo-time-series") |>
    html_element(".link-list") |>
    html_elements("a") |>
    html_attr("href")
  url <- grep(pattern, urls, value = TRUE, fixed = TRUE)
  url <- paste0("https://www.ifo.de", url)
  url
}
