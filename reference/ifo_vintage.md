# Return ifo business climate vintage data

Return ifo business climate vintage data

## Usage

``` r
ifo_vintage(
  type = c("germany", "industry", "manufacturing", "services", "trade", "wholesale",
    "retail", "construction")
)
```

## Source

<https://www.ifo.de/en/ifo-time-series>

## Arguments

- type:

  (`character(1)`)  
  Defaults to `"germany"`. One of:

  - `"germany"`: returns the vintages of the ifo business climate index
    for Germany.

  - `"industry"`, `"manufacturing"`, `"services"`, `"trade"`,
    `"wholesale"`, `"retail"`, `"construction"`: returns the vintages of
    the ifo business climate for the sector.

## Value

A [`data.frame()`](https://rdrr.io/r/base/data.frame.html) containing
the monthly ifo business climate vintages in long format.

## Details

A vintage is the time series as published in a given month. Each vintage
runs from the start of the series to its own release month, so later
vintages contain more months and may revise earlier values, for example
through seasonal adjustment. The output contains one observation per row
in `value`. The other columns describe each observation:

- `yearmonth`: the observed month.

- `vintage`: the first day of the month in which the series was
  published.

- `indicator`: climate, situation, or expectation.

- `series`: index or balance.

`type = "germany"` and `type = "industry"` return an index with 2015 =
100. All other sectors return balances. `type = "industry"` corresponds
to "Industry and Trade" in the source. ifo updates the vintage workbooks
less often than the monthly releases, so the latest vintage can lag the
current
[`ifo_business()`](https://m-muecke.github.io/ifo/reference/ifo_business.md)
release by several months.

## Examples

``` r
# \donttest{
vintage <- ifo_vintage("germany")
head(vintage)
#>    yearmonth    vintage   indicator series value
#> 1 2005-01-01 2018-04-01     climate  index  91.9
#> 2 2005-01-01 2018-04-01 expectation  index  97.2
#> 3 2005-01-01 2018-04-01   situation  index  87.0
#> 4 2005-01-01 2018-05-01     climate  index  92.0
#> 5 2005-01-01 2018-05-01 expectation  index  97.1
#> 6 2005-01-01 2018-05-01   situation  index  87.2
# }
```
