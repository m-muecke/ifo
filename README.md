
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ifo

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/m-muecke/ifo/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/m-muecke/ifo/actions/workflows/R-CMD-check.yaml)
[![CRAN
status](https://www.r-pkg.org/badges/version/ifo)](https://CRAN.R-project.org/package=ifo)
<!-- badges: end -->

## Overview

The goal of ifo is to provide a simple interface to the [ifo
institute](https://www.ifo.de/en/ifo-time-series) time series data. The
package is still in an early stage of development and the API might
change in the future. Feel free to open an issue if you have any
suggestions.

## Installation

You can install the released version of ifo from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("ifo")
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("m-muecke/ifo")
```

## Usage

``` r
library(ifo)

climate <- ifo_business()
climate
#>        yearmonth uncertainty economic_expansion   indicator  series value
#>           <Date>       <num>              <num>      <char>  <char> <num>
#>    1: 2005-01-01          NA           83.10000     climate   index  92.2
#>    2: 2005-02-01          NA           50.40000     climate   index  91.9
#>    3: 2005-03-01          NA            4.90000     climate   index  90.1
#>    4: 2005-04-01          NA           18.70000     climate   index  89.9
#>    5: 2005-05-01          NA           11.70000     climate   index  89.4
#>   ---                                                                    
#> 1436: 2024-08-01        64.8           20.80000 expectation balance -18.1
#> 1437: 2024-09-01        65.7            9.35941 expectation balance -18.7
#> 1438: 2024-10-01        66.2           39.98913 expectation balance -16.7
#> 1439: 2024-11-01        65.9           23.17931 expectation balance -17.5
#> 1440: 2024-12-01        66.6           13.01194 expectation balance -23.0
```

<img src="man/figures/README-plotting-1.png" width="100%" />
