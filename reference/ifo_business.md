# Return ifo business climate data

Return ifo business climate data

## Usage

``` r
ifo_business(
  type = c("germany", "sectors", "eastern", "saxony"),
  long_format = TRUE
)
```

## Source

<https://www.ifo.de/en/ifo-time-series>

## Arguments

- type:

  (`character(1)`)  
  Defaults to `"germany"`. One of:

  - `"germany"`: returns the ifo business climate index for Germany.

  - `"sectors"`: returns the ifo business climate index for different
    sectors.

  - `"eastern"`: returns the ifo business climate index for eastern
    Germany.

  - `"saxony"`: returns the ifo business climate index for Saxony.

- long_format:

  (`logical(1)`)  
  If `TRUE` return the data in long format. Only applies to `type`
  `"germany"` and `"sectors"`. Default `TRUE`.

## Value

A [`data.frame()`](https://rdrr.io/r/base/data.frame.html) containing
the monthly ifo business climate time series.

## Details

With `long_format = TRUE`, `type = "germany"` and `type = "sectors"`
return one observation per row in `value`. The other columns describe
each observation:

- `indicator`: climate, situation, or expectation.

- `series`: index or balance.

- `sector`: the sector, returned only for `type = "sectors"`.

For `type = "sectors"`, `sector = "industry"` corresponds to "Industry
and Trade" in the source. It is the only sector available as both an
index and a balance; all other sectors are balances.

For `type = "germany"`, `uncertainty` and `economic_expansion` repeat
across the six `indicator` and `series` combinations for each month.

## See also

The [article](https://m-muecke.github.io/ifo/articles/publication.html)
for a reproducible example.

## Examples

``` r
# \donttest{
business <- ifo_business("germany")
head(business)
#>    yearmonth uncertainty economic_expansion   indicator  series value
#> 1 2005-01-01          NA               83.1     climate   index  92.2
#> 2 2005-01-01          NA               83.1   situation   index  87.5
#> 3 2005-01-01          NA               83.1 expectation   index  97.2
#> 4 2005-01-01          NA               83.1     climate balance   1.5
#> 5 2005-01-01          NA               83.1   situation balance  -0.7
#> 6 2005-01-01          NA               83.1 expectation balance   3.8
# }
```
