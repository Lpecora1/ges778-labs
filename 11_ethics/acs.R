# script to download acs tables and aggregate group totals.
# uses ct-data-haven/cwi package

year <- 2024

fetch <- purrr::map(
    c(internet = "B28002", commute = "B08006"),
    cwi::multi_geo_acs,
    towns = NULL,
    state = "24",
    tracts = "all",
    year = year
) |>
    purrr::map(cwi::label_acs, year = year) |>
    purrr::map(
        dplyr::mutate,
        level = forcats::fct_relabel(level, stringr::str_remove, "^\\d_")
    )

out <- list()

# % households with no internet; with no cell data
out[["internet"]] <- fetch[["internet"]] |>
    # cwi::show_uniq(label) |>
    dplyr::group_by(year, level, name) |>
    cwi::add_grps(
        list(total_hh = 1, no_internet = 13, cell_data_only = 6),
        group = label
    ) |>
    cwi::calc_shares(group = label, denom = "total_hh") |>
    dplyr::rename(group = label)

# % workers who commute by means other than driving; work from home
out[["commute"]] <- fetch[["commute"]] |>
    # cwi::show_uniq(label) |>
    dplyr::group_by(year, level, name) |>
    cwi::add_grps(
        list(
            workers_16plus = 1,
            drive_to_work = 2,
            transit_walk_or_bike = c(8, 14, 15),
            work_from_home = 17
        ),
        group = label
    ) |>
    cwi::calc_shares(group = label, denom = "workers_16plus") |>
    dplyr::rename(group = label)

denoms <- c("total_hh", "workers_16plus")

out_df <- out |>
    dplyr::bind_rows() |>
    dplyr::filter(!is.na(share) | group %in% denoms) |>
    dplyr::ungroup() |>
    tidyr::pivot_wider(
        id_cols = c(level, name),
        names_from = group,
        values_from = c(estimate, share),
        names_vary = "slowest"
    ) |>
    janitor::remove_empty("cols") |>
    dplyr::rename_with(
        \(x) stringr::str_remove(x, "^estimate_"),
        .cols = dplyr::any_of(paste("estimate", denoms, sep = "_"))
    ) |>
    # dplyr::rename(total_pop = estimate_total_pop, total_hh = estimate_total_hh, median_hh_income = estimate_median_hh_income) |>
    dplyr::select(-dplyr::matches("estimate_")) |>
    dplyr::rename_with(\(x) stringr::str_remove(x, "share_")) |>
    dplyr::filter(total_hh > 0)

readr::write_csv(out_df, "11_ethics/acs_addl.csv")
