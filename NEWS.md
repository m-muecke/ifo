# ifo (development version)

* Trailing rows without a date, which the ifo workbooks use for footnotes, are no longer returned.
* `ifo_business()` no longer emits hundreds of coercion warnings for `type = "eastern"` and `type = "saxony"`, whose workbooks store their numbers as text.
* `ifo_business("sectors")` now correctly labels the industry columns, which previously had the index and balance values swapped.
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
