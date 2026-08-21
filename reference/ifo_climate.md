# Return ifo climate data

Return ifo climate data

## Usage

``` r
ifo_climate(type = c("import", "export", "world", "euro"))
```

## Source

<https://www.ifo.de/en/ifo-time-series>

## Arguments

- type:

  (`character(1)`)  
  Defaults to `"import"`. One of:

  - `"import"`: returns the ifo import climate.

  - `"export"`: returns the ifo export climate.

  - `"world"`: returns the ifo world economic climate.

  - `"euro"`: returns the ifo world economic climate for the euro zone.

## Value

A [`data.frame()`](https://rdrr.io/r/base/data.frame.html) containing
the ifo climate time series. Monthly for `"import"` and `"export"`,
quarterly for `"world"` and `"euro"`.

## Details

`type = "import"` and `type = "export"` return seasonally adjusted
indices. In the export data, `special_trade` instead gives the annual
percentage change in special-trade exports. `type = "world"` and
`type = "euro"` return balances.

## References

Grimme C, Lehmann R, Nöller M (2018). “Das ifo Importklima – ein erster
Frühindikator für die Prognose der deutschen Importe.” *ifo
Schnelldienst*, **71**(12), 27–32.

Grimme, Christian, Lehmann, Robert, Nöller, Marvin (2021). “Forecasting
imports with information from abroad.” *Economic Modelling*, **98**,
109–117.

## Examples

``` r
# \donttest{
climate <- ifo_climate("import")
head(climate)
#>    yearmonth     climate
#> 1 1995-01-01  0.35603601
#> 2 1995-02-01  0.54317807
#> 3 1995-03-01  0.15852869
#> 4 1995-04-01  0.30643586
#> 5 1995-05-01  0.39497586
#> 6 1995-06-01 -0.01505054
# }
```
