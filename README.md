
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ifo

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/m-muecke/ifo/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/m-muecke/ifo/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

## Overview

The goal of ifo is to provide a simple interface to the [ifo
institute](https://www.ifo.de/en/ifo-time-series) business survey data.
The shape of the output data is still experimental and might change in
the future. Feel free to open an issue if you have any suggestions.

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

climate <- ifo_climate()
climate
#> # A tibble: 231 × 9
#>   yearmonth  climate_index situation_index expectation_index climate_balance
#>   <date>             <dbl>           <dbl>             <dbl>           <dbl>
#> 1 2005-01-01          92.2            87.4              97.2             1.5
#> 2 2005-02-01          92              88                96.2             1  
#> 3 2005-03-01          90.1            85.9              94.5            -3.1
#> 4 2005-04-01          90              86.3              93.7            -3.4
#> 5 2005-05-01          89.4            86.1              92.7            -4.7
#> # ℹ 226 more rows
#> # ℹ 4 more variables: situation_balance <dbl>, expectation_balance <dbl>,
#> #   uncertainty <dbl>, economic_expansion <dbl>
```

``` r
library(dplyr)
library(ggplot2)

climate |>
  select(yearmonth, ends_with("index")) |>
  tidyr::pivot_longer(-yearmonth, names_to = "component") |>
  mutate(component = sub("_index", "", component, fixed = TRUE)) |>
  ggplot(aes(x = yearmonth, y = value, color = component)) +
  geom_line() +
  theme_minimal() +
  theme(
    legend.title = element_blank(),
    legend.position = "top",
    plot.caption = element_text(
      hjust = 0, vjust = 0, size = 10, margin = margin(10, 0, 0, 0)
    ),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    panel.grid.minor.y = element_blank()
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
