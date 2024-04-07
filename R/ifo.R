#' Return ifo business climate
#'
#' @description
#' Long time-series of the ifo Business Climate for Germany and its two and
#' its two components, the business situation, and the expectations for sectors.
#'
#' @param type `character(1)` one of `"climate"`, `"sectors"`,`"eastern"`,
#'   `"saxony"`. Default `"climate"`.
#' @param long_format `logical(1)` if `TRUE` return the data in long format.
#'   Only applies to `type` `"climate"` and `"sectors"`. Default `TRUE`.
#' @returns A `data.frame()` containing the ifo business climate.
#' @references <https://www.ifo.de/en/ifo-time-series>
#' @family ifo business survey
#' @export
#' @examples
#' \donttest{
#' ifo_climate()
#' }
ifo_climate <- function(type = c("climate", "sectors", "eastern", "saxony"),
                        long_format = TRUE) {
  type <- match.arg(type)
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
      col_types <- c("text", rep("numeric", 24L))
      col_names <- "yearmonth"
      indicator <- c("climate", "situation", "expectation")
      nms <- as.character(outer(
        paste(indicator, "industry", sep = "_"), c("balance", "index"), paste,
        sep = "_"
      ))
      col_names <- c(col_names, nms)
      nms <- as.character(outer(
        indicator,
        c("manufacturing", "services", "trade", "wholesale", "retail", "construction"),
        paste,
        sep = "_"
      ))
      nms <- paste0(nms, "_balance")
      col_names <- c(col_names, nms)
    },
    {
      col_names <- c("yearmonth", "climate", "situation", "expectation")
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

  if (long_format && type %in% c("climate", "sectors")) {
    if (type == "climate") {
      res |> tidyr::pivot_longer(climate_index:expectation_balance,
        names_to = c("indicator", "series"),
        names_pattern = "(.*)_(.*)",
        values_drop_na = TRUE
      )
    } else {
      res |> tidyr::pivot_longer(!yearmonth,
        names_to = c("indicator", "sector", "series"),
        names_pattern = "(.*)_(.*)_(.*)",
        values_drop_na = TRUE
      )
    }
  } else {
    res
  }
}

#' Return ifo export expectations
#'
#' @description
#' Long time-series of the ifo Export Expectations for manufacturing.
#'
#' @returns A `data.frame()` containing the ifo export expectations.
#' @inherit ifo_climate references
#' @family ifo business survey
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
#' @returns A `data.frame()` containing the ifo employment expectations.
#' @inherit ifo_climate references
#' @family ifo business survey
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

#' Return ifo export climate
#'
#' @description
#' Long time series for the ifo Export Climate and the annual rate of change of real
#' exports.
#'
#' @returns A `data.frame()` containing the ifo export climate.
#' @inherit ifo_climate references
#' @family ifo time series
#' @export
#' @examples
#' \donttest{
#' ifo_export_climate()
#' }
ifo_export_climate <- function() {
  res <- ifo_download(
    type = "export_climate",
    skip = 10L,
    col_names = c("yearmonth", "ifo_climate", "special_trade"),
    col_types = c("date", "numeric", "numeric")
  )
  res$yearmonth <- as.Date(format(res$yearmonth, "%Y-%m-01"))
  res
}

#' Return ifo import climate
#'
#' @description
#' Long time-series of the ifo import climate.
#'
#' @returns A `data.frame()` containing the ifo import climate.
#' @references `r format_bib("grimme2018ifo", "grimme2021forecasting")`
#' @family ifo time series
#' @export
#' @examples
#' \donttest{
#' ifo_import_climate()
#' }
ifo_import_climate <- function() {
  res <- ifo_download(
    type = "import_climate",
    skip = 10L,
    col_names = c("yearmonth", "climate"),
    col_types = c("date", "numeric")
  )
  res$yearmonth <- as.Date(format(res$yearmonth, "%Y-%m-01"))
  res
}

ifo_download <- function(type, ...) {
  url <- ifo_url(type)
  tf <- tempfile(fileext = ".xlsx")
  on.exit(unlink(tf), add = TRUE)
  utils::download.file(url, destfile = tf, quiet = TRUE, mode = "wb")
  readxl::read_xlsx(tf, ...)
}

ifo_url <- function(type) {
  pattern <- switch(type,
    climate = "gsk",
    sectors = "gsk",
    eastern = "ostd",
    saxony = "sachsen",
    export = "export",
    employment = "empl",
    export_climate = "exklima",
    import_climate = "imklima"
  )
  urls <- read_html("https://www.ifo.de/en/ifo-time-series") |>
    html_elements(".link-list") |>
    html_elements("a") |>
    html_attr("href")
  url <- grep(pattern, urls, value = TRUE, fixed = TRUE)
  url <- paste0("https://www.ifo.de", url)
  url
}
