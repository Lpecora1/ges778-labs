#' Convert named colors to hex codes
#'
#' This is a simplified ripoff of the function at
#' https://stackoverflow.com/a/70121688/5325862, already revised in
#' https://github.com/danielvartan/rutils/blob/main/R/col2hex.R
#'
#' @param color A character vector of named R colors
#' @returns A character vector of hex codes, one per item in `color`
#' @examples
#' col2hex(c("gray10", "gray20", "gray95"))
#' # returns "#1A1A1A" "#333333" "#F2F2F2"
col2hex <- function(color) {
    # returns matrix with rows for r, g, b
    rgb <- grDevices::col2rgb(color)
    # transpose into matrix with cols for r, g, b
    rgb_t <- t(rgb)
    # convert to hex codes with max value 255
    hex <- grDevices::rgb(rgb_t, maxColorValue = 255)
    hex
}
