#' Return ifo business climate data
#'
#' @details
#' With `long_format = TRUE`, `type = "germany"` and `type = "sectors"` return one observation per
#' row in `value`. The other columns describe each observation:
#' * `indicator`: climate, situation, or expectation.
#' * `series`: index or balance.
#' * `sector`: the sector, returned only for `type = "sectors"`.
#'
#' For `type = "sectors"`, `sector = "industry"` corresponds to "Industry and Trade" in the source.
#' It is the only sector available as both an index and a balance; all other sectors are balances.
#'
#' For `type = "germany"`, `uncertainty` and `economic_expansion` repeat across the six
#' `indicator` and `series` combinations for each month.
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
#' business <- ifo_business("germany")
#' head(business)
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
        c("index", "balance"),
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
      # these sheets store their numbers as text, which ifo_download() converts
      col_types <- rep("text", 4L)
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
#' @details
#' For `type = "employment"`, `expectation` contains the employment barometer, an index with
#' 2015 = 100. `manufacturing`, `construction`, `trade`, and `service_sector` contain balances.
#'
#' @param type (`character(1)`)\cr
#'   Defaults to `"export"`. One of:
#'   * `"export"`: returns the ifo export expectations for manufacturing.
#'   * `"employment"`: returns the ifo employment barometer for Germany.
#' @returns A `data.frame()` containing the monthly ifo expectation time series.
#' @inherit ifo_business source
#' @export
#' @examplesIf curl::has_internet()
#' \donttest{
#' expectation <- ifo_expectation("export")
#' head(expectation)
#' }
ifo_expectation <- function(type = c("export", "employment")) {
  type <- match.arg(type)
  tab <- switch(
    type,
    export = ifo_download(
      type = "export",
      skip = 9L,
      col_names = c("yearmonth", "expectation"),
      col_types = c("date", "numeric")
    ),
    employment = ifo_download(
      type = "employment",
      skip = 9L,
      col_names = c(
        "yearmonth",
        "expectation",
        "manufacturing",
        "construction",
        "trade",
        "service_sector"
      ),
      col_types = c("date", rep("numeric", 5L))
    )
  )
  has_value <- tab[, rowSums(!is.na(.SD)) > 0L, .SDcols = !"yearmonth"]
  tab <- tab[has_value]
  tab <- setDF(tab)
  tab
}

#' Return ifo climate data
#'
#' @details
#' `type = "import"` and `type = "export"` return seasonally adjusted indices. In the export data,
#' `special_trade` instead gives the annual percentage change in special-trade exports.
#' `type = "world"` and `type = "euro"` return balances. The source provides these two series only
#' through the fourth quarter of 2019.
#'
#' @param type (`character(1)`)\cr
#'   Defaults to `"import"`. One of:
#'   * `"import"`: returns the ifo import climate.
#'   * `"export"`: returns the ifo export climate.
#'   * `"world"`: returns the ifo world economic climate.
#'   * `"euro"`: returns the ifo world economic climate for the euro zone.
#' @returns A `data.frame()` containing the ifo climate time series. Monthly for `"import"` and
#'   `"export"`, quarterly for `"world"` and `"euro"`.
#' @inherit ifo_business source
#' @references
#' `r format_bib("grimme2018ifo", "grimme2021forecasting")`
#' @export
#' @examplesIf curl::has_internet()
#' \donttest{
#' climate <- ifo_climate("import")
#' head(climate)
#' }
ifo_climate <- function(type = c("import", "export", "world", "euro")) {
  type <- match.arg(type)
  tab <- switch(
    type,
    import = ifo_download(
      type = "import_climate",
      skip = 10L,
      col_names = c("yearmonth", "climate"),
      col_types = c("date", "numeric")
    ),
    export = ifo_download(
      type = "export_climate",
      skip = 10L,
      col_names = c("yearmonth", "ifo_climate", "special_trade"),
      col_types = c("date", "numeric", "numeric")
    ),
    ifo_download(
      type = type,
      quarterly = TRUE,
      skip = 11L,
      col_names = c("yearmonth", "economic_climate", "present_situation", "expectation"),
      col_types = c("text", rep("numeric", 3L))
    )
  )
  tab <- setDF(tab)
  tab
}

