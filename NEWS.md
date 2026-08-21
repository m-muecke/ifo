# ifo 0.2.5

* Trailing undated rows used for workbook footnotes are no longer returned.
* `ifo_business()` no longer emits coercion warnings for `type = "eastern"` and `type = "saxony"`.
* `ifo_business("sectors")` now labels the industry index and balance columns correctly.
* `ifo_climate("world")` and `ifo_climate("euro")` now return quarter-start dates instead of treating quarter labels as months.
* `ifo_expectation("export")` no longer drops the first observation.

# ifo 0.2.4

* Clearer error when the ifo website returns multiple urls for a single type.

# ifo 0.2.3

* `ifo_expectation()` now returns column `expectation` instead of the
  misspelled `expecation`.

# ifo 0.2.2

* Documentation improvements.

# ifo 0.2.1

* Adjust to new ifo website urls.

# ifo 0.2.0

* Move to curl package for HTTP requests.

# ifo 0.1.0

* Initial CRAN submission.
