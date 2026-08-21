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

## See also

The [article](https://m-muecke.github.io/ifo/articles/publication.html)
for a reproducible example.

## Examples

``` r
# \donttest{
business <- ifo_business("germany")
head(business)
#>    yearmonth uncertainty economic_expansion indicator series value
#> 1 2005-01-01          NA               83.1   climate  index  92.2
#> 2 2005-02-01          NA               50.4   climate  index  92.0
#> 3 2005-03-01          NA                4.9   climate  index  90.1
#> 4 2005-04-01          NA               18.7   climate  index  89.9
#> 5 2005-05-01          NA               11.7   climate  index  89.4
#> 6 2005-06-01          NA               32.1   climate  index  89.3
# }
```