#' Return ifo business climate vintage data
#'
#' @details
#' A vintage is the time series as published in a given month. Each vintage runs from the start
#' of the series to its own release month, so later vintages contain more months and may revise
#' earlier values, for example through seasonal adjustment. The output contains one observation
#' per row in `value`. The other columns describe each observation:
#' * `yearmonth`: the observed month.
#' * `vintage`: the first day of the month in which the series was published.
#' * `indicator`: climate, situation, or expectation.
#' * `series`: index or balance.
#'
#' `type = "germany"` and `type = "industry"` return an index with 2015 = 100. All other sectors
#' return balances. `type = "industry"` corresponds to "Industry and Trade" in the source.
#' ifo updates the vintage workbooks less often than the monthly releases, so the latest vintage
#' can lag the current [ifo_business()] release by several months.
#'
#' @param type (`character(1)`)\cr
#'   Defaults to `"germany"`. One of:
#'   * `"germany"`: returns the vintages of the ifo business climate index for Germany.
#'   * `"industry"`, `"manufacturing"`, `"services"`, `"trade"`, `"wholesale"`, `"retail"`,
#'     `"construction"`: returns the vintages of the ifo business climate for the sector.
#' @returns A `data.frame()` containing the monthly ifo business climate vintages in long format.
#' @inherit ifo_business source
#' @export
#' @examplesIf curl::has_internet()
#' \donttest{
#' vintage <- ifo_vintage("germany")
#' head(vintage)
#' }
ifo_vintage <- function(
  type = c(
    "germany",
    "industry",
    "manufacturing",
    "services",
    "trade",
    "wholesale",
    "retail",
    "construction"
  )
) {
  type <- match.arg(type)
  path <- ifo_file(paste0("vintage_", type))
  on.exit(unlink(path), add = TRUE)
  sheets <- c(climate = "Climate", situation = "Situation", expectation = "Expectations")
  tab <- rbindlist(
    lapply(sheets, \(sheet) setDT(readxl::read_xlsx(path, sheet = sheet))),
    idcol = "indicator"
  )
  setnames(tab, "Date", "yearmonth")
  tab <- melt(
    tab,
    id.vars = c("indicator", "yearmonth"),
    variable.name = "vintage",
    variable.factor = FALSE,
    na.rm = TRUE
  )
  yearmonth <- vintage <- value <- series <- NULL
  tab[, yearmonth := parse_monthname(yearmonth)]
  tab[, vintage := as.Date(sub("^v(\\d{4})m(\\d{2})$", "\\1-\\2-01", vintage))]
  tab[, value := as.numeric(value)]
  tab[, series := if (type %in% c("germany", "industry")) "index" else "balance"]
  setcolorder(tab, c("yearmonth", "vintage", "indicator", "series", "value"))
  setorderv(tab, c("yearmonth", "vintage", "indicator"))
  tab <- setDF(tab)
  tab
}

ifo_download <- function(type, ..., quarterly = FALSE) {
  path <- ifo_file(type)
  on.exit(unlink(path), add = TRUE)
  tab <- setDT(readxl::read_xlsx(path, ...))
  yearmonth <- NULL
  tab[, yearmonth := parse_yearmonth(yearmonth, quarterly)]
  tab <- tab[!is.na(yearmonth)]
  tab[, names(.SD) := lapply(.SD, as.numeric), .SDcols = is.character]
  tab[]
}

ifo_file <- function(type) {
  path <- tempfile(fileext = ".xlsx")
  curl::curl_download(ifo_url(type), path)
  path
}

parse_yearmonth <- function(x, quarterly = FALSE) {
  if (inherits(x, "POSIXct")) {
    return(as.Date(trunc(x, "months")))
  }
  if (!quarterly) {
    return(as.Date(paste0("01/", x), "%d/%m/%Y")) # nolint
  }
  quarter <- suppressWarnings(as.integer(sub("/.*$", "", x)))
  year <- suppressWarnings(as.integer(sub("^.*/", "", x)))
  as.Date(sprintf("%04d-%02d-01", year, quarter * 3L - 2L), "%Y-%m-%d")
}

parse_monthname <- function(x) {
  month <- match(sub(" .*$", "", x), month.name)
  year <- as.integer(sub("^.* ", "", x))
  as.Date(sprintf("%04d-%02d-01", year, month), "%Y-%m-%d")
}

ifo_url <- function(type) {
  pattern <- switch(
    type,
    germany = "gsk",
    sectors = "gsk",
    eastern = "ostd",
    saxony = "sachsen",
    export = "export",
    employment = "ifo Employment Barometer for Germany",
    export_climate = "exklima",
    import_climate = "imklima",
    vintage_germany = "vintage/Germany-",
    vintage_industry = "vintage/Industry_and_Trade-",
    vintage_manufacturing = "vintage/Manufacturing-",
    vintage_services = "vintage/Services-",
    vintage_trade = "vintage/Trade-",
    vintage_wholesale = "vintage/Wholesale_Trade-",
    vintage_retail = "vintage/Retail_Trade-",
    vintage_construction = "vintage/Construction-",
    type
  )
  links <- read_html("https://www.ifo.de/en/ifo-time-series") |>
    html_elements(".paragraph--linkliste") |>
    html_elements("a")
  urls <- html_attr(links, "href")
  labels <- html_attr(links, "title")

  if (length(urls) == 0L) {
    stop("Found no timeseries urls.", call. = FALSE)
  }
  url <- urls[grepl(pattern, paste(urls, labels), fixed = TRUE)]
  if (length(url) == 0L) {
    stop("No ifo data found for type: ", type, call. = FALSE)
  }
  if (length(url) > 1L) {
    stop("Found multiple ifo data urls for type: ", type, call. = FALSE)
  }
  paste0("https://www.ifo.de", url)
}
