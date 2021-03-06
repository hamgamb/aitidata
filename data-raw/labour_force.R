## code to prepare `labour_force` dataset goes here. It contains data from 4 relevant releases of the 6202.0 series released on the 3rd Thursday of each month.
## Table 12. Labour force status by Sex, State and Territory - Trend, Seasonally adjusted and Original
## Table 19. Monthly hours worked in all jobs by Employed full-time, part-time and Sex and by State and Territory - Trend and Seasonally adjusted
## Table 22. Underutilised persons by Age and Sex - Trend, Seasonally adjusted and Original
## Table 23. Underutilised persons by State and Territory and Sex - Trend, Seasonally adjusted and Original

library(readabs)
library(dplyr)
library(tidyr)
library(lubridate)

abs_test <- read_abs(cat_no = "6202.0", tables = "19a", retain_files = FALSE)

if (max(abs_test$date) <= max(aitidata::labour_force$date)) {
  message("Skipping `labour_force.rda`: appears to be up-to-date")
} else {
  
  message("Updating `labour-force-australia`")
  
  states <- c(
    "New South Wales",
    "Victoria",
    "Queensland",
    "South Australia",
    "Western Australia",
    "Tasmania",
    "Northern Territory",
    "Australian Capital Territory"
  )
  
  
  raw <- readabs::read_abs(cat_no = "6202.0", tables = c("12", "12a", "19", "19a", "22", "23", "23a"), retain_files = FALSE)
  
  labour_force_12 <- raw %>%
    dplyr::filter(table_no == "6202012" |table_no == "6202012a") %>%
    readabs::separate_series(column_names = c("indicator", "gender", "state")) %>%
    dplyr::mutate(
      value = ifelse(unit == "000", (1000 * value), (value)),
      year = lubridate::year(date),
      month = lubridate:: month(date, label = TRUE, abbr = FALSE),
      age = "Total (age)"
    ) %>%
    dplyr::select(date, year, month, indicator, gender, age, state, series_type, value, unit)
  
  
  labour_force_19 <- raw %>%
    filter(table_no == "6202019" | table_no == "6202019a") %>%
    separate(series, into = c("indicator", "gender", "state"), sep = ";") %>%
    mutate(across(c(indicator, gender), ~ trimws(gsub(">", "", .))),
           state = ifelse(gender %in% states, gender, "Australia"),
           gender = ifelse(gender %in% states, "Persons", gender),
           unit = "000",
           value = ifelse(unit == "000", 1000 * value, value),
           year = year(date),
           month = month(date, label = TRUE, abbr = FALSE),
           age = "Total (age)"
    ) %>%
    select(date, year, month, indicator, gender, age, state, series_type, value, unit)
  
  
  labour_force_22 <- raw %>%
    filter(table_no == 6202022) %>%
    separate(series, into = c("indicator", "gender", "age"), sep = ";") %>%
    mutate(across(c(indicator, gender, age), ~ trimws(gsub(">", "", .))),
           age = ifelse(age == "", "Total (age)", age),
           value = ifelse(unit == "000", (1000 * value), value),
           year = year(date),
           month = month(date, label = T, abbr = F),
           state = "Australia"
    ) %>%
    select(date, year, month, indicator, gender, age, state, series_type, value, unit)
  
  
  labour_force_23 <- raw %>%
    filter(table_no == "6202023" | table_no == "6202023a") %>%
    separate(series, into = c("indicator", "gender", "state"), sep = ";") %>%
    mutate(across(c(indicator, gender, state), ~ trimws(gsub(">", "", .))),
           state = ifelse(state == "", "Australia", state),
           value = ifelse(unit == "000", (1000 * value), value),
           year = lubridate::year(date),
           month = lubridate::month(date, label = T, abbr = F),
           age = "Total (age)"
    ) %>%
    select(date, year, month, indicator, gender, age, state, series_type, value, unit)
  
  labour_force <- bind_rows(list(labour_force_12, labour_force_19, labour_force_22, labour_force_23)) %>%
    distinct() %>%
    pivot_wider(names_from = indicator, values_from = value) %>%
    mutate("Underutilised total" = `Unemployed total` + `Underemployed total`) %>%
    pivot_longer(cols = c(9:length(.)), names_to = "indicator", values_to = "value", values_drop_na = TRUE)
  
  
  usethis::use_data(labour_force, overwrite = TRUE, compress = "xz")
}
