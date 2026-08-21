# Return ifo expectation data

Return ifo expectation data

## Usage

``` r
ifo_expectation(type = c("export", "employment"))
```

## Source

<https://www.ifo.de/en/ifo-time-series>

## Arguments

- type:

  (`character(1)`)  
  Defaults to `"export"`. One of:

  - `"export"`: returns the ifo export expectations for manufacturing.

  - `"employment"`: returns the ifo employment barometer for Germany.

## Value

A [`data.frame()`](https://rdrr.io/r/base/data.frame.html) containing
the monthly ifo expectation time series.

## Examples

``` r
# \donttest{
expectation <- ifo_expectation("export")
head(expectation)
#>    yearmonth expectation
#> 1 1991-02-01    -5.94689
#> 2 1991-03-01    -8.09049
#> 3 1991-04-01    -4.92426
#> 4 1991-05-01    -4.78301
#> 5 1991-06-01    -3.19577
#> 6 1991-07-01    -0.43986
# }
```
