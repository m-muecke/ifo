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
#' @returns A `data.frame()` containing the monthly ifo business climate time series.
#' @references <https://www.ifo.de/en/ifo-time-series>
#' @family ifo business survey
#' @export
#' @examples
#' \donttest{
#' ifo_business()
#' }
ifo_business <- function(type = c("climate", "sectors", "eastern", "saxony"),
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

#' Return ifo expectation
#'
#' @param type `character(1)` Defaults to `"employment"`. One of:
#'   * `"export"`: returns the ifo export expectations for manufacturing.
#'   * `"employment"`: returns the ifo employment barometer for Germany.
#' @returns A `data.frame()` containing the monthly ifo expectation time series.
#' @inherit ifo_business references
#' @export
#' @examples
#' \dontrun{
#' export <- ifo_expectation("export")
#' employment <- ifo_expectation("emplpoyment")
#' }
ifo_expectation <- function(type = c("export", "employment")) {
  type <- match.arg(type)
  if (type == "export") {
    ifo_download(
      type = "export",
      skip = 10L,
      col_names = c("yearmonth", "expecation"),
      col_types = c("date", "numeric")
    )
  } else {
    ifo_download(
      type = "employment",
      skip = 9L,
      col_names = c(
        "yearmonth", "expecation", "manufacturing", "construction", "trade", "service_sector" # nolint
      ),
      col_types = c("date", rep("numeric", 5L))
    )
  }
}

#' Return ifo climate
#'
#' @param type `character(1)` Defaults to `"import"`. One of:
#'   * `"import"`: returns the ifo import climate.
#'   * `"export"`: returns teh ifo export climate.
#' @returns A `data.frame()` containing the monthly ifo climate time series.
#' @references `r format_bib("grimme2018ifo", "grimme2021forecasting")`
#' @family ifo time series
#' @export
#' @examples
#' \dontrun{
#' import <- ifo_climate("import")
#' export <- ifo_climate("export")
#' }
ifo_climate <- function(type = c("import", "export")) {
  type <- match.arg(type)
  if (type == "import") {
    ifo_download(
      type = "import_climate",
      skip = 10L,
      col_names = c("yearmonth", "climate"),
      col_types = c("date", "numeric")
    )
  } else {
    ifo_download(
      type = "export_climate",
      skip = 10L,
      col_names = c("yearmonth", "ifo_climate", "special_trade"),
      col_types = c("date", "numeric", "numeric")
    )
  }
}

ifo_history <- function(type = c("world", "euro")) {
  type <- match.arg(type)
  ifo_download(
    type = type,
    skip = 11L,
    col_names = c(
      "yearmonth", "economic_climate", "present_situation", "expectation"
    ),
    col_types = c("text", rep("numeric", 3L))
  )
}

ifo_download <- function(type, ...) {
  url <- ifo_url(type)
  tf <- tempfile(fileext = ".xlsx")
  on.exit(unlink(tf), add = TRUE)
  utils::download.file(url, destfile = tf, quiet = TRUE, mode = "wb")
  res <- readxl::read_xlsx(tf, ...)
  if (inherits(res$yearmonth, "POSIXct")) {
    res$yearmonth <- as.Date(format(res$yearmonth, "%Y-%m-01"))
  } else {
    res$yearmonth <- as.Date(paste0("01/", res$yearmonth), "%d/%m/%Y") # nolint
  }
  res
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
    import_climate = "imklima",
    type
  )
  urls <- read_html("https://www.ifo.de/en/ifo-time-series") |>
    html_elements(".link-list") |>
    html_elements("a") |>
    html_attr("href")
  url <- grep(pattern, urls, value = TRUE, fixed = TRUE)
  url <- paste0("https://www.ifo.de", url)
  url
}
