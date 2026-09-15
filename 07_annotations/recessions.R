# data described at https://www.nber.org/research/data/us-business-cycle-expansions-and-contractions
# array of objects with keys for peak (start of recession) and trough (end)
recessions <- jsonlite::read_json(
    "https://data.nber.org/cycles/business_cycle_dates.json"
) |>
    purrr::map(tibble::as_tibble) |>
    dplyr::bind_rows() |>
    dplyr::mutate(dplyr::across(c(peak, trough), lubridate::ymd)) |>
    dplyr::filter(peak >= as.Date("2000-01-01")) |>
    dplyr::mutate(label = c("Dot-com bubble", "Great Recession", "COVID")) |>
    dplyr::relocate(label)

saveRDS(recessions, "07_annotations/recession_dates.rds")
