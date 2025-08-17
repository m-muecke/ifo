is_flag <- function(x) {
  is.logical(x) && length(x) == 1L && !is.na(x)
}
