#' Return ifo business climate data
#'
#' @param type (`character(1)`)\cr
#'   Defaults to `"germany"`. One of:
#'   * `"germany"`: returns the ifo business climate index for Germany.
#'   * `"sectors"`: returns the ifo business climate index for different sectors.
#'   * `"eastern"`: returns the ifo business climate index for eastern Germany.
#'   * `"saxony"`: returns the ifo business climate index for Saxony.
#' @param long_format (`logical(1)`)\cr
#'   If `TRUE` return the data in long format. Only applies to `type` `"germany"` and `"sectors"`.
#'   Default `TRUE`.
#' @returns A `data.frame()` containing the monthly ifo business climate time series.
#' @source <https://www.ifo.de/en/ifo-time-series>
#' @seealso The [article](https://m-muecke.github.io/ifo/articles/publication.html) for
#'   a reproducible example.
#' @export
#' @examplesIf curl::has_internet()
#' \donttest{
#' ifo_business("germany")
#' }
ifo_business <- function(
  type = c("germany", "sectors", "eastern", "saxony"),
  long_format = TRUE
) {
  type <- match.arg(type)
  stopifnot(is_flag(long_format))
  sheet <- 1L
  switch(
    type,
    germany = {
      col_names <- c(
        "yearmonth",
        "climate_index",
        "situation_index",
        "expectation_index",
        "climate_balance",
        "situation_balance",
        "expectation_balance",
        "uncertainty",
        "economic_expansion"
      )
      col_types <- c("text", rep("numeric", 8L))
    },
    sectors = {
      sheet <- 2L
      col_types <- c("text", rep("numeric", 24L))
      col_names <- "yearmonth"
      indicator <- c("climate", "situation", "expectation")
      nms <- as.character(outer(
        paste(indicator, "industry", sep = "_"),
        c("balance", "index"),
        paste,
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

  tab <- ifo_download(
    type = type,
    sheet = sheet,
    skip = 8L,
    col_names = col_names,
    col_types = col_types
  )

  if (!long_format) {
    tab <- setDF(tab)
    return(tab)
  }

  series <- sector <- NULL
  if (type == "germany") {
    tab <- melt(
      tab,
      measure.vars = measure(indicator, series, pattern = "(.*)_(index|balance)"),
      na.rm = TRUE
    )
  } else if (type == "sectors") {
    tab <- melt(
      tab,
      measure.vars = measure(indicator, sector, series, pattern = "(.*)_(.*)_(.*)"),
      na.rm = TRUE
    )
  }
  tab <- setDF(tab)
  tab
}

#' Return ifo expectation data
#'
#' @param type (`character(1)`)\cr
#'   Defaults to `"employment"`. One of:
#'   * `"export"`: returns the ifo export expectations for manufacturing.
#'   * `"employment"`: returns the ifo employment barometer for Germany.
#' @returns A `data.frame()` containing the monthly ifo expectation time series.
#' @inherit ifo_business source
#' @export
#' @examplesIf curl::has_internet()
#' \donttest{
#' ifo_expectation("export")
#' }
ifo_expectation <- function(type = c("export", "employment")) {
  type <- match.arg(type)
  if (type == "export") {
    tab <- ifo_download(
      type = "export",
      skip = 10L,
      col_names = c("yearmonth", "expecation"),
      col_types = c("date", "numeric")
    )
  } else {
    tab <- ifo_download(
      type = "employment",
      skip = 9L,
      col_names = c(
        "yearmonth",
        "expecation",
        "manufacturing",
        "construction",
        "trade",
        "service_sector"
      ),
      col_types = c("date", rep("numeric", 5L))
    )
  }
  tab <- setDF(tab)
  tab
}

#' Return ifo climate data
#'
#' @param type (`character(1)`)\cr
#'   Defaults to `"import"`. One of:
#'   * `"import"`: returns the ifo import climate.
#'   * `"export"`: returns the ifo export climate.
#'   * `"world"`: returns the ifo world economic climate.
#'   * `"euro"`: returns the ifo world economic climate for the euro zone.
#' @returns A `data.frame()` containing the monthly ifo climate time series.
#' @references
#' `r format_bib("grimme2018ifo", "grimme2021forecasting")`
#' @export
#' @examplesIf curl::has_internet()
#' \donttest{
#' ifo_climate("import")
#' }
ifo_climate <- function(type = c("import", "export", "world", "euro")) {
  type <- match.arg(type)
  if (type == "import") {
    tab <- ifo_download(
      type = "import_climate",
      skip = 10L,
      col_names = c("yearmonth", "climate"),
      col_types = c("date", "numeric")
    )
  } else if (type == "export") {
    tab <- ifo_download(
      type = "export_climate",
      skip = 10L,
      col_names = c("yearmonth", "ifo_climate", "special_trade"),
      col_types = c("date", "numeric", "numeric")
    )
  } else {
    tab <- ifo_download(
      type = type,
      skip = 11L,
      col_names = c("yearmonth", "economic_climate", "present_situation", "expectation"),
      col_types = c("text", rep("numeric", 3L))
    )
  }
  tab <- setDF(tab)
  tab
}

ifo_download <- function(type, ...) {
  url <- ifo_url(type)
  tf <- tempfile(fileext = ".xlsx")
  on.exit(unlink(tf), add = TRUE)
  curl::curl_download(url, tf)
  tab <- setDT(readxl::read_xlsx(tf, ...))
  yearmonth <- NULL
  if (inherits(tab$yearmonth, "POSIXct")) {
    tab[, yearmonth := as.Date(format(yearmonth, "%Y-%m-01"))]
  } else {
    tab[, yearmonth := as.Date(paste0("01/", yearmonth), "%d/%m/%Y")] # nolint
  }
  tab
}

ifo_url <- function(type) {
  pattern <- switch(
    type,
    germany = "gsk",
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
    html_elements(".paragraph--linkliste") |>
    html_elements("a") |>
    html_attr("href")
  if (length(urls) == 0L) {
    stop("Found no timeseries urls.", call. = FALSE)
  }
  url <- grep(pattern, urls, value = TRUE, fixed = TRUE)
  if (length(url) == 0L) {
    stop("No ifo data found for type: ", type, call. = FALSE)
  }
  paste0("https://www.ifo.de", url)
}
