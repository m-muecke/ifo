
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
#> # A tibble: 1,386 × 6
#>   yearmonth  uncertainty economic_expansion indicator   series  value
#>   <date>           <dbl>              <dbl> <chr>       <chr>   <dbl>
#> 1 2005-01-01          NA               83.1 climate     index    92.2
#> 2 2005-01-01          NA               83.1 situation   index    87.4
#> 3 2005-01-01          NA               83.1 expectation index    97.2
#> 4 2005-01-01          NA               83.1 climate     balance   1.5
#> 5 2005-01-01          NA               83.1 situation   balance  -0.9
#> # ℹ 1,381 more rows
```

``` r
library(dplyr)
library(ggplot2)

climate |>
  filter(series == "index") |>
  ggplot(aes(x = yearmonth, y = value, color = indicator)) +
  geom_line() +
  theme_minimal() +
  theme(
    legend.title = element_blank(),
    legend.position = "top",
    plot.title = element_text(face = "bold"),
    plot.caption = element_text(
      hjust = 0, vjust = 0, size = 8, margin = margin(10, 0, 0, 0)
    ),
    panel.grid.major.y = element_line(color = "black", linewidth = 0.2),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text = element_text(color = "black"),
    plot.margin = margin(10, 10, 10, 10)
  ) +
  labs(
    title = "ifo Business Climate Germany", subtitle = "Seasonally adjusted",
    y = NULL, x = NULL,
    caption = sprintf(
      "Source: ifo Business Survey, %s.", format(max(climate$yearmonth), "%B %Y")
    )
  ) +
  scale_color_manual(
    values = c(climate = "darkred", situation = "darkgrey", expectation = "darkblue"),
    labels = c(
      "ifo Business Climate",
      "Assessment of business situtation",
      "Business expectation"
    )
  )
```

<img src="man/figures/README-plotting-1.png" width="100%" />
