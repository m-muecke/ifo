
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ifo

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/m-muecke/ifo/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/m-muecke/ifo/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

## Overview

The goal of ifo is to provide a simple interface to the [ifo
institute](https://www.ifo.de/en/ifo-time-series) time series data. The
package is still in an early stage of development and the API might
change in the future. Feel free to open an issue if you have any
suggestions.

## Installation

You can install the development version of ifo from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("m-muecke/ifo")
```

## Usage

``` r
library(ifo)

climate <- ifo_business()
climate
#> # A tibble: 1,392 × 5
#>   yearmonth  uncertainty indicator   series  value
#>   <date>           <dbl> <chr>       <chr>   <dbl>
#> 1 2005-01-01          NA climate     index    92.2
#> 2 2005-01-01          NA situation   index    87.4
#> 3 2005-01-01          NA expectation index    97.2
#> 4 2005-01-01          NA climate     balance   1.5
#> 5 2005-01-01          NA situation   balance  -0.8
#> # ℹ 1,387 more rows
```

<img src="man/figures/README-plotting-1.png" width="100%" />
