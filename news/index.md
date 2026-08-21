# Changelog

## ifo (development version)

- Trailing rows without a date, which the ifo workbooks use for
  footnotes, are no longer returned.
- [`ifo_business()`](https://m-muecke.github.io/ifo/reference/ifo_business.md)
  no longer emits hundreds of coercion warnings for `type = "eastern"`
  and `type = "saxony"`, whose workbooks store their numbers as text.
- `ifo_business("sectors")` now correctly labels the industry columns,
  which previously had the index and balance values swapped.
- `ifo_climate("world")` and `ifo_climate("euro")` now return quarter
  start dates. Their rows are labelled by quarter, but were read as
  months, which placed 30 years of data in January to April of each
  year.
- `ifo_expectation("export")` no longer drops the first observation.

## ifo 0.2.4

CRAN release: 2026-06-29

- Clearer error when the ifo website returns multiple urls for a single
  type.

## ifo 0.2.3

CRAN release: 2026-02-06

- [`ifo_expectation()`](https://m-muecke.github.io/ifo/reference/ifo_expectation.md)
  now returns column `expectation` instead of the misspelled
  `expecation`.

## ifo 0.2.2

CRAN release: 2025-08-31

- Documentation improvements.

## ifo 0.2.1

CRAN release: 2025-06-07

- Adjust to new ifo website urls.

## ifo 0.2.0

CRAN release: 2024-11-28

- Move to curl package for HTTP requests.

## ifo 0.1.0

CRAN release: 2024-06-06

- Initial CRAN submission.
