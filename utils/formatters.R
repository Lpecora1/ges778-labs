## BASIC STRING FORMATTERS ----

# All of these can take additional arguments as you see fit.
# Remember that `scales::label_*` functions all return another function.

# percent: format decimal number as percentage,
# with the number of decimal places decided by a heuristic inside label_percent
percent <- scales::label_percent()

# percent100: format decimal number as percentage,
# rounded to the nearest whole number
percent100 <- scales::label_percent(accuracy = 1)

# comma: format a number with a comma to separate thousands
comma <- scales::label_number(big.mark = ",")

# dollar: format a number as currency based on your computer's internal location
dollar <- scales::label_currency()

# big_number: format a number with abbreviations for thousands, millions, billions, etc
# e.g. 12345 --> 12K
big_number <- scales::label_number(scale_cut = scales::cut_short_scale())

# big_dollar: combination of big_number and dollar
big_dollar <- scales::label_currency(scale_cut = scales::cut_short_scale())

## VERSATILE FORMATTER FUNCTIONS ----

# You can wrap any of those inside a function to take arguments on the fly

#' Flexible comma formatting function
#' @param x Numeric vector to be formatted
#' @param accuracy Number to pass to scales::label_number's accuracy argument. If `NULL`, uses internal heuristic. Default: 1
#' @return A string vector the same length as x
#' @examples
#'  comma_flex(c(1234, 12345, 12.4))
#'  # returns "1,234"  "12,345" "12"
#'  comma_flex(c(1000.23, 10.55), accuracy = 0.1)
#'  # returns "1,000.2" "10.6"
#' @seealso [scales::label_number]
comma_flex <- function(x, accuracy = 1) {
    # create a formatter function with the accuracy argument
    fmt <- scales::label_number(accuracy = accuracy, big.mark = ",")
    # apply that formatter to your vector x
    x_formatted <- fmt(x)
    # then return the formatted values
    x_formatted
}
